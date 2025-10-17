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
