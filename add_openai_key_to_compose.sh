#!/bin/bash

echo "========================================="
echo "➕ ADICIONANDO OPENAI_API_KEY"
echo "========================================="
echo ""

# Pegar a chave do .env
OPENAI_KEY=$(grep "^OPENAI_API_KEY=" .env | cut -d '=' -f2)

if [ -z "$OPENAI_KEY" ]; then
    echo "❌ OPENAI_API_KEY não encontrada no .env"
    exit 1
fi

echo "✅ API Key encontrada: ${OPENAI_KEY:0:30}...${OPENAI_KEY: -10}"
echo ""

# Fazer backup
cp docker-compose.yml docker-compose.yml.backup.$(date +%Y%m%d_%H%M%S)
echo "✅ Backup criado"
echo ""

# Adicionar OPENAI_API_KEY após GEMINI_API_KEY
echo "📝 Adicionando ao docker-compose.yml..."
sed -i "/GEMINI_API_KEY=/a\      - OPENAI_API_KEY=$OPENAI_KEY" docker-compose.yml

echo "✅ Adicionado!"
echo ""

echo "📄 Verificando resultado:"
echo "─────────────────────────────────────────"
grep -A 15 "environment:" docker-compose.yml | head -20
echo "─────────────────────────────────────────"

echo ""
echo "========================================="
echo "✅ CONFIGURAÇÃO ATUALIZADA"
echo "========================================="
