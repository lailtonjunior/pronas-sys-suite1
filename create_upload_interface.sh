#!/bin/bash
set -e

echo "📤 CRIANDO INTERFACE DE UPLOAD..."

# Criar página de upload no frontend
mkdir -p "frontend/src/app/admin/upload"

cat > "frontend/src/app/admin/upload/page.tsx" << 'PAGEEOF'
'use client'
import { useState } from 'react'
import Link from 'next/link'

export default function UploadDocumentos() {
  const [uploading, setUploading] = useState(false)
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
        setResultado(`✅ ${data.uploaded} arquivos enviados com sucesso!`)
        setFiles(null)
      } else {
        setResultado(`❌ Erro: ${data.detail}`)
      }
    } catch (error) {
      setResultado(`❌ Erro ao enviar arquivos`)
    } finally {
      setUploading(false)
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
        <div className="card" style={{ maxWidth: '800px', margin: '0 auto' }}>
          <div className="card-header" style={{ background: 'var(--azul-corporativo)' }}>
            <h1 className="card-title" style={{ color: 'var(--dourado-elegante)' }}>
              📤 Upload de Documentos
            </h1>
            <p className="text-sm" style={{ color: 'var(--cinza-claro)', marginTop: '0.5rem' }}>
              Envie PDFs de projetos, portarias e diligências para a base de conhecimento
            </p>
          </div>

          <div className="card-content" style={{ padding: '2rem' }}>
            {/* Categoria */}
            <div className="form-group">
              <label className="form-label">Categoria do Documento</label>
              <select
                value={categoria}
                onChange={(e) => setCategoria(e.target.value)}
                className="form-select"
              >
                <option value="aprovados">✅ Projetos Aprovados</option>
                <option value="reprovados">❌ Projetos Reprovados</option>
                <option value="portarias">📋 Portarias Oficiais</option>
                <option value="diligencias">⚠️ Notificações de Diligência</option>
                <option value="exemplos">�� Exemplos de Preenchimento</option>
              </select>
              <p className="text-sm text-gray" style={{ marginTop: '0.5rem' }}>
                {categoria === 'aprovados' && '→ Projetos que foram aprovados pelo Ministério'}
                {categoria === 'reprovados' && '→ Projetos que foram reprovados ou indeferidos'}
                {categoria === 'portarias' && '→ Portaria 8.031/2025 e documentos oficiais'}
                {categoria === 'diligencias' && '→ Ofícios de diligência e pendências'}
                {categoria === 'exemplos' && '→ Modelos e templates preenchidos'}
              </p>
            </div>

            {/* Upload de arquivos */}
            <div className="form-group">
              <label className="form-label">Arquivos PDF</label>
              <input
                type="file"
                multiple
                accept=".pdf,.docx"
                onChange={(e) => setFiles(e.target.files)}
                className="form-input"
              />
              <p className="text-sm text-gray" style={{ marginTop: '0.5rem' }}>
                Selecione um ou mais arquivos (PDF ou DOCX)
              </p>
            </div>

            {/* Arquivos selecionados */}
            {files && files.length > 0 && (
              <div style={{ 
                background: 'var(--azul-claro)', 
                padding: '1rem', 
                borderRadius: '0.5rem',
                marginBottom: '1.5rem'
              }}>
                <p className="text-sm font-semibold text-primary mb-2">
                  📄 {files.length} arquivo(s) selecionado(s):
                </p>
                <ul className="text-sm text-gray">
                  {Array.from(files).map((file, i) => (
                    <li key={i}>• {file.name} ({(file.size / 1024 / 1024).toFixed(2)} MB)</li>
                  ))}
                </ul>
              </div>
            )}

            {/* Botão upload */}
            <button
              onClick={handleUpload}
              disabled={uploading || !files}
              className="btn btn-primary"
              style={{ width: '100%', marginBottom: '1rem' }}
            >
              {uploading ? '⏳ Enviando...' : '📤 Fazer Upload'}
            </button>

            {/* Resultado */}
            {resultado && (
              <div style={{
                padding: '1rem',
                borderRadius: '0.5rem',
                background: resultado.startsWith('✅') ? '#d1fae5' : '#fee2e2',
                color: resultado.startsWith('✅') ? '#065f46' : '#991b1b'
              }}>
                {resultado}
              </div>
            )}

            {/* Informações */}
            <div style={{ 
              background: 'var(--dourado-claro)', 
              padding: '1rem', 
              borderRadius: '0.5rem',
              marginTop: '1.5rem'
            }}>
              <p className="text-sm font-semibold text-primary mb-2">💡 O que acontece após o upload:</p>
              <ul className="text-sm text-gray" style={{ paddingLeft: '1.5rem' }}>
                <li>A IA extrai texto do PDF automaticamente</li>
                <li>Identifica e classifica o tipo de documento</li>
                <li>Extrai metadados (instituição, área, valores)</li>
                <li>Gera embeddings para busca semântica</li>
                <li>Indexa no sistema RAG (Qdrant)</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
PAGEEOF

echo "✅ Interface de upload criada"

# Criar endpoint de upload no backend
cat > backend/app/api/upload.py << 'APIUPLOADEOF'
from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from typing import List
import shutil
from pathlib import Path
import logging

router = APIRouter()
logger = logging.getLogger(__name__)

KNOWLEDGE_BASE_PATH = Path("/app/../knowledge_base")

@router.post("/upload")
async def upload_documentos(
    categoria: str = Form(...),
    files: List[UploadFile] = File(...)
):
    """Upload de múltiplos PDFs para a base de conhecimento"""
    
    # Validar categoria
    categorias_validas = ["portarias", "aprovados", "reprovados", "diligencias", "exemplos"]
    if categoria not in categorias_validas:
        raise HTTPException(status_code=400, detail="Categoria inválida")
    
    # Criar pasta se não existir
    upload_dir = KNOWLEDGE_BASE_PATH / categoria
    upload_dir.mkdir(parents=True, exist_ok=True)
    
    uploaded_files = []
    
    for file in files:
        # Validar extensão
        if not file.filename.lower().endswith(('.pdf', '.docx')):
            continue
        
        # Salvar arquivo
        file_path = upload_dir / file.filename
        
        with file_path.open("wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        
        uploaded_files.append(file.filename)
        logger.info(f"Arquivo salvo: {file_path}")
    
    return {
        "uploaded": len(uploaded_files),
        "files": uploaded_files,
        "categoria": categoria
    }
APIUPLOADEOF

# Adicionar rota ao main.py
echo ""
echo "⚠️  ATENÇÃO: Adicione esta linha ao backend/app/main.py:"
echo ""
echo "from app.api import upload"
echo "app.include_router(upload.router, prefix=\"/api/knowledge\", tags=[\"Knowledge\"])"
echo ""

# Rebuild frontend
docker compose build frontend
docker compose restart frontend backend

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ INTERFACE DE UPLOAD CRIADA!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "🌐 Acesse: http://72.60.255.80:3000/admin/upload"
echo ""
echo "📤 Agora você pode fazer upload direto pelo navegador!"
echo ""

