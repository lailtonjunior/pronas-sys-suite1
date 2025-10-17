#!/bin/bash
set -e

echo "🤖 Implementando IA Avançada no Backend..."

# ═══════════════════════════════════════════════════════════════
# PARTE 3A: AGENTE DE VALIDAÇÃO INTELIGENTE
# ═══════════════════════════════════════════════════════════════

cat > backend/app/ai/agents/validation_agent.py << 'VALEOF'
"""
Agente de Validação Inteligente
Analisa anexos e retorna score de qualidade + alertas
"""
import google.generativeai as genai
from typing import Dict, List
from app.config import settings
import json
import logging

logger = logging.getLogger(__name__)

genai.configure(api_key=settings.GEMINI_API_KEY)


class ValidationAgent:
    """Agente especializado em validação de anexos PRONAS/PCD"""
    
    def __init__(self):
        self.model = genai.GenerativeModel('gemini-1.5-flash')
    
    async def validate_anexo(self, anexo_data: Dict, anexo_type: str) -> Dict:
        """
        Valida um anexo completo e retorna análise detalhada
        
        Returns:
            {
                "score": 0-100,
                "status": "excellent" | "good" | "needs_improvement" | "critical",
                "missing_fields": [],
                "warnings": [],
                "suggestions": [],
                "strengths": []
            }
        """
        
        if not settings.GEMINI_API_KEY:
            return self._fallback_validation(anexo_data)
        
        try:
            # Contar campos preenchidos
            total_fields = len(anexo_data)
            filled_fields = sum(1 for v in anexo_data.values() if v and str(v).strip())
            completion_rate = (filled_fields / total_fields * 100) if total_fields > 0 else 0
            
            # Prompt especializado
            prompt = self._build_validation_prompt(anexo_data, anexo_type, completion_rate)
            
            # Chamar Gemini
            response = self.model.generate_content(prompt)
            
            # Processar resposta
            return self._parse_validation_response(response.text, completion_rate)
            
        except Exception as e:
            logger.error(f"Erro na validação: {e}")
            return self._fallback_validation(anexo_data)
    
    def _build_validation_prompt(self, data: Dict, tipo: str, completion: float) -> str:
        """Constrói prompt de validação"""
        
        prompt = f"""Você é um especialista em avaliação de projetos PRONAS/PCD conforme Portaria GM/MS 8.031/2025.

Analise o seguinte {tipo}:

Taxa de conclusão: {completion:.1f}%
Campos preenchidos: {sum(1 for v in data.values() if v)}
Total de campos: {len(data)}

DADOS DO ANEXO:
{json.dumps(data, indent=2, ensure_ascii=False)[:2000]}

Avalie com base nos critérios da Portaria:
1. Completude das informações
2. Clareza e objetividade
3. Conformidade legal
4. Viabilidade técnica
5. Detalhamento adequado

Forneça uma análise estruturada com:
- Score de qualidade (0-100)
- Status (excellent/good/needs_improvement/critical)
- Campos faltantes ou incompletos
- Alertas e avisos importantes
- Sugestões de melhoria
- Pontos fortes identificados

Responda em formato JSON:
{{
  "score": 0-100,
  "status": "excellent|good|needs_improvement|critical",
  "missing_fields": ["campo1", "campo2"],
  "warnings": ["alerta1", "alerta2"],
  "suggestions": ["sugestão1", "sugestão2"],
  "strengths": ["ponto forte 1", "ponto forte 2"]
}}
"""
        return prompt
    
    def _parse_validation_response(self, response_text: str, completion: float) -> Dict:
        """Processa resposta do Gemini"""
        
        try:
            # Tentar extrair JSON
            import re
            json_match = re.search(r'\{[^}]+\}', response_text, re.DOTALL)
            
            if json_match:
                result = json.loads(json_match.group())
                
                # Ajustar score baseado na conclusão
                base_score = result.get('score', 50)
                adjusted_score = int((base_score * 0.7) + (completion * 0.3))
                result['score'] = max(0, min(100, adjusted_score))
                
                return result
        except:
            pass
        
        # Fallback: criar validação baseada em completion
        if completion >= 80:
            status = "good"
            score = int(completion * 0.9)
        elif completion >= 50:
            status = "needs_improvement"
            score = int(completion * 0.7)
        else:
            status = "critical"
            score = int(completion * 0.5)
        
        return {
            "score": score,
            "status": status,
            "missing_fields": [],
            "warnings": ["Complete mais campos para melhorar a avaliação"],
            "suggestions": ["Preencha todos os campos obrigatórios", "Revise as informações inseridas"],
            "strengths": [] if completion < 30 else ["Progresso inicial bom"]
        }
    
    def _fallback_validation(self, data: Dict) -> Dict:
        """Validação simples quando IA não disponível"""
        
        filled = sum(1 for v in data.values() if v)
        total = len(data)
        score = int((filled / total * 100)) if total > 0 else 0
        
        if score >= 80:
            status = "good"
            message = "Anexo bem preenchido"
        elif score >= 50:
            status = "needs_improvement"
            message = "Preencha mais campos"
        else:
            status = "critical"
            message = "Anexo incompleto"
        
        return {
            "score": score,
            "status": status,
            "missing_fields": [],
            "warnings": [message],
            "suggestions": ["Configure GEMINI_API_KEY para validação avançada"],
            "strengths": []
        }


# Instância global
validation_agent = ValidationAgent()
VALEOF

echo "✅ Agente de validação criado"

# ═══════════════════════════════════════════════════════════════
# PARTE 3B: AGENTE DE ANÁLISE DE CASOS
# ═══════════════════════════════════════════════════════════════

cat > backend/app/ai/agents/case_analyzer.py << 'CASEEOF'
"""
Agente de Análise de Casos Históricos
Busca e compara com projetos aprovados/reprovados
"""
from typing import Dict, List
from app.ai.rag.embeddings import generate_embedding
from app.ai.rag.vectorstore import search_similar_cases
from app.database.session import SessionLocal
from app.models.historical_case import HistoricalCase
import logging

logger = logging.getLogger(__name__)


class CaseAnalyzerAgent:
    """Analisa casos similares para fornecer insights"""
    
    async def find_similar_cases(
        self, 
        project_description: str, 
        field: str = None,
        only_approved: bool = False,
        limit: int = 5
    ) -> List[Dict]:
        """
        Busca casos similares usando RAG
        
        Args:
            project_description: Descrição do projeto
            field: Área do projeto
            only_approved: Apenas casos aprovados
            limit: Número máximo de casos
        
        Returns:
            Lista de casos similares com análise
        """
        
        try:
            # Gerar embedding da descrição
            query_text = f"{field or ''} {project_description}"
            query_vector = generate_embedding(query_text)
            
            # Buscar casos similares no Qdrant
            similar_cases = search_similar_cases(query_vector, limit=limit * 2)
            
            # Filtrar e formatar resultados
            db = SessionLocal()
            results = []
            
            for case in similar_cases:
                case_id = case.id
                historical = db.query(HistoricalCase).filter(
                    HistoricalCase.id == case_id
                ).first()
                
                if not historical:
                    continue
                
                # Filtrar por aprovação se necessário
                if only_approved and not historical.is_approved:
                    continue
                
                results.append({
                    "id": historical.id,
                    "title": historical.project_title,
                    "institution": historical.institution_name,
                    "field": historical.field,
                    "approved": historical.is_approved,
                    "score": historical.score,
                    "similarity": float(case.score),
                    "summary": historical.summary[:200],
                    "key_points": historical.key_points or [],
                    "rejection_reasons": historical.rejection_reasons or []
                })
                
                if len(results) >= limit:
                    break
            
            db.close()
            return results
            
        except Exception as e:
            logger.error(f"Erro ao buscar casos similares: {e}")
            return []
    
    async def analyze_risks(self, project_data: Dict) -> Dict:
        """
        Analisa riscos baseado em projetos reprovados
        
        Returns:
            {
                "risk_level": "low" | "medium" | "high",
                "common_mistakes": [],
                "recommendations": []
            }
        """
        
        try:
            # Buscar casos reprovados similares
            rejected_cases = await self.find_similar_cases(
                project_description=project_data.get('description', ''),
                field=project_data.get('field'),
                only_approved=False,
                limit=3
            )
            
            rejected = [c for c in rejected_cases if not c['approved']]
            
            if not rejected:
                return {
                    "risk_level": "low",
                    "common_mistakes": [],
                    "recommendations": ["Continue com boas práticas"]
                }
            
            # Extrair motivos de reprovação
            all_reasons = []
            for case in rejected:
                all_reasons.extend(case.get('rejection_reasons', []))
            
            # Determinar nível de risco
            risk_level = "high" if len(rejected) >= 2 else "medium"
            
            return {
                "risk_level": risk_level,
                "common_mistakes": list(set(all_reasons[:5])),
                "recommendations": [
                    "Revise o orçamento detalhadamente",
                    "Garanta objetivos mensuráveis",
                    "Documente a qualificação da equipe",
                    "Detalhe a metodologia"
                ]
            }
            
        except Exception as e:
            logger.error(f"Erro ao analisar riscos: {e}")
            return {
                "risk_level": "unknown",
                "common_mistakes": [],
                "recommendations": []
            }


# Instância global
case_analyzer = CaseAnalyzerAgent()
CASEEOF

echo "✅ Agente de análise de casos criado"

# ═══════════════════════════════════════════════════════════════
# PARTE 3C: ATUALIZAR API COM NOVOS ENDPOINTS
# ═══════════════════════════════════════════════════════════════

cat > backend/app/api/ai_assistant.py << 'AIAPIEOF'
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
AIAPIEOF

echo "✅ API de IA atualizada"

# ═══════════════════════════════════════════════════════════════
# PARTE 4: ATUALIZAR API DE ANEXOS COM VALIDAÇÃO AUTOMÁTICA
# ═══════════════════════════════════════════════════════════════

cat > backend/app/api/anexos.py << 'ANEXOAPIEOF'
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
ANEXOAPIEOF

echo "✅ API de anexos atualizada com validação"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ IA AVANÇADA IMPLEMENTADA NO BACKEND!"
echo "═══════════════════════════════════════════════════════════════"

