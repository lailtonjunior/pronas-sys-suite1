'use client'
import { useEffect, useState } from 'react'
import { useParams } from 'next/navigation'
import Link from 'next/link'

export default function EditarProjeto() {
  const params = useParams()
  const projectId = params.id
  const [project, setProject] = useState<any>(null)
  const [anexos, setAnexos] = useState<any[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadData()
  }, [projectId])

  const loadData = async () => {
    try {
      const [projectRes, anexosRes] = await Promise.all([
        fetch(`http://72.60.255.80:8000/api/projects/${projectId}`),
        fetch(`http://72.60.255.80:8000/api/anexos/project/${projectId}`)
      ])

      const projectData = await projectRes.json()
      const anexosData = await anexosRes.json()

      setProject(projectData)
      setAnexos(anexosData)
    } catch (error) {
      console.error('Erro ao carregar dados:', error)
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
          <Link href="/dashboard" className="logo-prime">
            PRIME PRONAS/PCD
          </Link>
          <Link href="/dashboard">
            <button className="btn btn-outline" style={{ color: 'white', borderColor: 'white' }}>
              ← Voltar ao Dashboard
            </button>
          </Link>
        </div>
      </header>

      <div className="container py-8">
        {/* Project Header */}
        <div className="card mb-8" style={{ borderLeft: '6px solid var(--dourado-elegante)' }}>
          <div className="card-content p-6">
            <div className="flex justify-between items-start">
              <div>
                <h1 className="text-3xl font-bold text-primary mb-2">{project?.title}</h1>
                <p className="text-gray">{project?.description}</p>
                <div className="flex gap-4 mt-4">
                  <span className="badge badge-info">ID: {project?.id}</span>
                  <span className="badge badge-warning">Em Elaboração</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Anexos Grid */}
        <div className="grid grid-cols-1 gap-4">
          {anexos.map((anexo, index) => (
            <AnexoCard key={anexo.id} anexo={anexo} index={index + 1} />
          ))}
        </div>
      </div>
    </div>
  )
}

function AnexoCard({ anexo, index }: any) {
  const anexoInfo: any = {
    'ANEXO_I': {
      nome: 'Declaração de Ciência e Concordância',
      desc: 'Declaração do responsável legal da instituição',
      icon: '��',
      importance: 'Obrigatório'
    },
    'ANEXO_II': {
      nome: 'Formulário de Apresentação de Projeto',
      desc: 'Formulário completo com 40+ campos (MAIS IMPORTANTE)',
      icon: '📝',
      importance: 'Crítico'
    },
    'ANEXO_III': {
      nome: 'Declaração de Capacidade Técnico-Operativa',
      desc: 'Comprovação de capacidade técnica da instituição',
      icon: '🏥',
      importance: 'Obrigatório'
    },
    'ANEXO_IV': {
      nome: 'Modelo de Orçamento',
      desc: 'Detalhamento completo de custos diretos e indiretos',
      icon: '💰',
      importance: 'Obrigatório'
    },
    'ANEXO_V': {
      nome: 'Formulário de Equipamentos',
      desc: 'Listagem detalhada de equipamentos (se aplicável)',
      icon: '🔧',
      importance: 'Condicional'
    },
    'ANEXO_VI': {
      nome: 'Requerimento de Habilitação',
      desc: 'Para instituições não habilitadas no Ministério',
      icon: '📄',
      importance: 'Condicional'
    },
    'ANEXO_VII': {
      nome: 'Minuta do Termo de Compromisso',
      desc: 'Modelo informativo para referência',
      icon: '✍️',
      importance: 'Informativo'
    }
  }

  const info = anexoInfo[anexo.tipo] || { nome: anexo.tipo, desc: '', icon: '📄', importance: '' }
  const completion = anexo.completion_score || 0
  const romanNumerals = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII']

  return (
    <div className="card animate-fade-in" style={{ 
      borderLeft: info.importance === 'Crítico' ? '4px solid var(--dourado-elegante)' : '4px solid var(--azul-corporativo)' 
    }}>
      <div className="card-content p-6">
        <div className="flex items-center gap-6">
          {/* Icon */}
          <div style={{ fontSize: '4rem', minWidth: '5rem', textAlign: 'center' }}>
            {info.icon}
          </div>
          
          {/* Content */}
          <div style={{ flex: 1 }}>
            <div className="flex items-center gap-3 mb-2">
              <h3 className="text-2xl font-bold text-primary">
                Anexo {romanNumerals[index - 1]}
              </h3>
              {info.importance && (
                <span className={`badge ${
                  info.importance === 'Crítico' ? 'badge-gold' :
                  info.importance === 'Obrigatório' ? 'badge-warning' :
                  'badge-info'
                }`}>
                  {info.importance}
                </span>
              )}
            </div>
            
            <p className="text-lg font-semibold text-gray mb-1">{info.nome}</p>
            <p className="text-sm text-gray mb-4">{info.desc}</p>
            
            {/* Progress Bar */}
            <div className="flex items-center gap-3">
              <div className="progress-container" style={{ flex: 1, height: '2rem' }}>
                <div 
                  className="progress-bar"
                  style={{ width: `${completion}%` }}
                >
                  {completion > 10 && `${completion}%`}
                </div>
              </div>
              <span className="text-xl font-bold text-primary" style={{ minWidth: '4rem', textAlign: 'right' }}>
                {completion}%
              </span>
            </div>
          </div>

          {/* Action Button */}
          <Link href={`/anexo/${anexo.id}`}>
            <button className={completion > 0 ? 'btn btn-outline' : 'btn btn-primary'}>
              {completion > 0 ? '✏️ Continuar' : '🚀 Iniciar'}
            </button>
          </Link>
        </div>
      </div>
    </div>
  )
}
