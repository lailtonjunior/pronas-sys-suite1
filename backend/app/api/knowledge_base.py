from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from typing import List
import shutil
from pathlib import Path
import logging

router = APIRouter()
logger = logging.getLogger(__name__)

# Path correto dentro do container
KNOWLEDGE_BASE = Path("/app/knowledge_base")

@router.post("/upload")
async def upload_documentos(
    categoria: str = Form(...),
    files: List[UploadFile] = File(...)
):
    """Upload de múltiplos PDFs"""
    
    logger.info(f"📤 Upload iniciado - Categoria: {categoria}, Arquivos: {len(files)}")
    
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
    
    # Criar diretório se não existir
    upload_dir.mkdir(parents=True, exist_ok=True)
    
    logger.info(f"📁 Salvando em: {upload_dir}")
    
    uploaded = []
    errors = []
    
    for file in files:
        if not file.filename.lower().endswith(('.pdf', '.docx')):
            logger.warning(f"⚠️ Ignorado (formato inválido): {file.filename}")
            continue
        
        file_path = upload_dir / file.filename
        
        try:
            with file_path.open("wb") as buffer:
                content = await file.read()
                buffer.write(content)
            
            uploaded.append(file.filename)
            logger.info(f"✅ SALVO: {file.filename} em {file_path}")
            
        except Exception as e:
            error_msg = f"Erro ao salvar {file.filename}: {str(e)}"
            logger.error(f"❌ {error_msg}")
            errors.append(error_msg)
    
    logger.info(f"🎉 Upload concluído: {len(uploaded)}/{len(files)} arquivos")
    
    return {
        "uploaded": len(uploaded),
        "files": uploaded,
        "errors": errors,
        "categoria": categoria,
        "pasta": str(upload_dir)
    }

@router.get("/status")
async def get_status():
    """Status da base de conhecimento"""
    
    stats = {}
    for folder in ["aprovados", "reprovados", "diligencias", "portarias", "exemplos"]:
        folder_path = KNOWLEDGE_BASE / folder
        if folder_path.exists():
            pdfs = list(folder_path.glob("*.pdf"))
            stats[folder] = {
                "count": len(pdfs),
                "files": [p.name for p in pdfs[:5]]  # Primeiros 5
            }
        else:
            stats[folder] = {"count": 0, "files": []}
    
    return {
        "total": sum(s["count"] for s in stats.values()),
        "by_category": stats,
        "base_path": str(KNOWLEDGE_BASE)
    }

@router.post("/process")
async def process_documents():
    """Processar documentos com IA (endpoint para compatibilidade)"""
    return {
        "status": "ok",
        "message": "Use ./import_now.sh no servidor para processar"
    }
