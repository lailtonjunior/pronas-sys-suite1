#!/bin/bash
set -e

echo "🎨 Implementando CSS Puro (sem Tailwind)..."

# Parar frontend
docker compose stop frontend

# REMOVER COMPLETAMENTE TAILWIND
cat > frontend/package.json << 'PKGEOF'
{
  "name": "pronas-frontend",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start"
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
    "typescript": "^5"
  }
}
PKGEOF

# REMOVER postcss.config.js e tailwind.config.js
rm -f frontend/postcss.config.js frontend/tailwind.config.js

# CSS COMPLETO COM CLASSES UTILITÁRIAS
cat > frontend/src/app/globals.css << 'CSSEOF'
/* Reset e Base */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
  line-height: 1.6;
  color: #1f2937;
  background: #f9fafb;
}

/* Container */
.container {
  max-width: 1280px;
  margin: 0 auto;
  padding: 0 1rem;
}

/* Gradientes */
.bg-gradient {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.bg-gradient-blue {
  background: linear-gradient(to bottom right, #eff6ff, #dbeafe);
}

.bg-gradient-dark {
  background: linear-gradient(to bottom right, #1e40af, #7c3aed, #db2777);
}

/* Cards */
.card {
  background: white;
  border-radius: 0.75rem;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
  overflow: hidden;
}

.card-hover {
  transition: all 0.2s;
}

.card-hover:hover {
  box-shadow: 0 10px 25px rgba(0,0,0,0.15);
  transform: translateY(-2px);
}

/* Buttons */
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 0.75rem 1.5rem;
  font-weight: 600;
  border-radius: 0.5rem;
  border: none;
  cursor: pointer;
  transition: all 0.2s;
  text-decoration: none;
}

.btn-primary {
  background: #3b82f6;
  color: white;
}

.btn-primary:hover {
  background: #2563eb;
}

.btn-outline {
  background: transparent;
  border: 2px solid #3b82f6;
  color: #3b82f6;
}

.btn-outline:hover {
  background: #eff6ff;
}

.btn-lg {
  padding: 1rem 2rem;
  font-size: 1.125rem;
}

/* Badge */
.badge {
  display: inline-flex;
  align-items: center;
  padding: 0.25rem 0.75rem;
  border-radius: 9999px;
  font-size: 0.75rem;
  font-weight: 600;
}

.badge-warning {
  background: #fef3c7;
  color: #92400e;
}

.badge-success {
  background: #d1fae5;
  color: #065f46;
}

.badge-default {
  background: #e5e7eb;
  color: #374151;
}

.badge-danger {
  background: #fee2e2;
  color: #991b1b;
}

/* Forms */
.form-input {
  width: 100%;
  padding: 0.75rem 1rem;
  border: 1px solid #d1d5db;
  border-radius: 0.5rem;
  font-size: 1rem;
}

.form-input:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.form-label {
  display: block;
  font-weight: 600;
  margin-bottom: 0.5rem;
  color: #374151;
}

/* Progress Bar */
.progress-bar {
  width: 100%;
  height: 2rem;
  background: #e5e7eb;
  border-radius: 9999px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #3b82f6, #8b5cf6);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: bold;
  transition: width 0.5s ease;
}

/* Grid */
.grid {
  display: grid;
  gap: 1.5rem;
}

.grid-cols-1 { grid-template-columns: repeat(1, 1fr); }
.grid-cols-2 { grid-template-columns: repeat(2, 1fr); }
.grid-cols-3 { grid-template-columns: repeat(3, 1fr); }
.grid-cols-4 { grid-template-columns: repeat(4, 1fr); }

@media (min-width: 768px) {
  .md-grid-cols-2 { grid-template-columns: repeat(2, 1fr); }
  .md-grid-cols-3 { grid-template-columns: repeat(3, 1fr); }
  .md-grid-cols-4 { grid-template-columns: repeat(4, 1fr); }
}

/* Flex */
.flex {
  display: flex;
}

.flex-col {
  flex-direction: column;
}

.items-center {
  align-items: center;
}

.justify-center {
  justify-content: center;
}

.justify-between {
  justify-content: space-between;
}

.gap-2 { gap: 0.5rem; }
.gap-3 { gap: 0.75rem; }
.gap-4 { gap: 1rem; }
.gap-6 { gap: 1.5rem; }
.gap-8 { gap: 2rem; }

/* Spacing */
.p-4 { padding: 1rem; }
.p-6 { padding: 1.5rem; }
.p-8 { padding: 2rem; }
.px-4 { padding-left: 1rem; padding-right: 1rem; }
.px-8 { padding-left: 2rem; padding-right: 2rem; }
.py-2 { padding-top: 0.5rem; padding-bottom: 0.5rem; }
.py-4 { padding-top: 1rem; padding-bottom: 1rem; }
.py-6 { padding-top: 1.5rem; padding-bottom: 1.5rem; }
.py-8 { padding-top: 2rem; padding-bottom: 2rem; }
.py-20 { padding-top: 5rem; padding-bottom: 5rem; }

.mb-2 { margin-bottom: 0.5rem; }
.mb-3 { margin-bottom: 0.75rem; }
.mb-4 { margin-bottom: 1rem; }
.mb-6 { margin-bottom: 1.5rem; }
.mb-8 { margin-bottom: 2rem; }
.mb-16 { margin-bottom: 4rem; }

/* Text */
.text-center { text-align: center; }
.text-sm { font-size: 0.875rem; }
.text-lg { font-size: 1.125rem; }
.text-xl { font-size: 1.25rem; }
.text-2xl { font-size: 1.5rem; }
.text-3xl { font-size: 1.875rem; }
.text-4xl { font-size: 2.25rem; }
.text-6xl { font-size: 4rem; }
.text-8xl { font-size: 6rem; }

.font-bold { font-weight: 700; }
.font-semibold { font-weight: 600; }

.text-white { color: white; }
.text-gray-500 { color: #6b7280; }
.text-gray-600 { color: #4b5563; }
.text-gray-700 { color: #374151; }
.text-gray-900 { color: #111827; }
.text-blue-600 { color: #2563eb; }

/* Animations */
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
  animation: fadeIn 0.4s ease-out;
}

.spinner {
  border: 3px solid #e5e7eb;
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

/* Utilities */
.min-h-screen {
  min-height: 100vh;
}

.shadow {
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

.shadow-lg {
  box-shadow: 0 10px 25px rgba(0,0,0,0.1);
}

.rounded {
  border-radius: 0.25rem;
}

.rounded-lg {
  border-radius: 0.5rem;
}

.rounded-xl {
  border-radius: 0.75rem;
}

.border {
  border: 1px solid #e5e7eb;
}

.border-2 {
  border: 2px solid #e5e7eb;
}

.overflow-hidden {
  overflow: hidden;
}

.sticky {
  position: sticky;
}

.top-0 {
  top: 0;
}

.z-10 {
  z-index: 10;
}
CSSEOF

echo "✅ CSS puro implementado"

# Rebuild
docker compose build --no-cache frontend
docker compose up -d frontend

echo "⏳ Aguardando 20 segundos..."
sleep 20

docker compose logs frontend | tail -15

echo ""
echo "✅ PRONTO! CSS Puro implementado sem Tailwind"
echo "🌐 Acesse: http://72.60.255.80:3000"
echo ""

