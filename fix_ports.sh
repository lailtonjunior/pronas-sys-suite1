#!/bin/bash
set -e

echo "🔧 Corrigindo conflito de portas..."

# Parar containers
docker compose down 2>/dev/null || true

# Backup
cp docker-compose.yml docker-compose.yml.backup 2>/dev/null || true

# Criar docker-compose.yml com portas alternativas
cat > docker-compose.yml << 'COMPEOF'
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: pronas_postgres
    environment:
      POSTGRES_DB: pronas_pcd
      POSTGRES_USER: pronas_user
      POSTGRES_PASSWORD: pronas_2025_secure
    ports:
      - "5433:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - pronas_network
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U pronas_user"]
      interval: 10s
      timeout: 5s
      retries: 5

  qdrant:
    image: qdrant/qdrant:latest
    container_name: pronas_qdrant
    ports:
      - "6334:6333"
    volumes:
      - qdrant_data:/qdrant/storage
    networks:
      - pronas_network
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    container_name: pronas_redis
    ports:
      - "6380:6379"
    volumes:
      - redis_data:/data
    networks:
      - pronas_network
    restart: unless-stopped
    command: redis-server --appendonly yes

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: pronas_backend
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://pronas_user:pronas_2025_secure@postgres:5432/pronas_pcd
      - QDRANT_URL=http://qdrant:6333
      - REDIS_URL=redis://redis:6379
      - SECRET_KEY=change-this-secret-key-in-production-min-32-chars
    volumes:
      - ./backend:/app
      - ./data:/data
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - pronas_network
    restart: unless-stopped
    command: uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: pronas_frontend
    ports:
      - "3000:3000"
    environment:
      - NEXT_PUBLIC_API_URL=http://localhost:8000
    volumes:
      - ./frontend:/app
      - /app/node_modules
      - /app/.next
    depends_on:
      - backend
    networks:
      - pronas_network
    restart: unless-stopped

networks:
  pronas_network:
    driver: bridge

volumes:
  postgres_data:
  qdrant_data:
  redis_data:
COMPEOF

echo "✅ Portas atualizadas: Postgres=5433, Qdrant=6334, Redis=6380"
docker rm -f pronas_backend pronas_frontend pronas_postgres pronas_redis pronas_qdrant 2>/dev/null || true
echo "🚀 Iniciando sistema..."
docker compose up -d --build
echo "⏳ Aguardando 30s..."
sleep 30
docker compose ps
echo ""
echo "✅ Acesse: http://72.60.255.80:3000 (Frontend)"
echo "✅ Acesse: http://72.60.255.80:8000/docs (API)"
