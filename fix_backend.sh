#!/bin/bash
set -e

echo "🔧 Corrigindo backend..."

# Parar backend
docker compose stop backend

# Atualizar requirements.txt
cat > backend/requirements.txt << 'REQEOF'
fastapi==0.109.0
uvicorn[standard]==0.27.0
python-multipart==0.0.9
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-dotenv==1.0.0
pydantic==2.5.3
pydantic-settings==2.1.0
sqlalchemy==2.0.25
asyncpg==0.29.0
alembic==1.13.1
psycopg2-binary==2.9.9
redis==5.0.1
hiredis==2.3.2
langchain==0.1.1
langchain-community==0.0.13
langchain-core==0.1.10
langgraph==0.0.20
qdrant-client==1.7.0
sentence-transformers==2.3.1
torch==2.1.2
transformers==4.36.2
google-generativeai==0.3.2
httpx==0.26.0
aiohttp==3.9.1
pypdf==3.17.4
python-docx==1.1.0
reportlab==4.0.9
openpyxl==3.1.2
tenacity==8.2.3
pyyaml==6.0.1
REQEOF

echo "✅ requirements.txt atualizado"

# Remover container e imagem
docker compose rm -f backend 2>/dev/null || true
docker rmi pronas-sys-suite1-backend 2>/dev/null || true

echo "🔨 Rebuilding backend (isso pode levar alguns minutos)..."
docker compose build --no-cache backend

echo "🚀 Iniciando backend..."
docker compose up -d backend

echo "⏳ Aguardando 20 segundos..."
sleep 20

echo ""
echo "📊 Status do backend:"
docker compose ps backend

echo ""
echo "📋 Últimas linhas do log:"
docker compose logs backend | tail -20

echo ""
echo "🧪 Testando API..."
curl -s http://localhost:8000/health || echo "Backend ainda inicializando..."

echo ""
echo "✅ Correção concluída!"
