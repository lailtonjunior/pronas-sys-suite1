#!/bin/bash
set -e

echo "🔧 Corrigindo CORS no backend..."

# Atualizar main.py com CORS configurado corretamente
cat > backend/app/main.py << 'MAINEOF'
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api import auth, projects, anexos, ai_assistant, knowledge_base
from app.database.session import engine, Base
import logging

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Criar aplicação
app = FastAPI(
    title="Assistente PRONAS/PCD",
    description="Sistema RAG Multi-Agente para elaboração de projetos PRONAS/PCD",
    version="1.0.0"
)

# ═══════════════════════════════════════════════════════════════
# CONFIGURAÇÃO CORS - PERMITE TODAS AS ORIGENS
# ═══════════════════════════════════════════════════════════════

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Permite todas as origens
    allow_credentials=True,
    allow_methods=["*"],  # Permite todos os métodos (GET, POST, PUT, DELETE, etc)
    allow_headers=["*"],  # Permite todos os headers
)

# ═══════════════════════════════════════════════════════════════
# INICIALIZAÇÃO DO BANCO DE DADOS
# ═══════════════════════════════════════════════════════════════

@app.on_event("startup")
async def startup_event():
    logger.info("🚀 Assistente PRONAS/PCD v1.0.0")
    
    # Criar tabelas
    try:
        Base.metadata.create_all(bind=engine)
        logger.info("✅ Tabelas criadas/verificadas")
    except Exception as e:
        logger.error(f"❌ Erro ao criar tabelas: {e}")

# ═══════════════════════════════════════════════════════════════
# ROTAS
# ═══════════════════════════════════════════════════════════════

@app.get("/")
async def root():
    return {
        "app": "Assistente PRONAS/PCD",
        "version": "1.0.0",
        "status": "online",
        "docs": "/docs"
    }

@app.get("/health")
async def health():
    return {
        "status": "healthy",
        "app": "Assistente PRONAS/PCD",
        "version": "1.0.0"
    }

# Incluir routers
app.include_router(auth.router, prefix="/api/auth", tags=["Auth"])
app.include_router(projects.router, prefix="/api/projects", tags=["Projects"])
app.include_router(anexos.router, prefix="/api/anexos", tags=["Anexos"])
app.include_router(ai_assistant.router, prefix="/api/ai", tags=["AI"])
app.include_router(knowledge_base.router, prefix="/api/knowledge", tags=["Knowledge"])
MAINEOF

echo "✅ main.py atualizado com CORS"

# Reiniciar backend
echo "🔄 Reiniciando backend..."
docker compose restart backend

echo "⏳ Aguardando 10 segundos..."
sleep 10

# Testar CORS
echo ""
echo "🧪 Testando CORS..."
curl -H "Origin: http://72.60.255.80:3000" \
     -H "Access-Control-Request-Method: POST" \
     -H "Access-Control-Request-Headers: Content-Type" \
     -X OPTIONS \
     http://localhost:8000/api/projects/ -v 2>&1 | grep -i "access-control"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ CORS CORRIGIDO!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "🧪 Teste novamente criar um projeto no frontend"
echo "🌐 http://72.60.255.80:3000/projeto/novo"
echo ""

