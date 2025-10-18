#!/bin/bash

echo "🔐 CHECKLIST DE SEGURANÇA FINAL"
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

# 2. Verificar se há secrets em arquivos que vão para o Git
echo ""
echo "🔍 Procurando secrets em arquivos rastreados pelo Git..."
if git ls-files | xargs grep -l "sk-proj-" 2>/dev/null | grep -v ".gitignore"; then
    echo "❌ ENCONTRADOS secrets em arquivos do Git!"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ Nenhum secret encontrado em arquivos rastreados"
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
    git status .env 2>/dev/null || echo "   (.env não rastreado - OK)"
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
