#!/bin/bash
set -e

echo "🔧 Corrigindo API de projetos..."

# Atualizar API de projetos para tornar owner_id opcional
cat > backend/app/api/projects.py << 'PROJEOF'
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
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
    """Criar novo projeto - owner_id é opcional"""
    
    # Verificar se existe algum usuário, senão cria um padrão
    user = db.query(User).first()
    
    if not user:
        # Criar usuário padrão automaticamente
        from passlib.context import CryptContext
        pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
        
        user = User(
            email="admin@pronas.com",
            hashed_password=pwd_context.hash("pronas2025"),
            full_name="Administrador PRONAS",
            institution_name="Sistema",
            is_active=True,
            is_superuser=True
        )
        db.add(user)
        db.commit()
        db.refresh(user)
    
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
    
    # Criar 7 anexos vazios
    anexos_config = [
        ("ANEXO_I", "Declaração de Ciência e Concordância"),
        ("ANEXO_II", "Formulário de Apresentação de Projeto"),
        ("ANEXO_III", "Declaração de Capacidade Técnico-Operativa"),
        ("ANEXO_IV", "Modelo de Orçamento"),
        ("ANEXO_V", "Formulário de Equipamentos"),
        ("ANEXO_VI", "Requerimento de Habilitação"),
        ("ANEXO_VII", "Minuta do Termo de Compromisso")
    ]
    
    for tipo, nome in anexos_config:
        anexo = Anexo(
            project_id=db_project.id,
            tipo=tipo,
            nome=nome,
            dados={},
            completion_score=0
        )
        db.add(anexo)
    
    db.commit()
    
    return ProjectResponse(
        id=db_project.id,
        title=db_project.title,
        status=db_project.status.value if hasattr(db_project.status, 'value') else str(db_project.status),
        field=db_project.field.value if hasattr(db_project.field, 'value') else str(db_project.field),
        completion_percentage=0
    )

@router.get("/", response_model=List[ProjectResponse])
async def list_projects(db: Session = Depends(get_db)):
    """Listar todos os projetos"""
    projects = db.query(Project).all()
    
    result = []
    for p in projects:
        # Calcular completion_percentage
        anexos = db.query(Anexo).filter(Anexo.project_id == p.id).all()
        avg_completion = sum([a.completion_score or 0 for a in anexos]) // len(anexos) if anexos else 0
        
        result.append(ProjectResponse(
            id=p.id,
            title=p.title,
            status=p.status.value if hasattr(p.status, 'value') else str(p.status),
            field=p.field.value if hasattr(p.field, 'value') else str(p.field),
            completion_percentage=avg_completion
        ))
    
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
    return {"message": "Projeto deletado com sucesso"}
PROJEOF

echo "✅ API de projetos corrigida"

# Reiniciar backend
echo "🔄 Reiniciando backend..."
docker compose restart backend

echo "⏳ Aguardando 10 segundos..."
sleep 10

# Testar criação de projeto
echo ""
echo "🧪 Testando criação de projeto..."
curl -X POST http://localhost:8000/api/projects/ \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Centro de Reabilitação Teste",
    "description": "Projeto de teste após correção",
    "field": "prestacao_servicos_medico_assistenciais",
    "institution_name": "Hospital Teste",
    "institution_cnpj": "00.000.000/0000-00",
    "priority_area": "Reabilitação"
  }'

echo ""
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ API CORRIGIDA!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "🧪 Agora teste criar um projeto no frontend:"
echo "   http://72.60.255.80:3000/projeto/novo"
echo ""
echo "👤 Usuário admin criado automaticamente:"
echo "   Email: admin@pronas.com"
echo "   Senha: pronas2025"
echo ""

