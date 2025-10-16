from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams, PointStruct
from app.config import settings
import logging

logger = logging.getLogger(__name__)

def get_qdrant_client():
    return QdrantClient(url=settings.QDRANT_URL)

def init_collection():
    client = get_qdrant_client()
    try:
        client.create_collection(
            collection_name=settings.QDRANT_COLLECTION_NAME,
            vectors_config=VectorParams(size=768, distance=Distance.COSINE)
        )
        logger.info(f"✅ Coleção {settings.QDRANT_COLLECTION_NAME} criada")
    except Exception as e:
        logger.info(f"Coleção já existe ou erro: {e}")

def search_similar_cases(query_vector, limit=5):
    client = get_qdrant_client()
    results = client.search(
        collection_name=settings.QDRANT_COLLECTION_NAME,
        query_vector=query_vector,
        limit=limit
    )
    return results
