#!/bin/bash
set -e

echo "🔧 CORRIGINDO ESTRUTURA DE PASTAS..."
echo "═══════════════════════════════════════════════════════════════"
echo ""

cd /root/pronas-sys-suite1/knowledge_base

# 1. Verificar estrutura atual
echo "📁 Estrutura atual:"
ls -la

echo ""
echo "📊 Contagem de PDFs por pasta:"
for folder in */; do
    count=$(find "$folder" -name "*.pdf" 2>/dev/null | wc -l)
    echo "   $folder → $count PDFs"
done

echo ""
echo "🔄 Reorganizando pastas..."

# 2. Mover oficioresposta → diligencias
if [ -d "oficioresposta" ]; then
    echo "   📂 oficioresposta/ → diligencias/"
    mkdir -p diligencias
    find oficioresposta -name "*.pdf" -exec mv {} diligencias/ \; 2>/dev/null || true
    rmdir oficioresposta 2>/dev/null || rm -rf oficioresposta
    echo "      ✅ Movido"
fi

# 3. Mover parecerdiligencia → diligencias
if [ -d "parecerdiligencia" ]; then
    echo "   📂 parecerdiligencia/ → diligencias/"
    mkdir -p diligencias
    find parecerdiligencia -name "*.pdf" -exec mv {} diligencias/ \; 2>/dev/null || true
    rmdir parecerdiligencia 2>/dev/null || rm -rf parecerdiligencia
    echo "      ✅ Movido"
fi

# 4. Garantir que todas as pastas padrão existem
for folder in aprovados reprovados diligencias portarias exemplos; do
    mkdir -p "$folder"
done

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ ESTRUTURA CORRIGIDA!"
echo "═══════════════════════════════════════════════════════════════"
echo ""

echo "📊 Nova estrutura:"
ls -la

echo ""
echo "📄 Total de PDFs por pasta:"
for folder in aprovados reprovados diligencias portarias exemplos; do
    if [ -d "$folder" ]; then
        count=$(find "$folder" -name "*.pdf" 2>/dev/null | wc -l)
        echo "   ✅ $folder/ → $count PDFs"
    fi
done

echo ""
TOTAL=$(find . -name "*.pdf" 2>/dev/null | wc -l)
echo "🎯 TOTAL: $TOTAL PDFs"
echo ""

