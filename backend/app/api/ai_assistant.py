from fastapi import APIRouter, HTTPException
from typing import Optional, Dict, List
import logging
from datetime import datetime
from pydantic import BaseModel

from app.ai.agents.intelligent_text_agent import IntelligentTextAgent

router = APIRouter()
text_agent = IntelligentTextAgent()
logger = logging.getLogger(__name__)

# ============================================================================
# MODELS
# ============================================================================

class GenerateFieldRequest(BaseModel):
    field_name: str
    project_context: Dict
    max_length: Optional[int] = 1500

class ProjectContextSimple(BaseModel):
    titulo: str
    instituicao: str
    tipo: Optional[str] = ""
    publico_alvo: Optional[str] = ""

# ============================================================================
# ENDPOINTS
# ============================================================================

@router.post("/generate-field-simple")
async def generate_field_simple(request: GenerateFieldRequest):
    """
    Gera conteúdo contextualizado SEM depender do banco de dados
    (versão simplificada para testes)
    
    Body JSON:
    {
        "field_name": "justificativa",
        "project_context": {
            "titulo": "Nome do projeto",
            "instituicao": "Nome da instituição",
            "tipo": "Tipo do projeto",
            "publico_alvo": "Público alvo"
        },
        "max_length": 1500
    }
    """
    try:
        logger.info(f"📝 Gerando campo '{request.field_name}' (modo simples)")
        
        # Casos similares vazios por enquanto (RAG será integrado depois)
        similar_cases = []
        
        # Gerar texto contextualizado
        result = await text_agent.generate_contextual_text(
            field_name=request.field_name,
            project_context=request.project_context,
            similar_cases=similar_cases,
            max_length=request.max_length
        )
        
        logger.info(f"✅ Geração concluída: {result['provider']} | {result.get('latency_ms', 0)}ms")
        
        return result
        
    except Exception as e:
        logger.error(f"❌ Erro na geração: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Erro ao gerar conteúdo: {str(e)}")

@router.post("/test-generation")
async def test_generation(campo: str = "justificativa"):
    """
    Endpoint de teste rápido para validar geração de IA
    """
    project_context = {
        "titulo": "AMPLIAÇÃO E QUALIFICAÇÃO DOS ATENDIMENTOS EM FISIOTERAPIA",
        "instituicao": "APAE de Colinas - TO",
        "tipo": "Qualificação de Serviços",
        "publico_alvo": "Pessoas com Deficiência Física e Neurológica"
    }
    
    similar_cases = []
    
    logger.info(f"🧪 Teste: gerando campo '{campo}'")
    
    result = await text_agent.generate_contextual_text(
        field_name=campo,
        project_context=project_context,
        similar_cases=similar_cases,
        max_length=800
    )
    
    return result

@router.get("/health")
async def health_check():
    """Verifica health dos providers de IA"""
    health_status = text_agent.get_health_status()
    
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "providers": health_status
    }

# ============================================================================
# ENDPOINT COM BANCO DE DADOS (DESABILITADO ATÉ CORRIGIR IMPORTS)
# ============================================================================

# @router.post("/generate-field")
# async def generate_field_content(
#     field_name: str,
#     project_id: int,
#     db: Session = Depends(get_db)
# ):
#     """
#     Gera conteúdo contextualizado buscando projeto do banco
#     (DESABILITADO - aguardando correção de imports)
#     """
#     pass
