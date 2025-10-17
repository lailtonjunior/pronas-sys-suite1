#!/bin/bash
set -e

echo "🔧 PROCESSANDO OS 9 ARQUIVOS RESTANTES..."
echo "═══════════════════════════════════════════════════════════════"
echo ""

docker compose exec -T backend python3 << 'PYLASTEOF'
import sys
sys.path.insert(0, '/app')

from pathlib import Path
from app.database.session import SessionLocal
from app.models.historical_case import HistoricalCase
import PyPDF2
import re

# Lista com os nomes CORRETOS dos arquivos
remaining_files = [
    ("diligencias", "1 - oficio de diligencia - INSTITUTO DO CARINHO.pdf"),
    ("diligencias", "1. OFICIO 47-2024 - RESPOSTA DILIGÊNCIA 398-2024.pdf"),
    ("diligencias", "Diligência_SEI_MS - 0044418739 - Parecer nº 461.pdf"),
    ("diligencias", "OFÍCIO 19-2024 - RESPOSTA DILIGÊNCIA 238-2024.pdf"),
    ("diligencias", "Ofício de Resposta_ 1ª Diligência Parecer nº. 286_2024 - instituto do carinho.pdf"),
    ("diligencias", "Parecer Diligência_PRADOS-MG.pdf"),
    ("diligencias", "SEI_MS - 0044150029 - Parecer nº 267 APAE COLINAS.pdf"),
    ("diligencias", "SEI_MS - 0044408194 - Parecer 454 BARROLANDIA .pdf"),
    ("portarias", "PORTARIA GM_MS Nº 8.031, DE 5 DE setembro DE 2025 - PORTARIA GM_MS Nº 8.031, DE 5 DE setembro DE 2025 - DOU - Imprensa Nacional.pdf")
]

db = SessionLocal()
knowledge_base = Path("/knowledge_base")

def clean_text(text):
    if not text:
        return ""
    text = text.replace('\x00', '')
    text = text.replace('\ufffd', '')
    text = re.sub(r'"+', '"', text)
    text = re.sub(r"'+", "'", text)
    return text

def extract_text_safe(pdf_path):
    try:
        with open(pdf_path, 'rb') as f:
            pdf = PyPDF2.PdfReader(f)
            text = ""
            for page in pdf.pages:
                try:
                    text += clean_text(page.extract_text()) + "\n"
                except:
                    continue
            return text
    except:
        return ""

success = 0

print(f"{'='*70}")
print(f"📋 PROCESSANDO 9 ARQUIVOS FINAIS")
print(f"{'='*70}\n")

for i, (folder, filename) in enumerate(remaining_files, 1):
    pdf_path = knowledge_base / folder / filename
    
    if not pdf_path.exists():
        print(f"[{i}/9] ⚠️  Não encontrado: {filename[:50]}")
        continue
    
    print(f"[{i}/9] {filename[:52]:52s} ", end="", flush=True)
    
    try:
        # Verificar duplicata
        title = pdf_path.stem[:200]
        if db.query(HistoricalCase).filter_by(project_title=title).first():
            print("⏭️")
            continue
        
        # Extrair
        text = extract_text_safe(pdf_path)
        if len(text) < 30:
            print("⚠️")
            continue
        
        # Classificar
        if folder == "portarias":
            field = "portaria_oficial"
            is_approved = None
            score = 100
            priority = "Portaria Oficial"
        else:
            field = "diligencia"
            is_approved = None
            score = 60
            priority = "Diligências e Portarias"
        
        # Extrair instituição
        inst_match = re.search(r'(APAE[^,\n]{0,50}|Associação[^,\n]{0,50}|Instituto[^,\n]{0,50})', text[:2000], re.I)
        inst = clean_text(inst_match.group(0).strip()) if inst_match else "Instituição"
        
        summary = clean_text(text[:400])
        
        db.rollback()
        
        case = HistoricalCase(
            project_title=title,
            institution_name=inst[:200],
            field=field,
            priority_area=priority,
            is_approved=is_approved,
            score=score,
            summary=summary,
            key_points=[],
            rejection_reasons=[]
        )
        
        db.add(case)
        db.commit()
        db.refresh(case)
        
        print(f"✅ ID:{case.id}")
        success += 1
        
    except Exception as e:
        db.rollback()
        print(f"❌ {str(e)[:25]}")

db.close()

print(f"\n{'='*70}")
print(f"✅ PROCESSAMENTO FINAL CONCLUÍDO!")
print(f"   • {success} documentos importados")
print(f"{'='*70}")

PYLASTEOF

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "📊 ESTATÍSTICAS FINAIS COMPLETAS"
echo "═══════════════════════════════════════════════════════════════"
echo ""

TOTAL=$(docker compose exec -T postgres psql -U pronas_user -d pronas_pcd -t -c "SELECT COUNT(*) FROM historical_cases;" | tr -d ' ')
APROVADOS=$(docker compose exec -T postgres psql -U pronas_user -d pronas_pcd -t -c "SELECT COUNT(*) FROM historical_cases WHERE is_approved = true;" | tr -d ' ')
REPROVADOS=$(docker compose exec -T postgres psql -U pronas_user -d pronas_pcd -t -c "SELECT COUNT(*) FROM historical_cases WHERE is_approved = false;" | tr -d ' ')
OUTROS=$(docker compose exec -T postgres psql -U pronas_user -d pronas_pcd -t -c "SELECT COUNT(*) FROM historical_cases WHERE is_approved IS NULL;" | tr -d ' ')

echo "🗄️  BASE DE CONHECIMENTO COMPLETA:"
echo "   • TOTAL: $TOTAL casos"
echo "   • ✅ Aprovados: $APROVADOS ($(($APROVADOS * 100 / $TOTAL))%)"
echo "   • ❌ Reprovados: $REPROVADOS ($(($REPROVADOS * 100 / $TOTAL))%)"
echo "   • ⚠️  Diligências/Portarias: $OUTROS ($(($OUTROS * 100 / $TOTAL))%)"
echo ""
echo "�� SISTEMA 100% OPERACIONAL!"
echo ""
echo "🚀 TESTE AGORA:"
echo "   http://72.60.255.80:3000/projeto/6/editar"
echo ""

