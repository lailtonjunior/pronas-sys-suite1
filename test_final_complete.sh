#!/bin/bash

echo "========================================="
echo "🎯 TESTE FINAL COMPLETO"
echo "========================================="
echo ""

echo "1️⃣ Verificando API Key no container:"
docker compose exec -T backend python << 'PYEOF'
import os
api_key = os.getenv("OPENAI_API_KEY")
print(f"API Key: {'✅ Presente' if api_key else '❌ Ausente'}")
if api_key:
    print(f"Valor: {api_key[:30]}...{api_key[-10:]}")
PYEOF

echo ""
echo "2️⃣ Verificando biblioteca OpenAI:"
docker compose exec -T backend python << 'PYEOF'
try:
    from openai import AsyncOpenAI
    import openai
    print(f"✅ OpenAI v{openai.__version__} instalado")
except ImportError:
    print("❌ OpenAI não instalado")
PYEOF

echo ""
echo "3️⃣ Health Check dos Providers:"
HEALTH=$(curl -s http://localhost:8000/api/ai/health)
echo "$HEALTH" | python3 -m json.tool

OPENAI_AVAIL=$(echo "$HEALTH" | python3 -c "import sys, json; print(json.load(sys.stdin)['providers']['openai']['available'])" 2>/dev/null)

echo ""
if [ "$OPENAI_AVAIL" = "True" ]; then
    echo "🎉 OPENAI DISPONÍVEL!"
else
    echo "⚠️  OpenAI ainda indisponível"
fi

echo ""
echo "4️⃣ Teste de Geração:"
RESULT=$(curl -s -X POST "http://localhost:8000/api/ai/test-generation?campo=justificativa")
PROVIDER=$(echo "$RESULT" | python3 -c "import sys, json; print(json.load(sys.stdin)['provider'])" 2>/dev/null)

echo "Provider usado: $PROVIDER"

if [ "$PROVIDER" = "gpt-4o-mini" ]; then
    echo ""
    echo "🎉��🎉 SUCESSO TOTAL! GPT-4o-mini FUNCIONANDO! 🎉🎉🎉"
elif [ "$PROVIDER" = "gemini-2.5-flash" ]; then
    echo ""
    echo "⚠️  OpenAI falhou, usando Gemini (fallback funcionando)"
fi

echo ""
echo "========================================="
