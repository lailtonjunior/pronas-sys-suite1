#!/bin/bash

echo "📝 PREPARANDO COMMIT LIMPO"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 1. Status atual
echo "1️⃣ Status do repositório:"
git status --short

echo ""
echo "2️⃣ Adicionando arquivos seguros..."

# Adicionar apenas arquivos seguros
git add .gitignore
git add docker-compose.yml
git add backend/requirements.txt
git add backend/app/
git add frontend/
git add *.sh
git add README*.md
git add ENTREGA_FINAL.md
git add .env.example

# Garantir que .env NÃO seja adicionado
git reset .env 2>/dev/null || true

echo ""
echo "3️⃣ Arquivos que serão commitados:"
git status --short

echo ""
echo "4️⃣ Verificando se há secrets nos arquivos staged..."
if git diff --cached | grep -i "sk-proj-[A-Za-z0-9_-]\{20,\}"; then
    echo "❌ ERRO: Encontrados secrets nos arquivos!"
    echo "   Cancele e corrija: git reset HEAD"
    exit 1
fi

echo "✅ Nenhum secret encontrado"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Pronto para commit!"
