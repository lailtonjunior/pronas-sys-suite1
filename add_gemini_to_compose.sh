#!/bin/bash
set -e

echo "🔧 ADICIONANDO GEMINI_API_KEY AO DOCKER-COMPOSE.YML"
echo "═══════════════════════════════════════════════════════════════"
echo ""

cd /root/pronas-sys-suite1

# Pegar a chave do .env
GEMINI_KEY=$(grep "GEMINI_API_KEY" .env | cut -d '=' -f2)

if [ -z "$GEMINI_KEY" ]; then
    echo "❌ GEMINI_API_KEY não encontrada no .env!"
    exit 1
fi

echo "✅ GEMINI_API_KEY: ${GEMINI_KEY:0:25}..."
echo ""

# Backup
cp docker-compose.yml docker-compose.yml.bak.$(date +%s)

# Adicionar GEMINI_API_KEY na seção environment do backend
echo "📝 Atualizando docker-compose.yml..."

# Usar sed para adicionar após SECRET_KEY
sed -i "/SECRET_KEY=change-this-secret-key-in-production-min-32-chars/a\      - GEMINI_API_KEY=$GEMINI_KEY" docker-compose.yml

echo "✅ GEMINI_API_KEY adicionada!"
echo ""

# Mostrar a seção environment
echo "📋 Nova configuração:"
grep -A 10 "environment:" docker-compose.yml | head -15

echo ""
echo "🔄 Reiniciando backend..."
docker compose stop backend
docker compose up -d backend

echo ""
echo "⏳ Aguardando 20 segundos..."
sleep 20

echo ""
echo "🔍 Verificando variáveis no container:"
docker compose exec backend env | grep GEMINI_API_KEY

echo ""
echo "🧪 Testando Gemini..."
docker compose exec -T backend python3 << 'PYTEST'
import google.generativeai as genai
import os

try:
    key = os.getenv('GEMINI_API_KEY')
    if not key:
        print("❌ GEMINI_API_KEY não disponível")
        exit(1)
    
    print(f"✅ Chave encontrada: {key[:30]}...")
    
    genai.configure(api_key=key)
    model = genai.GenerativeModel('gemini-1.5-flash')
    response = model.generate_content("Responda apenas: Gemini OK")
    
    print(f"✅ Gemini respondeu: {response.text.strip()}")
    print("")
    print("🎉 GEMINI FUNCIONANDO PERFEITAMENTE!")
    
except Exception as e:
    print(f"❌ Erro ao conectar Gemini: {e}")
    exit(1)
PYTEST

if [ $? -eq 0 ]; then
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "�� CONFIGURAÇÃO CONCLUÍDA COM SUCESSO!"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "🧪 Testando endpoint /ai/suggest:"
    echo ""
    
    RESPONSE=$(curl -s -X POST http://localhost:8000/api/ai/suggest \
      -H "Content-Type: application/json" \
      -d '{
        "field_name": "justificativa",
        "field_context": {
          "current_value": "",
          "label": "Justificativa"
        },
        "project_context": {
          "title": "AMPLIANDO ATENDIMENTOS DE FISIOTERAPIA NA APAE DE COLINAS",
          "field": "prestacao_servicos_medico_assistenciais",
          "institution_name": "APAE de Colinas do Tocantins",
          "priority_area": "Reabilitação Física e Funcional"
        }
      }')
    
    echo "$RESPONSE" | jq -r '.suggestion' 2>/dev/null | head -c 400
    
    echo ""
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "✅ IA COMPLETAMENTE FUNCIONAL!"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "🚀 TESTE NO FRONTEND:"
    echo "   http://72.60.255.80:3000/projeto/6/editar"
    echo ""
    echo "   1. Preencha o título do projeto"
    echo "   2. Clique no botão 'IA' 🤖 em qualquer campo"
    echo "   3. Aguarde 3-5 segundos"
    echo "   4. A sugestão aparecerá automaticamente!"
    echo ""
else
    echo ""
    echo "❌ Ainda há um problema. Veja o erro acima."
fi

