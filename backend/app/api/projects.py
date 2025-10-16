from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.database.session import get_db
from app.models.project import Project, ProjectStatus, ProjectField
from app.models.anexo import Anexo
from pydantic import BaseModel

router = APIRouter()

class ProjectCreate(BaseModel):
    title: str
    description: str
    field: ProjectField
    institution_name: str
    institution_cnpj: str
    priority_area: str = None

class ProjectResponse(BaseModel):
    id: int
    title: str
    status: str
    field: str
    completion_percentage: int
    
    class Config:
        from_attributes = True

@router.post("/", response_model=ProjectResponse)
async def create_project(project: ProjectCreate, db: Session = Depends(get_db)):
    db_project = Project(**project.dict(), owner_id=1)  # TODO: Get from token
    db.add(db_project)
    db.commit()
    db.refresh(db_project)
    
    # Criar 7 anexos vazios
    for i in range(1, 8):
        anexo = Anexo(
            project_id=db_project.id,
            tipo=f"ANEXO_{['I','II','III','IV','V','VI','VII'][i-1]}",
            nome=f"Anexo {['I','II','III','IV','V','VI','VII'][i-1]}"
        )
        db.add(anexo)
    
    db.commit()
    
    return {
        "id": db_project.id,
        "title": db_project.title,
        "status": db_project.status,
        "field": db_project.field,
        "completion_percentage": 0
    }

@router.get("/", response_model=List[ProjectResponse])
async def list_projects(db: Session = Depends(get_db)):
    projects = db.query(Project).all()
    return [{
        "id": p.id,
        "title": p.title,
        "status": p.status,
        "field": p.field,
        "completion_percentage": sum([a.completion_score for a in p.anexos]) // 7 if p.anexos else 0
    } for p in projects]

@router.get("/{project_id}")
async def get_project(project_id: int, db: Session = Depends(get_db)):
    project = db.query(Project).filter(Project.id == project_id).first()
    if not project:
        raise HTTPException(status_code=404, detail="Projeto não encontrado")
    return project

@router.delete("/{project_id}")
async def delete_project(project_id: int, db: Session = Depends(get_db)):
    project = db.query(Project).filter(Project.id == project_id).first()
    if not project:
        raise HTTPException(status_code=404, detail="Projeto não encontrado")
    db.delete(project)
    db.commit()
    return {"message": "Projeto deletado com sucesso"}
