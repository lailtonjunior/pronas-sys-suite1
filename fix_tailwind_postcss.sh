#!/bin/bash
set -e

echo "🔧 Corrigindo Tailwind CSS..."

# Parar frontend
docker compose stop frontend

# Remover node_modules e package-lock
docker compose exec frontend rm -rf node_modules package-lock.json .next 2>/dev/null || true

# Atualizar package.json com versões corretas
cat > frontend/package.json << 'PKGEOF'
{
  "name": "pronas-frontend",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  },
  "dependencies": {
    "next": "14.1.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@types/node": "^20",
    "@types/react": "^18",
    "@types/react-dom": "^18",
    "autoprefixer": "^10.4.17",
    "postcss": "^8.4.33",
    "tailwindcss": "^3.4.1",
    "typescript": "^5"
  }
}
PKGEOF

# Atualizar PostCSS config
cat > frontend/postcss.config.js << 'POSTEOF'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
POSTEOF

# Atualizar Tailwind config
cat > frontend/tailwind.config.js << 'TAILEOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
TAILEOF

# CSS Global limpo com Tailwind
cat > frontend/src/app/globals.css << 'CSSEOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  * {
    @apply border-border;
  }
  body {
    @apply bg-background text-foreground;
  }
}

/* Animações */
@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-fade-in {
  animation: fadeIn 0.3s ease-out;
}

/* Loading spinner */
.spinner {
  border: 3px solid #f3f4f6;
  border-top: 3px solid #3b82f6;
  border-radius: 50%;
  width: 40px;
  height: 40px;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Hover effects */
.hover-scale {
  transition: transform 0.2s ease;
}

.hover-scale:hover {
  transform: scale(1.02);
}
CSSEOF

echo "✅ Arquivos de configuração atualizados"

# Rebuild do zero
echo "🔨 Rebuild do frontend..."
docker compose build --no-cache frontend

# Iniciar
echo "🚀 Iniciando frontend..."
docker compose up -d frontend

echo "⏳ Aguardando 30 segundos..."
sleep 30

echo ""
echo "📋 Verificando logs..."
docker compose logs frontend | tail -20

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ TAILWIND CSS CORRIGIDO!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "🌐 Acesse: http://72.60.255.80:3000"
echo ""

