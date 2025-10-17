#!/bin/bash
set -e

echo "🤖 PROCESSANDO DOCUMENTOS COM IA..."
echo "═══════════════════════════════════════════════════════════════"
echo ""

cd /root/pronas-sys-suite1

# Contar arquivos
TOTAL=$(docker compose exec backend find /knowledge_base -name "*.pdf" | wc -l)
echo "📊 Total de PDFs encontrados: $TOTAL"
echo ""

if [ "$TOTAL" -eq 0 ]; then
    echo "⚠️  Nenhum PDF encontrado para processar!"
    exit 0
fi

echo "🔄 Iniciando processamento..."
echo ""

# Processar com Python + IA
docker compose exec -T backend python3 << 'PYEOF'
import sys
sys.path.insert(0, '/app')

from pathlib import Path
import PyPDF2
import json
from app.database.session import SessionLocal
from app.models.historical_case import HistoricalCase
from app.ai.rag.embeddings import generate_embedding
from app.ai.rag.vectorstore import qdrant_client, COLLECTION_NAME
from qdrant_client.models import PointStruct
import uuid

print("📚 Importador de Documentos PRONAS/PCD")
print("="*60)

db = SessionLocal()
knowledge_base = Path("/knowledge_base")

# Função para extrair texto de PDF
def extract_text_from_pdf(pdf_path):
    try:
        text = ""
        with open(pdf_path, 'rb') as file:
            pdf = PyPDF2.PdfReader(file)
            for page in pdf.pages:
                text += page.extract_text() + "\n"
        return text
    except Exception as e:
        print(f"⚠️  Erro ao extrair {pdf_path.name}: {e}")
        return ""

# Classificar documento
def classify_document(text, filename):
    text_lower = text.lower()
    filename_lower = filename.lower()
    
    # Detectar tipo
    if any(word in text_lower for word in ["fisioterapia", "atendimento", "médico", "clínico", "terapia"]):
        tipo = "prestacao_servicos_medico_assistenciais"
    elif any(word in text_lower for word in ["capacitação", "treinamento", "curso", "formação"]):
        tipo = "formacao_treinamento_recursos_humanos"
    elif any(word in text_lower for word in ["pesquisa", "estudo", "científico"]):
        tipo = "realizacao_pesquisas"
    else:
        tipo = "prestacao_servicos_medico_assistenciais"
    
    # Detectar status
    if any(word in text_lower for word in ["aprovado", "deferido"]):
        is_approved = True
    elif any(word in text_lower for word in ["indeferido", "reprovado"]):
        is_approved = False
    else:
        is_approved = None
    
    # Extrair instituição
    import re
    inst_match = re.search(r'(APAE|Associação)[^\n]{0,50}', text[:2000], re.IGNORECASE)
    instituicao = inst_match.group(0) if inst_match else "Instituição não identificada"
    
    return tipo, is_approved, instituicao

# Processar cada pasta
folders = ["aprovados", "reprovados", "diligencias", "portarias"]
total_imported = 0

for folder in folders:
    folder_path = knowledge_base / folder
    if not folder_path.exists():
        continue
    
    pdfs = list(folder_path.glob("*.pdf"))
    if not pdfs:
        continue
    
    print(f"\n📁 Processando: {folder} ({len(pdfs)} PDFs)")
    
    for pdf_path in pdfs:
        try:
            print(f"   📄 {pdf_path.name}...", end=" ")
            
            # Extrair texto
            text = extract_text_from_pdf(pdf_path)
            if not text or len(text) < 50:
                print("⚠️  Texto vazio, pulando")
                continue
            
            # Classificar
            tipo, is_approved, instituicao = classify_document(text, pdf_path.name)
            
            # Determinar score baseado em pasta
            if folder == "aprovados":
                score = 85
                is_approved = True
            elif folder == "reprovados":
                score = 40
                is_approved = False
            else:
                score = 70
            
            # Salvar no banco
            case = HistoricalCase(
                project_title=pdf_path.stem[:200],
                institution_name=instituicao[:200],
                field=tipo,
                priority_area="Geral",
                is_approved=is_approved,
                score=score,
                summary=text[:500],
                key_points=[],
                rejection_reasons=[]
            )
            
            db.add(case)
            db.commit()
            db.refresh(case)
            
            # Gerar embedding e indexar no Qdrant
            try:
                embedding = generate_embedding(text[:3000])
                
                point = PointStruct(
                    id=str(uuid.uuid4()),
                    vector=embedding.tolist(),
                    payload={
                        "case_id": case.id,
                        "title": case.project_title,
                        "field": tipo,
                        "is_approved": is_approved,
                        "score": score,
                        "text": text[:500]
                    }
                )
                
                qdrant_client.upsert(
                    collection_name=COLLECTION_NAME,
                    points=[point]
                )
                
                print("✅")
                total_imported += 1
                
            except Exception as e:
                print(f"⚠️ Erro no embedding: {e}")
                
        except Exception as e:
            print(f"❌ Erro: {e}")

db.close()

print("\n" + "="*60)
print(f"✅ PROCESSAMENTO CONCLUÍDO!")
print(f"   • {total_imported} documentos importados e indexados")
print("="*60)

PYEOF

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "🎉 IMPORTAÇÃO FINALIZADA!"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Verificar banco
echo "📊 Verificando banco de dados..."
docker compose exec postgres psql -U pronas_user -d pronas_pcd -t -c "SELECT COUNT(*) FROM historical_cases;" | tr -d ' ' | xargs echo "Total de casos no banco:"

echo ""
echo "🎯 Próximo passo: Enviar mais PDFs!"
echo "   http://72.60.255.80:3000/admin/upload"
echo ""

