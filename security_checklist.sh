#!/bin/bash

echo "🔐 CHECKLIST DE SEGURANÇA"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

ERRORS=0

# 1. Verificar se .env está no .gitignore
if grep -q "^.env$" .gitignore; then
    echo "✅ .env está no .gitignore"
else
    echo "❌ .env NÃO está no .gitignore"
    ERRORS=$((ERRORS + 1))
fi

# 2. Verificar se há secrets no código
if grep -rn "sk-proj-" . --exclude-dir=.git --exclude=".env" --exclude="*.backup*" 2>/dev/null; then
    echo "❌ ENCONTRADAS API keys no código!"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ Nenhuma API key encontrada no código"
fi

# 3. Verificar docker-compose.yml
if grep -q "\${OPENAI_API_KEY}" docker-compose.yml; then
    echo "✅ docker-compose.yml usa variáveis de ambiente"
else
    echo "❌ docker-compose.yml pode conter secrets hardcoded"
    ERRORS=$((ERRORS + 1))
fi

# 4. Verificar se .env existe
if [ -f .env ]; then
    echo "✅ .env existe"
else
    echo "❌ .env NÃO existe"
    ERRORS=$((ERRORS + 1))
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ERRORS -eq 0 ]; then
    echo "✅ TUDO OK! Seguro para fazer push."
    exit 0
else
    echo "❌ ERROS ENCONTRADOS: $ERRORS"
    echo "   NÃO faça push até corrigir!"
    exit 1
fi
