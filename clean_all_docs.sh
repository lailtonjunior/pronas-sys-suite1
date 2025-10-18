#!/bin/bash

echo "🧹 LIMPANDO TODOS OS ARQUIVOS DE DOCUMENTAÇÃO"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

FILES=(
    "README_SISTEMA_IA.md"
    "ENTREGA_FINAL.md"
    "SISTEMA_IA.md"
    "*.sh"
)

for file in "${FILES[@]}"; do
    if ls $file 1> /dev/null 2>&1; then
        echo "🔄 Limpando: $file"
        
        # Substituir chaves OpenAI
        sed -i 's/sk-proj-[A-Za-z0-9_-]\{50,\}/sk-proj-YOUR_OPENAI_KEY_HERE/g' $file
        
        # Substituir chaves Gemini
        sed -i 's/AIzaSy[A-Za-z0-9_-]\{30,\}/AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXX/g' $file
        
        # Substituir chaves Perplexity
        sed -i 's/pplx-[A-Za-z0-9_]\{40,\}/pplx-YOUR_PERPLEXITY_KEY_HERE/g' $file
        
        # Substituir passwords PostgreSQL
        sed -i 's/YOUR_DB_PASSWORD_HERE/YOUR_DB_PASSWORD_HERE/g' $file
        
        # Substituir SECRET_KEY
        sed -i 's/SECRET_KEY=[a-f0-9]\{64\}/SECRET_KEY=your_secret_key_min_32_chars_here/g' $file
    fi
done

echo ""
echo "✅ Todos os arquivos limpos"
