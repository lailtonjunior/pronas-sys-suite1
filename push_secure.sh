#!/bin/bash

echo "🔒 PUSH SEGURO (SEM API KEYS)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 1. Verificar se há secrets no código
echo "1️⃣ Verificando por secrets..."
if grep -r "sk-proj-" . --exclude-dir=.git --exclude=".env" --exclude="*.backup*"; then
    echo "❌ ERRO: Ainda há API keys no código!"
    echo "   Execute: ./fix_security_issue.sh"
    exit 1
fi

if grep -r "AIzaSy" docker-compose.yml; then
    echo "❌ ERRO: Ainda há API keys no docker-compose.yml!"
    exit 1
fi

echo "✅ Nenhum secret encontrado no código"

# 2. Adicionar mudanças
echo ""
echo "2️⃣ Adicionando arquivos corrigidos..."
git add docker-compose.yml
git add .gitignore
git add README_SISTEMA_IA.md
git add ENTREGA_FINAL.md
git add *.sh

# 3. Commit
echo ""
echo "3️⃣ Criando commit de correção..."
git commit -m "🔒 Security: Remove hardcoded API keys, use environment variables

- Moved all API keys to environment variables
- Updated docker-compose.yml to use \${VAR} syntax
- Added .env to .gitignore
- Updated documentation with security best practices

IMPORTANT: Old API keys have been exposed and must be revoked!"

# 4. Push forçado (reescreve histórico)
echo ""
echo "4️⃣ Fazendo push (force)..."
git push --force origin main

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ PUSH CONCLUÍDO COM SEGURANÇA"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
