#!/bin/bash
set -e

echo "🎨 Aplicando Tema PRIME Projetos Sociais..."

# ═══════════════════════════════════════════════════════════════
# 1. CSS PROFISSIONAL COM PALETA PRIME
# ═══════════════════════════════════════════════════════════════

cat > frontend/src/app/globals.css << 'CSSEOF'
/* ═══════════════════════════════════════════════════════════════
   PRIME - Sistema PRONAS/PCD
   Design Profissional baseado na identidade PRIME Projetos Sociais
   ═══════════════════════════════════════════════════════════════ */

/* PALETA DE CORES PRIME */
:root {
  /* Cores Primárias */
  --azul-corporativo: #1A4A6D;
  --dourado-elegante: #B5A68B;
  
  /* Neutros */
  --branco-gelo: #FDFCF9;
  --cinza-claro: #F5F2ED;
  --grafite: #2c2c2c;
  --cinza-medio: #6c757d;
  --cinza-suave: #E0E0E0;
  --branco: #FFFFFF;
  
  /* Variações do Azul */
  --azul-escuro: #0F2E44;
  --azul-hover: #2A5F82;
  --azul-claro: #E8F1F8;
  
  /* Variações do Dourado */
  --dourado-hover: #A89672;
  --dourado-claro: #F5F0E8;
  
  /* Status */
  --verde-sucesso: #4CAF50;
  --amarelo-alerta: #FFC107;
  --vermelho-erro: #F44336;
}

/* Reset e Base */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  line-height: 1.6;
  color: var(--grafite);
  background: var(--branco-gelo);
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

/* ═══════════════════════════════════════════════════════════════
   LAYOUT E ESTRUTURA
   ═══════════════════════════════════════════════════════════════ */

.container {
  max-width: 1280px;
  margin: 0 auto;
  padding: 0 2rem;
}

.min-h-screen {
  min-height: 100vh;
}

/* ═══════════════════════════════════════════════════════════════
   HEADER / NAVBAR
   ═══════════════════════════════════════════════════════════════ */

.header-prime {
  background: var(--azul-corporativo);
  color: var(--branco-gelo);
  box-shadow: 0 2px 8px rgba(26, 74, 109, 0.2);
  position: sticky;
  top: 0;
  z-index: 100;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem 2rem;
}

.logo-prime {
  font-size: 2rem;
  font-weight: 700;
  color: var(--dourado-elegante);
  text-decoration: none;
}

.subtitle-prime {
  font-size: 0.875rem;
  color: var(--cinza-claro);
  margin-top: 0.25rem;
}

/* ═══════════════════════════════════════════════════════════════
   HERO SECTION (Homepage)
   ═══════════════════════════════════════════════════════════════ */

.hero-prime {
  background: linear-gradient(135deg, var(--azul-corporativo) 0%, var(--azul-escuro) 100%);
  color: var(--branco-gelo);
  padding: 6rem 2rem;
  text-align: center;
  position: relative;
  overflow: hidden;
}

.hero-prime::before {
  content: '';
  position: absolute;
  top: -50%;
  right: -10%;
  width: 60%;
  height: 200%;
  background: radial-gradient(circle, rgba(181, 166, 139, 0.1) 0%, transparent 70%);
  animation: float 20s infinite ease-in-out;
}

@keyframes float {
  0%, 100% { transform: translateY(0) rotate(0deg); }
  50% { transform: translateY(-20px) rotate(5deg); }
}

.hero-title {
  font-size: 4rem;
  font-weight: 800;
  margin-bottom: 1rem;
  position: relative;
  z-index: 1;
}

.hero-title-accent {
  color: var(--dourado-elegante);
}

.hero-subtitle {
  font-size: 1.5rem;
  color: var(--cinza-claro);
  margin-bottom: 0.5rem;
}

.hero-badge {
  display: inline-block;
  background: var(--dourado-elegante);
  color: var(--azul-corporativo);
  padding: 0.5rem 1.5rem;
  border-radius: 2rem;
  font-weight: 600;
  font-size: 0.875rem;
  margin-top: 1rem;
}

/* ═══════════════════════════════════════════════════════════════
   CARDS
   ═══════════════════════════════════════════════════════════════ */

.card {
  background: var(--branco);
  border: 1px solid var(--cinza-suave);
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
  transition: all 0.3s ease;
  overflow: hidden;
}

.card:hover {
  box-shadow: 0 8px 24px rgba(26, 74, 109, 0.15);
  transform: translateY(-4px);
  border-color: var(--azul-corporativo);
}

.card-header {
  padding: 1.5rem;
  border-bottom: 1px solid var(--cinza-suave);
}

.card-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--azul-corporativo);
  margin: 0;
}

.card-content {
  padding: 1.5rem;
}

/* Card com Destaque Dourado */
.card-featured {
  border-top: 4px solid var(--dourado-elegante);
}

/* Card de Estatística */
.stat-card {
  text-align: center;
  padding: 2rem;
}

.stat-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
}

.stat-value {
  font-size: 3rem;
  font-weight: 800;
  color: var(--azul-corporativo);
  display: block;
  margin-bottom: 0.5rem;
}

.stat-label {
  color: var(--cinza-medio);
  font-size: 0.875rem;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

/* ═══════════════════════════════════════════════════════════════
   BOTÕES
   ═══════════════════════════════════════════════════════════════ */

.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 0.875rem 1.75rem;
  font-weight: 600;
  font-size: 1rem;
  border-radius: 8px;
  border: none;
  cursor: pointer;
  transition: all 0.2s ease;
  text-decoration: none;
  font-family: inherit;
}

/* Botão Primário (Azul Corporativo) */
.btn-primary {
  background: var(--azul-corporativo);
  color: var(--branco-gelo);
  box-shadow: 0 4px 12px rgba(26, 74, 109, 0.3);
}

.btn-primary:hover {
  background: var(--azul-hover);
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(26, 74, 109, 0.4);
}

/* Botão Secundário (Outline Azul) */
.btn-outline {
  background: transparent;
  border: 2px solid var(--azul-corporativo);
  color: var(--azul-corporativo);
}

.btn-outline:hover {
  background: var(--azul-claro);
}

/* Botão de Destaque (Dourado) */
.btn-gold {
  background: var(--dourado-elegante);
  color: var(--azul-corporativo);
  box-shadow: 0 4px 12px rgba(181, 166, 139, 0.3);
}

.btn-gold:hover {
  background: var(--dourado-hover);
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(181, 166, 139, 0.4);
}

/* Tamanhos */
.btn-sm {
  padding: 0.5rem 1rem;
  font-size: 0.875rem;
}

.btn-lg {
  padding: 1.25rem 2.5rem;
  font-size: 1.125rem;
  border-radius: 10px;
}

/* ═══════════════════════════════════════════════════════════════
   BADGES / TAGS
   ═══════════════════════════════════════════════════════════════ */

.badge {
  display: inline-flex;
  align-items: center;
  padding: 0.375rem 1rem;
  border-radius: 2rem;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.badge-warning {
  background: #FFF4E5;
  color: #E65100;
}

.badge-success {
  background: #E8F5E9;
  color: #2E7D32;
}

.badge-info {
  background: var(--azul-claro);
  color: var(--azul-corporativo);
}

.badge-gold {
  background: var(--dourado-claro);
  color: var(--azul-corporativo);
  border: 1px solid var(--dourado-elegante);
}

/* ═══════════════════════════════════════════════════════════════
   PROGRESS BAR
   ═══════════════════════════════════════════════════════════════ */

.progress-container {
  width: 100%;
  height: 2.5rem;
  background: var(--cinza-claro);
  border-radius: 1.25rem;
  overflow: hidden;
  position: relative;
}

.progress-bar {
  height: 100%;
  background: linear-gradient(90deg, var(--azul-corporativo) 0%, var(--dourado-elegante) 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: 700;
  font-size: 0.875rem;
  transition: width 0.8s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: inset 0 2px 4px rgba(0,0,0,0.1);
}

/* ═══════════════════════════════════════════════════════════════
   FORMULÁRIOS
   ═══════════════════════════════════════════════════════════════ */

.form-group {
  margin-bottom: 1.5rem;
}

.form-label {
  display: block;
  font-weight: 600;
  color: var(--azul-corporativo);
  margin-bottom: 0.5rem;
  font-size: 0.875rem;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.form-input,
.form-select,
.form-textarea {
  width: 100%;
  padding: 0.875rem 1rem;
  border: 2px solid var(--cinza-suave);
  border-radius: 8px;
  font-size: 1rem;
  font-family: inherit;
  color: var(--grafite);
  background: var(--branco);
  transition: all 0.2s ease;
}

.form-input:focus,
.form-select:focus,
.form-textarea:focus {
  outline: none;
  border-color: var(--azul-corporativo);
  box-shadow: 0 0 0 4px var(--azul-claro);
}

.form-textarea {
  resize: vertical;
  min-height: 120px;
}

/* ═══════════════════════════════════════════════════════════════
   GRID E LAYOUT
   ═══════════════════════════════════════════════════════════════ */

.grid {
  display: grid;
  gap: 2rem;
}

.grid-cols-2 { grid-template-columns: repeat(2, 1fr); }
.grid-cols-3 { grid-template-columns: repeat(3, 1fr); }
.grid-cols-4 { grid-template-columns: repeat(4, 1fr); }

@media (max-width: 768px) {
  .grid-cols-2,
  .grid-cols-3,
  .grid-cols-4 {
    grid-template-columns: 1fr;
  }
}

/* Flex Utilities */
.flex { display: flex; }
.flex-col { flex-direction: column; }
.items-center { align-items: center; }
.justify-between { justify-content: space-between; }
.justify-center { justify-content: center; }
.gap-2 { gap: 0.5rem; }
.gap-4 { gap: 1rem; }
.gap-6 { gap: 1.5rem; }

/* ═══════════════════════════════════════════════════════════════
   SPACING UTILITIES
   ═══════════════════════════════════════════════════════════════ */

.p-4 { padding: 1rem; }
.p-6 { padding: 1.5rem; }
.p-8 { padding: 2rem; }
.py-4 { padding-top: 1rem; padding-bottom: 1rem; }
.py-6 { padding-top: 1.5rem; padding-bottom: 1.5rem; }
.py-8 { padding-top: 2rem; padding-bottom: 2rem; }
.py-20 { padding-top: 5rem; padding-bottom: 5rem; }

.mb-2 { margin-bottom: 0.5rem; }
.mb-4 { margin-bottom: 1rem; }
.mb-6 { margin-bottom: 1.5rem; }
.mb-8 { margin-bottom: 2rem; }
.mb-12 { margin-bottom: 3rem; }

/* ═══════════════════════════════════════════════════════════════
   TIPOGRAFIA
   ═══════════════════════════════════════════════════════════════ */

.text-center { text-align: center; }
.font-bold { font-weight: 700; }
.font-semibold { font-weight: 600; }

.text-sm { font-size: 0.875rem; }
.text-base { font-size: 1rem; }
.text-lg { font-size: 1.125rem; }
.text-xl { font-size: 1.25rem; }
.text-2xl { font-size: 1.5rem; }
.text-3xl { font-size: 1.875rem; }
.text-4xl { font-size: 2.25rem; }

/* ═══════════════════════════════════════════════════════════════
   ANIMAÇÕES
   ═══════════════════════════════════════════════════════════════ */

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-fade-in {
  animation: fadeInUp 0.6s ease-out;
}

.spinner {
  border: 4px solid var(--cinza-claro);
  border-top: 4px solid var(--azul-corporativo);
  border-radius: 50%;
  width: 48px;
  height: 48px;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* ═══════════════════════════════════════════════════════════════
   UTILITIES DIVERSAS
   ═══════════════════════════════════════════════════════════════ */

.shadow-sm { box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
.shadow-md { box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
.shadow-lg { box-shadow: 0 10px 30px rgba(26, 74, 109, 0.15); }

.rounded { border-radius: 0.5rem; }
.rounded-lg { border-radius: 0.75rem; }
.rounded-xl { border-radius: 1rem; }

.border { border: 1px solid var(--cinza-suave); }
.border-2 { border: 2px solid var(--cinza-suave); }

.overflow-hidden { overflow: hidden; }
.sticky { position: sticky; }
.relative { position: relative; }

/* Cores de Texto */
.text-primary { color: var(--azul-corporativo); }
.text-gold { color: var(--dourado-elegante); }
.text-gray { color: var(--cinza-medio); }
.text-white { color: var(--branco-gelo); }

/* Backgrounds */
.bg-primary { background-color: var(--azul-corporativo); }
.bg-gold { background-color: var(--dourado-elegante); }
.bg-light { background-color: var(--cinza-claro); }
.bg-white { background-color: var(--branco); }
CSSEOF

echo "✅ CSS PRIME criado"

# Continua no próximo bloco...

# ═══════════════════════════════════════════════════════════════
# PARTE 2: HOMEPAGE COM TEMA PRIME
# ═══════════════════════════════════════════════════════════════

cat > frontend/src/app/page.tsx << 'HOMEEOF'
'use client'
import Link from 'next/link'

export default function Home() {
  return (
    <div className="min-h-screen">
      {/* Hero Section */}
      <section className="hero-prime">
        <div className="container">
          <h1 className="hero-title animate-fade-in">
            <span className="hero-title-accent">PRIME</span> PRONAS/PCD
          </h1>
          <p className="hero-subtitle">
            Sistema Inteligente com IA para Elaboração dos 7 Anexos Obrigatórios
          </p>
          <div className="hero-badge">Portaria GM/MS 8.031/2025</div>
          
          <div style={{ marginTop: '3rem' }}>
            <Link href="/dashboard">
              <button className="btn btn-gold btn-lg">
                🚀 Acessar Dashboard
              </button>
            </Link>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20" style={{ background: 'var(--cinza-claro)' }}>
        <div className="container">
          <div className="text-center mb-12">
            <h2 className="text-4xl font-bold text-primary mb-4">
              Funcionalidades Avançadas
            </h2>
            <p className="text-lg text-gray">
              Sistema completo com Inteligência Artificial Multi-Agente
            </p>
          </div>

          <div className="grid grid-cols-3">
            <FeatureCard
              icon="🤖"
              title="IA Multi-Agente"
              description="Sistema RAG com Gemini, Perplexity e Qdrant para sugestões contextualizadas"
              accent="primary"
            />
            <FeatureCard
              icon="✅"
              title="Validação Inteligente"
              description="Score de qualidade 0-100 e alertas preventivos automáticos"
              accent="gold"
            />
            <FeatureCard
              icon="📚"
              title="Base de Casos"
              description="Análise de projetos aprovados e reprovados similares"
              accent="primary"
            />
          </div>
        </div>
      </section>

      {/* Stats Section */}
      <section className="py-20 bg-primary text-white">
        <div className="container">
          <div className="grid grid-cols-4">
            <StatItem number="7" label="Anexos Obrigatórios" />
            <StatItem number="3" label="Agentes de IA" />
            <StatItem number="100%" label="Conformidade Legal" />
            <StatItem number="5" label="Casos Históricos" />
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20" style={{ background: 'var(--dourado-claro)' }}>
        <div className="container text-center">
          <h2 className="text-4xl font-bold text-primary mb-6">
            Pronto para Elaborar seu Projeto?
          </h2>
          <p className="text-lg text-gray mb-8">
            Utilize nossa plataforma completa com assistência de IA
          </p>
          <Link href="/projeto/novo">
            <button className="btn btn-primary btn-lg">
              ➕ Criar Primeiro Projeto
            </button>
          </Link>
        </div>
      </section>
    </div>
  )
}

function FeatureCard({ icon, title, description, accent }: any) {
  const borderClass = accent === 'gold' ? 'border-top: 4px solid var(--dourado-elegante)' : 'border-top: 4px solid var(--azul-corporativo)'
  
  return (
    <div className="card card-featured animate-fade-in" style={{ borderTop: borderClass === 'gold' ? '4px solid var(--dourado-elegante)' : '4px solid var(--azul-corporativo)' }}>
      <div className="card-content text-center">
        <div style={{ fontSize: '4rem', marginBottom: '1rem' }}>{icon}</div>
        <h3 className="text-2xl font-bold text-primary mb-3">{title}</h3>
        <p className="text-gray">{description}</p>
      </div>
    </div>
  )
}

function StatItem({ number, label }: any) {
  return (
    <div className="text-center animate-fade-in">
      <div className="text-6xl font-bold text-gold mb-2">{number}</div>
      <div className="text-lg" style={{ color: 'var(--cinza-claro)' }}>{label}</div>
    </div>
  )
}
HOMEEOF

echo "✅ Homepage PRIME criada"

# ═══════════════════════════════════════════════════════════════
# PARTE 3: DASHBOARD COM TEMA PRIME
# ═══════════════════════════════════════════════════════════════

cat > frontend/src/app/dashboard/page.tsx << 'DASHEOF'
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
DASHEOF

echo "✅ Dashboard PRIME criado"

# ═══════════════════════════════════════════════════════════════
# PARTE 4: PÁGINA DE NOVO PROJETO
# ═══════════════════════════════════════════════════════════════

cat > frontend/src/app/projeto/novo/page.tsx << 'NEWPROJEOF'
'use client'
import { useState } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'

export default function NovoProjeto() {
  const router = useRouter()
  const [loading, setLoading] = useState(false)
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    field: 'prestacao_servicos_medico_assistenciais',
    institution_name: '',
    institution_cnpj: '',
    priority_area: ''
  })

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)

    try {
      const response = await fetch('http://72.60.255.80:8000/api/projects/', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData)
      })

      if (!response.ok) throw new Error('Erro ao criar projeto')

      const project = await response.json()
      alert('✅ Projeto criado com sucesso!')
      router.push(`/projeto/${project.id}/editar`)
    } catch (error) {
      console.error(error)
      alert('❌ Erro ao criar projeto')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen" style={{ background: 'var(--cinza-claro)' }}>
      {/* Header */}
      <header className="header-prime">
        <div className="header-content">
          <Link href="/dashboard" className="logo-prime">
            PRIME PRONAS/PCD
          </Link>
        </div>
      </header>

      <div className="container py-8">
        <div style={{ maxWidth: '800px', margin: '0 auto' }}>
          <div className="card">
            <div className="card-header" style={{ background: 'var(--azul-corporativo)', color: 'white' }}>
              <h1 className="card-title" style={{ color: 'var(--dourado-elegante)' }}>
                Criar Novo Projeto PRONAS/PCD
              </h1>
              <p className="text-sm" style={{ color: 'var(--cinza-claro)', marginTop: '0.5rem' }}>
                Preencha as informações básicas do seu projeto
              </p>
            </div>
            
            <div className="card-content" style={{ padding: '2rem' }}>
              <form onSubmit={handleSubmit}>
                {/* Título */}
                <div className="form-group">
                  <label className="form-label">Título do Projeto *</label>
                  <input
                    type="text"
                    required
                    value={formData.title}
                    onChange={(e) => setFormData({...formData, title: e.target.value})}
                    className="form-input"
                    placeholder="Ex: Centro de Reabilitação Física Integrado"
                  />
                </div>

                {/* Descrição */}
                <div className="form-group">
                  <label className="form-label">Descrição Breve</label>
                  <textarea
                    value={formData.description}
                    onChange={(e) => setFormData({...formData, description: e.target.value})}
                    className="form-textarea"
                    placeholder="Breve descrição do objetivo do projeto"
                  />
                </div>

                {/* Área */}
                <div className="form-group">
                  <label className="form-label">Área do Projeto *</label>
                  <select
                    required
                    value={formData.field}
                    onChange={(e) => setFormData({...formData, field: e.target.value})}
                    className="form-select"
                  >
                    <option value="prestacao_servicos_medico_assistenciais">
                      Prestação de Serviços Médico-Assistenciais
                    </option>
                    <option value="formacao_treinamento_recursos_humanos">
                      Formação e Treinamento de Recursos Humanos
                    </option>
                    <option value="realizacao_pesquisas">
                      Realização de Pesquisas
                    </option>
                  </select>
                </div>

                {/* Área Prioritária */}
                <div className="form-group">
                  <label className="form-label">Área Prioritária</label>
                  <input
                    type="text"
                    value={formData.priority_area}
                    onChange={(e) => setFormData({...formData, priority_area: e.target.value})}
                    className="form-input"
                    placeholder="Ex: Reabilitação Física, TEA, Deficiência Visual"
                  />
                </div>

                {/* Instituição */}
                <div className="form-group">
                  <label className="form-label">Nome da Instituição *</label>
                  <input
                    type="text"
                    required
                    value={formData.institution_name}
                    onChange={(e) => setFormData({...formData, institution_name: e.target.value})}
                    className="form-input"
                    placeholder="Ex: Hospital Regional de Saúde"
                  />
                </div>

                {/* CNPJ */}
                <div className="form-group">
                  <label className="form-label">CNPJ da Instituição *</label>
                  <input
                    type="text"
                    required
                    value={formData.institution_cnpj}
                    onChange={(e) => setFormData({...formData, institution_cnpj: e.target.value})}
                    className="form-input"
                    placeholder="00.000.000/0000-00"
                  />
                </div>

                {/* Botões */}
                <div className="flex gap-4" style={{ marginTop: '2rem' }}>
                  <Link href="/dashboard" style={{ flex: 1 }}>
                    <button type="button" className="btn btn-outline" style={{ width: '100%' }}>
                      ← Cancelar
                    </button>
                  </Link>
                  <button type="submit" disabled={loading} className="btn btn-primary" style={{ flex: 2 }}>
                    {loading ? '⏳ Criando...' : '✅ Criar Projeto'}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
NEWPROJEOF

echo "✅ Página de novo projeto criada"

# Rebuild frontend
echo ""
echo "🔨 Rebuilding frontend..."
docker compose build --no-cache frontend
docker compose up -d frontend

echo "⏳ Aguardando 20 segundos..."
sleep 20

docker compose logs frontend | tail -15

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ TEMA PRIME APLICADO COM SUCESSO!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "🎨 Design Profissional PRIME implementado"
echo "🌐 Acesse: http://72.60.255.80:3000"
echo ""
echo "Páginas disponíveis:"
echo "  • Homepage:      http://72.60.255.80:3000"
echo "  • Dashboard:     http://72.60.255.80:3000/dashboard"
echo "  • Novo Projeto:  http://72.60.255.80:3000/projeto/novo"
echo ""

