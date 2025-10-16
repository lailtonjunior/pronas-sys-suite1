import sys
sys.path.append('..')
from app.ai.rag.vectorstore import init_collection

print("🔮 Inicializando coleção Qdrant...")
init_collection()
print("✅ Qdrant configurado!")
