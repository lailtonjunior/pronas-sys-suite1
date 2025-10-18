#!/bin/bash

echo "🔧 CORRIGINDO ARQUIVO .ENV"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Backup
cp .env .env.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || true

# Criar .env limpo
cat > .env << 'ENVFILE'
# Database Configuration
DATABASE_URL=postgresql://pronas_user:YOUR_DB_PASSWORD_HERE@postgres:5432/pronas_pcd

# Vector Database (RAG)
QDRANT_URL=http://qdrant:6333

# Cache
REDIS_URL=redis://redis:6379

# Security
SECRET_KEY=your_secret_key_min_32_chars_here

# AI APIs - SUBSTITUIR OpenAI por NOVA chave
OPENAI_API_KEY=SUBSTITUIR_POR_NOVA_CHAVE_AQUI
GEMINI_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXX
PERPLEXITY_API_KEY=pplx-YOUR_PERPLEXITY_KEY_HERE

# Application Settings
DEBUG=False
ALLOWED_ORIGINS=http://72.60.255.80,http://72.60.255.80:3000

# AI/ML Configuration
EMBEDDING_MODEL=sentence-transformers/paraphrase-multilingual-mpnet-base-v2
ENVFILE

echo "✅ .env limpo e criado"
echo ""
echo "⚠️  Agora execute: ./update_openai_key.sh"
