#!/bin/bash

echo "========================================="
echo "🔧 CORRIGINDO VARIÁVEIS DE AMBIENTE"
echo "========================================="
echo ""

echo "1️⃣ Verificando .env..."
if grep -q "OPENAI_API_KEY" .env; then
    echo "✅ OPENAI_API_KEY está no .env"
else
    echo "❌ OPENAI_API_KEY NÃO está no .env"
    exit 1
fi

echo ""
echo "2️⃣ Verificando docker-compose.yml..."

# Backup do docker-compose.yml
cp docker-compose.yml docker-compose.yml.backup
echo "✅ Backup criado: docker-compose.yml.backup"

echo ""
echo "3️⃣ Conteúdo atual da seção backend:"
echo "─────────────────────────────────────────"
grep -A 20 "  backend:" docker-compose.yml | head -25
echo "─────────────────────────────────────────"

echo ""
echo "4️⃣ Verificando se OPENAI_API_KEY está sendo passada..."
if grep -A 20 "  backend:" docker-compose.yml | grep -q "OPENAI_API_KEY"; then
    echo "✅ OPENAI_API_KEY já está configurada"
else
    echo "⚠️  OPENAI_API_KEY NÃO está sendo passada para o container"
    echo "   Você precisa adicionar manualmente ao docker-compose.yml"
fi

echo ""
echo "========================================="
