from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database.session import get_db
from app.models.anexo import Anexo
from pydantic import BaseModel
from typing import Dict, Any

router = APIRouter()

class AnexoUpdate(BaseModel):
    dados: Dict[str, Any]

@router.get("/{anexo_id}")
async def get_anexo(anexo_id: int, db: Session = Depends(get_db)):
    anexo = db.query(Anexo).filter(Anexo.id == anexo_id).first()
    if not anexo:
        raise HTTPException(status_code=404, detail="Anexo não encontrado")
    return anexo

@router.put("/{anexo_id}")
async def update_anexo(anexo_id: int, update: AnexoUpdate, db: Session = Depends(get_db)):
    anexo = db.query(Anexo).filter(Anexo.id == anexo_id).first()
    if not anexo:
        raise HTTPException(status_code=404, detail="Anexo não encontrado")
    
    anexo.dados = update.dados
    
    # Calcular completion score
    total_fields = len(update.dados)
    filled_fields = sum(1 for v in update.dados.values() if v)
    anexo.completion_score = int((filled_fields / total_fields * 100)) if total_fields > 0 else 0
    
    db.commit()
    db.refresh(anexo)
    return anexo

@router.get("/project/{project_id}")
async def list_project_anexos(project_id: int, db: Session = Depends(get_db)):
    anexos = db.query(Anexo).filter(Anexo.project_id == project_id).all()
    return anexos
