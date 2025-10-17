#!/bin/bash
set -e

echo "🔧 CORRIGINDO ROTA DE UPLOAD..."

# ═══════════════════════════════════════════════════════════════
# 1. VERIFICAR SE A ROTA EXISTE
# ═══════════════════════════════════════════════════════════════

echo "🔍 Verificando rotas registradas..."

if grep -q "knowledge_base" backend/app/main.py; then
    echo "✅ Rota já existe no main.py"
else
    echo "⚠️ Rota NÃO existe, vamos adicionar..."
fi

# ═══════════════════════════════════════════════════════════════
# 2. ADICIONAR ROTA AO MAIN.PY
# ═══════════════════════════════════════════════════════════════

# Backup do main.py
cp backend/app/main.py backend/app/main.py.backup

# Verificar se já tem o import
if ! grep -q "from app.api import.*knowledge_base" backend/app/main.py; then
    # Adicionar import
    sed -i 's/from app.api import \(.*\)/from app.api import \1, knowledge_base/' backend/app/main.py
    echo "✅ Import adicionado"
fi

# Verificar se já tem a rota registrada
if ! grep -q 'app.include_router(knowledge_base.router' backend/app/main.py; then
    # Adicionar rota antes da última linha
    sed -i '$i app.include_router(knowledge_base.router, prefix="/api/knowledge", tags=["Knowledge"])' backend/app/main.py
    echo "✅ Rota registrada"
fi

# ═══════════════════════════════════════════════════════════════
# 3. VERIFICAR SE O ARQUIVO DA API EXISTE
# ═══════════════════════════════════════════════════════════════

if [ ! -f "backend/app/api/knowledge_base.py" ]; then
    echo "⚠️ Arquivo knowledge_base.py não existe, criando..."
    
    cat > backend/app/api/knowledge_base.py << 'KBEOF'
from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from typing import List
import shutil
from pathlib import Path
import logging

router = APIRouter()
logger = logging.getLogger(__name__)

KNOWLEDGE_BASE = Path("/app/../knowledge_base")

@router.post("/upload")
async def upload_documentos(
    categoria: str = Form(...),
    files: List[UploadFile] = File(...)
):
    """Upload de PDFs para base de conhecimento"""
    
    # Mapear categoria para pasta
    pasta_map = {
        "aprovados_medico": "aprovados",
        "aprovados_formacao": "aprovados",
        "aprovados_pesquisa": "aprovados",
        "reprovados_medico": "reprovados",
        "reprovados_formacao": "reprovados",
        "reprovados_pesquisa": "reprovados",
        "diligencia_oficio": "diligencias",
        "diligencia_resposta": "diligencias",
        "portarias": "portarias",
        "exemplos": "exemplos"
    }
    
    pasta = pasta_map.get(categoria, "aprovados")
    upload_dir = KNOWLEDGE_BASE / pasta
    upload_dir.mkdir(parents=True, exist_ok=True)
    
    uploaded = []
    
    for file in files:
        if not file.filename.lower().endswith(('.pdf', '.docx')):
            continue
        
        file_path = upload_dir / file.filename
        
        with file_path.open("wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        
        uploaded.append(file.filename)
        logger.info(f"✅ Upload: {file_path}")
    
    return {
        "uploaded": len(uploaded),
        "files": uploaded,
        "categoria": categoria,
        "pasta": pasta
    }

@router.post("/process")
async def process_documents():
    """Processar documentos com IA"""
    return {
        "processed": 0,
        "message": "Execute ./import_documents.sh no servidor"
    }

@router.get("/status")
async def get_status():
    """Status da base de conhecimento"""
    import os
    
    stats = {}
    for folder in ["aprovados", "reprovados", "diligencias", "portarias", "exemplos"]:
        folder_path = KNOWLEDGE_BASE / folder
        if folder_path.exists():
            count = len(list(folder_path.glob("*.pdf")))
            stats[folder] = count
        else:
            stats[folder] = 0
    
    return {
        "total": sum(stats.values()),
        "by_category": stats
    }
KBEOF
    
    echo "✅ API knowledge_base.py criada"
fi

# ═══════════════════════════════════════════════════════════════
# 4. CRIAR ESTRUTURA DE PASTAS
# ═══════════════════════════════════════════════════════════════

mkdir -p knowledge_base/{aprovados,reprovados,diligencias,portarias,exemplos}
echo "✅ Estrutura de pastas criada"

# ═══════════════════════════════════════════════════════════════
# 5. REINICIAR BACKEND
# ═══════════════════════════════════════════════════════════════

echo ""
echo "🔄 Reiniciando backend..."
docker compose restart backend

echo "⏳ Aguardando 15 segundos..."
sleep 15

# ═══════════════════════════════════════════════════════════════
# 6. TESTAR ROTA
# ═══════════════════════════════════════════════════════════════

echo ""
echo "🧪 Testando rota de upload..."

# Teste 1: Verificar status
echo "Teste 1: GET /api/knowledge/status"
curl -s http://localhost:8000/api/knowledge/status | head -c 200
echo ""

# Teste 2: Verificar se o endpoint existe
echo ""
echo "Teste 2: Verificando endpoints disponíveis"
curl -s http://localhost:8000/docs | grep -o "knowledge" | head -3
echo ""

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ CORREÇÃO APLICADA!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "🧪 TESTE AGORA:"
echo "   1. Acesse: http://72.60.255.80:3000/admin/upload"
echo "   2. Selecione arquivos"
echo "   3. Faça upload"
echo ""
echo "📋 Se ainda der erro, execute:"
echo "   docker compose logs backend | grep -i knowledge"
echo ""

