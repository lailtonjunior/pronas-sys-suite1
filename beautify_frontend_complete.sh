#!/bin/bash
set -e

echo "🎨 Deixando o Frontend PROFISSIONAL..."

# ═══════════════════════════════════════════════════════════════
# 1. CONFIGURAR TAILWIND CORRETAMENTE
# ═══════════════════════════════════════════════════════════════

cat > frontend/postcss.config.js << 'POSTEOF'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
POSTEOF

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
        primary: {
          50: '#eff6ff',
          100: '#dbeafe',
          200: '#bfdbfe',
          300: '#93c5fd',
          400: '#60a5fa',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
          800: '#1e40af',
          900: '#1e3a8a',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
TAILEOF

cat > frontend/src/app/globals.css << 'CSSEOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --card: 0 0% 100%;
    --card-foreground: 222.2 84% 4.9%;
    --primary: 221.2 83.2% 53.3%;
    --primary-foreground: 210 40% 98%;
    --border: 214.3 31.8% 91.4%;
    --radius: 0.5rem;
  }
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'Inter', system-ui, -apple-system, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

/* Animações suaves */
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.animate-fade-in {
  animation: fadeIn 0.3s ease-out;
}

/* Gradientes bonitos */
.gradient-blue {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.gradient-green {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

/* Efeitos hover */
.hover-scale {
  transition: transform 0.2s ease;
}

.hover-scale:hover {
  transform: scale(1.02);
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
CSSEOF

echo "✅ CSS configurado"

# ═══════════════════════════════════════════════════════════════
# 2. HOMEPAGE BONITA
# ═══════════════════════════════════════════════════════════════

cat > frontend/src/app/page.tsx << 'HOMEEOF'
'use client'
import Link from 'next/link'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-600 via-purple-600 to-pink-500">
      {/* Hero Section */}
      <div className="container mx-auto px-4 py-20">
        <div className="text-center text-white mb-16 animate-fade-in">
          <h1 className="text-6xl font-bold mb-4">
            Assistente PRONAS/PCD
          </h1>
          <p className="text-2xl text-blue-100 mb-2">
            Sistema inteligente com IA para elaboração dos 7 anexos obrigatórios
          </p>
          <p className="text-lg text-blue-200">
            Portaria GM/MS 8.031/2025
          </p>
        </div>

        {/* Features Grid */}
        <div className="grid md:grid-cols-3 gap-8 mb-12">
          <FeatureCard
            icon="🤖"
            title="IA Multi-Agente"
            description="Sistema RAG com Gemini, Perplexity e Qdrant"
          />
          <FeatureCard
            icon="✅"
            title="Validação Inteligente"
            description="Score de qualidade e alertas preventivos"
          />
          <FeatureCard
            icon="📚"
            title="Base de Casos"
            description="Análise de projetos aprovados e reprovados"
          />
        </div>

        {/* CTA Button */}
        <div className="text-center">
          <Link href="/dashboard">
            <Button 
              size="lg" 
              className="text-xl px-12 py-6 bg-white text-blue-600 hover:bg-blue-50 shadow-2xl"
            >
              Acessar Dashboard →
            </Button>
          </Link>
        </div>

        {/* Stats */}
        <div className="grid grid-cols-3 gap-8 mt-20 text-white text-center">
          <div className="animate-fade-in" style={{animationDelay: '0.1s'}}>
            <div className="text-5xl font-bold">7</div>
            <div className="text-blue-200">Anexos Obrigatórios</div>
          </div>
          <div className="animate-fade-in" style={{animationDelay: '0.2s'}}>
            <div className="text-5xl font-bold">3</div>
            <div className="text-blue-200">Agentes de IA</div>
          </div>
          <div className="animate-fade-in" style={{animationDelay: '0.3s'}}>
            <div className="text-5xl font-bold">100%</div>
            <div className="text-blue-200">Conformidade Legal</div>
          </div>
        </div>
      </div>
    </div>
  )
}

function FeatureCard({ icon, title, description }: any) {
  return (
    <Card className="bg-white/10 backdrop-blur-lg border-white/20 hover-scale">
      <CardContent className="p-6 text-center text-white">
        <div className="text-6xl mb-4">{icon}</div>
        <h3 className="text-2xl font-bold mb-2">{title}</h3>
        <p className="text-blue-100">{description}</p>
      </CardContent>
    </Card>
  )
}
HOMEEOF

echo "✅ Homepage criada"

# ═══════════════════════════════════════════════════════════════
# 3. DASHBOARD PROFISSIONAL
# ═══════════════════════════════════════════════════════════════

cat > frontend/src/app/dashboard/page.tsx << 'DASHEOF'
'use client'
import { useEffect, useState } from 'react'
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import Link from 'next/link'

export default function Dashboard() {
  const [projects, setProjects] = useState<any[]>([])
  const [stats, setStats] = useState({
    total: 0,
    draft: 0,
    submitted: 0,
    approved: 0,
    avgCompletion: 0
  })
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadData()
  }, [])

  const loadData = async () => {
    try {
      const response = await fetch('http://72.60.255.80:8000/api/projects/')
      const data = await response.json()
      setProjects(data)
      
      setStats({
        total: data.length,
        draft: data.filter((p: any) => p.status === 'DRAFT').length,
        submitted: data.filter((p: any) => p.status === 'submetido').length,
        approved: data.filter((p: any) => p.status === 'aprovado').length,
        avgCompletion: data.reduce((acc: number, p: any) => acc + (p.completion_percentage || 0), 0) / (data.length || 1)
      })
    } catch (error) {
      console.error('Erro:', error)
    } finally {
      setLoading(false)
    }
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="spinner"></div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-blue-50">
      {/* Header */}
      <div className="bg-white shadow-sm border-b sticky top-0 z-10">
        <div className="max-w-7xl mx-auto px-8 py-6">
          <div className="flex justify-between items-center">
            <div>
              <h1 className="text-3xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
                Dashboard PRONAS/PCD
              </h1>
              <p className="text-gray-600 mt-1">Sistema RAG Multi-Agente com IA</p>
            </div>
            <Link href="/projeto/novo">
              <Button size="lg" className="shadow-lg">
                ➕ Novo Projeto
              </Button>
            </Link>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-8 py-8">
        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <StatCard 
            title="Total de Projetos" 
            value={stats.total} 
            icon="📊"
            gradient="from-blue-500 to-blue-600"
          />
          <StatCard 
            title="Em Elaboração" 
            value={stats.draft} 
            icon="✏️"
            gradient="from-yellow-500 to-orange-500"
          />
          <StatCard 
            title="Submetidos" 
            value={stats.submitted} 
            icon="📤"
            gradient="from-purple-500 to-pink-500"
          />
          <StatCard 
            title="Aprovados" 
            value={stats.approved} 
            icon="✅"
            gradient="from-green-500 to-emerald-600"
          />
        </div>

        {/* Progress */}
        <Card className="mb-8 shadow-lg">
          <CardHeader>
            <CardTitle>Conclusão Média dos Anexos</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="flex items-center gap-4">
              <div className="flex-1 bg-gray-200 rounded-full h-10 overflow-hidden">
                <div 
                  className="bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500 h-10 flex items-center justify-center text-white font-bold transition-all duration-500"
                  style={{ width: `${stats.avgCompletion}%` }}
                >
                  {stats.avgCompletion > 10 && `${stats.avgCompletion.toFixed(0)}%`}
                </div>
              </div>
              <span className="text-3xl font-bold text-gray-700">
                {stats.avgCompletion.toFixed(0)}%
              </span>
            </div>
          </CardContent>
        </Card>

        {/* Projects List */}
        <Card className="shadow-lg">
          <CardHeader>
            <CardTitle>Meus Projetos</CardTitle>
          </CardHeader>
          <CardContent>
            {projects.length === 0 ? (
              <div className="text-center py-16">
                <div className="text-8xl mb-4">��</div>
                <p className="text-gray-500 text-xl mb-6">Nenhum projeto cadastrado</p>
                <Link href="/projeto/novo">
                  <Button size="lg">🚀 Criar Primeiro Projeto</Button>
                </Link>
              </div>
            ) : (
              <div className="space-y-4">
                {projects.map((project) => (
                  <ProjectCard key={project.id} project={project} onUpdate={loadData} />
                ))}
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  )
}

function StatCard({ title, value, icon, gradient }: any) {
  return (
    <Card className="overflow-hidden hover-scale shadow-lg">
      <CardContent className="p-0">
        <div className={`h-2 bg-gradient-to-r ${gradient}`}></div>
        <div className="p-6">
          <div className="text-4xl mb-3">{icon}</div>
          <p className="text-gray-600 text-sm mb-1">{title}</p>
          <p className="text-4xl font-bold text-gray-900">{value}</p>
        </div>
      </CardContent>
    </Card>
  )
}

function ProjectCard({ project, onUpdate }: any) {
  const statusConfig: any = {
    'DRAFT': { label: 'Em Elaboração', variant: 'warning', color: 'text-yellow-700' },
    'submetido': { label: 'Submetido', variant: 'default', color: 'text-blue-700' },
    'aprovado': { label: 'Aprovado', variant: 'success', color: 'text-green-700' },
    'rejeitado': { label: 'Rejeitado', variant: 'danger', color: 'text-red-700' }
  }

  const config = statusConfig[project.status] || statusConfig['DRAFT']

  return (
    <div className="border-2 rounded-xl p-6 hover:shadow-xl transition-all bg-white hover-scale">
      <div className="flex justify-between items-start">
        <div className="flex-1">
          <div className="flex items-center gap-3 mb-3">
            <h3 className="text-2xl font-bold text-gray-900">{project.title}</h3>
            <Badge variant={config.variant}>{config.label}</Badge>
          </div>
          
          <div className="flex gap-6 text-sm text-gray-600 mb-4">
            <span className="flex items-center gap-1">
              <span className="font-semibold">ID:</span> #{project.id}
            </span>
            <span className="flex items-center gap-1">
              <span className="font-semibold">Área:</span> 
              {project.field?.replace(/_/g, ' ').substring(0, 30)}...
            </span>
          </div>
          
          {/* Progress Bar */}
          <div className="flex items-center gap-3">
            <div className="flex-1 bg-gray-200 rounded-full h-4 overflow-hidden">
              <div 
                className="bg-gradient-to-r from-blue-500 to-purple-500 h-4 rounded-full transition-all duration-500"
                style={{ width: `${project.completion_percentage}%` }}
              />
            </div>
            <span className="text-lg font-bold text-gray-700 min-w-[4rem] text-right">
              {project.completion_percentage}%
            </span>
          </div>
        </div>
        
        <div className="flex gap-2 ml-6">
          <Link href={`/projeto/${project.id}/editar`}>
            <Button variant="outline" className="shadow">
              ✏️ Editar
            </Button>
          </Link>
        </div>
      </div>
    </div>
  )
}
DASHEOF

echo "✅ Dashboard melhorado"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ FRONTEND PROFISSIONAL COMPLETO!"
echo "═══════════════════════════════════════════════════════════════"

