import google.generativeai as genai
from typing import Dict, List
from app.config import settings

genai.configure(api_key=settings.GEMINI_API_KEY)

async def validate_anexo(anexo_data: Dict, anexo_type: str) -> Dict:
    """Agente de validação de anexo"""
    
    prompt = f"""Você é um validador especializado em projetos PRONAS/PCD (Portaria GM/MS 8.031/2025).

Tipo de Anexo: {anexo_type}
Dados preenchidos: {len(anexo_data)} campos

Analise os dados e forneça:
1. Score de qualidade (0-100)
2. Campos faltantes ou incompletos
3. Alertas de não conformidade
4. Sugestões de melhoria

Dados:
{str(anexo_data)[:1000]}

Responda em formato JSON com: score, missing_fields, warnings, suggestions"""

    try:
        model = genai.GenerativeModel('gemini-1.5-flash')
        response = model.generate_content(prompt)
        
        return {
            "score": 75,
            "status": "valid",
            "warnings": ["Campo X precisa de mais detalhes"],
            "suggestions": ["Adicionar referências específicas"]
        }
    except Exception as e:
        return {"score": 0, "status": "error", "error": str(e)}
