#!/bin/bash

echo "💰 ANÁLISE DE PERFORMANCE E CUSTO"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

TOTAL_MS=0
TOTAL_COST=0

for i in {1..5}; do
    echo "Teste $i/5..."
    START=$(date +%s%3N)
    
    RESULT=$(curl -s -X POST "http://localhost:8000/api/ai/test-generation?campo=justificativa")
    
    END=$(date +%s%3N)
    LATENCY=$((END - START))
    
    PROVIDER=$(echo "$RESULT" | python3 -c "import sys, json; print(json.load(sys.stdin).get('provider', 'erro'))" 2>/dev/null)
    
    echo "  Provider: $PROVIDER | Latência: ${LATENCY}ms"
    
    TOTAL_MS=$((TOTAL_MS + LATENCY))
    TOTAL_COST=$(echo "$TOTAL_COST + 0.0007" | bc)
    
    sleep 1
done

AVG_MS=$((TOTAL_MS / 5))

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 MÉTRICAS (5 gerações):"
echo "   Latência média: ${AVG_MS}ms"
echo "   Custo total: US$ $(printf '%.4f' $TOTAL_COST)"
echo "   Custo por geração: US$ 0.0007"
echo ""
echo "💡 PROJEÇÕES:"
echo "   100 gerações/dia = US$ 2.10/mês"
echo "   200 gerações/dia = US$ 4.20/mês"
echo "   500 gerações/dia = US$ 10.50/mês"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
