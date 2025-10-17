from typing import Dict, List
from app.ai.rag.embeddings import generate_embedding
from app.ai.rag.vectorstore import search_similar_cases
import google.generativeai as genai
from app.config import settings
import logging

logger = logging.getLogger(__name__)
genai.configure(api_key=settings.GEMINI_API_KEY)

def safe_gemini_call(prompt: str, timeout: int = 12) -> str:
    """Chamada SEGURA ao Gemini com extração robusta"""
    try:
        model = genai.GenerativeModel('gemini-2.5-flash')
        
        response = model.generate_content(
            prompt,
            generation_config={
                'temperature': 0.8,
                'max_output_tokens': 600
            }
        )
        
        # Extração segura
        if not response.candidates:
            return None
        
        candidate = response.candidates[0]
        
        # Verificar se completou normalmente
        if candidate.finish_reason not in [1, 'STOP']:
            logger.warning(f"Finish reason: {candidate.finish_reason}")
            return None
        
        # Extrair texto
        if not candidate.content or not candidate.content.parts:
            return None
        
        text_parts = []
        for part in candidate.content.parts:
            if hasattr(part, 'text') and part.text:
                text_parts.append(part.text)
        
        if text_parts:
            return ' '.join(text_parts).strip()
        
        return None
        
    except Exception as e:
        logger.warning(f"Gemini falhou: {str(e)[:80]}")
        return None

async def suggest_text(field_name: str, field_context: Dict, project_context: Dict) -> Dict:
    """IA INTELIGENTE: RAG + Reescrita contextualizada"""
    
    # 1. QUERY CONTEXTUAL
    query_parts = [field_name]
    
    if project_context.get('title'):
        query_parts.append(project_context['title'])
    if project_context.get('field'):
        query_parts.append(project_context['field'])
    if project_context.get('priority_area'):
        query_parts.append(project_context['priority_area'])
    
    # Contexto preenchido
    filled_context = []
    if project_context.get('dados'):
        for key, val in project_context['dados'].items():
            if key != field_name and val and len(str(val)) > 30:
                query_parts.append(str(val)[:100])
                filled_context.append(f"{key}: {str(val)[:150]}")
    
    query = " ".join(query_parts)
    logger.info(f"🔍 Query: {query[:120]}...")
    
    # 2. BUSCAR CASOS (RAG)
    try:
        query_vector = generate_embedding(query)
        similar_cases = search_similar_cases(query_vector, limit=8)
        logger.info(f"✅ {len(similar_cases)} casos (scores: {[f'{c.score:.2f}' for c in similar_cases[:3]]})")
    except Exception as e:
        logger.error(f"RAG erro: {e}")
        return {
            "suggestion": "⚠️ Erro ao buscar casos similares.",
            "confidence": 0.0,
            "error": str(e)[:100]
        }
    
    if not similar_cases:
        return {
            "suggestion": "⚠️ Nenhum caso encontrado.",
            "confidence": 0.0
        }
    
    # 3. EXTRAIR CONTEÚDO DOS CASOS
    references_text = []
    for i, case in enumerate(similar_cases[:3], 1):
        text = case.payload.get('text', '')
        title = case.payload.get('title', 'Projeto')
        
        if text and len(text) > 80:
            references_text.append(f"EXEMPLO {i}:\n{text[:400]}")
    
    references_combined = "\n\n".join(references_text)
    
    # 4. TENTAR REESCREVER COM GEMINI
    title = project_context.get('title', 'Projeto não nomeado')
    institution = project_context.get('institution_name', 'Instituição não informada')
    
    prompt = f"""Você é especialista em elaboração de projetos PRONAS/PCD (Portaria 8.031/2025).

**CONTEXTO DO PROJETO:**
Título: {title}
Instituição: {institution}
Área: {project_context.get('field', '')}

{"**CAMPOS JÁ PREENCHIDOS:**" if filled_context else ""}
{chr(10).join(filled_context) if filled_context else ""}

**REFERÊNCIAS DE PROJETOS APROVADOS:**
{references_combined}

**TAREFA:**
Gere um texto profissional de 200-250 palavras para o campo "{field_name}" ESPECIFICAMENTE para o projeto "{title}".

**REQUISITOS:**
1. Adapte os exemplos acima para o contexto de "{title}"
2. Use linguagem técnica da área de saúde
3. Mencione especificidades da {institution}
4. Cite conformidade com Portaria 8.031/2025
5. Inclua indicadores mensuráveis quando aplicável
6. Seja coerente com campos já preenchidos

Gere APENAS o texto para o campo, sem introdução."""

    logger.info("🤖 Tentando reescrever com Gemini...")
    gemini_text = safe_gemini_call(prompt)
    
    # 5. RESULTADO
    if gemini_text and len(gemini_text) >= 100:
        # SUCESSO: Gemini reescreveu contextualizadamente!
        logger.info(f"✅ Gemini reescreveu: {len(gemini_text)} chars")
        
        suggestion = gemini_text
        
        # Adicionar referências
        suggestion += f"\n\n---\n📚 **Baseado em {len(references_text)} projetos aprovados similares**"
        
        return {
            "suggestion": suggestion,
            "confidence": 0.92,
            "references": [
                {
                    "id": str(c.id),
                    "score": float(c.score),
                    "title": c.payload.get('title', '')[:60]
                }
                for c in similar_cases[:5]
            ],
            "similar_cases_count": len(similar_cases),
            "model_used": "gemini_rewriter",
            "rewritten": True
        }
    
    else:
        # FALLBACK: Mostrar exemplos + orientações
        logger.info("📚 Fallback: exemplos + orientações")
        
        best = similar_cases[0]
        best_text = best.payload.get('text', '')
        
        suggestion = f"""**📋 Referências de projetos aprovados similares:**

{references_combined}

---

💡 **COMO ADAPTAR PARA: "{title}"**

**Seu contexto:**
• Instituição: {institution}
• Campo: {field_name}

**Diretrizes de adaptação:**
1. Use a estrutura dos exemplos acima
2. Substitua informações genéricas por dados da {institution}
3. Para "{title}", enfatize aspectos específicos:
   - Se ampliação: mencione demanda atual e projeção
   - Se qualificação: detalhe capacitação da equipe
   - Se fisioterapia: destaque especialidades e público-alvo
4. Cite Portaria 8.031/2025
5. Inclua metas mensuráveis (%, números, prazos)"""
        
        if filled_context:
            suggestion += f"\n\n**📌 Mantenha coerência com:**\n" + "\n".join([f"• {f}" for f in filled_context[:3]])
        
        return {
            "suggestion": suggestion,
            "confidence": 0.75,
            "references": [{"id": str(c.id), "score": float(c.score)} for c in similar_cases[:3]],
            "similar_cases_count": len(similar_cases),
            "model_used": "rag_with_guidance",
            "rewritten": False
        }
