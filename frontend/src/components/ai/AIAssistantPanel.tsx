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
