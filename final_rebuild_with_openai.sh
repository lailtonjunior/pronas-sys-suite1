#!/bin/bash

echo "========================================="
echo "🔨 REBUILD FINAL COM OPENAI"
echo "========================================="
echo ""

echo "1️⃣ Verificando requirements.txt..."
if grep -q "^openai" backend/requirements.txt; then
    echo "✅ openai já está no requirements.txt"
else
    echo "📝 Adicionando openai e tenacity..."
    cat >> backend/requirements.txt << 'REQS'

# OpenAI API e Retry Logic
openai>=1.3.0
tenacity>=8.2.0
REQS
    echo "✅ Adicionado!"
fi

echo ""
echo "2️⃣ Últimas linhas do requirements.txt:"
echo "─────────────────────────────────────────"
tail -10 backend/requirements.txt
echo "─────────────────────────────────────────"

echo ""
echo "3️⃣ Parando containers..."
docker compose down

echo ""
echo "4️⃣ Removendo imagem antiga do backend..."
docker rmi pronas-sys-suite1-backend 2>/dev/null || echo "   (imagem não existia)"

echo ""
echo "5️⃣ Rebuild do backend (SEM CACHE)..."
echo "   ⏳ Isso vai demorar 2-3 minutos..."
docker compose build backend --no-cache

echo ""
echo "6️⃣ Subindo todos os serviços..."
docker compose up -d

echo ""
echo "7️⃣ Aguardando 25 segundos para inicialização completa..."
sleep 25

echo ""
echo "8️⃣ Verificando instalação:"
echo "─────────────────────────────────────────"
docker compose exec backend pip list | grep -E "openai|tenacity"
echo "─────────────────────────────────────────"

echo ""
echo "9️⃣ Verificando logs de inicialização:"
docker compose logs backend | grep -E "OpenAI|Gemini|disponível" | tail -10

echo ""
echo "========================================="
echo "✅ REBUILD CONCLUÍDO"
echo "========================================="
