#!/bin/bash

echo "========================================="
echo "🧪 TESTE 1: Health Check"
echo "========================================="
curl -s http://localhost:8000/api/ai/health | python3 -m json.tool
echo ""
echo ""

echo "========================================="
echo "🧪 TESTE 2: Geração Simples (justificativa)"
echo "========================================="
curl -s -X POST "http://localhost:8000/api/ai/test-generation?campo=justificativa" | python3 -m json.tool
echo ""
echo ""

echo "========================================="
echo "🧪 TESTE 3: Geração com Contexto Customizado"
echo "========================================="
curl -s -X POST "http://localhost:8000/api/ai/generate-field-simple" \
  -H "Content-Type: application/json" \
  -d '{
    "field_name": "objetivos",
    "project_context": {
      "titulo": "Aquisição de Equipamentos para Reabilitação",
      "instituicao": "Centro de Reabilitação São Paulo",
      "tipo": "Aquisição de Equipamentos",
      "publico_alvo": "Crianças com Paralisia Cerebral"
    },
    "max_length": 600
  }' | python3 -m json.tool

echo ""
echo ""
echo "✅ Testes concluídos!"
