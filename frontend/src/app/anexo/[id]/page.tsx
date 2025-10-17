'use client'
import { useEffect, useState } from 'react'
import { useParams, useRouter } from 'next/navigation'
import Link from 'next/link'

export default function EditarAnexo() {
  const params = useParams()
  const router = useRouter()
  const anexoId = params.id
  
  const [anexo, setAnexo] = useState<any>(null)
  const [formData, setFormData] = useState<any>({})
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [aiSuggestion, setAiSuggestion] = useState<any>(null)
  const [loadingAI, setLoadingAI] = useState(false)

  useEffect(() => {
    loadAnexo()
  }, [anexoId])

  const loadAnexo = async () => {
    try {
      const response = await fetch(`http://72.60.255.80:8000/api/anexos/${anexoId}`)
      const data = await response.json()
      setAnexo(data)
      setFormData(data.dados || {})
    } catch (error) {
      console.error('Erro:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleSave = async () => {
    setSaving(true)
    try {
      const response = await fetch(`http://72.60.255.80:8000/api/anexos/${anexoId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ dados: formData })
      })

      if (!response.ok) throw new Error('Erro ao salvar')

      alert('✅ Anexo salvo com sucesso!')
      await loadAnexo()
    } catch (error) {
      console.error('Erro ao salvar:', error)
      alert('❌ Erro ao salvar anexo')
    } finally {
      setSaving(false)
    }
  }

  const getSuggestion = async (fieldName: string) => {
    setLoadingAI(true)
    try {
      const response = await fetch('http://72.60.255.80:8000/api/ai/suggest', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          field_name: fieldName,
          field_context: { current_value: formData[fieldName] || '' },
          project_context: {
            field: anexo?.project?.field || 'prestacao_servicos_medico_assistenciais',
            priority_area: 'Reabilitação',
            institution: 'Hospital'
          }
        })
      })

      const data = await response.json()
      setAiSuggestion({ fieldName, ...data })
    } catch (error) {
      console.error('Erro ao obter sugestão:', error)
    } finally {
      setLoadingAI(false)
    }
  }

  const applySuggestion = () => {
    if (aiSuggestion) {
      setFormData({
        ...formData,
        [aiSuggestion.fieldName]: aiSuggestion.suggestion
      })
      setAiSuggestion(null)
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
          <div className="flex gap-2">
            <button onClick={handleSave} disabled={saving} className="btn btn-gold">
              {saving ? '💾 Salvando...' : '💾 Salvar'}
            </button>
            <Link href={`/projeto/${anexo?.project_id}/editar`}>
              <button className="btn btn-outline" style={{ color: 'white', borderColor: 'white' }}>
                ← Voltar
              </button>
            </Link>
          </div>
        </div>
      </header>

      <div className="container py-8">
        <div className="grid" style={{ gridTemplateColumns: '2fr 1fr', gap: '2rem' }}>
          {/* Editor Principal */}
          <div>
            <div className="card mb-4">
              <div className="card-header" style={{ background: 'var(--azul-corporativo)', color: 'white' }}>
                <h1 className="card-title" style={{ color: 'var(--dourado-elegante)' }}>
                  {anexo?.nome}
                </h1>
                <p className="text-sm" style={{ color: 'var(--cinza-claro)', marginTop: '0.5rem' }}>
                  Anexo {anexo?.tipo?.replace('ANEXO_', '')}
                </p>
              </div>
            </div>

            <div className="card">
              <div className="card-content" style={{ padding: '2rem' }}>
                {/* Exemplo de campos do Anexo II */}
                <div className="form-group">
                  <label className="form-label">Título do Projeto</label>
                  <div className="flex gap-2">
                    <input
                      type="text"
                      value={formData.titulo_projeto || ''}
                      onChange={(e) => setFormData({...formData, titulo_projeto: e.target.value})}
                      className="form-input"
                      placeholder="Nome completo do projeto"
                      style={{ flex: 1 }}
                    />
                    <button 
                      onClick={() => getSuggestion('titulo_projeto')}
                      className="btn btn-outline btn-sm"
                      disabled={loadingAI}
                    >
                      🤖 IA
                    </button>
                  </div>
                </div>

                <div className="form-group">
                  <label className="form-label">Justificativa</label>
                  <div className="flex gap-2" style={{ alignItems: 'flex-start' }}>
                    <textarea
                      value={formData.justificativa || ''}
                      onChange={(e) => setFormData({...formData, justificativa: e.target.value})}
                      className="form-textarea"
                      placeholder="Justifique a necessidade do projeto..."
                      style={{ flex: 1 }}
                    />
                    <button 
                      onClick={() => getSuggestion('justificativa')}
                      className="btn btn-outline btn-sm"
                      disabled={loadingAI}
                    >
                      🤖 IA
                    </button>
                  </div>
                </div>

                <div className="form-group">
                  <label className="form-label">Objetivos</label>
                  <div className="flex gap-2" style={{ alignItems: 'flex-start' }}>
                    <textarea
                      value={formData.objetivos || ''}
                      onChange={(e) => setFormData({...formData, objetivos: e.target.value})}
                      className="form-textarea"
                      placeholder="Descreva os objetivos gerais e específicos..."
                      style={{ flex: 1 }}
                    />
                    <button 
                      onClick={() => getSuggestion('objetivos')}
                      className="btn btn-outline btn-sm"
                      disabled={loadingAI}
                    >
                      🤖 IA
                    </button>
                  </div>
                </div>

                <div className="text-center text-sm text-gray" style={{ marginTop: '2rem' }}>
                  💡 Clique em "🤖 IA" ao lado de cada campo para obter sugestões inteligentes
                </div>
              </div>
            </div>
          </div>

          {/* Painel de IA */}
          <div>
            <div className="card sticky" style={{ top: '1rem' }}>
              <div className="card-header">
                <h3 className="card-title" style={{ fontSize: '1.25rem' }}>
                  🤖 Assistente IA
                </h3>
              </div>
              <div className="card-content">
                {loadingAI ? (
                  <div className="text-center py-8">
                    <div className="spinner" style={{ margin: '0 auto' }}></div>
                    <p className="text-sm text-gray" style={{ marginTop: '1rem' }}>
                      Gerando sugestão...
                    </p>
                  </div>
                ) : aiSuggestion ? (
                  <div>
                    <div style={{ 
                      background: 'var(--dourado-claro)', 
                      border: '2px solid var(--dourado-elegante)',
                      borderRadius: '0.5rem',
                      padding: '1rem',
                      marginBottom: '1rem'
                    }}>
                      <div className="flex items-center justify-between mb-2">
                        <span className="text-sm font-semibold text-primary">
                          💡 Sugestão da IA
                        </span>
                        <span className="badge badge-gold">
                          {Math.round(aiSuggestion.confidence * 100)}% confiança
                        </span>
                      </div>
                      <p className="text-sm" style={{ whiteSpace: 'pre-wrap', color: 'var(--grafite)' }}>
                        {aiSuggestion.suggestion}
                      </p>
                    </div>

                    <button onClick={applySuggestion} className="btn btn-primary" style={{ width: '100%' }}>
                      ✅ Aplicar Sugestão
                    </button>

                    <button 
                      onClick={() => setAiSuggestion(null)} 
                      className="btn btn-outline btn-sm" 
                      style={{ width: '100%', marginTop: '0.5rem' }}
                    >
                      ✖ Descartar
                    </button>
                  </div>
                ) : (
                  <div className="text-center py-8">
                    <div style={{ fontSize: '3rem', marginBottom: '1rem' }}>🤖</div>
                    <p className="text-sm text-gray">
                      Clique em "🤖 IA" ao lado de um campo para obter sugestões
                    </p>
                  </div>
                )}

                <div style={{ 
                  background: 'var(--azul-claro)', 
                  borderRadius: '0.5rem', 
                  padding: '1rem',
                  marginTop: '1.5rem'
                }}>
                  <div className="text-xs font-semibold text-primary mb-2">💡 DICAS:</div>
                  <ul className="text-xs text-gray" style={{ paddingLeft: '1.25rem' }}>
                    <li>Use linguagem objetiva</li>
                    <li>Seja específico nos dados</li>
                    <li>Mencione conformidade legal</li>
                    <li>Inclua indicadores mensuráveis</li>
                  </ul>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
