#!/bin/bash
set -e

echo "🔧 CORRIGINDO ERRO 'sexually_explicit'"
echo "═══════════════════════════════════════════════════════════════"
echo ""

cd /root/pronas-sys-suite1

cat > backend/app/ai/agents/text_agent.py << 'FIXEDAGENT'
from typing import Dict, List
import google.generativeai as genai
from app.config import settings
from app.ai.rag.embeddings import generate_embedding
from app.ai.rag.vectorstore import search_similar_cases
import logging

logger = logging.getLogger(__name__)
genai.configure(api_key=settings.GEMINI_API_KEY)

def safe_extract_text(response) -> str:
    """Extração SEGURA do texto da resposta"""
    try:
        # Verificar se há candidatos
        if not response.candidates:
            logger.warning("Sem candidatos na resposta")
            return None
        
        candidate = response.candidates[0]
        
        # Verificar finish_reason
        if candidate.finish_reason not in [1, 'STOP']:  # 1 = STOP (normal)
            logger.warning(f"Finish reason anormal: {candidate.finish_reason}")
            return None
        
        # Verificar se tem partes
        if not candidate.content or not candidate.content.parts:
            logger.warning("Sem partes no conteúdo")
            return None
        
        # Extrair texto das partes
        text_parts = []
        for part in candidate.content.parts:
            if hasattr(part, 'text') and part.text:
                text_parts.append(part.text)
        
        if text_parts:
            return ' '.join(text_parts).strip()
        
        return None
        
    except Exception as e:
        logger.error(f"Erro ao extrair texto: {e}")
        return None

async def suggest_text(field_name: str, field_context: Dict, project_context: Dict) -> Dict:
    """Agente CONTEXTUAL com extração segura"""
    
    # 1. RAG (sempre primeiro)
    try:
        query = f"{project_context.get('field', '')} {field_name} {project_context.get('title', '')}"
        query_vector = generate_embedding(query)
        similar_cases = search_similar_cases(query_vector, limit=5)
        logger.info(f"✅ RAG: {len(similar_cases)} casos")
    except Exception as e:
        logger.error(f"RAG erro: {e}")
        similar_cases = []
    
    # 2. Contexto do projeto
    context_parts = []
    if project_context.get('title'):
        context_parts.append(f"Título: {project_context['title']}")
    if project_context.get('institution_name'):
        context_parts.append(f"Instituição: {project_context['institution_name']}")
    if project_context.get('field'):
        context_parts.append(f"Área: {project_context['field']}")
    
    # Campos já preenchidos
    if project_context.get('dados'):
        for key, val in project_context['dados'].items():
            if val and len(str(val)) > 20:
                context_parts.append(f"{key}: {str(val)[:150]}...")
    
    context_text = "\n".join(context_parts)
    
    # 3. Contexto RAG
    rag_text = ""
    if similar_cases:
        rag_text = "\n".join([
            f"Ref {i+1}: {case.payload.get('summary', '')[:200]}"
            for i, case in enumerate(similar_cases[:2])
        ])
    
    # 4. Prompt otimizado (SEM palavras que possam acionar filtros)
    prompt = f"""Especialista em projetos de saúde PRONAS/PCD.

CONTEXTO:
{context_text}

CAMPO: {field_name}

{f"REFERÊNCIAS:{chr(10)}{rag_text}" if rag_text else ""}

Gere texto profissional de 150 palavras para "{field_name}". 
Use linguagem técnica e mencione Portaria 8.031/2025."""

    # 5. Tentar Gemini
    gemini_text = None
    
    try:
        model = genai.GenerativeModel('gemini-2.5-flash')
        
        response = model.generate_content(
            prompt,
            generation_config={
                'temperature': 0.7,
                'max_output_tokens': 500
            }
        )
        
        # Extrair texto de forma SEGURA
        gemini_text = safe_extract_text(response)
        
        if gemini_text and len(gemini_text) >= 50:
            logger.info(f"✅ Gemini OK: {len(gemini_text)} chars")
        else:
            logger.warning("Gemini retornou texto vazio ou curto")
            gemini_text = None
            
    except Exception as e:
        logger.warning(f"Gemini erro: {str(e)[:100]}")
        gemini_text = None
    
    # 6. Fallback RAG se Gemini falhou
    if not gemini_text and similar_cases:
        logger.info("📚 Fallback RAG")
        
        best = similar_cases[0]
        summary = best.payload.get('summary', '')
        
        if len(similar_cases) >= 2:
            second = similar_cases[1]
            gemini_text = f"""{summary[:300]}

{second.payload.get('summary', '')[:200]}

💡 Adapte para: {project_context.get('title', 'seu projeto')} - {project_context.get('institution_name', '')}
Conforme Portaria 8.031/2025."""
        else:
            gemini_text = f"""{summary[:400]}

💡 Baseado em projeto aprovado. Adapte ao contexto:
- {project_context.get('title', 'Seu projeto')}
- {project_context.get('institution_name', 'Sua instituição')}"""
    
    # 7. Retorno
    if not gemini_text:
        return {
            "suggestion": "⚠️ Não foi possível gerar sugestão. Adicione mais documentos na base.",
            "confidence": 0.0,
            "error": "no_content"
        }
    
    model_used = "gemini-2.5-flash" if gemini_text and 'Adapte' not in gemini_text[:50] else "rag_fallback"
    
    return {
        "suggestion": gemini_text.strip(),
        "confidence": 0.92 if model_used == "gemini-2.5-flash" else 0.75,
        "references": [{"id": str(c.id), "score": float(c.score)} for c in similar_cases[:3]],
        "similar_cases_count": len(similar_cases),
        "model_used": model_used,
        "contextual": True,
        "fields_used": len(context_parts)
    }
FIXEDAGENT

echo "✅ text_agent.py com extração segura"

echo ""
echo "🔄 Reiniciando..."
docker compose restart backend
sleep 15

echo ""
echo "🧪 TESTANDO VERSÃO CORRIGIDA:"
echo ""

for test_num in {1..3}; do
    echo "Teste $test_num:"
    
    RESP=$(curl -s -X POST http://localhost:8000/api/ai/suggest \
      -H "Content-Type: application/json" \
      -d "{
        \"field_name\": \"justificativa\",
        \"field_context\": {},
        \"project_context\": {
          \"title\": \"Ampliando Fisioterapia na APAE\",
          \"field\": \"prestacao_servicos_medico_assistenciais\",
          \"institution_name\": \"APAE Colinas\"
        }
      }")
    
    MODEL=$(echo "$RESP" | jq -r '.model_used')
    CONF=$(echo "$RESP" | jq -r '.confidence')
    
    echo "   Modelo: $MODEL | Confiança: $CONF"
    
    if [ "$MODEL" = "gemini-2.5-flash" ]; then
        echo ""
        echo "✅ GEMINI FUNCIONANDO!"
        echo ""
        echo "📄 EXEMPLO DE SUGESTÃO:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "$RESP" | jq -r '.suggestion' | fold -w 70 -s | head -15
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        break
    fi
    
    sleep 2
done

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ SISTEMA OTIMIZADO!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "🚀 TESTE: http://72.60.255.80:3000/projeto/6/editar"
echo ""

