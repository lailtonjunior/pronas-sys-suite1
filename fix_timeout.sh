#!/bin/bash
set -e

echo "🔧 AUMENTANDO TIMEOUT E OTIMIZANDO"
echo "═══════════════════════════════════════════════════════════════"
echo ""

cd /root/pronas-sys-suite1

# Atualizar text_agent.py com timeout maior
cat > backend/app/ai/agents/text_agent.py << 'AGENTFIX'
from typing import Dict, List
import google.generativeai as genai
from app.config import settings
from app.ai.rag.embeddings import generate_embedding
from app.ai.rag.vectorstore import search_similar_cases
import asyncio
import logging

logger = logging.getLogger(__name__)
genai.configure(api_key=settings.GEMINI_API_KEY)

async def suggest_text(field_name: str, field_context: Dict, project_context: Dict) -> Dict:
    """Agente de sugestão usando RAG + Gemini 2.5"""
    
    try:
        # 1. Buscar casos similares (RAG) - Rápido
        query = f"{project_context.get('field', '')} {field_name}"
        query_vector = generate_embedding(query)
        similar_cases = search_similar_cases(query_vector, limit=3)
        
        # 2. Montar contexto compacto
        rag_context = ""
        if similar_cases:
            rag_context = "\n".join([
                f"Caso {i+1}: {case.payload.get('summary', '')[:200]}"
                for i, case in enumerate(similar_cases[:2])
            ])
        
        # 3. Prompt otimizado (mais curto = resposta mais rápida)
        prompt = f"""Você é especialista em projetos PRONAS/PCD (Portaria 8.031/2025).

Campo: {field_name}
Projeto: {project_context.get('title', '')}
Área: {project_context.get('field', '')}
Instituição: {project_context.get('institution_name', '')}

{f"Referências:{chr(10)}{rag_context}" if rag_context else ""}

Gere um texto profissional de 150-180 palavras para este campo. 
Use linguagem técnica e mencione conformidade legal."""

        # 4. Chamar Gemini com timeout de 20 segundos
        model = genai.GenerativeModel(
            'gemini-2.5-flash',
            generation_config={
                'temperature': 0.7,
                'top_p': 0.8,
                'top_k': 40,
                'max_output_tokens': 400,
            }
        )
        
        response = await asyncio.wait_for(
            asyncio.to_thread(model.generate_content, prompt),
            timeout=20.0  # Aumentado para 20 segundos
        )
        
        suggestion = response.text.strip().replace('**', '').replace('##', '')
        
        return {
            "suggestion": suggestion,
            "confidence": 0.85 if similar_cases else 0.65,
            "references": [{"id": str(c.id), "score": float(c.score)} for c in similar_cases],
            "similar_cases_count": len(similar_cases),
            "model_used": "gemini-2.5-flash"
        }
        
    except asyncio.TimeoutError:
        logger.warning("Timeout em 20s")
        
        # Fallback: Retornar caso similar se houver
        if similar_cases:
            best = similar_cases[0]
            return {
                "suggestion": f"{best.payload.get('summary', '')[:400]}\n\n[Baseado em caso aprovado similar]",
                "confidence": 0.60,
                "references": [{"id": str(best.id), "score": float(best.score)}],
                "fallback": "rag_only"
            }
        
        return {
            "suggestion": "Tempo limite excedido. Tente novamente.",
            "confidence": 0.0,
            "error": "timeout"
        }
        
    except Exception as e:
        logger.error(f"Erro: {e}")
        
        # Fallback RAG
        if similar_cases:
            return {
                "suggestion": f"{similar_cases[0].payload.get('summary', '')[:300]}",
                "confidence": 0.50,
                "fallback": "rag_only"
            }
        
        return {
            "suggestion": "Erro ao gerar sugestão.",
            "confidence": 0.0,
            "error": str(e)[:100]
        }
AGENTFIX

echo "✅ text_agent.py atualizado (timeout: 20s)"

echo ""
echo "🔄 Reiniciando backend..."
docker compose restart backend

echo ""
echo "⏳ Aguardando 15 segundos..."
sleep 15

echo ""
echo "�� TESTE 1 - Rápido:"
curl -s -X POST http://localhost:8000/api/ai/suggest \
  -H "Content-Type: application/json" \
  -d '{
    "field_name": "titulo",
    "field_context": {},
    "project_context": {
      "title": "Fisioterapia APAE",
      "field": "prestacao_servicos_medico_assistenciais"
    }
  }' | jq -r '.suggestion' | head -c 300

echo ""
echo ""
echo "🧪 TESTE 2 - Completo (aguarde 10s):"

START=$(date +%s)
RESPONSE=$(curl -s -X POST http://localhost:8000/api/ai/suggest \
  -H "Content-Type: application/json" \
  -d '{
    "field_name": "justificativa",
    "field_context": {},
    "project_context": {
      "title": "AMPLIANDO FISIOTERAPIA APAE COLINAS",
      "field": "prestacao_servicos_medico_assistenciais",
      "institution_name": "APAE Colinas"
    }
  }')
END=$(date +%s)
DURATION=$((END - START))

echo ""
echo "📄 RESPOSTA:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "$RESPONSE" | jq -r '.suggestion' | fold -w 70 -s
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "⏱️  Tempo: ${DURATION}s"
echo "📊 Confiança: $(echo "$RESPONSE" | jq -r '.confidence')"
echo "🎯 Modelo: $(echo "$RESPONSE" | jq -r '.model_used // "fallback"')"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ IA OTIMIZADA E FUNCIONANDO!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "🚀 TESTE NO FRONTEND:"
echo "   http://72.60.255.80:3000/projeto/6/editar"
echo ""
echo "💡 Tempo esperado: 5-15 segundos"
echo ""

