from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database.session import get_db
from app.ai.agents.text_agent import suggest_text
from app.ai.agents.validation_agent import validate_anexo
from pydantic import BaseModel
from typing import Dict

router = APIRouter()

class SuggestionRequest(BaseModel):
    field_name: str
    field_context: Dict
    project_context: Dict

class ValidationRequest(BaseModel):
    anexo_data: Dict
    anexo_type: str

@router.post("/suggest")
async def get_suggestion(request: SuggestionRequest):
    result = await suggest_text(
        request.field_name,
        request.field_context,
        request.project_context
    )
    return result

@router.post("/validate")
async def validate(request: ValidationRequest):
    result = await validate_anexo(request.anexo_data, request.anexo_type)
    return result

@router.get("/health")
async def ai_health():
    return {"status": "online", "agents": ["text", "validation", "price", "case_analyzer"]}
