from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.database.session import get_db
from app.models.project import Project, ProjectStatus, ProjectField
from app.models.anexo import Anexo
from app.models.user import User
from pydantic import BaseModel

router = APIRouter()

class ProjectCreate(BaseModel):
    title: str
    description: str = ""
    field: ProjectField
    institution_name: str
    institution_cnpj: str
    priority_area: str = ""

@router.post("/")
async def create_project(project: ProjectCreate, db: Session = Depends(get_db)):
    """Criar novo projeto"""
    
    # Buscar primeiro usuário
    user = db.query(User).first()
    if not user:
        raise HTTPException(
            status_code=500, 
            detail="Nenhum usuário encontrado. Execute o script de inicialização."
        )
    
    try:
        # Criar projeto
        db_project = Project(
            title=project.title,
            description=project.description,
            field=project.field,
            institution_name=project.institution_name,
            institution_cnpj=project.institution_cnpj,
            priority_area=project.priority_area,
            owner_id=user.id,
            status=ProjectStatus.DRAFT
        )
        
        db.add(db_project)
        db.commit()
        db.refresh(db_project)
        
        # Criar 7 anexos
        anexos = [
            ("ANEXO_I", "Declaração de Ciência e Concordância"),
            ("ANEXO_II", "Formulário de Apresentação de Projeto"),
            ("ANEXO_III", "Declaração de Capacidade Técnico-Operativa"),
            ("ANEXO_IV", "Modelo de Orçamento"),
            ("ANEXO_V", "Formulário de Equipamentos"),
            ("ANEXO_VI", "Requerimento de Habilitação"),
            ("ANEXO_VII", "Minuta do Termo de Compromisso")
        ]
        
        for tipo, nome in anexos:
            anexo = Anexo(
                project_id=db_project.id,
                tipo=tipo,
                nome=nome,
                dados={},
                completion_score=0
            )
            db.add(anexo)
        
        db.commit()
        
        return {
            "id": db_project.id,
            "title": db_project.title,
            "status": "DRAFT",
            "field": str(db_project.field.value if hasattr(db_project.field, 'value') else db_project.field),
            "completion_percentage": 0
        }
        
    except Exception as e:
        db.rollback()
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Erro: {str(e)}")

@router.get("/")
async def list_projects(db: Session = Depends(get_db)):
    """Listar todos os projetos"""
    projects = db.query(Project).all()
    
    result = []
    for p in projects:
        anexos = db.query(Anexo).filter(Anexo.project_id == p.id).all()
        avg = sum([a.completion_score or 0 for a in anexos]) // len(anexos) if anexos else 0
        
        result.append({
            "id": p.id,
            "title": p.title,
            "status": str(p.status.value if hasattr(p.status, 'value') else p.status),
            "field": str(p.field.value if hasattr(p.field, 'value') else p.field),
            "completion_percentage": avg
        })
    
    return result

@router.get("/{project_id}")
async def get_project(project_id: int, db: Session = Depends(get_db)):
    """Obter projeto por ID"""
    project = db.query(Project).filter(Project.id == project_id).first()
    if not project:
        raise HTTPException(status_code=404, detail="Projeto não encontrado")
    return project

@router.delete("/{project_id}")
async def delete_project(project_id: int, db: Session = Depends(get_db)):
    """Deletar projeto"""
    project = db.query(Project).filter(Project.id == project_id).first()
    if not project:
        raise HTTPException(status_code=404, detail="Projeto não encontrado")
    
    db.delete(project)
    db.commit()
    return {"message": "Projeto deletado"}
