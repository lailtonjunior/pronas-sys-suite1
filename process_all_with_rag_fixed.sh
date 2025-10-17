#!/bin/bash
set -e

echo "🤖 PROCESSAMENTO COMPLETO COM RAG..."
echo "═══════════════════════════════════════════════════════════════"
echo ""

cd /root/pronas-sys-suite1

# 1. Contar PDFs
echo "📊 Contagem de PDFs:"
TOTAL=$(docker compose exec backend find /knowledge_base -name "*.pdf" -type f 2>/dev/null | wc -l)
echo "   🎯 Total: $TOTAL PDFs"
echo ""

if [ "$TOTAL" -eq 0 ]; then
    echo "⚠️  Nenhum PDF encontrado!"
    exit 0
fi

# 2. Processar com RAG
docker compose exec -T backend python3 << 'PYEOF'
import sys
sys.path.insert(0, '/app')

from pathlib import Path
from app.database.session import SessionLocal
from app.models.historical_case import HistoricalCase
from app.ai.rag.embeddings import generate_embedding
from app.ai.rag.vectorstore import get_qdrant_client
from app.config import settings
from qdrant_client.models import PointStruct
import PyPDF2
import uuid
import re

print("🤖 Processamento com RAG\n")

db = SessionLocal()
qdrant = get_qdrant_client()
knowledge_base = Path("/knowledge_base")

# Inicializar coleção se não existir
try:
    qdrant.get_collection(settings.QDRANT_COLLECTION_NAME)
    print(f"✅ Coleção '{settings.QDRANT_COLLECTION_NAME}' pronta\n")
except:
    from app.ai.rag.vectorstore import init_collection
    init_collection()
    print(f"✅ Coleção criada\n")

def extract_text(pdf_path):
    try:
        with open(pdf_path, 'rb') as file:
            pdf = PyPDF2.PdfReader(file)
            return "".join([page.extract_text() for page in pdf.pages])
    except:
        return ""

total_db = 0
total_rag = 0

for folder in ["aprovados", "reprovados", "diligencias", "portarias"]:
    folder_path = knowledge_base / folder
    if not folder_path.exists():
        continue
    
    pdfs = list(folder_path.glob("*.pdf"))
    if not pdfs:
        continue
    
    print(f"📁 {folder.upper()}: {len(pdfs)} PDFs")
    
    for pdf in pdfs:
        print(f"   {pdf.name[:45]}... ", end="", flush=True)
        
        try:
            # Verificar duplicata
            if db.query(HistoricalCase).filter_by(project_title=pdf.stem[:200]).first():
                print("⏭️")
                continue
            
            # Extrair texto
            text = extract_text(pdf)
            if len(text) < 50:
                print("⚠️  vazio")
                continue
            
            # Classificar
            is_approved = folder == "aprovados"
            score = 85 if is_approved else 40 if folder == "reprovados" else 60
            
            inst_match = re.search(r'(APAE|Associação)[^\n]{0,60}', text[:2000], re.I)
            inst = inst_match.group(0).strip() if inst_match else "Instituição"
            
            # Salvar no PostgreSQL
            case = HistoricalCase(
                project_title=pdf.stem[:200],
                institution_name=inst[:200],
                field="prestacao_servicos_medico_assistenciais",
                priority_area="Reabilitação",
                is_approved=is_approved,
                score=score,
                summary=text[:500],
                key_points=[],
                rejection_reasons=[]
            )
            
            db.add(case)
            db.commit()
            db.refresh(case)
            total_db += 1
            
            # Gerar embedding e indexar no Qdrant
            try:
                embedding = generate_embedding(text[:3000])
                
                point = PointStruct(
                    id=str(uuid.uuid4()),
                    vector=embedding.tolist(),
                    payload={
                        "case_id": case.id,
                        "title": case.project_title,
                        "institution": inst,
                        "is_approved": is_approved,
                        "score": score,
                        "text": text[:300]
                    }
                )
                
                qdrant.upsert(
                    collection_name=settings.QDRANT_COLLECTION_NAME,
                    points=[point]
                )
                
                total_rag += 1
                print(f"✅ ID:{case.id} RAG")
                
            except Exception as e:
                print(f"✅ ID:{case.id} (⚠️ RAG: {str(e)[:20]})")
            
        except Exception as e:
            print(f"❌ {str(e)[:30]}")

db.close()

print(f"\n{'='*70}")
print(f"✅ PROCESSAMENTO CONCLUÍDO!")
print(f"   • {total_db} documentos salvos no PostgreSQL")
print(f"   • {total_rag} documentos indexados no Qdrant (RAG)")
print(f"{'='*70}")

PYEOF

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "📊 ESTATÍSTICAS FINAIS"
echo "═══════════════════════════════════════════════════════════════"
echo ""

TOTAL_DB=$(docker compose exec -T postgres psql -U pronas_user -d pronas_pcd -t -c "SELECT COUNT(*) FROM historical_cases;" | tr -d ' ')
APROVADOS=$(docker compose exec -T postgres psql -U pronas_user -d pronas_pcd -t -c "SELECT COUNT(*) FROM historical_cases WHERE is_approved = true;" | tr -d ' ')
REPROVADOS=$(docker compose exec -T postgres psql -U pronas_user -d pronas_pcd -t -c "SELECT COUNT(*) FROM historical_cases WHERE is_approved = false;" | tr -d ' ')

echo "📊 Base de Conhecimento:"
echo "   • Total: $TOTAL_DB casos"
echo "   • Aprovados: $APROVADOS"
echo "   • Reprovados: $REPROVADOS"
echo ""

echo "🎉 SISTEMA PRONTO!"
echo ""
echo "🧪 Teste a IA agora:"
echo "   1. Acesse: http://72.60.255.80:3000/projeto/6/editar"
echo "   2. Crie/edite um anexo"
echo "   3. Clique no botão 'IA' 🤖"
echo "   4. A IA vai sugerir com base nos $TOTAL_DB casos!"
echo ""

