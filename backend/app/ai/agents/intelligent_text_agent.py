import os
from typing import Dict, List, Optional
import asyncio
from enum import Enum
from datetime import datetime
import logging

try:
    from openai import AsyncOpenAI
    OPENAI_AVAILABLE = True
except ImportError:
    OPENAI_AVAILABLE = False

try:
    import google.generativeai as genai
    GEMINI_AVAILABLE = True
except ImportError:
    GEMINI_AVAILABLE = False

from tenacity import (
    retry,
    stop_after_attempt,
    wait_exponential,
    retry_if_exception_type
)

logger = logging.getLogger(__name__)

class LLMProvider(Enum):
    OPENAI = "openai"
    GEMINI = "gemini"
    RAG_ONLY = "rag_only"

class IntelligentTextAgent:
    """
    Agente inteligente multi-LLM com fallback automático
    Prioridade: GPT-4o-mini → Gemini 2.5 Flash → RAG puro
    """
    
    def __init__(self):
        self.openai_key = os.getenv("OPENAI_API_KEY")
        self.gemini_key = os.getenv("GEMINI_API_KEY")
        
        # Inicializar clientes
        if OPENAI_AVAILABLE and self.openai_key:
            self.openai_client = AsyncOpenAI(api_key=self.openai_key)
            logger.info("✅ OpenAI client inicializado (GPT-4o-mini)")
        else:
            self.openai_client = None
            logger.warning("⚠️  OpenAI não disponível")
        
        if GEMINI_AVAILABLE and self.gemini_key:
            genai.configure(api_key=self.gemini_key)
            self.gemini_model = genai.GenerativeModel('gemini-2.0-flash-exp')
            logger.info("✅ Gemini client inicializado")
        else:
            self.gemini_model = None
            logger.warning("⚠️  Gemini não disponível")
        
        # Circuit breaker para health tracking
        self.provider_health = {
            LLMProvider.OPENAI: {"failures": 0, "last_success": None},
            LLMProvider.GEMINI: {"failures": 0, "last_success": None}
        }
        self.max_failures = 3
    
    async def generate_contextual_text(
        self,
        field_name: str,
        project_context: Dict,
        similar_cases: List[Dict],
        max_length: int = 1000
    ) -> Dict:
        """
        Gera texto contextualizado usando multi-LLM com fallback
        
        Args:
            field_name: Nome do campo a ser preenchido (ex: "justificativa")
            project_context: Contexto do projeto atual (título, instituição, etc)
            similar_cases: Lista de casos similares do RAG
            max_length: Tamanho máximo do texto gerado
            
        Returns:
            Dict com texto gerado, provider usado, confiança e referências
        """
        start_time = datetime.now()
        
        # Construir prompt contextual rico
        prompt = self._build_contextual_prompt(
            field_name=field_name,
            project_context=project_context,
            similar_cases=similar_cases,
            max_length=max_length
        )
        
        # Tentar GPT-4o-mini primeiro (prioridade)
        if self._is_provider_healthy(LLMProvider.OPENAI) and self.openai_client:
            try:
                logger.info(f"🚀 Tentando GPT-4o-mini para campo '{field_name}'")
                result = await self._generate_with_openai(prompt, max_length)
                self._mark_success(LLMProvider.OPENAI)
                
                latency = (datetime.now() - start_time).total_seconds()
                logger.info(f"✅ GPT-4o-mini: sucesso em {latency:.2f}s")
                
                return {
                    "text": result,
                    "provider": "gpt-4o-mini",
                    "confidence": 0.95,
                    "references": [case.get("id", f"case_{i}") for i, case in enumerate(similar_cases[:3])],
                    "latency_ms": int(latency * 1000)
                }
            except Exception as e:
                self._mark_failure(LLMProvider.OPENAI)
                logger.error(f"❌ OpenAI falhou: {str(e)}")
        
        # Fallback para Gemini
        if self._is_provider_healthy(LLMProvider.GEMINI) and self.gemini_model:
            try:
                logger.info(f"🔄 Fallback para Gemini para campo '{field_name}'")
                result = await self._generate_with_gemini(prompt, max_length)
                self._mark_success(LLMProvider.GEMINI)
                
                latency = (datetime.now() - start_time).total_seconds()
                logger.info(f"✅ Gemini: sucesso em {latency:.2f}s")
                
                return {
                    "text": result,
                    "provider": "gemini-2.5-flash",
                    "confidence": 0.85,
                    "references": [case.get("id", f"case_{i}") for i, case in enumerate(similar_cases[:3])],
                    "latency_ms": int(latency * 1000)
                }
            except Exception as e:
                self._mark_failure(LLMProvider.GEMINI)
                logger.error(f"❌ Gemini falhou: {str(e)}")
        
        # Fallback final: RAG puro (sempre funciona)
        logger.warning(f"⚠️  Usando RAG puro para campo '{field_name}'")
        return self._generate_rag_only(field_name, similar_cases)
    
    def _build_contextual_prompt(
        self,
        field_name: str,
        project_context: Dict,
        similar_cases: List[Dict],
        max_length: int
    ) -> str:
        """Constrói prompt rico com contexto completo"""
        
        titulo = project_context.get("titulo", "")
        instituicao = project_context.get("instituicao", "")
        tipo_projeto = project_context.get("tipo", "")
        
        # Extrair exemplos de projetos aprovados
        exemplos = []
        for i, case in enumerate(similar_cases[:3], 1):
            score = case.get('score', 0)
            exemplo_texto = case.get('metadata', {}).get(field_name, '')
            
            if exemplo_texto and len(exemplo_texto) > 50:
                exemplos.append(
                    f"📄 Exemplo {i} (Projeto aprovado - Relevância: {score:.1%}):\n{exemplo_texto[:800]}"
                )
        
        exemplos_formatados = "\n\n".join(exemplos) if exemplos else "Nenhum exemplo específico disponível."
        
        # Prompt otimizado para documentos governamentais
        prompt = f"""Você é um especialista em elaboração de projetos PRONAS/PCD (Programa Nacional de Apoio à Atenção da Saúde da Pessoa com Deficiência) do Ministério da Saúde do Brasil.

📋 TAREFA: Escrever o campo "{field_name}" para o seguinte projeto:

📍 CONTEXTO DO PROJETO:
- Título: {titulo}
- Instituição: {instituicao}
- Tipo: {tipo_projeto}

📚 DIRETRIZES OBRIGATÓRIAS:
1. Linguagem formal, técnica e adequada para documentos oficiais do Ministério da Saúde
2. Terminologia apropriada da área de saúde e reabilitação de PcD
3. Baseie-se nos exemplos aprovados, mas ADAPTE especificamente para "{titulo}"
4. Mantenha coerência total com o contexto fornecido
5. Seja objetivo, claro e específico
6. Máximo de {max_length} caracteres
7. IMPORTANTE: Não copie literalmente - REESCREVA adaptando ao contexto atual

📖 EXEMPLOS DE PROJETOS APROVADOS SIMILARES:
{exemplos_formatados}

✍️ ESCREVA APENAS o conteúdo do campo "{field_name}", sem introduções, títulos ou explicações adicionais. O texto deve estar pronto para inserção direta no formulário oficial."""

        return prompt
    
    @retry(
        stop=stop_after_attempt(3),
        wait=wait_exponential(multiplier=1, min=2, max=10),
        retry=retry_if_exception_type((TimeoutError, ConnectionError))
    )
    async def _generate_with_openai(self, prompt: str, max_length: int) -> str:
        """Gera texto usando GPT-4o-mini com retry logic"""
        
        response = await self.openai_client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {
                    "role": "system",
                    "content": "Você é um especialista em elaboração de projetos governamentais de saúde do Brasil, com foco em projetos PRONAS/PCD."
                },
                {
                    "role": "user",
                    "content": prompt
                }
            ],
            max_tokens=min(int(max_length / 2), 2000),
            temperature=0.7,
            top_p=0.9,
            timeout=30.0
        )
        
        return response.choices[0].message.content.strip()
    
    async def _generate_with_gemini(self, prompt: str, max_length: int) -> str:
        """Gera texto usando Gemini 2.5 Flash"""
        
        generation_config = {
            "temperature": 0.7,
            "top_p": 0.9,
            "max_output_tokens": min(int(max_length / 2), 2000),
        }
        
        # Safety settings permissivos para documentos governamentais
        safety_settings = [
            {"category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_NONE"},
            {"category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_NONE"},
            {"category": "HARM_CATEGORY_SEXUALLY_EXPLICIT", "threshold": "BLOCK_NONE"},
            {"category": "HARM_CATEGORY_DANGEROUS_CONTENT", "threshold": "BLOCK_NONE"},
        ]
        
        response = await asyncio.to_thread(
            self.gemini_model.generate_content,
            prompt,
            generation_config=generation_config,
            safety_settings=safety_settings
        )
        
        return response.text.strip()
    
    def _generate_rag_only(self, field_name: str, similar_cases: List[Dict]) -> Dict:
        """Fallback final: retorna exemplos formatados (sistema atual)"""
        
        exemplos = []
        for i, case in enumerate(similar_cases[:3], 1):
            metadata = case.get('metadata', {})
            texto = metadata.get(field_name, '')
            
            if texto and len(texto) > 50:
                score = case.get('score', 0)
                exemplos.append(f"📄 Exemplo {i} (Relevância: {score:.1%}):\n{texto[:500]}...")
        
        texto_final = "\n\n".join(exemplos) if exemplos else "⚠️  Nenhum exemplo relevante encontrado na base de conhecimento."
        
        return {
            "text": f"📚 EXEMPLOS DE PROJETOS APROVADOS:\n\n{texto_final}\n\n💡 NOTA: Adapte estes exemplos ao contexto específico do seu projeto.",
            "provider": "rag-only",
            "confidence": 0.75,
            "references": [case.get("id", f"case_{i}") for i, case in enumerate(similar_cases[:3])],
            "note": "Sistema retornou exemplos. Reescreva adaptando ao seu contexto."
        }
    
    def _is_provider_healthy(self, provider: LLMProvider) -> bool:
        """Verifica health do provider (circuit breaker)"""
        return self.provider_health[provider]["failures"] < self.max_failures
    
    def _mark_success(self, provider: LLMProvider):
        """Marca sucesso e reseta contador"""
        self.provider_health[provider]["failures"] = 0
        self.provider_health[provider]["last_success"] = datetime.now()
    
    def _mark_failure(self, provider: LLMProvider):
        """Incrementa contador de falhas"""
        self.provider_health[provider]["failures"] += 1
        logger.warning(
            f"⚠️  {provider.value}: {self.provider_health[provider]['failures']}/{self.max_failures} falhas"
        )

    def get_health_status(self) -> Dict:
        """Retorna status de saúde de todos os providers"""
        return {
            "openai": {
                "available": self.openai_client is not None,
                "failures": self.provider_health[LLMProvider.OPENAI]["failures"],
                "last_success": self.provider_health[LLMProvider.OPENAI]["last_success"],
                "healthy": self._is_provider_healthy(LLMProvider.OPENAI)
            },
            "gemini": {
                "available": self.gemini_model is not None,
                "failures": self.provider_health[LLMProvider.GEMINI]["failures"],
                "last_success": self.provider_health[LLMProvider.GEMINI]["last_success"],
                "healthy": self._is_provider_healthy(LLMProvider.GEMINI)
            }
        }
