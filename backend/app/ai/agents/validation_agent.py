"""
Agente de Validação Inteligente
Analisa anexos e retorna score de qualidade + alertas
"""
import google.generativeai as genai
from typing import Dict, List
from app.config import settings
import json
import logging

logger = logging.getLogger(__name__)

genai.configure(api_key=settings.GEMINI_API_KEY)


class ValidationAgent:
    """Agente especializado em validação de anexos PRONAS/PCD"""
    
    def __init__(self):
        self.model = genai.GenerativeModel('gemini-1.5-flash')
    
    async def validate_anexo(self, anexo_data: Dict, anexo_type: str) -> Dict:
        """
        Valida um anexo completo e retorna análise detalhada
        
        Returns:
            {
                "score": 0-100,
                "status": "excellent" | "good" | "needs_improvement" | "critical",
                "missing_fields": [],
                "warnings": [],
                "suggestions": [],
                "strengths": []
            }
        """
        
        if not settings.GEMINI_API_KEY:
            return self._fallback_validation(anexo_data)
        
        try:
            # Contar campos preenchidos
            total_fields = len(anexo_data)
            filled_fields = sum(1 for v in anexo_data.values() if v and str(v).strip())
            completion_rate = (filled_fields / total_fields * 100) if total_fields > 0 else 0
            
            # Prompt especializado
            prompt = self._build_validation_prompt(anexo_data, anexo_type, completion_rate)
            
            # Chamar Gemini
            response = self.model.generate_content(prompt)
            
            # Processar resposta
            return self._parse_validation_response(response.text, completion_rate)
            
        except Exception as e:
            logger.error(f"Erro na validação: {e}")
            return self._fallback_validation(anexo_data)
    
    def _build_validation_prompt(self, data: Dict, tipo: str, completion: float) -> str:
        """Constrói prompt de validação"""
        
        prompt = f"""Você é um especialista em avaliação de projetos PRONAS/PCD conforme Portaria GM/MS 8.031/2025.

Analise o seguinte {tipo}:

Taxa de conclusão: {completion:.1f}%
Campos preenchidos: {sum(1 for v in data.values() if v)}
Total de campos: {len(data)}

DADOS DO ANEXO:
{json.dumps(data, indent=2, ensure_ascii=False)[:2000]}

Avalie com base nos critérios da Portaria:
1. Completude das informações
2. Clareza e objetividade
3. Conformidade legal
4. Viabilidade técnica
5. Detalhamento adequado

Forneça uma análise estruturada com:
- Score de qualidade (0-100)
- Status (excellent/good/needs_improvement/critical)
- Campos faltantes ou incompletos
- Alertas e avisos importantes
- Sugestões de melhoria
- Pontos fortes identificados

Responda em formato JSON:
{{
  "score": 0-100,
  "status": "excellent|good|needs_improvement|critical",
  "missing_fields": ["campo1", "campo2"],
  "warnings": ["alerta1", "alerta2"],
  "suggestions": ["sugestão1", "sugestão2"],
  "strengths": ["ponto forte 1", "ponto forte 2"]
}}
"""
        return prompt
    
    def _parse_validation_response(self, response_text: str, completion: float) -> Dict:
        """Processa resposta do Gemini"""
        
        try:
            # Tentar extrair JSON
            import re
            json_match = re.search(r'\{[^}]+\}', response_text, re.DOTALL)
            
            if json_match:
                result = json.loads(json_match.group())
                
                # Ajustar score baseado na conclusão
                base_score = result.get('score', 50)
                adjusted_score = int((base_score * 0.7) + (completion * 0.3))
                result['score'] = max(0, min(100, adjusted_score))
                
                return result
        except:
            pass
        
        # Fallback: criar validação baseada em completion
        if completion >= 80:
            status = "good"
            score = int(completion * 0.9)
        elif completion >= 50:
            status = "needs_improvement"
            score = int(completion * 0.7)
        else:
            status = "critical"
            score = int(completion * 0.5)
        
        return {
            "score": score,
            "status": status,
            "missing_fields": [],
            "warnings": ["Complete mais campos para melhorar a avaliação"],
            "suggestions": ["Preencha todos os campos obrigatórios", "Revise as informações inseridas"],
            "strengths": [] if completion < 30 else ["Progresso inicial bom"]
        }
    
    def _fallback_validation(self, data: Dict) -> Dict:
        """Validação simples quando IA não disponível"""
        
        filled = sum(1 for v in data.values() if v)
        total = len(data)
        score = int((filled / total * 100)) if total > 0 else 0
        
        if score >= 80:
            status = "good"
            message = "Anexo bem preenchido"
        elif score >= 50:
            status = "needs_improvement"
            message = "Preencha mais campos"
        else:
            status = "critical"
            message = "Anexo incompleto"
        
        return {
            "score": score,
            "status": status,
            "missing_fields": [],
            "warnings": [message],
            "suggestions": ["Configure GEMINI_API_KEY para validação avançada"],
            "strengths": []
        }


# Instância global
validation_agent = ValidationAgent()
