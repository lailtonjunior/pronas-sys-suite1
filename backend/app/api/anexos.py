from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database.session import get_db
from app.models.anexo import Anexo
from app.ai.agents.validation_agent import validation_agent
from pydantic import BaseModel
from typing import Dict, Any

router = APIRouter()

class AnexoUpdate(BaseModel):
    dados: Dict[str, Any]

@router.get("/{anexo_id}")
async def get_anexo(anexo_id: int, db: Session = Depends(get_db)):
    """Obter anexo por ID"""
    anexo = db.query(Anexo).filter(Anexo.id == anexo_id).first()
    if not anexo:
        raise HTTPException(status_code=404, detail="Anexo não encontrado")
    return anexo

@router.put("/{anexo_id}")
async def update_anexo(anexo_id: int, update: AnexoUpdate, db: Session = Depends(get_db)):
    """Atualizar anexo com validação automática"""
    anexo = db.query(Anexo).filter(Anexo.id == anexo_id).first()
    if not anexo:
        raise HTTPException(status_code=404, detail="Anexo não encontrado")
    
    # Atualizar dados
    anexo.dados = update.dados
    
    # Calcular completion score
    total_fields = len(update.dados)
    filled_fields = sum(1 for v in update.dados.values() if v and str(v).strip())
    anexo.completion_score = int((filled_fields / total_fields * 100)) if total_fields > 0 else 0
    
    # Validação automática com IA
    try:
        validation_result = await validation_agent.validate_anexo(update.dados, anexo.tipo)
        anexo.validation_status = validation_result.get('status', 'pending')
        anexo.ai_suggestions = validation_result.get('suggestions', [])
    except Exception as e:
        print(f"Erro na validação: {e}")
        anexo.validation_status = "pending"
    
    db.commit()
    db.refresh(anexo)
    
    return {
        "anexo": anexo,
        "validation": validation_result if 'validation_result' in locals() else None
    }

@router.get("/project/{project_id}")
async def list_project_anexos(project_id: int, db: Session = Depends(get_db)):
    """Listar anexos de um projeto"""
    anexos = db.query(Anexo).filter(Anexo.project_id == project_id).all()
    return anexos

@router.post("/{anexo_id}/validate")
async def validate_anexo_endpoint(anexo_id: int, db: Session = Depends(get_db)):
    """Validar anexo manualmente"""
    anexo = db.query(Anexo).filter(Anexo.id == anexo_id).first()
    if not anexo:
        raise HTTPException(status_code=404, detail="Anexo não encontrado")
    
    validation = await validation_agent.validate_anexo(anexo.dados, anexo.tipo)
    
    return {
        "anexo_id": anexo_id,
        "validation": validation
    }
