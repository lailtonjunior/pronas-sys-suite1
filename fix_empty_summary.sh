#!/bin/bash
set -e

echo "🔧 CORRIGINDO ACESSO AOS DADOS DOS CASOS"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Verificar estrutura dos dados no Qdrant
echo "1️⃣ Verificando estrutura dos casos no Qdrant:"
docker compose exec -T backend python3 << 'CHECKDATA'
from app.ai.rag.embeddings import generate_embedding
from app.ai.rag.vectorstore import search_similar_cases

query_vector = generate_embedding("fisioterapia APAE")
cases = search_similar_cases(query_vector, limit=3)

print(f"\nEncontrados {len(cases)} casos")
print("\nEstrutura do payload:")

for i, case in enumerate(cases[:2], 1):
    print(f"\nCaso {i}:")
    print(f"  ID: {case.id}")
    print(f"  Score: {case.score:.3f}")
    print(f"  Payload keys: {list(case.payload.keys())}")
    
    # Ver conteúdo de cada campo
    for key in ['summary', 'text', 'text_preview', 'full_text']:
        val = case.payload.get(key)
        if val:
            print(f"  {key}: {val[:100]}...")
        else:
            print(f"  {key}: VAZIO")

CHECKDATA

echo ""
echo "═══════════════════════════════════════════════════════════════"

