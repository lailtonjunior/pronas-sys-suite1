from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams, PointStruct
from app.config import settings
import logging

logger = logging.getLogger(__name__)

# Nome da coleção
COLLECTION_NAME = settings.QDRANT_COLLECTION_NAME if hasattr(settings, 'QDRANT_COLLECTION_NAME') else "pronas_cases"

def get_qdrant_client():
    """Retorna cliente Qdrant"""
    return QdrantClient(
        url=settings.QDRANT_URL,
        api_key=settings.QDRANT_API_KEY if hasattr(settings, 'QDRANT_API_KEY') else None,
        timeout=30
    )

# Cliente global
qdrant_client = get_qdrant_client()

def init_collection():
    """Inicializa coleção no Qdrant"""
    try:
        client = get_qdrant_client()
        
        # Tentar pegar coleção existente
        try:
            client.get_collection(COLLECTION_NAME)
            logger.info(f"✅ Coleção '{COLLECTION_NAME}' já existe")
            return True
        except:
            pass
        
        # Criar nova coleção
        client.create_collection(
            collection_name=COLLECTION_NAME,
            vectors_config=VectorParams(
                size=768,  # Dimensão do embedding do Gemini
                distance=Distance.COSINE
            )
        )
        logger.info(f"✅ Coleção '{COLLECTION_NAME}' criada")
        return True
        
    except Exception as e:
        logger.error(f"❌ Erro ao inicializar Qdrant: {e}")
        return False

def search_similar_cases(query_vector, limit=5):
    """Busca casos similares no Qdrant"""
    try:
        client = get_qdrant_client()
        results = client.search(
            collection_name=COLLECTION_NAME,
            query_vector=query_vector if isinstance(query_vector, list) else query_vector.tolist(),
            limit=limit
        )
        return results
    except Exception as e:
        logger.error(f"Erro na busca: {e}")
        return []

# Exportar tudo
__all__ = [
    'qdrant_client',
    'get_qdrant_client', 
    'COLLECTION_NAME', 
    'init_collection', 
    'search_similar_cases'
]
