#!/bin/bash
echo "🚀 Iniciando Assistente PRONAS/PCD..."

# Subir containers
docker-compose up -d postgres qdrant redis

# Aguardar serviços
echo "⏳ Aguardando serviços..."
sleep 10

# Inicializar banco
docker-compose run --rm backend python scripts/init_db.py

# Inicializar Qdrant
docker-compose run --rm backend python scripts/init_qdrant.py

# Subir aplicação completa
docker-compose up -d

echo "✅ Sistema rodando!"
echo "📖 API Docs: http://localhost:8000/docs"
echo "🌐 Frontend: http://localhost:3000"
