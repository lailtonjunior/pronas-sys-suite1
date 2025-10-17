'use client'
import { useEffect, useState } from 'react'
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
      <div className="min-h-screen flex items-center justify-center" style={{ background: 'var(--cinza-claro)' }}>
        <div className="spinner"></div>
      </div>
    )
  }

  return (
    <div className="min-h-screen" style={{ background: 'var(--cinza-claro)' }}>
      {/* Header */}
      <header className="header-prime">
        <div className="header-content">
          <div>
            <Link href="/" className="logo-prime">
              PRIME PRONAS/PCD
            </Link>
            <div className="subtitle-prime">Sistema RAG Multi-Agente</div>
          </div>
          <Link href="/projeto/novo">
            <button className="btn btn-gold">
              ➕ Novo Projeto
            </button>
          </Link>
        </div>
      </header>

      <div className="container py-8">
        {/* Stats Cards */}
        <div className="grid grid-cols-4 mb-8">
          <StatCard 
            title="Total de Projetos" 
            value={stats.total} 
            icon="📊"
          />
          <StatCard 
            title="Em Elaboração" 
            value={stats.draft} 
            icon="✏️"
          />
          <StatCard 
            title="Submetidos" 
            value={stats.submitted} 
            icon="📤"
          />
          <StatCard 
            title="Aprovados" 
            value={stats.approved} 
            icon="✅"
          />
        </div>

        {/* Progress */}
        <div className="card mb-8">
          <div className="card-header">
            <h2 className="card-title">Conclusão Média dos Anexos</h2>
          </div>
          <div className="card-content">
            <div className="flex items-center gap-4">
              <div className="progress-container" style={{ flex: 1 }}>
                <div 
                  className="progress-bar"
                  style={{ width: `${stats.avgCompletion}%` }}
                >
                  {stats.avgCompletion > 10 && `${stats.avgCompletion.toFixed(0)}%`}
                </div>
              </div>
              <span className="text-4xl font-bold text-primary">
                {stats.avgCompletion.toFixed(0)}%
              </span>
            </div>
          </div>
        </div>

        {/* Projects List */}
        <div className="card">
          <div className="card-header">
            <h2 className="card-title">Meus Projetos</h2>
          </div>
          <div className="card-content">
            {projects.length === 0 ? (
              <div className="text-center py-20">
                <div className="text-8xl mb-6">📝</div>
                <p className="text-xl text-gray mb-8">Nenhum projeto cadastrado</p>
                <Link href="/projeto/novo">
                  <button className="btn btn-primary btn-lg">
                    🚀 Criar Primeiro Projeto
                  </button>
                </Link>
              </div>
            ) : (
              <div className="flex flex-col gap-4">
                {projects.map((project) => (
                  <ProjectCard key={project.id} project={project} />
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}

function StatCard({ title, value, icon }: any) {
  return (
    <div className="card card-featured stat-card">
      <div className="stat-icon">{icon}</div>
      <span className="stat-value">{value}</span>
      <span className="stat-label">{title}</span>
    </div>
  )
}

function ProjectCard({ project }: any) {
  const statusConfig: any = {
    'DRAFT': { label: 'Em Elaboração', class: 'badge-warning' },
    'submetido': { label: 'Submetido', class: 'badge-info' },
    'aprovado': { label: 'Aprovado', class: 'badge-success' },
    'rejeitado': { label: 'Rejeitado', class: 'badge-danger' }
  }

  const config = statusConfig[project.status] || statusConfig['DRAFT']

  return (
    <div className="card" style={{ borderLeft: '4px solid var(--dourado-elegante)' }}>
      <div className="card-content">
        <div className="flex justify-between items-start">
          <div style={{ flex: 1 }}>
            <div className="flex items-center gap-3 mb-3">
              <h3 className="text-2xl font-bold text-primary">{project.title}</h3>
              <span className={`badge ${config.class}`}>{config.label}</span>
            </div>
            
            <div className="flex gap-6 text-sm text-gray mb-4">
              <span>📋 ID: #{project.id}</span>
              <span>🏥 {project.field?.substring(0, 30)}...</span>
            </div>
            
            <div className="flex items-center gap-3">
              <div className="progress-container" style={{ flex: 1, height: '1.5rem' }}>
                <div 
                  className="progress-bar"
                  style={{ width: `${project.completion_percentage}%`, fontSize: '0.75rem' }}
                >
                  {project.completion_percentage > 15 && `${project.completion_percentage}%`}
                </div>
              </div>
              <span className="text-xl font-bold text-primary">
                {project.completion_percentage}%
              </span>
            </div>
          </div>
          
          <div className="flex gap-2" style={{ marginLeft: '2rem' }}>
            <Link href={`/projeto/${project.id}/editar`}>
              <button className="btn btn-outline btn-sm">
                ✏️ Editar
              </button>
            </Link>
          </div>
        </div>
      </div>
    </div>
  )
}
