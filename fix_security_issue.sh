#!/bin/bash

echo "🚨 CORREÇÃO DE SEGURANÇA: Removendo API Keys do Git"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 1. Backup do docker-compose.yml
cp docker-compose.yml docker-compose.yml.backup.security
echo "✅ Backup criado"

# 2. Substituir API keys hardcoded por variáveis de ambiente
echo "📝 Modificando docker-compose.yml..."

# Criar versão corrigida do docker-compose.yml
cat > docker-compose.yml.new << 'COMPOSE'
version: '3.8'

services:
  postgres:
    image: postgres:15
    container_name: pronas_postgres
    environment:
      - POSTGRES_USER=pronas_user
      - POSTGRES_PASSWORD=pronas_2025_secure
      - POSTGRES_DB=pronas_pcd
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    networks:
      - pronas_network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U pronas_user"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    container_name: pronas_redis
    ports:
      - "6379:6379"
    networks:
      - pronas_network

  qdrant:
    image: qdrant/qdrant:latest
    container_name: pronas_qdrant
    ports:
      - "6333:6333"
    volumes:
      - qdrant_data:/qdrant/storage
    networks:
      - pronas_network

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: pronas_backend
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - QDRANT_URL=${QDRANT_URL}
      - REDIS_URL=${REDIS_URL}
      - SECRET_KEY=${SECRET_KEY}
      - GEMINI_API_KEY=${GEMINI_API_KEY}
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - PERPLEXITY_API_KEY=${PERPLEXITY_API_KEY}
    volumes:
      - ./backend:/app
      - ./data:/data
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - pronas_network

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: pronas_frontend
    ports:
      - "3000:3000"
    environment:
      - NEXT_PUBLIC_API_URL=http://72.60.255.80:8000
    volumes:
      - ./frontend:/app
      - /app/node_modules
    depends_on:
      - backend
    networks:
      - pronas_network

networks:
  pronas_network:
    driver: bridge

volumes:
  postgres_data:
  qdrant_data:
COMPOSE

mv docker-compose.yml.new docker-compose.yml
echo "✅ docker-compose.yml corrigido (usando variáveis de ambiente)"

# 3. Verificar .gitignore
echo ""
echo "📝 Verificando .gitignore..."
if ! grep -q "^.env$" .gitignore 2>/dev/null; then
    echo ".env" >> .gitignore
    echo "*.backup*" >> .gitignore
    echo "docker-compose.yml.backup*" >> .gitignore
    echo "✅ .gitignore atualizado"
else
    echo "✅ .env já está no .gitignore"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ CORREÇÕES APLICADAS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
