#!/bin/bash
set -e

echo "🔄 ATUALIZANDO SISTEMA DE CLASSIFICAÇÃO..."

# ═══════════════════════════════════════════════════════════════
# 1. ATUALIZAR INTERFACE DE UPLOAD COM 3 TIPOS DE PROJETO
# ═══════════════════════════════════════════════════════════════

cat > "frontend/src/app/admin/upload/page.tsx" << 'PAGEEOF'
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
PAGEEOF

echo "✅ Interface atualizada com 3 tipos de projeto"

# ═══════════════════════════════════════════════════════════════
# 2. ATUALIZAR CLASSIFICADOR INTELIGENTE
# ═══════════════════════════════════════════════════════════════

cat > backend/app/ai/document_processor/classifier.py << 'CLASSIFIEREOF'
"""
Classificador Inteligente de Documentos PRONAS/PCD
Identifica os 3 tipos de projeto + diligências
"""
import re
from typing import Dict, Optional
import google.generativeai as genai
from app.config import settings

genai.configure(api_key=settings.GEMINI_API_KEY)
model = genai.GenerativeModel('gemini-1.5-flash')


class DocumentClassifier:
    """Classifica documentos PRONAS/PCD nos 3 tipos + status"""
    
    TIPOS_PROJETO = {
        "prestacao_servicos_medico_assistenciais": {
            "nome": "Prestação de Serviços Médico-Assistenciais",
            "keywords": ["fisioterapia", "atendimento", "médico", "clínico", "terapia", "odontologia", 
                        "psicologia", "consulta", "reabilitação", "habilitação", "saúde"],
            "emoji": "🏥"
        },
        "formacao_treinamento_recursos_humanos": {
            "nome": "Formação e Treinamento de Recursos Humanos",
            "keywords": ["capacitação", "treinamento", "curso", "formação", "qualificação", 
                        "profissionais", "educação", "libras", "braille", "workshop"],
            "emoji": "🎓"
        },
        "realizacao_pesquisas": {
            "nome": "Realização de Pesquisas",
            "keywords": ["pesquisa", "estudo", "investigação", "científico", "metodologia", 
                        "dados", "análise", "levantamento", "publicação", "artigo"],
            "emoji": "🔬"
        }
    }
    
    def classify_document(self, text: str, filename: str = "") -> Dict:
        """
        Classifica documento em:
        - Tipo de projeto (1 dos 3)
        - Status (aprovado/reprovado/diligência)
        - Categoria específica
        """
        
        text_lower = text.lower()
        filename_lower = filename.lower()
        
        # 1. Detectar se é diligência
        if self._is_diligencia(text_lower, filename_lower):
            return {
                "categoria": "diligencia",
                "tipo_projeto": None,
                "is_approved": None,
                "is_diligencia_resposta": self._is_resposta_diligencia(text_lower),
                "classificacao": "Ofício de Diligência" if not self._is_resposta_diligencia(text_lower) else "Resposta de Diligência"
            }
        
        # 2. Detectar se é portaria
        if self._is_portaria(text_lower, filename_lower):
            return {
                "categoria": "portaria",
                "tipo_projeto": None,
                "is_approved": None,
                "classificacao": "Portaria Oficial"
            }
        
        # 3. Classificar tipo de projeto (1 dos 3)
        tipo_projeto = self._classify_project_type(text_lower)
        
        # 4. Detectar se aprovado ou reprovado
        is_approved = self._detect_status(text_lower)
        
        # 5. Usar IA para confirmação
        ai_classification = self._ai_classify(text[:3000])
        
        return {
            "categoria": "projeto",
            "tipo_projeto": ai_classification.get("tipo_projeto", tipo_projeto),
            "is_approved": ai_classification.get("is_approved", is_approved),
            "classificacao": self._format_classification(
                ai_classification.get("tipo_projeto", tipo_projeto),
                ai_classification.get("is_approved", is_approved)
            ),
            "confianca": ai_classification.get("confianca", 0.5)
        }
    
    def _classify_project_type(self, text: str) -> str:
        """Classifica em 1 dos 3 tipos de projeto por keywords"""
        
        scores = {}
        
        for tipo, info in self.TIPOS_PROJETO.items():
            score = sum(1 for keyword in info["keywords"] if keyword in text)
            scores[tipo] = score
        
        # Retornar tipo com maior score
        if max(scores.values()) > 0:
            return max(scores, key=scores.get)
        
        return "prestacao_servicos_medico_assistenciais"  # Default
    
    def _detect_status(self, text: str) -> Optional[bool]:
        """Detecta se projeto foi aprovado ou reprovado"""
        
        aprovado_keywords = ["aprovado", "deferido", "homologado", "aceito", "habilitado"]
        reprovado_keywords = ["indeferido", "reprovado", "rejeitado", "não habilitado", "inabilitado"]
        
        has_aprovado = any(word in text for word in aprovado_keywords)
        has_reprovado = any(word in text for word in reprovado_keywords)
        
        if has_aprovado and not has_reprovado:
            return True
        elif has_reprovado and not has_aprovado:
            return False
        
        return None  # Não detectado
    
    def _is_diligencia(self, text: str, filename: str) -> bool:
        """Detecta se é ofício de diligência"""
        diligencia_keywords = ["diligência", "diligencia", "pendência", "esclarecimento", 
                              "complementação", "solicitação", "ofício"]
        
        return any(word in text or word in filename for word in diligencia_keywords)
    
    def _is_resposta_diligencia(self, text: str) -> bool:
        """Detecta se é resposta à diligência"""
        resposta_keywords = ["resposta", "atendimento", "esclarecimento prestado", 
                            "em atenção", "em resposta"]
        
        return any(word in text for word in resposta_keywords)
    
    def _is_portaria(self, text: str, filename: str) -> bool:
        """Detecta se é portaria oficial"""
        portaria_keywords = ["portaria", "ministério da saúde", "gabinete do ministro", 
                            "gm/ms", "consolidação"]
        
        return any(word in text or word in filename for word in portaria_keywords)
    
    def _ai_classify(self, text_sample: str) -> Dict:
        """Usa IA para classificação mais precisa"""
        
        prompt = f"""Classifique este documento PRONAS/PCD:

Tipos possíveis:
1. prestacao_servicos_medico_assistenciais (🏥 atendimento clínico, fisioterapia, etc)
2. formacao_treinamento_recursos_humanos (🎓 capacitação, cursos, treinamentos)
3. realizacao_pesquisas (🔬 pesquisa científica sobre deficiência)

Status:
- Aprovado (true)
- Reprovado (false)
- Não identificado (null)

Retorne JSON:
{{
  "tipo_projeto": "um dos 3 tipos acima",
  "is_approved": true/false/null,
  "confianca": 0.0 a 1.0,
  "justificativa": "breve explicação"
}}

Documento:
{text_sample}

JSON:"""

        try:
            response = model.generate_content(prompt)
            import json
            
            json_text = response.text
            if "```
                json_text = json_text.split("```json").split("```
            elif "```" in json_text:
                json_text = json_text.split("``````")[0]
            
            return json.loads(json_text.strip())
        except:
            return {"tipo_projeto": None, "is_approved": None, "confianca": 0}
    
    def _format_classification(self, tipo: str, is_approved: Optional[bool]) -> str:
        """Formata classificação legível"""
        
        tipo_info = self.TIPOS_PROJETO.get(tipo, {})
        emoji = tipo_info.get("emoji", "📄")
        nome = tipo_info.get("nome", "Projeto")
        
        status = ""
        if is_approved is True:
            status = "✅ APROVADO"
        elif is_approved is False:
            status = "❌ REPROVADO"
        else:
            status = "⏳ Status não identificado"
        
        return f"{emoji} {nome} - {status}"


# Instância global
classifier = DocumentClassifier()
CLASSIFIEREOF

echo "✅ Classificador inteligente criado"

# Rebuild
docker compose build frontend backend
docker compose restart frontend backend

echo ""
echo "⏳ Aguardando 15 segundos..."
sleep 15

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ SISTEMA ATUALIZADO!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "🎯 Agora o sistema identifica:"
echo "   🏥 Prestação de Serviços Médico-Assistenciais"
echo "   🎓 Formação e Treinamento de Recursos Humanos"
echo "   🔬 Realização de Pesquisas"
echo "   ⚠️  Ofícios de Diligência"
echo "   📝 Respostas de Diligência"
echo "   📋 Portarias Oficiais"
echo ""
echo "📤 Acesse: http://72.60.255.80:3000/admin/upload"
echo ""
echo "💡 Pode fazer upload de múltiplos PDFs de uma vez!"
echo "   A IA vai classificar automaticamente cada um!"
echo ""

