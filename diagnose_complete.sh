#!/bin/bash
set -e

echo "🔍 DIAGNÓSTICO COMPLETO DA IA"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# 1. Verificar GEMINI_API_KEY
echo "1️⃣ Verificando GEMINI_API_KEY:"
if docker compose exec backend env | grep -q "GEMINI_API_KEY=sk"; then
    echo "   ✅ GEMINI_API_KEY está configurada"
    docker compose exec backend env | grep "GEMINI_API_KEY" | sed 's/\(GEMINI_API_KEY=sk[^"]*\).*/\1.../'
else
    echo "   ❌ GEMINI_API_KEY NÃO está configurada!"
    echo ""
    echo "   📝 Configure com:"
    echo "   echo 'GEMINI_API_KEY=SUA_CHAVE_AQUI' >> .env"
fi

echo ""

# 2. Testar geração de embedding
echo "2️⃣ Testando geração de embeddings:"
docker compose exec backend python3 << 'EMBEOF'
try:
    from app.ai.rag.embeddings import generate_embedding
    emb = generate_embedding("teste fisioterapia")
    print(f"   ✅ Embedding gerado: {len(emb)} dimensões")
except Exception as e:
    print(f"   ❌ Erro: {e}")
EMBEOF

echo ""

# 3. Testar busca no Qdrant
echo "3️⃣ Testando busca no Qdrant:"
docker compose exec backend python3 << 'QDREOF'
try:
    from app.ai.rag.embeddings import generate_embedding
    from app.ai.rag.vectorstore import search_similar_cases
    
    query_vector = generate_embedding("fisioterapia APAE")
    results = search_similar_cases(query_vector, limit=3)
    print(f"   ✅ Encontrados: {len(results)} casos similares")
    for i, r in enumerate(results, 1):
        print(f"      {i}. Score: {r.score:.3f}")
except Exception as e:
    print(f"   ❌ Erro: {e}")
QDREOF

echo ""

# 4. Testar Gemini diretamente
echo "4️⃣ Testando API Gemini:"
docker compose exec backend python3 << 'GEMEOF'
import google.generativeai as genai
from app.config import settings
import os

try:
    key = os.getenv('GEMINI_API_KEY')
    if not key:
        print("   ❌ GEMINI_API_KEY não encontrada!")
    else:
        print(f"   🔑 Key: {key[:10]}...")
        genai.configure(api_key=key)
        model = genai.GenerativeModel('gemini-1.5-flash')
        response = model.generate_content("Diga olá em uma palavra")
        print(f"   ✅ Gemini respondeu: {response.text[:50]}")
except Exception as e:
    print(f"   ❌ Erro ao conectar Gemini: {e}")
GEMEOF

echo ""

# 5. Ver logs de erro
echo "5️⃣ Últimos erros do backend:"
docker compose logs backend --tail=20 | grep -i "error\|exception\|failed\|timeout" | tail -5 || echo "   ✅ Nenhum erro recente"

echo ""
echo "═══════════════════════════════════════════════════════════════"

