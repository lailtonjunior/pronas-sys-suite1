#!/bin/bash

echo "🧹 LIMPANDO SECRETS DO HISTÓRICO DO GIT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "⚠️  Isso vai reescrever o histórico do repositório!"
echo ""
echo "Pressione Enter para continuar ou Ctrl+C para cancelar..."
read

# Instalar git-filter-repo se necessário
if ! command -v git-filter-repo &> /dev/null; then
    echo "📦 Instalando git-filter-repo..."
    pip3 install git-filter-repo
fi

# Remover secrets do histórico
echo "🔄 Removendo secrets..."
git filter-repo --invert-paths --path .env --force

echo ""
echo "✅ Histórico limpo!"
echo ""
echo "⚠️  Agora você precisa fazer force push:"
echo "   git push --force origin main"
