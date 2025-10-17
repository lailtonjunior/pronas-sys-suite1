#!/bin/bash
set -e

echo "🔧 CORRIGINDO VARIÁVEIS DE AMBIENTE..."
echo "═══════════════════════════════════════════════════════════════"
echo ""

cd /root/pronas-sys-suite1

# 1. Verificar .env
echo "1️⃣ Verificando .env no host:"
if grep -q "GEMINI_API_KEY=AIza" .env; then
    echo "   ✅ GEMINI_API_KEY encontrada no .env"
else
    echo "   ❌ GEMINI_API_KEY não encontrada!"
    exit 1
fi

echo ""

# 2. Verificar docker-compose.yml
echo "2️⃣ Verificando docker-compose.yml:"
if grep -q "env_file:" docker-compose.yml; then
    echo "   ✅ env_file está configurado"
else
    echo "   ⚠️  Adicionando env_file ao docker-compose.yml..."
    
    # Backup
    cp docker-compose.yml docker-compose.yml.bak
    
    # Adicionar env_file ao backend
    sed -i '/backend:/a\    env_file:\n      - .env' docker-compose.yml
    
    echo "   ✅ env_file adicionado"
fi

echo ""

# 3. Parar containers
echo "3️⃣ Parando containers..."
docker compose down

echo ""

# 4. Subir novamente (vai ler o .env)
echo "4️⃣ Subindo containers com variáveis atualizadas..."
docker compose up -d

echo ""
echo "⏳ Aguardando 20 segundos..."
sleep 20

echo ""

# 5. Verificar se carregou
echo "5️⃣ Verificando se GEMINI_API_KEY foi carregada:"
if docker compose exec backend env | grep -q "GEMINI_API_KEY=AIza"; then
    echo "   ✅ GEMINI_API_KEY carregada no container!"
    docker compose exec backend env | grep "GEMINI_API_KEY" | sed 's/\(GEMINI_API_KEY=AIza[^"]*\).*/\1.../'
else
    echo "   ❌ Ainda não carregou..."
    
    # Forçar com export
    echo ""
    echo "   🔧 Forçando variável manualmente..."
    GEMINI_KEY=$(grep "GEMINI_API_KEY" .env | cut -d '=' -f2)
    
    # Adicionar ao ambiente do container
    docker compose exec -e GEMINI_API_KEY="$GEMINI_KEY" backend env | grep GEMINI
fi

echo ""

# 6. Testar Gemini
echo "6️⃣ Testando conexão com Gemini..."
docker compose exec -T backend python3 << 'TESTGEM'
import google.generativeai as genai
import os

try:
    key = os.getenv('GEMINI_API_KEY')
    print(f"   🔑 Key encontrada: {key[:15]}..." if key else "   ❌ Sem key")
    
    if not key:
        print("   ❌ GEMINI_API_KEY não disponível no container!")
        exit(1)
    
    genai.configure(api_key=key)
    model = genai.GenerativeModel('gemini-1.5-flash')
    response = model.generate_content("Responda apenas: OK")
    
    print(f"   ✅ Gemini funcionando!")
    print(f"   📝 Resposta: {response.text[:50]}")
    
except Exception as e:
    print(f"   ❌ Erro: {str(e)[:100]}")
    exit(1)
TESTGEM

echo ""

if [ $? -eq 0 ]; then
    echo "═══════════════════════════════════════════════════════════════"
    echo "🎉 GEMINI CONFIGURADO E FUNCIONANDO!"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "🧪 Testando endpoint /ai/suggest:"
    
    curl -s -X POST http://localhost:8000/api/ai/suggest \
      -H "Content-Type: application/json" \
      -d '{
        "field_name": "justificativa",
        "field_context": {"label": "Justificativa"},
        "project_context": {
          "title": "AMPLIANDO ATENDIMENTOS DE FISIOTERAPIA",
          "field": "prestacao_servicos_medico_assistenciais",
          "institution_name": "APAE Colinas"
        }
      }' | jq -r '.suggestion' | head -c 200
    
    echo ""
    echo ""
    echo "✅ Agora teste no frontend:"
    echo "   http://72.60.255.80:3000/projeto/6/editar"
else
    echo "═══════════════════════════════════════════════════════════════"
    echo "❌ ALGO AINDA ESTÁ ERRADO"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "Vamos verificar manualmente:"
    echo ""
    echo "1. Ver .env:"
    cat .env | grep GEMINI
    echo ""
    echo "2. Ver dentro do container:"
    docker compose exec backend env | grep GEMINI || echo "Não encontrada!"
fi

