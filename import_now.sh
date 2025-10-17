#!/bin/bash
set -e

echo "🤖 IMPORTAÇÃO RÁPIDA (SEM QDRANT)..."
echo "═══════════════════════════════════════════════════════════════"
echo ""

docker compose exec -T backend python3 << 'PYEOF'
import sys
sys.path.insert(0, '/app')

from pathlib import Path
from app.database.session import SessionLocal
from app.models.historical_case import HistoricalCase
import PyPDF2

print("📚 Importando PDFs para base de conhecimento\n")

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

total = 0

for folder in ["aprovados", "reprovados", "diligencias", "portarias"]:
    folder_path = knowledge_base / folder
    if not folder_path.exists():
        continue
    
    pdfs = list(folder_path.glob("*.pdf"))
    if not pdfs:
        continue
    
    print(f"📁 {folder}: {len(pdfs)} arquivos")
    
    for pdf in pdfs:
        print(f"   📄 {pdf.name}... ", end="")
        
        try:
            text = extract_text(pdf)
            
            if len(text) < 50:
                print("⚠️  vazio")
                continue
            
            # Classificar
            is_approved = folder == "aprovados"
            score = 85 if is_approved else 40
            
            # Extrair instituição do nome
            import re
            inst_match = re.search(r'APAE[^\.]*', pdf.name, re.IGNORECASE)
            instituicao = inst_match.group(0) if inst_match else "Instituição"
            
            # Salvar
            case = HistoricalCase(
                project_title=pdf.stem[:200],
                institution_name=instituicao[:200],
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
            
            print(f"✅ (ID: {case.id})")
            total += 1
            
        except Exception as e:
            print(f"❌ {e}")

db.close()

print(f"\n{'='*60}")
print(f"✅ Total importado: {total} documentos")
print(f"{'='*60}")

PYEOF

echo ""
echo "📊 Verificando banco de dados..."
TOTAL=$(docker compose exec postgres psql -U pronas_user -d pronas_pcd -t -c "SELECT COUNT(*) FROM historical_cases;" 2>/dev/null | tr -d ' ')

echo "   Total de casos no banco: $TOTAL"
echo ""

if [ "$TOTAL" -gt 0 ]; then
    echo "📋 Últimos 5 casos importados:"
    docker compose exec postgres psql -U pronas_user -d pronas_pcd -c "SELECT id, left(project_title, 60) as titulo, is_approved, score FROM historical_cases ORDER BY id DESC LIMIT 5;"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "🎉 IMPORTAÇÃO CONCLUÍDA!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "🚀 Próximo passo:"
echo "   • Envie mais PDFs: http://72.60.255.80:3000/admin/upload"
echo "   • Ou teste a IA nos anexos do projeto!"
echo ""

