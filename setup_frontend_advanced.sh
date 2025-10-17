#!/bin/bash
set -e

echo "🎨 Configurando Frontend Avançado..."

# ═══════════════════════════════════════════════════════════════
# 1. COMPONENTES UI BASE (Shadcn/UI)
# ═══════════════════════════════════════════════════════════════

mkdir -p frontend/src/components/ui

# Button Component
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

# Card Component
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

# Badge Component
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

# ═══════════════════════════════════════════════════════════════
# 2. DASHBOARD AVANÇADO
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
        draft: data.filter((p: any) => p.status === 'em_elaboracao').length,
        submitted: data.filter((p: any) => p.status === 'submetido').length,
        approved: data.filter((p: any) => p.status === 'aprovado').length,
        avgCompletion: data.reduce((acc: number, p: any) => acc + (p.completion_percentage || 0), 0) / (data.length || 1)
      })
    } catch (error) {
      console.error('Erro ao carregar dados:', error)
    } finally {
      setLoading(false)
    }
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center">
        <div className="text-xl">Carregando...</div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      {/* Header */}
      <div className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-8 py-6">
          <div className="flex justify-between items-center">
            <div>
              <h1 className="text-3xl font-bold text-blue-900">Dashboard PRONAS/PCD</h1>
              <p className="text-gray-600 mt-1">Sistema RAG Multi-Agente com IA</p>
            </div>
            <Link href="/projeto/novo">
              <Button size="lg">+ Novo Projeto</Button>
            </Link>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-8 py-8">
        {/* Cards de Estatísticas */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <StatCard 
            title="Total de Projetos" 
            value={stats.total} 
            icon="📊"
            color="blue" 
          />
          <StatCard 
            title="Em Elaboração" 
            value={stats.draft} 
            icon="✏️"
            color="yellow" 
          />
          <StatCard 
            title="Submetidos" 
            value={stats.submitted} 
            icon="📤"
            color="purple" 
          />
          <StatCard 
            title="Aprovados" 
            value={stats.approved} 
            icon="✅"
            color="green" 
          />
        </div>

        {/* Progresso Médio */}
        <Card className="mb-8">
          <CardHeader>
            <CardTitle>Conclusão Média dos Anexos</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="flex items-center gap-4">
              <div className="flex-1 bg-gray-200 rounded-full h-8">
                <div 
                  className="bg-gradient-to-r from-blue-500 to-green-500 h-8 rounded-full flex items-center justify-center text-white font-bold transition-all"
                  style={{ width: `${stats.avgCompletion}%` }}
                >
                  {stats.avgCompletion.toFixed(0)}%
                </div>
              </div>
              <span className="text-2xl font-bold text-gray-700">{stats.avgCompletion.toFixed(0)}%</span>
            </div>
          </CardContent>
        </Card>

        {/* Lista de Projetos */}
        <Card>
          <CardHeader>
            <CardTitle>Meus Projetos</CardTitle>
          </CardHeader>
          <CardContent>
            {projects.length === 0 ? (
              <div className="text-center py-12">
                <div className="text-6xl mb-4">📝</div>
                <p className="text-gray-500 text-lg mb-4">Nenhum projeto cadastrado</p>
                <Link href="/projeto/novo">
                  <Button>Criar Primeiro Projeto</Button>
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

function StatCard({ title, value, icon, color }: any) {
  const colors: any = {
    blue: 'from-blue-500 to-blue-600',
    green: 'from-green-500 to-green-600',
    yellow: 'from-yellow-500 to-yellow-600',
    purple: 'from-purple-500 to-purple-600'
  }
  
  return (
    <Card>
      <CardContent className="pt-6">
        <div className={`w-12 h-12 rounded-lg bg-gradient-to-br ${colors[color]} flex items-center justify-center text-2xl mb-4`}>
          {icon}
        </div>
        <p className="text-gray-600 text-sm mb-1">{title}</p>
        <p className="text-3xl font-bold">{value}</p>
      </CardContent>
    </Card>
  )
}

function ProjectCard({ project, onUpdate }: any) {
  const statusColors: any = {
    'em_elaboracao': 'warning',
    'submetido': 'default',
    'aprovado': 'success',
    'rejeitado': 'danger'
  }

  const statusLabels: any = {
    'em_elaboracao': 'Em Elaboração',
    'submetido': 'Submetido',
    'aprovado': 'Aprovado',
    'rejeitado': 'Rejeitado'
  }

  return (
    <div className="border rounded-lg p-6 hover:shadow-md transition-shadow bg-white">
      <div className="flex justify-between items-start">
        <div className="flex-1">
          <div className="flex items-center gap-3 mb-2">
            <h3 className="text-xl font-bold text-gray-900">{project.title}</h3>
            <Badge variant={statusColors[project.status]}>
              {statusLabels[project.status]}
            </Badge>
          </div>
          
          <div className="flex gap-6 text-sm text-gray-600 mb-4">
            <span>📋 ID: #{project.id}</span>
            <span>🏥 Área: {project.field?.replace(/_/g, ' ')}</span>
          </div>
          
          <div className="flex items-center gap-3">
            <div className="flex-1 bg-gray-200 rounded-full h-3">
              <div 
                className="bg-gradient-to-r from-blue-500 to-green-500 h-3 rounded-full transition-all"
                style={{ width: `${project.completion_percentage}%` }}
              />
            </div>
            <span className="text-sm font-semibold text-gray-700 min-w-[3rem]">
              {project.completion_percentage}%
            </span>
          </div>
        </div>
        
        <div className="flex gap-2 ml-6">
          <Link href={`/projeto/${project.id}/editar`}>
            <Button variant="outline">Editar Anexos</Button>
          </Link>
          <Link href={`/projeto/${project.id}`}>
            <Button>Ver Detalhes</Button>
          </Link>
        </div>
      </div>
    </div>
  )
}
DASHEOF

echo "✅ Dashboard avançado criado"

# ═══════════════════════════════════════════════════════════════
# 3. API CLIENT
# ═══════════════════════════════════════════════════════════════

mkdir -p frontend/src/lib

cat > frontend/src/lib/api.ts << 'APIEOF'
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://72.60.255.80:8000'

export const api = {
  // Projects
  async getProjects() {
    const res = await fetch(`${API_BASE_URL}/api/projects/`)
    if (!res.ok) throw new Error('Erro ao buscar projetos')
    return res.json()
  },

  async createProject(data: any) {
    const res = await fetch(`${API_BASE_URL}/api/projects/`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    })
    if (!res.ok) throw new Error('Erro ao criar projeto')
    return res.json()
  },

  async getProject(id: number) {
    const res = await fetch(`${API_BASE_URL}/api/projects/${id}`)
    if (!res.ok) throw new Error('Erro ao buscar projeto')
    return res.json()
  },

  // Anexos
  async getAnexo(id: number) {
    const res = await fetch(`${API_BASE_URL}/api/anexos/${id}`)
    if (!res.ok) throw new Error('Erro ao buscar anexo')
    return res.json()
  },

  async updateAnexo(id: number, data: any) {
    const res = await fetch(`${API_BASE_URL}/api/anexos/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ dados: data })
    })
    if (!res.ok) throw new Error('Erro ao atualizar anexo')
    return res.json()
  },

  async getProjectAnexos(projectId: number) {
    const res = await fetch(`${API_BASE_URL}/api/anexos/project/${projectId}`)
    if (!res.ok) throw new Error('Erro ao buscar anexos')
    return res.json()
  },

  // AI Assistant
  async getSuggestion(fieldName: string, fieldContext: any, projectContext: any) {
    const res = await fetch(`${API_BASE_URL}/api/ai/suggest`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        field_name: fieldName,
        field_context: fieldContext,
        project_context: projectContext
      })
    })
    if (!res.ok) throw new Error('Erro ao obter sugestão')
    return res.json()
  },

  async validateAnexo(anexoData: any, anexoType: string) {
    const res = await fetch(`${API_BASE_URL}/api/ai/validate`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        anexo_data: anexoData,
        anexo_type: anexoType
      })
    })
    if (!res.ok) throw new Error('Erro ao validar anexo')
    return res.json()
  },

  // Knowledge Base
  async getCases(approvedOnly?: boolean) {
    const url = approvedOnly 
      ? `${API_BASE_URL}/api/knowledge/cases?approved_only=true`
      : `${API_BASE_URL}/api/knowledge/cases`
    const res = await fetch(url)
    if (!res.ok) throw new Error('Erro ao buscar casos')
    return res.json()
  },

  async getCase(id: number) {
    const res = await fetch(`${API_BASE_URL}/api/knowledge/cases/${id}`)
    if (!res.ok) throw new Error('Erro ao buscar caso')
    return res.json()
  }
}
APIEOF

echo "✅ API client criado"

echo ""
echo "✅ Frontend base configurado!"
echo "Rebuild e reiniciar frontend..."

