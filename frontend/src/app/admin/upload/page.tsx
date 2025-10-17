'use client'
import { useState } from 'react'
import Link from 'next/link'

export default function UploadDocumentos() {
  const [uploading, setUploading] = useState(false)
  const [processando, setProcessando] = useState(false)
  const [categoria, setCategoria] = useState('aprovados')
  const [files, setFiles] = useState<FileList | null>(null)
  const [resultado, setResultado] = useState<string>('')

  const handleUpload = async () => {
    if (!files || files.length === 0) {
      alert('Selecione pelo menos um arquivo')
      return
    }

    setUploading(true)
    setResultado('')

    const formData = new FormData()
    formData.append('categoria', categoria)
    
    for (let i = 0; i < files.length; i++) {
      formData.append('files', files[i])
    }

    try {
      const response = await fetch('http://72.60.255.80:8000/api/knowledge/upload', {
        method: 'POST',
        body: formData
      })

      const data = await response.json()
      
      if (response.ok) {
        setResultado(`✅ ${data.uploaded} arquivos enviados! Processando...`)
        setFiles(null)
        
        // Iniciar processamento automático
        await processarDocumentos()
      } else {
        setResultado(`❌ Erro: ${data.detail}`)
      }
    } catch (error) {
      setResultado(`❌ Erro ao enviar arquivos`)
    } finally {
      setUploading(false)
    }
  }

  const processarDocumentos = async () => {
    setProcessando(true)
    try {
      const response = await fetch('http://72.60.255.80:8000/api/knowledge/process', {
        method: 'POST'
      })
      
      const data = await response.json()
      setResultado(`✅ Processamento concluído! ${data.processed} documentos indexados na base de conhecimento.`)
    } catch (error) {
      setResultado(`⚠️ Upload OK, mas erro ao processar. Execute manualmente: ./import_documents.sh`)
    } finally {
      setProcessando(false)
    }
  }

  return (
    <div className="min-h-screen" style={{ background: 'var(--cinza-claro)' }}>
      <header className="header-prime">
        <div className="header-content">
          <Link href="/dashboard" className="logo-prime">
            PRIME PRONAS/PCD
          </Link>
          <Link href="/dashboard">
            <button className="btn btn-outline" style={{ color: 'white', borderColor: 'white' }}>
              ← Dashboard
            </button>
          </Link>
        </div>
      </header>

      <div className="container py-8">
        <div className="card" style={{ maxWidth: '900px', margin: '0 auto' }}>
          <div className="card-header" style={{ background: 'var(--azul-corporativo)' }}>
            <h1 className="card-title" style={{ color: 'var(--dourado-elegante)' }}>
              📤 Upload de Documentos PRONAS/PCD
            </h1>
            <p className="text-sm" style={{ color: 'var(--cinza-claro)', marginTop: '0.5rem' }}>
              Envie até 50 PDFs de projetos, diligências e portarias
            </p>
          </div>

          <div className="card-content" style={{ padding: '2rem' }}>
            {/* Categoria */}
            <div className="form-group">
              <label className="form-label">Tipo de Documento</label>
              <select
                value={categoria}
                onChange={(e) => setCategoria(e.target.value)}
                className="form-select"
                style={{ fontSize: '1rem' }}
              >
                <optgroup label="📊 Projetos Aprovados">
                  <option value="aprovados_medico">✅ Prestação de Serviços Médico-Assistenciais (Aprovado)</option>
                  <option value="aprovados_formacao">✅ Formação e Treinamento de Recursos Humanos (Aprovado)</option>
                  <option value="aprovados_pesquisa">✅ Realização de Pesquisas (Aprovado)</option>
                </optgroup>
                
                <optgroup label="❌ Projetos Reprovados">
                  <option value="reprovados_medico">❌ Prestação de Serviços Médico-Assistenciais (Reprovado)</option>
                  <option value="reprovados_formacao">❌ Formação e Treinamento de Recursos Humanos (Reprovado)</option>
                  <option value="reprovados_pesquisa">❌ Realização de Pesquisas (Reprovado)</option>
                </optgroup>
                
                <optgroup label="⚠️ Diligências">
                  <option value="diligencia_oficio">⚠️ Ofício de Diligência (Solicitação)</option>
                  <option value="diligencia_resposta">📝 Resposta de Diligência</option>
                </optgroup>
                
                <optgroup label="📋 Outros">
                  <option value="portarias">📋 Portarias Oficiais (8.031/2025, etc)</option>
                  <option value="exemplos">📖 Exemplos de Preenchimento</option>
                </optgroup>
              </select>
              
              <div style={{ 
                background: 'var(--azul-claro)', 
                padding: '0.75rem', 
                borderRadius: '0.5rem',
                marginTop: '0.75rem'
              }}>
                <p className="text-sm text-primary">
                  {categoria.includes('medico') && '🏥 Projetos de atendimento clínico, fisioterapia, odontologia, psicologia, etc.'}
                  {categoria.includes('formacao') && '🎓 Projetos de capacitação profissional, cursos, treinamentos em Libras/Braille, etc.'}
                  {categoria.includes('pesquisa') && '🔬 Projetos de pesquisa científica sobre deficiência e acessibilidade.'}
                  {categoria === 'diligencia_oficio' && '⚠️ Ofícios do Ministério solicitando esclarecimentos ou documentos.'}
                  {categoria === 'diligencia_resposta' && '📝 Respostas da instituição às diligências solicitadas.'}
                  {categoria === 'portarias' && '📋 Documentos normativos oficiais do Ministério da Saúde.'}
                  {categoria === 'exemplos' && '📖 Modelos e templates de projetos bem-sucedidos.'}
                </p>
              </div>
            </div>

            {/* Upload de arquivos */}
            <div className="form-group">
              <label className="form-label">Arquivos PDF/DOCX (Múltiplos)</label>
              <input
                type="file"
                multiple
                accept=".pdf,.docx"
                onChange={(e) => setFiles(e.target.files)}
                className="form-input"
                style={{ cursor: 'pointer' }}
              />
              <p className="text-sm text-gray" style={{ marginTop: '0.5rem' }}>
                💡 Selecione vários arquivos de uma vez (Ctrl+Click ou Cmd+Click)
              </p>
            </div>

            {/* Arquivos selecionados */}
            {files && files.length > 0 && (
              <div style={{ 
                background: 'var(--dourado-claro)', 
                border: '2px solid var(--dourado-elegante)',
                padding: '1rem', 
                borderRadius: '0.5rem',
                marginBottom: '1.5rem'
              }}>
                <p className="text-sm font-semibold text-primary mb-2">
                  📄 {files.length} arquivo(s) selecionado(s):
                </p>
                <div style={{ maxHeight: '200px', overflowY: 'auto' }}>
                  <ul className="text-sm text-gray">
                    {Array.from(files).map((file, i) => (
                      <li key={i} style={{ marginBottom: '0.25rem' }}>
                        • {file.name} <span className="text-primary">({(file.size / 1024 / 1024).toFixed(2)} MB)</span>
                      </li>
                    ))}
                  </ul>
                </div>
                <p className="text-sm font-semibold text-primary" style={{ marginTop: '0.75rem' }}>
                  Total: {Array.from(files).reduce((acc, f) => acc + f.size, 0) / 1024 / 1024} MB
                </p>
              </div>
            )}

            {/* Botão upload */}
            <button
              onClick={handleUpload}
              disabled={uploading || processando || !files}
              className="btn btn-primary"
              style={{ width: '100%', marginBottom: '1rem', fontSize: '1.125rem', padding: '1rem' }}
            >
              {uploading ? '📤 Enviando arquivos...' : 
               processando ? '🤖 IA processando documentos...' : 
               '🚀 Fazer Upload e Processar com IA'}
            </button>

            {/* Resultado */}
            {resultado && (
              <div style={{
                padding: '1rem',
                borderRadius: '0.5rem',
                background: resultado.startsWith('✅') ? '#d1fae5' : resultado.startsWith('⚠️') ? '#fef3c7' : '#fee2e2',
                color: resultado.startsWith('✅') ? '#065f46' : resultado.startsWith('⚠️') ? '#92400e' : '#991b1b',
                fontWeight: '600'
              }}>
                {resultado}
              </div>
            )}

            {/* Informações sobre o processamento */}
            <div style={{ 
              background: 'var(--azul-claro)', 
              padding: '1.25rem', 
              borderRadius: '0.5rem',
              marginTop: '1.5rem'
            }}>
              <p className="text-sm font-semibold text-primary mb-3">🤖 A IA irá processar automaticamente:</p>
              <div className="grid grid-cols-2" style={{ gap: '1rem' }}>
                <div>
                  <p className="text-sm font-semibold text-primary mb-1">📊 Extração:</p>
                  <ul className="text-sm text-gray" style={{ paddingLeft: '1.25rem' }}>
                    <li>Identificação da instituição</li>
                    <li>Título e objetivos do projeto</li>
                    <li>Valores e orçamento</li>
                    <li>Recursos humanos</li>
                    <li>Equipamentos SIGEM</li>
                  </ul>
                </div>
                <div>
                  <p className="text-sm font-semibold text-primary mb-1">🔍 Classificação:</p>
                  <ul className="text-sm text-gray" style={{ paddingLeft: '1.25rem' }}>
                    <li>Tipo de projeto (1 dos 3)</li>
                    <li>Status (aprovado/reprovado)</li>
                    <li>Pontos fortes/fracos</li>
                    <li>Motivos de diligência</li>
                    <li>Indexação para busca</li>
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
