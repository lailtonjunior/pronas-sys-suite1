#!/bin/bash
set -e

echo "🔍 VERIFICANDO MODELOS GEMINI DISPONÍVEIS"
echo "═══════════════════════════════════════════════════════════════"
echo ""

docker compose exec -T backend python3 << 'PYMODELS'
import google.generativeai as genai
import os

genai.configure(api_key=os.getenv('GEMINI_API_KEY'))

print("📋 MODELOS DISPONÍVEIS:\n")

models_info = {
    'gemini-2.5-pro': '🏆 Melhor qualidade (mais lento)',
    'gemini-2.0-flash': '⚡ Muito rápido e inteligente',
    'gemini-1.5-pro': '💎 Alta qualidade (estável)',
    'gemini-1.5-flash': '⚡ Rápido e eficiente',
    'gemini-pro': '🔧 Modelo legado (estável)'
}

available = []

for m in genai.list_models():
    if 'generateContent' in m.supported_generation_methods:
        model_name = m.name.replace('models/', '')
        desc = models_info.get(model_name, '')
        print(f"   ✅ {model_name:25s} {desc}")
        available.append(model_name)

print("\n" + "="*70)
print("📊 RECOMENDAÇÕES:\n")

if 'gemini-2.5-pro' in available:
    print("   🥇 MELHOR: gemini-2.5-pro")
    print("      • Qualidade máxima")
    print("      • Ótimo para textos complexos")
    print("      • Resposta: 3-8 segundos")
    recommended = 'gemini-2.5-pro'
    
elif 'gemini-2.0-flash' in available:
    print("   🥇 MELHOR: gemini-2.0-flash")
    print("      • Excelente equilíbrio")
    print("      • Muito rápido")
    print("      • Resposta: 1-3 segundos")
    recommended = 'gemini-2.0-flash'
    
elif 'gemini-1.5-pro' in available:
    print("   🥇 MELHOR: gemini-1.5-pro")
    print("      • Alta qualidade")
    print("      • Estável e confiável")
    print("      • Resposta: 2-5 segundos")
    recommended = 'gemini-1.5-pro'
    
elif 'gemini-1.5-flash' in available:
    print("   🥇 MELHOR: gemini-1.5-flash")
    print("      • Rápido")
    print("      • Boa qualidade")
    print("      • Resposta: 1-3 segundos")
    recommended = 'gemini-1.5-flash'
    
else:
    print("   🥇 USAR: gemini-pro")
    print("      • Modelo legado")
    print("      • Estável")
    recommended = 'gemini-pro'

print(f"\n   🎯 RECOMENDADO: {recommended}")

# Salvar recomendação em arquivo
with open('/tmp/recommended_model.txt', 'w') as f:
    f.write(recommended)

print("\n" + "="*70)

PYMODELS

echo ""
echo "═══════════════════════════════════════════════════════════════"

