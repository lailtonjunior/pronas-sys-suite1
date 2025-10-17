from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from typing import List
import shutil
from pathlib import Path
import logging

router = APIRouter()
logger = logging.getLogger(__name__)

KNOWLEDGE_BASE_PATH = Path("/app/../knowledge_base")

@router.post("/upload")
async def upload_documentos(
    categoria: str = Form(...),
    files: List[UploadFile] = File(...)
):
    """Upload de múltiplos PDFs para a base de conhecimento"""
    
    # Validar categoria
    categorias_validas = ["portarias", "aprovados", "reprovados", "diligencias", "exemplos"]
    if categoria not in categorias_validas:
        raise HTTPException(status_code=400, detail="Categoria inválida")
    
    # Criar pasta se não existir
    upload_dir = KNOWLEDGE_BASE_PATH / categoria
    upload_dir.mkdir(parents=True, exist_ok=True)
    
    uploaded_files = []
    
    for file in files:
        # Validar extensão
        if not file.filename.lower().endswith(('.pdf', '.docx')):
            continue
        
        # Salvar arquivo
        file_path = upload_dir / file.filename
        
        with file_path.open("wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        
        uploaded_files.append(file.filename)
        logger.info(f"Arquivo salvo: {file_path}")
    
    return {
        "uploaded": len(uploaded_files),
        "files": uploaded_files,
        "categoria": categoria
    }
