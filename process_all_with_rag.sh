#!/bin/bash
set -e

echo "🤖 PROCESSAMENTO COMPLETO COM RAG..."
echo "═══════════════════════════════════════════════════════════════"
echo ""

cd /root/pronas-sys-suite1

# 1. Contar PDFs em todas as pastas
echo "📊 Contagem de PDFs:"
APROVADOS=$(docker compose exec backend find /knowledge_base/aprovados -name "*.pdf" 2>/dev/null | wc -l)
REPROVADOS=$(docker compose exec backend find /knowledge_base/reprovados -name "*.pdf" 2>/dev/null | wc -l)
DILIGENCIAS=$(docker compose exec backend find /knowledge_base/diligencias -name "*.pdf" 2>/dev/null | wc -l)
PORTARIAS=$(docker compose exec backend find /knowledge_base/portarias -name "*.pdf" 2>/dev/null | wc -l)

echo "   ✅ Aprovados:    $APROVADOS PDFs"
echo "   ❌ Reprovados:   $REPROVADOS PDFs"
echo "   ⚠️  Diligências:  $DILIGENCIAS PDFs"
echo "   📋 Portarias:    $PORTARIAS PDFs"

TOTAL=$((APROVADOS + REPROVADOS + DILIGENCIAS + PORTARIAS))
echo ""
echo "   🎯 TOTAL: $TOTAL PDFs para processar"
echo ""

if [ "$TOTAL" -eq 0 ]; then
    echo "⚠️  Nenhum PDF encontrado!"
    exit 0
fi

# 2. Processar TODOS com IA + RAG
echo "🔄 Processando com IA e gerando embeddings..."
echo ""

docker compose exec -T backend python3 << 'PYEOF'
import sys
sys.path.insert(0, '/app')

from pathlib import Path
from app.database.session import SessionLocal
from app.models.historical_case import HistoricalCase
from app.ai.rag.embeddings import generate_embedding
from app.ai.rag.vectorstore import qdrant_client, COLLECTION_NAME
from qdrant_client.models import PointStruct
import PyPDF2
import uuid
import re

print("🤖 Sistema de Importação com RAG\n")

db = SessionLocal()
knowledge_base = Path("/knowledge_base")

def extract_text(pdf_path):
    try:
        with open(pdf_path, 'rb') as file:
            pdf = PyPDF2.PdfReader(file)
            text = ""
            for page in pdf.pages:
                text += page.extract_text() + "\n"
            return text
    except:
        return ""

def classify_document(text, filename, folder):
    text_lower = text.lower()
    
    # Detectar tipo de projeto
    if any(word in text_lower for word in ["fisioterapia", "atendimento", "médico", "reabilitação"]):
        tipo = "prestacao_servicos_medico_assistenciais"
    elif any(word in text_lower for word in ["capacitação", "treinamento", "curso"]):
        tipo = "formacao_treinamento_recursos_humanos"
    elif any(word in text_lower for word in ["pesquisa", "estudo", "científico"]):
        tipo = "realizacao_pesquisas"
    else:
        tipo = "prestacao_servicos_medico_assistenciais"
    
    # Status baseado na pasta
    if folder == "aprovados":
        is_approved = True
        score = 85
    elif folder == "reprovados":
        is_approved = False
        score = 35
    elif folder == "diligencias":
        is_approved = None
        score = 60
    else:
        is_approved = None
        score = 70
    
    # Extrair instituição
    inst_match = re.search(r'(APAE|Associação)[^\n]{0,60}', text[:2000], re.IGNORECASE)
    instituicao = inst_match.group(0).strip() if inst_match else "Instituição"
    
    return tipo, is_approved, score, instituicao[:200]

total_processed = 0
total_rag = 0

for folder in ["aprovados", "reprovados", "diligencias", "portarias"]:
    folder_path = knowledge_base / folder
    if not folder_path.exists():
        continue
    
    pdfs = list(folder_path.glob("*.pdf"))
    if not pdfs:
        continue
    
    print(f"\n📁 {folder.upper()}: {len(pdfs)} PDFs")
    print("-" * 60)
    
    for pdf in pdfs:
        print(f"   📄 {pdf.name[:50]}... ", end="", flush=True)
        
        try:
            # Extrair texto
            text = extract_text(pdf)
            
            if len(text) < 50:
                print("⚠️  vazio")
                continue
            
            # Classificar
            tipo, is_approved, score, instituicao = classify_document(text, pdf.name, folder)
            
            # Verificar se já existe
            existing = db.query(HistoricalCase).filter(
                HistoricalCase.project_title == pdf.stem[:200]
            ).first()
            
            if existing:
                print("⏭️  já existe")
                continue
            
            # Salvar no banco
            case = HistoricalCase(
                project_title=pdf.stem[:200],
                institution_name=instituicao,
                field=tipo,
                priority_area="Reabilitação e Habilitação",
                is_approved=is_approved,
                score=score,
                summary=text[:500],
                key_points=[],
                rejection_reasons=[]
            )
            
            db.add(case)
            db.commit()
            db.refresh(case)
            
            total_processed += 1
            
            # Gerar embedding e indexar no Qdrant
            try:
                # Usar primeiros 3000 caracteres para embedding
                embedding_text = text[:3000]
                embedding = generate_embedding(embedding_text)
                
                # Criar ponto no Qdrant
                point = PointStruct(
                    id=str(uuid.uuid4()),
                    vector=embedding.tolist(),
                    payload={
                        "case_id": case.id,
                        "title": case.project_title,
                        "institution": instituicao,
                        "field": tipo,
                        "is_approved": is_approved,
                        "score": score,
                        "text_preview": text[:300]
                    }
                )
                
                qdrant_client.upsert(
                    collection_name=COLLECTION_NAME,
                    points=[point]
                )
                
                total_rag += 1
                print(f"✅ RAG (ID: {case.id})")
                
            except Exception as e:
                print(f"✅ DB (⚠️ RAG falhou: {str(e)[:30]})")
            
        except Exception as e:
            print(f"❌ {str(e)[:40]}")

db.close()

print("\n" + "="*60)
print(f"✅ Processamento concluído!")
print(f"   • {total_processed} documentos salvos no PostgreSQL")
print(f"   • {total_rag} documentos indexados no Qdrant (RAG)")
print("="*60)

PYEOF

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "📊 ESTATÍSTICAS FINAIS"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Contar casos no banco
TOTAL_DB=$(docker compose exec -T postgres psql -U pronas_user -d pronas_pcd -t -c "SELECT COUNT(*) FROM historical_cases;" | tr -d ' ')
APROVADOS_DB=$(docker compose exec -T postgres psql -U pronas_user -d pronas_pcd -t -c "SELECT COUNT(*) FROM historical_cases WHERE is_approved = true;" | tr -d ' ')
REPROVADOS_DB=$(docker compose exec -T postgres psql -U pronas_user -d pronas_pcd -t -c "SELECT COUNT(*) FROM historical_cases WHERE is_approved = false;" | tr -d ' ')

echo "📊 Banco PostgreSQL:"
echo "   • Total de casos: $TOTAL_DB"
echo "   • Aprovados: $APROVADOS_DB"
echo "   • Reprovados: $REPROVADOS_DB"
echo ""

echo "🎉 SISTEMA RAG COMPLETO!"
echo ""
echo "🧪 Teste agora:"
echo "   1. Acesse: http://72.60.255.80:3000/projeto/6/editar"
echo "   2. Clique em um anexo"
echo "   3. Clique no botão 'IA' ao lado de um campo"
echo "   4. A IA vai sugerir com base nos $TOTAL_DB casos!"
echo ""

