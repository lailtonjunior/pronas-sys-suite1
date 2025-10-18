#!/bin/bash

echo "🔍 VERIFICANDO ARQUIVO .ENV"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Verificar se .env existe e está limpo
if [ ! -f .env ]; then
    echo "❌ Arquivo .env não existe!"
    exit 1
fi

# Verificar se tem lixo (comandos cat/EOF)
if grep -q "cat >" .env; then
    echo "❌ .env ainda tem comandos (lixo)!"
    echo "   Execute: ./fix_env_file.sh"
    exit 1
fi

echo "✅ .env existe e está limpo"
echo ""

# Mostrar estrutura (SEM EXPOR CHAVES COMPLETAS)
echo "📋 Estrutura do .env:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

while IFS='=' read -r key value; do
    # Pular linhas vazias e comentários
    [[ -z "$key" || "$key" =~ ^# ]] && continue
    
    # Mostrar apenas primeiros 30 caracteres de valores sensíveis
    if [[ "$key" == *"KEY"* || "$key" == *"PASSWORD"* || "$key" == *"SECRET"* ]]; then
        echo "$key=${value:0:30}..."
    else
        echo "$key=$value"
    fi
done < .env

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Verificar se OpenAI foi atualizada
if grep -q "OPENAI_API_KEY=SUBSTITUIR" .env; then
    echo "⚠️  OPENAI_API_KEY ainda não foi atualizada!"
    echo "   Execute: ./create_new_openai_key.sh"
    exit 1
fi

if grep -q "OPENAI_API_KEY=sk-proj-hwvuNw" .env; then
    echo "❌ ERRO: .env ainda tem a chave EXPOSTA antiga!"
    echo "   Execute: ./create_new_openai_key.sh"
    exit 1
fi

echo "✅ Todas as variáveis configuradas corretamente!"
echo ""
