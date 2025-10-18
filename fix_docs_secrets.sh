#!/bin/bash

echo "🧹 Limpando secrets dos arquivos de documentação"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Substituir a chave real por placeholder em README_SISTEMA_IA.md
sed -i 's/OPENAI_API_KEY=sk-proj-[A-Za-z0-9_-]*/OPENAI_API_KEY=sk-proj-YOUR_KEY_HERE/g' README_SISTEMA_IA.md

# Substituir em ENTREGA_FINAL.md se existir
if [ -f ENTREGA_FINAL.md ]; then
    sed -i 's/sk-proj-[A-Za-z0-9_-]*/sk-proj-YOUR_KEY_HERE/g' ENTREGA_FINAL.md
fi

# Limpar qualquer outro arquivo
sed -i 's/sk-proj-[A-Za-z0-9_-]*/sk-proj-YOUR_KEY_HERE/g' SISTEMA_IA.md 2>/dev/null || true

echo "✅ Documentação limpa"
