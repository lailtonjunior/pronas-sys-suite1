from typing import Dict, List
import google.generativeai as genai
from app.config import settings
from app.ai.rag.embeddings import generate_embedding
from app.ai.rag.vectorstore import search_similar_cases

genai.configure(api_key=settings.GEMINI_API_KEY)

async def suggest_text(field_name: str, field_context: Dict, project_context: Dict) -> Dict:
    """Agente de sugestão de texto usando RAG + Gemini"""
    
    # Buscar casos similares
    query = f"{project_context.get('field', '')} {project_context.get('priority_area', '')} {field_name}"
    query_vector = generate_embedding(query)
    similar_cases = search_similar_cases(query_vector, limit=3)
    
    # Montar contexto RAG
    rag_context = "\n\n".join([
        f"Caso {i+1} (Score: {case.score:.2f}):\n{case.payload.get('text', '')}"
        for i, case in enumerate(similar_cases)
    ])
    
    # Prompt para Gemini
    prompt = f"""Você é um especialista em elaboração de projetos PRONAS/PCD conforme Portaria GM/MS 8.031/2025.

Campo a preencher: {field_name}
Contexto do Projeto:
- Área: {project_context.get('field', '')}
- Área Prioritária: {project_context.get('priority_area', '')}
- Instituição: {project_context.get('institution', '')}

Referências de projetos aprovados:
{rag_context}

Gere uma sugestão profissional, objetiva e alinhada com a legislação para este campo.
Limite: 200 palavras."""

    try:
        model = genai.GenerativeModel('gemini-1.5-flash')
        response = model.generate_content(prompt)
        
        return {
            "suggestion": response.text,
            "confidence": 0.85,
            "references": [{"id": c.id, "score": c.score} for c in similar_cases]
        }
    except Exception as e:
        return {
            "suggestion": "Erro ao gerar sugestão. Tente novamente.",
            "confidence": 0.0,
            "error": str(e)
        }
