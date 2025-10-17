#!/bin/bash
set -e

echo "🔧 Corrigindo paths do frontend..."

# ═══════════════════════════════════════════════════════════════
# 1. ATUALIZAR tsconfig.json
# ═══════════════════════════════════════════════════════════════

cat > frontend/tsconfig.json << 'TSEOF'
{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [
      {
        "name": "next"
      }
    ],
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
TSEOF

echo "✅ tsconfig.json atualizado"

# ═══════════════════════════════════════════════════════════════
# 2. ATUALIZAR next.config.js
# ═══════════════════════════════════════════════════════════════

cat > frontend/next.config.js << 'NEXTEOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
}

module.exports = nextConfig
NEXTEOF

echo "✅ next.config.js atualizado"

# ═══════════════════════════════════════════════════════════════
# 3. CRIAR ARQUIVO tailwind.config.js
# ═══════════════════════════════════════════════════════════════

cat > frontend/tailwind.config.js << 'TAILEOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        border: "hsl(var(--border))",
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
      },
    },
  },
  plugins: [],
}
TAILEOF

echo "✅ tailwind.config.js criado"

# ═══════════════════════════════════════════════════════════════
# 4. CRIAR ARQUIVO globals.css
# ═══════════════════════════════════════════════════════════════

mkdir -p frontend/src/app

cat > frontend/src/app/globals.css << 'CSSEOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
  --background: 0 0% 100%;
  --foreground: 222.2 84% 4.9%;
  --border: 214.3 31.8% 91.4%;
}

* {
  border-color: hsl(var(--border));
}

body {
  background-color: hsl(var(--background));
  color: hsl(var(--foreground));
}
CSSEOF

echo "✅ globals.css criado"

# ═══════════════════════════════════════════════════════════════
# 5. ATUALIZAR layout.tsx
# ═══════════════════════════════════════════════════════════════

cat > frontend/src/app/layout.tsx << 'LAYOUTEOF'
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'Assistente PRONAS/PCD',
  description: 'Sistema RAG Multi-Agente para elaboração de projetos PRONAS/PCD',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="pt-BR">
      <body className={inter.className}>{children}</body>
    </html>
  )
}
LAYOUTEOF

echo "✅ layout.tsx atualizado"

# ═══════════════════════════════════════════════════════════════
# 6. VERIFICAR SE COMPONENTES EXISTEM
# ═══════════════════════════════════════════════════════════════

echo "📦 Verificando componentes UI..."

if [ ! -f "frontend/src/components/ui/card.tsx" ]; then
  echo "⚠️  Criando componentes UI..."
  
  mkdir -p frontend/src/components/ui
  
  # Card
  cat > frontend/src/components/ui/card.tsx << 'CARDEOF'
import * as React from "react"

export function Card({ className = "", ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return (
    <div className={`rounded-lg border bg-white shadow-sm ${className}`} {...props} />
  )
}

export function CardHeader({ className = "", ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return <div className={`flex flex-col space-y-1.5 p-6 ${className}`} {...props} />
}

export function CardTitle({ className = "", ...props }: React.HTMLAttributes<HTMLHeadingElement>) {
  return <h3 className={`text-2xl font-semibold leading-none tracking-tight ${className}`} {...props} />
}

export function CardContent({ className = "", ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return <div className={`p-6 pt-0 ${className}`} {...props} />
}
CARDEOF

  # Button
  cat > frontend/src/components/ui/button.tsx << 'BUTTONEOF'
import * as React from "react"

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: "default" | "outline" | "ghost" | "destructive"
  size?: "default" | "sm" | "lg"
}

export function Button({ 
  className = "", 
  variant = "default", 
  size = "default", 
  ...props 
}: ButtonProps) {
  const baseStyles = "inline-flex items-center justify-center rounded-lg font-semibold transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2 disabled:opacity-50 disabled:pointer-events-none"
  
  const variants = {
    default: "bg-blue-600 text-white hover:bg-blue-700 focus:ring-blue-500",
    outline: "border-2 border-blue-600 text-blue-600 hover:bg-blue-50",
    ghost: "text-gray-700 hover:bg-gray-100",
    destructive: "bg-red-600 text-white hover:bg-red-700 focus:ring-red-500"
  }
  
  const sizes = {
    default: "px-4 py-2 text-sm",
    sm: "px-3 py-1.5 text-xs",
    lg: "px-6 py-3 text-base"
  }
  
  return (
    <button 
      className={`${baseStyles} ${variants[variant]} ${sizes[size]} ${className}`}
      {...props}
    />
  )
}
BUTTONEOF

  # Badge
  cat > frontend/src/components/ui/badge.tsx << 'BADGEEOF'
import * as React from "react"

interface BadgeProps extends React.HTMLAttributes<HTMLDivElement> {
  variant?: "default" | "success" | "warning" | "danger"
}

export function Badge({ className = "", variant = "default", ...props }: BadgeProps) {
  const variants = {
    default: "bg-gray-100 text-gray-800",
    success: "bg-green-100 text-green-800",
    warning: "bg-yellow-100 text-yellow-800",
    danger: "bg-red-100 text-red-800"
  }
  
  return (
    <div className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold ${variants[variant]} ${className}`} {...props} />
  )
}
BADGEEOF

  echo "✅ Componentes UI criados"
else
  echo "✅ Componentes UI já existem"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ Configurações corrigidas!"
echo "═══════════════════════════════════════════════════════════════"

