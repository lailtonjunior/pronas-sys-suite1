#!/bin/bash
set -e

echo "🔄 SINCRONIZANDO PDFs DO HOST PARA O CONTAINER..."
echo "═══════════════════════════════════════════════════════════════"
echo ""

cd /root/pronas-sys-suite1/knowledge_base

# Ver quantos PDFs temos no host
echo "📊 No HOST:"
for folder in aprovados reprovados diligencias portarias exemplos; do
    if [ -d "$folder" ]; then
        count=$(find "$folder" -name "*.pdf" 2>/dev/null | wc -l)
        echo "   $folder: $count PDFs"
    fi
done

echo ""
echo "🔄 Copiando para o container..."

# Copiar cada pasta para o container
for folder in aprovados reprovados diligencias portarias exemplos; do
    if [ -d "$folder" ]; then
        echo "   📁 Copiando $folder/..."
        
        # Criar pasta no container
        docker compose exec backend mkdir -p "/knowledge_base/$folder"
        
        # Copiar PDFs
        docker cp "$folder" pronas_backend:/knowledge_base/
        
        count=$(find "$folder" -name "*.pdf" 2>/dev/null | wc -l)
        echo "      ✅ $count PDFs copiados"
    fi
done

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ SINCRONIZAÇÃO CONCLUÍDA!"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Verificar no container
echo "📊 DENTRO DO CONTAINER:"
docker compose exec backend bash -c 'for folder in aprovados reprovados diligencias portarias exemplos; do
    count=$(find /knowledge_base/$folder -name "*.pdf" 2>/dev/null | wc -l)
    echo "   $folder: $count PDFs"
done'

TOTAL=$(docker compose exec backend find /knowledge_base -name "*.pdf" 2>/dev/null | wc -l)
echo ""
echo "🎯 TOTAL no container: $TOTAL PDFs"
echo ""

