#!/bin/bash

echo "🧹 LIMPANDO SECRETS DO README"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Substituir todas as chaves reais por placeholders
sed -i 's/sk-proj-[A-Za-z0-9_-]\{50,\}/sk-proj-YOUR_KEY_HERE/g' README_SISTEMA_IA.md
sed -i 's/AIzaSy[A-Za-z0-9_-]\{30,\}/AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXX/g' README_SISTEMA_IA.md
sed -i 's/pplx-[A-Za-z0-9]\{40,\}/pplx-YOUR_KEY_HERE/g' README_SISTEMA_IA.md

echo "✅ README limpo"
echo ""

# Verificar se ainda há secrets
if grep -q "sk-proj-[A-Za-z0-9_-]\{50,\}" README_SISTEMA_IA.md; then
    echo "⚠️  Ainda há secrets no README!"
else
    echo "✅ Nenhum secret encontrado"
fi
