from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database.session import get_db
from app.ai.agents.text_agent import suggest_text
from app.ai.agents.validation_agent import validation_agent
from app.ai.agents.case_analyzer import case_analyzer
from pydantic import BaseModel
from typing import Dict, List

router = APIRouter()

class SuggestionRequest(BaseModel):
    field_name: str
    field_context: Dict
    project_context: Dict

class ValidationRequest(BaseModel):
    anexo_data: Dict
    anexo_type: str

class SimilarCasesRequest(BaseModel):
    project_description: str
    field: str = None
    only_approved: bool = False
    limit: int = 5

@router.post("/suggest")
async def get_suggestion(request: SuggestionRequest):
    """Obter sugestão de texto com IA"""
    result = await suggest_text(
        request.field_name,
        request.field_context,
        request.project_context
    )
    return result

@router.post("/validate")
async def validate(request: ValidationRequest):
    """Validar anexo com score de qualidade"""
    result = await validation_agent.validate_anexo(
        request.anexo_data, 
        request.anexo_type
    )
    return result

@router.post("/similar-cases")
async def find_similar_cases(request: SimilarCasesRequest):
    """Buscar casos similares"""
    cases = await case_analyzer.find_similar_cases(
        project_description=request.project_description,
        field=request.field,
        only_approved=request.only_approved,
        limit=request.limit
    )
    return {"cases": cases, "total": len(cases)}

@router.post("/analyze-risks")
async def analyze_risks(project_data: Dict):
    """Analisar riscos baseado em projetos reprovados"""
    analysis = await case_analyzer.analyze_risks(project_data)
    return analysis

@router.get("/health")
async def ai_health():
    """Status dos agentes de IA"""
    return {
        "status": "online",
        "agents": {
            "text_suggestion": "active",
            "validation": "active",
            "case_analyzer": "active",
            "price_search": "pending"
        }
    }
