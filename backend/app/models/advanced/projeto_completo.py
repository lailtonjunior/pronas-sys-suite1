"""
Modelo de dados completo para projetos PRONAS/PCD
Baseado na análise detalhada do projeto APAE Paraíso do Tocantins
"""
from sqlalchemy import Column, Integer, String, Float, JSON, ForeignKey, Text, Boolean, Date
from sqlalchemy.orm import relationship
from app.database.session import Base
from typing import List, Dict, Optional
from pydantic import BaseModel
from datetime import date


# ═══════════════════════════════════════════════════════════════
# MODELOS SQLALCHEMY (BANCO DE DADOS)
# ═══════════════════════════════════════════════════════════════

class ProjetoCompleto(Base):
    """Projeto PRONAS/PCD com estrutura completa"""
    __tablename__ = "projetos_completos"
    
    id = Column(Integer, primary_key=True)
    
    # 1. IDENTIFICAÇÃO
    razao_social = Column(String(500))
    cnpj = Column(String(18))
    endereco_completo = Column(Text)
    telefone = Column(String(50))
    email = Column(String(200))
    
    # Projeto
    titulo = Column(String(500))
    valor_total = Column(Float)
    prazo_execucao_meses = Column(Integer)
    
    # 2. OBJETIVOS E JUSTIFICATIVA
    objetivo_geral = Column(Text)
    objetivos_especificos = Column(JSON)  # Lista de strings
    contexto_socioeconomico = Column(JSON)  # Dict com população, municípios, etc
    
    # 3. ESTRUTURA DE ATENDIMENTOS
    atendimentos = Column(JSON)  # Array de objetos estruturados
    
    # 4. RECURSOS HUMANOS
    recursos_humanos = Column(JSON)  # Array de objetos com cargo, qtd, salários
    custo_total_rh = Column(Float)
    percentual_rh = Column(Float)  # % do custo total
    
    # 5. EQUIPAMENTOS E ESTRUTURA FÍSICA
    equipamentos_permanentes = Column(JSON)  # SIGEM
    materiais_consumo = Column(JSON)
    custo_total_equipamentos = Column(Float)
    ambientes = Column(JSON)  # Salas e estrutura física
    
    # 6. METAS E MONITORAMENTO
    metas_quantitativas = Column(JSON)  # Por modalidade
    indicadores = Column(JSON)
    cronograma = Column(JSON)
    
    # MÉTRICAS CALCULADAS
    custo_por_beneficiario = Column(Float)
    custo_por_atendimento = Column(Float)
    percentual_equipamentos = Column(Float)
    
    # VALIDAÇÕES E ALERTAS
    alertas = Column(JSON)  # Lista de alertas gerados
    score_conformidade = Column(Integer)  # 0-100
    status_validacao = Column(String(50))  # aprovado/pendente/rejeitado


class RecursoHumano(Base):
    """Detalhamento de recursos humanos"""
    __tablename__ = "recursos_humanos"
    
    id = Column(Integer, primary_key=True)
    projeto_id = Column(Integer, ForeignKey('projetos_completos.id'))
    
    cargo = Column(String(200))
    quantidade = Column(Integer)
    forma_contratacao = Column(String(50))  # CLT, PJ, etc
    carga_horaria_semanal = Column(Integer)
    periodo_meses = Column(Integer)
    
    salario_base_mensal = Column(Float)
    inss = Column(Float)
    fgts = Column(Float)
    ferias_13_provisao = Column(Float)
    encargos_totais_mensais = Column(Float)
    custo_mensal_total = Column(Float)
    custo_total_funcao = Column(Float)


class Equipamento(Base):
    """Equipamentos permanentes (SIGEM)"""
    __tablename__ = "equipamentos"
    
    id = Column(Integer, primary_key=True)
    projeto_id = Column(Integer, ForeignKey('projetos_completos.id'))
    
    codigo_sigem = Column(String(50))
    nome_item = Column(String(500))
    especificacao_tecnica = Column(Text)
    ambiente_alocacao = Column(String(200))
    quantidade = Column(Integer)
    valor_unitario = Column(Float)
    valor_total = Column(Float)


# ═══════════════════════════════════════════════════════════════
# MODELOS PYDANTIC (SCHEMAS API)
# ═══════════════════════════════════════════════════════════════

class ContextoSocioeconomico(BaseModel):
    populacao_sede: int
    populacao_total_abrangida: int
    municipios_beneficiados: List[str]
    perfil_usuarios: str


class AtendimentoDetalhado(BaseModel):
    nome: str
    descricao: str
    profissionais: List[Dict]  # {cargo, quantidade, fonte_custeio, carga_horaria}
    materiais_consumo: List[Dict]
    equipamentos: List[str]  # Códigos SIGEM
    periodo_meses: int
    meta_atendimentos: int
    capacidade_sala: Optional[str]
    dependencias: List[str]  # Links para outros atendimentos


class RecursoHumanoSchema(BaseModel):
    cargo: str
    quantidade: int
    forma_contratacao: str
    carga_horaria_semanal: int
    periodo_meses: int
    salario_base_mensal: float
    
    # Calculados
    inss: Optional[float] = None
    fgts: Optional[float] = None
    ferias_13_provisao: Optional[float] = None
    custo_total_funcao: Optional[float] = None


class EquipamentoSchema(BaseModel):
    codigo_sigem: Optional[str]
    nome: str
    especificacao: str
    ambiente: str
    quantidade: int
    valor_unitario: float
    valor_total: float


class MetaQuantitativa(BaseModel):
    modalidade: str
    atendimentos_21_meses: int
    atendimentos_mensais: int


class ProjetoCompletoSchema(BaseModel):
    # Identificação
    razao_social: str
    cnpj: str
    titulo: str
    valor_total: float
    prazo_meses: int
    
    # Objetivos
    objetivo_geral: str
    objetivos_especificos: List[str]
    contexto: ContextoSocioeconomico
    
    # Estrutura
    atendimentos: List[AtendimentoDetalhado]
    recursos_humanos: List[RecursoHumanoSchema]
    equipamentos: List[EquipamentoSchema]
    materiais_consumo: List[Dict]
    
    # Metas
    metas: List[MetaQuantitativa]
    cronograma: Dict
    
    # Métricas (calculadas)
    custo_por_beneficiario: Optional[float] = None
    custo_por_atendimento: Optional[float] = None
    percentual_rh: Optional[float] = None
