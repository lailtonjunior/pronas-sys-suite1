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
