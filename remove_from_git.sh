#!/bin/bash

echo "🗑️  REMOVENDO ARQUIVO PROBLEMÁTICO DO GIT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Remover do staging
git reset HEAD README_SISTEMA_IA.md

# Remover do histórico
git rm --cached README_SISTEMA_IA.md

# Adicionar ao .gitignore temporariamente
echo "README_SISTEMA_IA.md" >> .gitignore

echo ""
echo "✅ Arquivo removido do Git"
echo ""
echo "Agora:"
echo "1. Limpe o arquivo: ./clean_all_docs.sh"
echo "2. Remova do .gitignore: sed -i '/README_SISTEMA_IA.md/d' .gitignore"
echo "3. Adicione novamente: git add README_SISTEMA_IA.md"
