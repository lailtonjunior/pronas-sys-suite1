#!/bin/bash

echo "🔐 CHECKLIST DE SEGURANÇA FINAL (v2)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

ERRORS=0

# 1. Verificar .gitignore
if grep -q "^\.env$" .gitignore; then
    echo "✅ .env está no .gitignore"
else
    echo "❌ .env NÃO está no .gitignore"
    echo ".env" >> .gitignore
    echo "   ✅ Adicionado agora"
fi

# 2. Verificar se há secrets REAIS (não patterns de busca)
# Busca por chaves OpenAI reais (não o pattern "sk-proj-")
echo ""
echo "🔍 Procurando secrets REAIS em arquivos rastreados..."

# Buscar chaves OpenAI reais (50+ caracteres)
REAL_SECRETS=$(git ls-files | xargs grep -l "sk-proj-[A-Za-z0-9_-]\{50,\}" 2>/dev/null | grep -v "security_check" | grep -v ".gitignore")

if [ -n "$REAL_SECRETS" ]; then
    echo "❌ ENCONTRADOS secrets em:"
    echo "$REAL_SECRETS"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ Nenhum secret real encontrado"
fi

# 3. Verificar docker-compose.yml
if grep -q "\${OPENAI_API_KEY}" docker-compose.yml; then
    echo "✅ docker-compose.yml usa variáveis de ambiente"
else
    echo "⚠️  docker-compose.yml pode ter secrets hardcoded"
fi

# 4. Verificar se .env existe e não está rastreado
if [ -f .env ] && ! git ls-files --error-unmatch .env 2>/dev/null; then
    echo "✅ .env existe e NÃO está no Git"
else
    echo "⚠️  Verificar status do .env"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $ERRORS -eq 0 ]; then
    echo "✅ SEGURO PARA PUSH!"
    exit 0
else
    echo "❌ ERROS: $ERRORS - Corrija antes de fazer push!"
    exit 1
fi
