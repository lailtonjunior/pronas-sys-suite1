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
