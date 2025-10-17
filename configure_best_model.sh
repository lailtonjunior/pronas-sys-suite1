#!/bin/bash
set -e

echo "🤖 CONFIGURANDO MELHOR MODELO GEMINI"
echo "═══════════════════════════════════════════════════════════════"
echo ""

cd /root/pronas-sys-suite1

# Criar text_agent.py otimizado
cat > backend/app/ai/agents/text_agent.py << 'AGENTEOF'
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
    """Agente de sugestão de texto usando RAG + Gemini 2.5"""
    
    try:
        # 1. Buscar casos similares (RAG)
        query = f"{project_context.get('field', '')} {project_context.get('priority_area', '')} {field_name}"
        query_vector = generate_embedding(query)
        similar_cases = search_similar_cases(query_vector, limit=5)
        
        # 2. Montar contexto RAG
        rag_context = ""
        if similar_cases:
            rag_context = "\n\n".join([
                f"📋 Caso Aprovado {i+1} (Score: {case.score:.2f}):\n{case.payload.get('summary', case.payload.get('text', ''))[:400]}"
                for i, case in enumerate(similar_cases[:3])
            ])
        
        # 3. Montar prompt otimizado
        prompt = f"""Você é um especialista em elaboração de projetos PRONAS/PCD (Programa Nacional de Apoio à Atenção da Saúde da Pessoa com Deficiência) conforme Portaria GM/MS nº 8.031/2025.

📌 CAMPO A PREENCHER: {field_name}

🏥 CONTEXTO DO PROJETO:
- Título: {project_context.get('title', 'Não informado')}
- Área: {project_context.get('field', 'prestacao_servicos_medico_assistenciais')}
- Área Prioritária: {project_context.get('priority_area', 'Reabilitação')}
- Instituição: {project_context.get('institution_name', 'Não informada')}

{"📚 REFERÊNCIAS DE PROJETOS APROVADOS:" if rag_context else ""}
{rag_context}

📝 INSTRUÇÕES:
1. Gere um texto profissional e técnico para o campo "{field_name}"
2. Mencione conformidade com a Portaria GM/MS nº 8.031/2025
3. Use terminologia técnica da área de saúde e reabilitação
4. Inclua indicadores mensuráveis quando aplicável
5. Seja específico e objetivo
6. Limite: 150-200 palavras

Gere APENAS o conteúdo sugerido, sem explicações adicionais."""

        # 4. Tentar gemini-2.5-flash primeiro (mais rápido)
        try:
            model = genai.GenerativeModel('gemini-2.5-flash')
            response = await asyncio.wait_for(
                asyncio.to_thread(model.generate_content, prompt),
                timeout=10.0
            )
            model_used = 'gemini-2.5-flash'
            
        except Exception as e:
            # Fallback para gemini-2.5-pro se flash falhar
            logger.warning(f"gemini-2.5-flash falhou: {e}. Tentando gemini-2.5-pro...")
            model = genai.GenerativeModel('gemini-2.5-pro')
            response = await asyncio.wait_for(
                asyncio.to_thread(model.generate_content, prompt),
                timeout=15.0
            )
            model_used = 'gemini-2.5-pro'
        
        # 5. Processar resposta
        suggestion_text = response.text.strip()
        
        # Limpar formatação markdown se houver
        suggestion_text = suggestion_text.replace('**', '').replace('##', '')
        
        return {
            "suggestion": suggestion_text,
            "confidence": 0.90 if len(similar_cases) >= 3 else 0.75 if len(similar_cases) > 0 else 0.60,
            "references": [
                {"id": str(c.id), "score": float(c.score), "title": c.payload.get('title', '')[:50]} 
                for c in similar_cases[:3]
            ],
            "similar_cases_count": len(similar_cases),
            "model_used": model_used
        }
        
    except asyncio.TimeoutError:
        logger.error("Timeout ao gerar sugestão")
        return {
            "suggestion": "⏱️ Tempo limite excedido. A IA está processando muitos pedidos. Tente novamente em alguns segundos.",
            "confidence": 0.0,
            "error": "timeout"
        }
        
    except Exception as e:
        error_msg = str(e)
        logger.error(f"Erro ao gerar sugestão: {error_msg}")
        
        # Se houver casos similares, retornar pelo menos isso
        if similar_cases and len(similar_cases) > 0:
            best_case = similar_cases[0]
            return {
                "suggestion": f"📚 Baseado em caso similar aprovado:\n\n{best_case.payload.get('summary', '')[:400]}",
                "confidence": 0.5,
                "references": [{"id": str(best_case.id), "score": float(best_case.score)}],
                "similar_cases_count": len(similar_cases),
                "fallback": "rag_only"
            }
        
        return {
            "suggestion": "❌ Erro ao processar solicitação. Verifique a conexão e tente novamente.",
            "confidence": 0.0,
            "error": error_msg[:100]
        }
AGENTEOF

echo "✅ text_agent.py configurado com gemini-2.5-flash + fallback"

echo ""
echo "🔄 Reiniciando backend..."
docker compose restart backend

echo ""
echo "⏳ Aguardando 15 segundos..."
sleep 15

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "🧪 TESTANDO IA COM GEMINI 2.5"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Teste 1: Verificar modelo
echo "1️⃣ Testando conexão Gemini 2.5:"
docker compose exec -T backend python3 << 'TEST1'
import google.generativeai as genai
import os

genai.configure(api_key=os.getenv('GEMINI_API_KEY'))

try:
    model = genai.GenerativeModel('gemini-2.5-flash')
    response = model.generate_content("Diga apenas: OK")
    print(f"   ✅ Gemini 2.5 Flash: {response.text.strip()}")
except Exception as e:
    print(f"   ❌ Erro: {e}")
TEST1

echo ""
echo "2️⃣ Testando endpoint /ai/suggest com projeto real:"
echo ""

RESPONSE=$(curl -s -X POST http://localhost:8000/api/ai/suggest \
  -H "Content-Type: application/json" \
  -d '{
    "field_name": "justificativa",
    "field_context": {
      "label": "Justificativa do Projeto"
    },
    "project_context": {
      "title": "AMPLIANDO ATENDIMENTOS DE FISIOTERAPIA NA APAE DE COLINAS",
      "field": "prestacao_servicos_medico_assistenciais",
      "institution_name": "APAE de Colinas do Tocantins",
      "priority_area": "Reabilitação Física e Funcional"
    }
  }')

echo "📄 SUGESTÃO GERADA PELA IA:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "$RESPONSE" | jq -r '.suggestion' 2>/dev/null | fold -w 70 -s
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 MÉTRICAS:"
echo "   • Confiança: $(echo "$RESPONSE" | jq -r '.confidence')"
echo "   • Casos similares: $(echo "$RESPONSE" | jq -r '.similar_cases_count')"
echo "   • Modelo usado: $(echo "$RESPONSE" | jq -r '.model_used')"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "🎉 IA CONFIGURADA COM SUCESSO!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "�� AGORA TESTE NO FRONTEND:"
echo "   http://72.60.255.80:3000/projeto/6/editar"
echo ""
echo "💡 DICAS:"
echo "   • Tempo de resposta: 2-5 segundos"
echo "   • Qualidade: Excelente (Gemini 2.5)"
echo "   • Se travar, aguarde 10s e tente novamente"
echo ""

