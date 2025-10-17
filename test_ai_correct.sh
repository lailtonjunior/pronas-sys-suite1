#!/bin/bash

echo "🧪 TESTANDO IA COM PARÂMETROS CORRETOS..."
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Testar com a estrutura CORRETA que o backend espera
echo "1️⃣ Teste com parâmetros corretos:"
curl -X POST http://localhost:8000/api/ai/suggest \
  -H "Content-Type: application/json" \
  -d '{
    "field_name": "justificativa",
    "field_context": {
      "current_value": "",
      "label": "Justificativa"
    },
    "project_context": {
      "title": "AMPLIANDO ATENDIMENTOS DE FISIOTERAPIA NA APAE DE COLINAS",
      "field": "prestacao_servicos_medico_assistenciais",
      "institution_name": "APAE de Colinas do Tocantins"
    }
  }' | jq .

echo ""
echo "2️⃣ Teste para objetivos:"
curl -X POST http://localhost:8000/api/ai/suggest \
  -H "Content-Type: application/json" \
  -d '{
    "field_name": "objetivos",
    "field_context": {
      "current_value": "",
      "label": "Objetivos"
    },
    "project_context": {
      "title": "AMPLIANDO ATENDIMENTOS DE FISIOTERAPIA NA APAE DE COLINAS",
      "field": "prestacao_servicos_medico_assistenciais",
      "institution_name": "APAE de Colinas do Tocantins"
    }
  }' | jq .

echo ""
echo "═══════════════════════════════════════════════════════════════"

