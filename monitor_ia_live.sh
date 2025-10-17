#!/bin/bash

while true; do
    clear
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║         📊 MONITOR EM TEMPO REAL - SISTEMA IA             ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    date
    echo ""
    
    echo "🏥 Health Status:"
    curl -s http://localhost:8000/api/ai/health | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(f\"  OpenAI: {'✅' if data['providers']['openai']['available'] else '❌'} | Gemini: {'✅' if data['providers']['gemini']['available'] else '❌'}\")
print(f\"  Status: {data['status']}\")
"
    
    echo ""
    echo "📝 Últimas Requisições (últimos 30s):"
    docker compose logs --since 30s backend 2>/dev/null | grep -E "INFO:app.ai|provider|Gemini|OpenAI" | tail -5
    
    echo ""
    echo "Pressione Ctrl+C para sair | Atualiza a cada 5s"
    sleep 5
done
