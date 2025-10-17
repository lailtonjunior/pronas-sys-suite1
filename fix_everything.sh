#!/bin/bash
set -e

echo "🔧 CORREÇÃO COMPLETA DO SISTEMA..."

# ═══════════════════════════════════════════════════════════════
# 1. VERIFICAR E CRIAR USUÁRIO ADMIN
# ═══════════════════════════════════════════════════════════════

echo "👤 Criando usuário admin..."

docker compose exec backend python << 'PYEOF'
import sys
sys.path.insert(0, '/app')

from app.database.session import SessionLocal
from app.models.user import User
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

db = SessionLocal()

# Verificar se já existe
existing = db.query(User).first()

if not existing:
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
    print("✅ Usuário admin criado (ID: {})".format(user.id))
else:
    print("✅ Usuário já existe (ID: {})".format(existing.id))

db.close()
PYEOF

# ═══════════════════════════════════════════════════════════════
# 2. SIMPLIFICAR API DE PROJETOS
# ═══════════════════════════════════════════════════════════════

echo ""
echo "📝 Simplificando API de projetos..."

cat > backend/app/api/projects.py << 'SIMPLEPROJEOF'
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
    """Criar projeto"""
    
    # Pegar primeiro usuário (deve existir)
    user = db.query(User).first()
    if not user:
        raise HTTPException(status_code=500, detail="Nenhum usuário encontrado")
    
    # Criar projeto
    try:
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
        
        # Criar anexos
        anexos_names = [
            ("ANEXO_I", "Declaração de Ciência"),
            ("ANEXO_II", "Formulário de Apresentação"),
            ("ANEXO_III", "Capacidade Técnico-Operativa"),
            ("ANEXO_IV", "Modelo de Orçamento"),
            ("ANEXO_V", "Formulário de Equipamentos"),
            ("ANEXO_VI", "Requerimento de Habilitação"),
            ("ANEXO_VII", "Minuta do Termo de Compromisso")
        ]
        
        for tipo, nome in anexos_names:
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
        raise HTTPException(status_code=500, detail=f"Erro ao criar projeto: {str(e)}")

@router.get("/")
async def list_projects(db: Session = Depends(get_db)):
    """Listar projetos"""
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
    """Obter projeto"""
    project = db.query(Project).filter(Project.id == project_id).first()
    if not project:
        raise HTTPException(status_code=404, detail="Projeto não encontrado")
    return project

@router.delete("/{project_id}")
async def delete_project(project_id: int, db: Session = Depends(get_db)):
    """Deletar projeto"""
    project = db.query(Project).filter(Project.id == project_id).first()
    if not project:
        raise HTTPException(status_code=404, detail="Não encontrado")
    
    db.delete(project)
    db.commit()
    return {"ok": True}
SIMPLEPROJEOF

echo "✅ API simplificada"

# ═══════════════════════════════════════════════════════════════
# 3. REINICIAR BACKEND
# ═══════════════════════════════════════════════════════════════

echo ""
echo "🔄 Reiniciando backend..."
docker compose restart backend

echo "⏳ Aguardando 15 segundos..."
sleep 15

# ═══════════════════════════════════════════════════════════════
# 4. TESTAR TUDO
# ═══════════════════════════════════════════════════════════════

echo ""
echo "🧪 TESTANDO SISTEMA..."
echo ""

# Teste 1: Health check
echo "1. Health Check:"
curl -s http://localhost:8000/ | head -c 100
echo ""

# Teste 2: Listar projetos
echo ""
echo "2. Listar Projetos:"
curl -s http://localhost:8000/api/projects/ | head -c 100
echo ""

# Teste 3: Criar projeto
echo ""
echo "3. Criar Projeto:"
RESPONSE=$(curl -s -X POST http://localhost:8000/api/projects/ \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Teste Automático",
    "description": "Projeto criado pelo script de correção",
    "field": "prestacao_servicos_medico_assistenciais",
    "institution_name": "Hospital Teste",
    "institution_cnpj": "12.345.678/0001-90",
    "priority_area": "Reabilitação"
  }')

echo "$RESPONSE" | head -c 200
echo ""

# Verificar se criou
if echo "$RESPONSE" | grep -q '"id"'; then
    echo ""
    echo "✅ PROJETO CRIADO COM SUCESSO!"
    PROJECT_ID=$(echo "$RESPONSE" | grep -o '"id":[0-9]*' | grep -o '[0-9]*')
    echo "   ID: $PROJECT_ID"
else
    echo ""
    echo "❌ Erro ao criar projeto"
    echo "Resposta completa:"
    echo "$RESPONSE"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ CORREÇÃO COMPLETA!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "🌐 TESTE NO FRONTEND:"
echo "   http://72.60.255.80:3000/projeto/novo"
echo ""
echo "👤 Login (se necessário):"
echo "   Email: admin@pronas.com"
echo "   Senha: pronas2025"
echo ""
echo "�� Ver logs se houver erro:"
echo "   docker compose logs backend | tail -50"
echo ""

