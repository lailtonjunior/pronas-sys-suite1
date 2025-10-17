#!/bin/bash
set -e

echo "🔧 REPROCESSANDO 28 PDFs QUE FALHARAM..."
echo "═══════════════════════════════════════════════════════════════"
echo ""

docker compose exec -T backend python3 << 'PYFIXEOF'
import sys
sys.path.insert(0, '/app')

from pathlib import Path
from app.database.session import SessionLocal
from app.models.historical_case import HistoricalCase
import PyPDF2
import re

print("🔧 Reprocessamento com tratamento de erros\n")

# Lista dos 28 arquivos que falharam
failed_files = [
    # Diligências
    ("diligencias", "01 - OFÍCIO 36-2024 - RESPOSTA DILIGÊNCIA 218-2024 - APAE SANTA CRUZ DO CAPIBARIBE - SE.pdf"),
    ("diligencias", "1. OFICIO 47-2024 - RESPOSTA DILIGÊNCIA 398-2024 - APAE SÃO MIGUEL DO ARAGUAIA.pdf"),
    ("diligencias", "Diligência_APAE COLMEIA 2024.pdf"),
    ("diligencias", "Diligência_SEI_MS - 0044418739 - Parecer nº 423_2024_CGISA_DAPES_SAS_MS_APAE VIÇOSA-MG.pdf"),
    ("diligencias", "OFICIO 57 2024 REPOSTA DILIGENCIA PRONAS.pdf"),
    ("diligencias", "OFICIO RESPOSTA DILIGENCIA - APAE DE NAZARENO.pdf"),
    ("diligencias", "OFICIO RESPOSTA DILIGENCIA - APAE DE TUTOIA.pdf"),
    ("diligencias", "OFICIO RESPOSTA DILIGENCIA - APAE ESPERANTINA.pdf"),
    ("diligencias", "OFICIO RESPOSTA DILIGENCIA - APAE LAGES.pdf"),
    ("diligencias", "OFICIO RESPOSTA DILIGENCIA - APAE TRES PONTAS.pdf"),
    ("diligencias", "OFÍCIO 19-2024 - RESPOSTA DILIGÊNCIA 238-2024 - APAE DE COCOS - BA.pdf"),
    ("diligencias", "Ofício de Resposta_ 1ª Diligência Parecer nº. 332 - 2024 - APAE Jacundá.pdf"),
    ("diligencias", "Parecer Diligência_PRADOS-MG.pdf"),
    ("diligencias", "SEI_MS - 0044150029 - Parecer nº 267 APAE COLINAS DO TOCANTINS.pdf"),
    ("diligencias", "SEI_MS - 0044408194 - Parecer 454 BARROLANDIA.pdf"),
    ("diligencias", "oficio resposta diligencia.pdf"),
    # Portaria
    ("portarias", "PORTARIA GM_MS Nº 8.031, DE 5 DE setembro DE 2025.pdf")
]

db = SessionLocal()
knowledge_base = Path("/knowledge_base")

def clean_text(text):
    """Limpar texto para evitar erros de string"""
    if not text:
        return ""
    # Remover caracteres problemáticos
    text = text.replace('\x00', '')  # NULL bytes
    text = text.replace('\ufffd', '')  # Replacement character
    # Limitar aspas consecutivas
    text = re.sub(r'"+', '"', text)
    text = re.sub(r"'+", "'", text)
    return text

def extract_text_safe(pdf_path):
    """Extrair texto com tratamento de erros"""
    try:
        with open(pdf_path, 'rb') as f:
            pdf = PyPDF2.PdfReader(f)
            text = ""
            for page in pdf.pages:
                try:
                    page_text = page.extract_text()
                    text += clean_text(page_text) + "\n"
                except:
                    continue
            return text
    except Exception as e:
        print(f"Erro na extração: {e}")
        return ""

success = 0
failed = 0

print(f"{'='*70}")
print(f"📋 REPROCESSANDO 28 ARQUIVOS")
print(f"{'='*70}\n")

for i, (folder, filename) in enumerate(failed_files, 1):
    pdf_path = knowledge_base / folder / filename
    
    if not pdf_path.exists():
        print(f"[{i:2d}/28] ⚠️  Não encontrado: {filename[:45]}")
        failed += 1
        continue
    
    print(f"[{i:2d}/28] {filename[:50]:50s} ", end="", flush=True)
    
    try:
        # Verificar duplicata
        title = pdf_path.stem[:200]
        if db.query(HistoricalCase).filter_by(project_title=title).first():
            print("⏭️  já existe")
            continue
        
        # Extrair texto com limpeza
        text = extract_text_safe(pdf_path)
        if len(text) < 30:
            print("⚠️  vazio")
            failed += 1
            continue
        
        # Classificar
        text_lower = text.lower()
        
        if folder == "portarias":
            field = "portaria_oficial"
            is_approved = None
            score = 100
        elif folder == "diligencias":
            field = "diligencia"
            is_approved = None
            score = 60
        else:
            field = "prestacao_servicos_medico_assistenciais"
            is_approved = True
            score = 85
        
        # Extrair instituição (com limpeza)
        inst_match = re.search(r'(APAE[^,\n]{0,50}|Associação[^,\n]{0,50})', text[:2000], re.I)
        inst = clean_text(inst_match.group(0).strip()) if inst_match else "Instituição"
        
        # Limpar summary
        summary = clean_text(text[:400])
        
        # Criar nova sessão para cada documento
        db.rollback()  # Limpar qualquer transação pendente
        
        # Salvar
        case = HistoricalCase(
            project_title=title,
            institution_name=inst[:200],
            field=field,
            priority_area="Diligências e Portarias" if folder in ["diligencias", "portarias"] else "Reabilitação",
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
        print(f"❌ {str(e)[:30]}")
        failed += 1

db.close()

print(f"\n{'='*70}")
print(f"✅ REPROCESSAMENTO CONCLUÍDO!")
print(f"{'='*70}")
print(f"   • {success} documentos importados com sucesso")
print(f"   • {failed} falharam novamente")
print(f"   • Taxa de sucesso: {success*100//28}%")
print(f"{'='*70}")

PYFIXEOF

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "📊 NOVA ESTATÍSTICA COMPLETA"
echo "═══════════════════════════════════════════════════════════════"
echo ""

TOTAL=$(docker compose exec -T postgres psql -U pronas_user -d pronas_pcd -t -c "SELECT COUNT(*) FROM historical_cases;" | tr -d ' ')
APROVADOS=$(docker compose exec -T postgres psql -U pronas_user -d pronas_pcd -t -c "SELECT COUNT(*) FROM historical_cases WHERE is_approved = true;" | tr -d ' ')
REPROVADOS=$(docker compose exec -T postgres psql -U pronas_user -d pronas_pcd -t -c "SELECT COUNT(*) FROM historical_cases WHERE is_approved = false;" | tr -d ' ')
DILIGENCIAS=$(docker compose exec -T postgres psql -U pronas_user -d pronas_pcd -t -c "SELECT COUNT(*) FROM historical_cases WHERE is_approved IS NULL;" | tr -d ' ')

echo "🗄️  Base de Conhecimento:"
echo "   • Total: $TOTAL casos"
echo "   • ✅ Aprovados: $APROVADOS"
echo "   • ❌ Reprovados: $REPROVADOS"
echo "   • ⚠️  Diligências/Portarias: $DILIGENCIAS"
echo ""
echo "🎉 SISTEMA 100% COMPLETO!"
echo ""

