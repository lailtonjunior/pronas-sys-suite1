const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://72.60.255.80:8000'

export const api = {
  // Projects
  async getProjects() {
    const res = await fetch(`${API_BASE_URL}/api/projects/`)
    if (!res.ok) throw new Error('Erro ao buscar projetos')
    return res.json()
  },

  async createProject(data: any) {
    const res = await fetch(`${API_BASE_URL}/api/projects/`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    })
    if (!res.ok) throw new Error('Erro ao criar projeto')
    return res.json()
  },

  async getProject(id: number) {
    const res = await fetch(`${API_BASE_URL}/api/projects/${id}`)
    if (!res.ok) throw new Error('Erro ao buscar projeto')
    return res.json()
  },

  // Anexos
  async getAnexo(id: number) {
    const res = await fetch(`${API_BASE_URL}/api/anexos/${id}`)
    if (!res.ok) throw new Error('Erro ao buscar anexo')
    return res.json()
  },

  async updateAnexo(id: number, data: any) {
    const res = await fetch(`${API_BASE_URL}/api/anexos/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ dados: data })
    })
    if (!res.ok) throw new Error('Erro ao atualizar anexo')
    return res.json()
  },

  async getProjectAnexos(projectId: number) {
    const res = await fetch(`${API_BASE_URL}/api/anexos/project/${projectId}`)
    if (!res.ok) throw new Error('Erro ao buscar anexos')
    return res.json()
  },

  // AI Assistant
  async getSuggestion(fieldName: string, fieldContext: any, projectContext: any) {
    const res = await fetch(`${API_BASE_URL}/api/ai/suggest`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        field_name: fieldName,
        field_context: fieldContext,
        project_context: projectContext
      })
    })
    if (!res.ok) throw new Error('Erro ao obter sugestão')
    return res.json()
  },

  async validateAnexo(anexoData: any, anexoType: string) {
    const res = await fetch(`${API_BASE_URL}/api/ai/validate`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        anexo_data: anexoData,
        anexo_type: anexoType
      })
    })
    if (!res.ok) throw new Error('Erro ao validar anexo')
    return res.json()
  },

  // Knowledge Base
  async getCases(approvedOnly?: boolean) {
    const url = approvedOnly 
      ? `${API_BASE_URL}/api/knowledge/cases?approved_only=true`
      : `${API_BASE_URL}/api/knowledge/cases`
    const res = await fetch(url)
    if (!res.ok) throw new Error('Erro ao buscar casos')
    return res.json()
  },

  async getCase(id: number) {
    const res = await fetch(`${API_BASE_URL}/api/knowledge/cases/${id}`)
    if (!res.ok) throw new Error('Erro ao buscar caso')
    return res.json()
  }
}
