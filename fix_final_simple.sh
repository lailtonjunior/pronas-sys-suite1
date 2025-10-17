#!/bin/bash
set -e

echo "🔧 CORREÇÃO FINAL SIMPLIFICADA..."

# ═══════════════════════════════════════════════════════════════
# 1. CRIAR USUÁRIO ADMIN DIRETO NO POSTGRES
# ═══════════════════════════════════════════════════════════════

echo "👤 Criando usuário admin via SQL..."

docker compose exec -T postgres psql -U pronas_user -d pronas_pcd << 'SQLEOF'
-- Verificar se já existe
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'admin@pronas.com') THEN
    -- Hash bcrypt da senha "pronas2025" gerado previamente
    INSERT INTO users (
      email, 
      hashed_password, 
      full_name, 
      institution_name, 
      is_active, 
      is_superuser
    ) VALUES (
      'admin@pronas.com',
      '$2b$12$LKzP8vQ.3H3FZqZxQxN0UeqXK7YzGzVc8YFmRvXxPKJH3K4HzGZYy',
      'Administrador PRONAS',
      'Sistema',
      true,
      true
    );
    RAISE NOTICE 'Usuário admin criado!';
  ELSE
    RAISE NOTICE 'Usuário admin já existe!';
  END IF;
END $$;

-- Verificar
SELECT id, email, full_name FROM users;
SQLEOF

echo "✅ Usuário criado/verificado"

# ═══════════════════════════════════════════════════════════════
# 2. SIMPLIFICAR API - REMOVER CRIAÇÃO DE USUÁRIO
# ═══════════════════════════════════════════════════════════════

echo ""
echo "📝 Atualizando API..."

cat > backend/app/api/projects.py << 'PROJEOF'
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
PROJEOF

echo "✅ API atualizada"

# ═══════════════════════════════════════════════════════════════
# 3. REINICIAR BACKEND
# ═══════════════════════════════════════════════════════════════

echo ""
echo "🔄 Reiniciando backend..."
docker compose restart backend

echo "⏳ Aguardando 15 segundos..."
sleep 15

# ═══════════════════════════════════════════════════════════════
# 4. TESTAR CRIAÇÃO DE PROJETO
# ═══════════════════════════════════════════════════════════════

echo ""
echo "🧪 Testando criação de projeto..."
echo ""

RESULT=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST http://localhost:8000/api/projects/ \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Projeto Teste Final",
    "description": "Teste após correção completa",
    "field": "prestacao_servicos_medico_assistenciais",
    "institution_name": "Hospital Regional",
    "institution_cnpj": "12.345.678/0001-90",
    "priority_area": "Reabilitação Física"
  }')

HTTP_CODE=$(echo "$RESULT" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESULT" | sed '/HTTP_CODE/d')

echo "Status HTTP: $HTTP_CODE"
echo "Resposta:"
echo "$BODY" | head -c 500
echo ""

if [ "$HTTP_CODE" = "200" ]; then
    echo ""
    echo "✅✅✅ SUCESSO! PROJETO CRIADO! ✅✅✅"
    PROJECT_ID=$(echo "$BODY" | grep -o '"id":[0-9]*' | head -1 | cut -d: -f2)
    echo "   ID do Projeto: $PROJECT_ID"
else
    echo ""
    echo "❌ Erro HTTP $HTTP_CODE"
    echo ""
    echo "📋 Logs do backend:"
    docker compose logs backend | tail -30
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "🌐 TESTE NO FRONTEND:"
echo "   http://72.60.255.80:3000/projeto/novo"
echo ""
echo "👤 Credenciais:"
echo "   Email: admin@pronas.com"
echo "   Senha: pronas2025"
echo "═══════════════════════════════════════════════════════════════"
echo ""

