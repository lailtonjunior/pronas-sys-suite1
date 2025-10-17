#!/bin/bash
set -e

echo "🤖 CONFIGURANDO AGENTE HÍBRIDO DEFINITIVO"
echo "═══════════════════════════════════════════════════════════════"
echo ""

cd /root/pronas-sys-suite1

cat > backend/app/ai/agents/text_agent.py << 'HYBRIDAGENT'
from typing import Dict, List
import google.generativeai as genai
from app.config import settings
from app.ai.rag.embeddings import generate_embedding
from app.ai.rag.vectorstore import search_similar_cases
import logging

logger = logging.getLogger(__name__)
genai.configure(api_key=settings.GEMINI_API_KEY)

def get_gemini_text(response):
    """Extrai texto da resposta do Gemini"""
    try:
        return response.text
    except:
        try:
            parts = []
            for candidate in response.candidates:
                for part in candidate.content.parts:
                    if hasattr(part, 'text'):
                        parts.append(part.text)
            text = ' '.join(parts).strip()
            if text:
                return text
        except:
            pass
    return None

async def suggest_text(field_name: str, field_context: Dict, project_context: Dict) -> Dict:
    """Agente HÍBRIDO: RAG + Gemini com fallback inteligente"""
    
    # 1. SEMPRE buscar casos similares (RAG)
    try:
        query = f"{project_context.get('field', '')} {field_name} {project_context.get('title', '')}"
        query_vector = generate_embedding(query)
        similar_cases = search_similar_cases(query_vector, limit=5)
        logger.info(f"RAG encontrou {len(similar_cases)} casos similares")
    except Exception as e:
        logger.error(f"Erro no RAG: {e}")
        similar_cases = []
    
    # 2. Preparar contexto RAG
    rag_text = ""
    if similar_cases:
        rag_text = "\n\n".join([
            f"Exemplo {i+1} (Score {case.score:.2f}):\n{case.payload.get('summary', '')[:300]}"
            for i, case in enumerate(similar_cases[:2])
        ])
    
    # 3. TENTAR Gemini primeiro (com timeout curto)
    gemini_success = False
    suggestion_text = ""
    
    try:
        prompt = f"""Você é especialista em projetos PRONAS/PCD (Portaria 8.031/2025).

CAMPO: {field_name}
PROJETO: {project_context.get('title', 'Não informado')}
INSTITUIÇÃO: {project_context.get('institution_name', 'Não informada')}

{f"REFERÊNCIAS:{chr(10)}{rag_text}" if rag_text else ""}

Gere texto profissional de 150 palavras para "{field_name}". Use linguagem técnica."""

        model = genai.GenerativeModel('gemini-2.5-flash')
        
        # Chamar síncrono (mais confiável que async)
        response = model.generate_content(
            prompt,
            generation_config={
                'temperature': 0.7,
                'max_output_tokens': 400
            },
            request_options={'timeout': 15}
        )
        
        suggestion_text = get_gemini_text(response)
        
        if suggestion_text and len(suggestion_text) >= 50:
            gemini_success = True
            logger.info(f"✅ Gemini gerou {len(suggestion_text)} caracteres")
        else:
            logger.warning("Gemini retornou texto vazio ou muito curto")
            
    except Exception as e:
        logger.warning(f"Gemini falhou: {str(e)[:100]}")
    
    # 4. Se Gemini falhou, usar RAG puro
    if not gemini_success and similar_cases:
        logger.info("Usando fallback RAG")
        
        # Combinar os melhores casos
        if len(similar_cases) >= 2:
            texts = [c.payload.get('summary', '')[:250] for c in similar_cases[:2]]
            suggestion_text = f"""Com base em projetos aprovados similares:

{chr(10).join(texts)}

💡 Adapte este conteúdo para "{project_context.get('title', 'seu projeto')}" conforme Portaria 8.031/2025."""
        else:
            best = similar_cases[0]
            suggestion_text = f"""{best.payload.get('summary', '')[:400]}

💡 Modelo baseado em projeto aprovado. Adapte ao seu contexto específico."""
    
    # 5. Se tudo falhou
    if not suggestion_text or len(suggestion_text) < 20:
        return {
            "suggestion": "⚠️ Não foi possível gerar sugestão. Verifique a conexão ou adicione mais documentos na base de conhecimento.",
            "confidence": 0.0,
            "error": "no_content"
        }
    
    # 6. Retornar resultado
    return {
        "suggestion": suggestion_text.strip(),
        "confidence": 0.90 if gemini_success else 0.70 if similar_cases else 0.50,
        "references": [
            {"id": str(c.id), "score": float(c.score)} 
            for c in similar_cases[:3]
        ],
        "similar_cases_count": len(similar_cases),
        "model_used": "gemini-2.5-flash" if gemini_success else "rag_fallback",
        "rag_available": len(similar_cases) > 0
    }
HYBRIDAGENT

echo "✅ Agente híbrido configurado"

echo ""
echo "🔄 Reiniciando..."
docker compose restart backend
sleep 15

echo ""
echo "🧪 TESTE FINAL:"

for i in {1..2}; do
    echo ""
    echo "Teste $i:"
    
    RESP=$(curl -s -X POST http://localhost:8000/api/ai/suggest \
      -H "Content-Type: application/json" \
      -d '{
        "field_name": "objetivos",
        "field_context": {},
        "project_context": {
          "title": "FISIOTERAPIA APAE COLINAS",
          "field": "prestacao_servicos_medico_assistenciais",
          "institution_name": "APAE Colinas"
        }
      }')
    
    echo "Modelo: $(echo "$RESP" | jq -r '.model_used')"
    echo "Confiança: $(echo "$RESP" | jq -r '.confidence')"
    echo ""
    echo "$RESP" | jq -r '.suggestion' | head -c 300
    echo ""
    
    if [ "$(echo "$RESP" | jq -r '.model_used')" = "gemini-2.5-flash" ]; then
        echo "✅ GEMINI FUNCIONANDO!"
        break
    else
        echo "⚠️  Usando fallback RAG"
    fi
    
    sleep 3
done

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ SISTEMA PRONTO!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "🎯 O sistema agora:"
echo "   • Tenta Gemini primeiro (melhor qualidade)"
echo "   • Fallback automático para RAG se Gemini falhar"
echo "   • SEMPRE retorna algo útil"
echo ""
echo "🚀 TESTE: http://72.60.255.80:3000/projeto/6/editar"
echo ""

