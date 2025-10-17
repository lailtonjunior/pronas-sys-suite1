#!/bin/bash
set -e

echo "🚀 Implementando funcionalidades avançadas..."

# ═══════════════════════════════════════════════════════════════
# PARTE 2A: PÁGINA DE CRIAÇÃO DE PROJETO
# ═══════════════════════════════════════════════════════════════

mkdir -p frontend/src/app/projeto/novo

cat > frontend/src/app/projeto/novo/page.tsx << 'NEWPROJEOF'
'use client'
import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { Button } from '@/components/ui/button'
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card'

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
      alert('Projeto criado com sucesso!')
      router.push(`/projeto/${project.id}/editar`)
    } catch (error) {
      console.error(error)
      alert('Erro ao criar projeto')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 p-8">
      <div className="max-w-3xl mx-auto">
        <Card>
          <CardHeader>
            <CardTitle>Criar Novo Projeto PRONAS/PCD</CardTitle>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSubmit} className="space-y-6">
              {/* Título */}
              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Título do Projeto *
                </label>
                <input
                  type="text"
                  required
                  value={formData.title}
                  onChange={(e) => setFormData({...formData, title: e.target.value})}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  placeholder="Ex: Centro de Reabilitação Física Integrado"
                />
              </div>

              {/* Descrição */}
              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Descrição Breve
                </label>
                <textarea
                  value={formData.description}
                  onChange={(e) => setFormData({...formData, description: e.target.value})}
                  rows={3}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  placeholder="Breve descrição do objetivo do projeto"
                />
              </div>

              {/* Área do Projeto */}
              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Área do Projeto *
                </label>
                <select
                  required
                  value={formData.field}
                  onChange={(e) => setFormData({...formData, field: e.target.value})}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
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
              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Área Prioritária
                </label>
                <input
                  type="text"
                  value={formData.priority_area}
                  onChange={(e) => setFormData({...formData, priority_area: e.target.value})}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  placeholder="Ex: Reabilitação Física, TEA, Deficiência Visual"
                />
              </div>

              {/* Nome da Instituição */}
              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Nome da Instituição *
                </label>
                <input
                  type="text"
                  required
                  value={formData.institution_name}
                  onChange={(e) => setFormData({...formData, institution_name: e.target.value})}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  placeholder="Ex: Hospital Regional de Saúde"
                />
              </div>

              {/* CNPJ */}
              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  CNPJ da Instituição *
                </label>
                <input
                  type="text"
                  required
                  value={formData.institution_cnpj}
                  onChange={(e) => setFormData({...formData, institution_cnpj: e.target.value})}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  placeholder="00.000.000/0000-00"
                />
              </div>

              {/* Botões */}
              <div className="flex gap-4">
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => router.push('/dashboard')}
                  disabled={loading}
                >
                  Cancelar
                </Button>
                <Button type="submit" disabled={loading} className="flex-1">
                  {loading ? 'Criando...' : 'Criar Projeto e Continuar'}
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
NEWPROJEOF

echo "✅ Página de criação criada"

# ═══════════════════════════════════════════════════════════════
# PARTE 2B: PÁGINA DE EDIÇÃO COM ANEXOS
# ═══════════════════════════════════════════════════════════════

mkdir -p "frontend/src/app/projeto/[id]/editar"

cat > "frontend/src/app/projeto/[id]/editar/page.tsx" << 'EDITEOF'
'use client'
import { useEffect, useState } from 'react'
import { useParams } from 'next/navigation'
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'

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
      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center">
        <div className="text-xl">Carregando...</div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 p-8">
      <div className="max-w-6xl mx-auto">
        {/* Header */}
        <Card className="mb-8">
          <CardHeader>
            <div className="flex justify-between items-start">
              <div>
                <CardTitle>{project?.title}</CardTitle>
                <p className="text-gray-600 mt-2">{project?.description}</p>
              </div>
              <Badge variant="warning">Em Elaboração</Badge>
            </div>
          </CardHeader>
        </Card>

        {/* Lista de Anexos */}
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
  const getAnexoInfo = (tipo: string) => {
    const info: any = {
      'ANEXO_I': {
        nome: 'Declaração de Ciência e Concordância',
        descricao: 'Declaração do responsável legal',
        icon: '📋'
      },
      'ANEXO_II': {
        nome: 'Formulário de Apresentação de Projeto',
        descricao: 'Formulário completo com 40+ campos (MAIS IMPORTANTE)',
        icon: '📝'
      },
      'ANEXO_III': {
        nome: 'Declaração de Capacidade Técnico-Operativa',
        descricao: 'Comprovação de capacidade da instituição',
        icon: '🏥'
      },
      'ANEXO_IV': {
        nome: 'Modelo de Orçamento',
        descricao: 'Detalhamento de custos diretos e indiretos',
        icon: '💰'
      },
      'ANEXO_V': {
        nome: 'Formulário de Equipamentos',
        descricao: 'Listagem de equipamentos (se aplicável)',
        icon: '🔧'
      },
      'ANEXO_VI': {
        nome: 'Requerimento de Habilitação',
        descricao: 'Para instituições não habilitadas',
        icon: '📄'
      },
      'ANEXO_VII': {
        nome: 'Minuta do Termo de Compromisso',
        descricao: 'Modelo informativo',
        icon: '✍️'
      }
    }
    return info[tipo] || { nome: tipo, descricao: '', icon: '📄' }
  }

  const info = getAnexoInfo(anexo.tipo)
  const completion = anexo.completion_score || 0

  return (
    <Card className="hover:shadow-lg transition-shadow">
      <CardContent className="p-6">
        <div className="flex items-center gap-4">
          <div className="text-4xl">{info.icon}</div>
          
          <div className="flex-1">
            <div className="flex items-center gap-3 mb-1">
              <h3 className="text-lg font-bold">
                Anexo {['I','II','III','IV','V','VI','VII'][index-1]}
              </h3>
              {anexo.tipo === 'ANEXO_II' && (
                <Badge variant="warning">Obrigatório</Badge>
              )}
            </div>
            <p className="text-sm font-semibold text-gray-700">{info.nome}</p>
            <p className="text-xs text-gray-500 mt-1">{info.descricao}</p>
            
            <div className="mt-3 flex items-center gap-3">
              <div className="flex-1 bg-gray-200 rounded-full h-2">
                <div 
                  className="bg-gradient-to-r from-blue-500 to-green-500 h-2 rounded-full transition-all"
                  style={{ width: `${completion}%` }}
                />
              </div>
              <span className="text-sm font-semibold text-gray-700 min-w-[3rem]">
                {completion}%
              </span>
            </div>
          </div>

          <a 
            href={`/anexo/${anexo.id}`}
            className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors font-semibold"
          >
            {completion > 0 ? 'Continuar' : 'Iniciar'}
          </a>
        </div>
      </CardContent>
    </Card>
  )
}
EDITEOF

echo "✅ Página de edição criada"

# ═══════════════════════════════════════════════════════════════
# PARTE 2C: COMPONENTE PAINEL DE IA
# ═══════════════════════════════════════════════════════════════

mkdir -p frontend/src/components/ai

cat > frontend/src/components/ai/AIAssistantPanel.tsx << 'AIPANELEOF'
'use client'
import { useState } from 'react'
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'

interface AIAssistantPanelProps {
  fieldName: string
  currentValue: string
  projectContext: any
  onApplySuggestion: (suggestion: string) => void
}

export function AIAssistantPanel({ 
  fieldName, 
  currentValue, 
  projectContext,
  onApplySuggestion 
}: AIAssistantPanelProps) {
  const [suggestion, setSuggestion] = useState<any>(null)
  const [loading, setLoading] = useState(false)
  const [references, setReferences] = useState<any[]>([])

  const getSuggestion = async () => {
    setLoading(true)
    try {
      const response = await fetch('http://72.60.255.80:8000/api/ai/suggest', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          field_name: fieldName,
          field_context: { current_value: currentValue },
          project_context: projectContext
        })
      })

      const data = await response.json()
      setSuggestion(data)
      
      if (data.references) {
        setReferences(data.references)
      }
    } catch (error) {
      console.error('Erro ao obter sugestão:', error)
      setSuggestion({ 
        suggestion: 'Erro ao conectar com o assistente de IA. Tente novamente.', 
        confidence: 0 
      })
    } finally {
      setLoading(false)
    }
  }

  return (
    <Card className="sticky top-4">
      <CardHeader>
        <CardTitle className="text-lg flex items-center gap-2">
          🤖 Assistente IA
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        {/* Botão de sugestão */}
        <Button 
          onClick={getSuggestion}
          disabled={loading}
          className="w-full"
          variant={suggestion ? "outline" : "default"}
        >
          {loading ? '🔄 Gerando...' : suggestion ? '🔄 Nova Sugestão' : '✨ Obter Sugestão'}
        </Button>

        {/* Sugestão */}
        {suggestion && (
          <div className="space-y-3">
            <div className="p-4 bg-purple-50 border border-purple-200 rounded-lg">
              <div className="flex items-center justify-between mb-2">
                <span className="text-xs font-semibold text-purple-700">
                  💡 Sugestão da IA
                </span>
                <Badge variant={suggestion.confidence > 0.7 ? "success" : "warning"}>
                  {Math.round(suggestion.confidence * 100)}% confiança
                </Badge>
              </div>
              <p className="text-sm text-gray-700 whitespace-pre-wrap">
                {suggestion.suggestion}
              </p>
            </div>

            {suggestion.confidence > 0 && (
              <Button
                onClick={() => onApplySuggestion(suggestion.suggestion)}
                className="w-full"
                variant="default"
              >
                ✅ Aplicar Sugestão
              </Button>
            )}

            {references.length > 0 && (
              <div className="text-xs text-gray-500">
                📚 Baseado em {references.length} casos similares
              </div>
            )}
          </div>
        )}

        {/* Dicas */}
        <div className="p-3 bg-blue-50 border border-blue-200 rounded-lg text-xs">
          <div className="font-semibold text-blue-900 mb-1">💡 Dicas:</div>
          <ul className="text-blue-700 space-y-1 list-disc list-inside">
            <li>Use linguagem objetiva</li>
            <li>Seja específico nos dados</li>
            <li>Mencione conformidade legal</li>
          </ul>
        </div>
      </CardContent>
    </Card>
  )
}
AIPANELEOF

echo "✅ Painel de IA criado"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ FUNCIONALIDADES AVANÇADAS IMPLEMENTADAS!"
echo "═══════════════════════════════════════════════════════════════"

