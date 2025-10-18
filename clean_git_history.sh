#!/bin/bash

echo "🧹 LIMPANDO HISTÓRICO DO GIT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "⚠️  ATENÇÃO: Isso vai reescrever o histórico do Git!"
echo "   Pressione Ctrl+C para cancelar ou Enter para continuar..."
read

# 1. Criar backup do repositório
echo "1️⃣ Criando backup..."
cd ..
tar -czf pronas-sys-suite1-backup-$(date +%Y%m%d_%H%M%S).tar.gz pronas-sys-suite1/
cd pronas-sys-suite1
echo "✅ Backup criado"

# 2. Usar git filter-branch para remover secrets
echo ""
echo "2️⃣ Removendo secrets do histórico..."

# Remover API keys do histórico
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch docker-compose.yml || true" \
  --prune-empty --tag-name-filter cat -- --all

# Adicionar docker-compose.yml novamente (versão limpa)
git add docker-compose.yml

echo ""
echo "✅ Histórico limpo"

# 3. Força garbage collection
echo ""
echo "3️⃣ Limpando referências antigas..."
git reflog expire --expire=now --all
git gc --prune=now --aggressive

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ HISTÓRICO LIMPO"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "⚠️  IMPORTANTE:"
echo "   1. A API key antiga foi exposta no GitHub"
echo "   2. VOCÊ DEVE REVOGAR E CRIAR UMA NOVA em:"
echo "      https://platform.openai.com/api-keys"
echo "   3. Atualizar a nova chave no arquivo .env"
echo ""
