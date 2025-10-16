from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Enum, Text
from sqlalchemy.orm import relationship
from datetime import datetime
import enum
from app.database.session import Base

class ProjectStatus(str, enum.Enum):
    DRAFT = "em_elaboracao"
    SUBMITTED = "submetido"
    APPROVED = "aprovado"
    REJECTED = "rejeitado"
    IN_REVIEW = "em_analise"

class ProjectField(str, enum.Enum):
    MEDICAL_ASSISTANCE = "prestacao_servicos_medico_assistenciais"
    TRAINING = "formacao_treinamento_recursos_humanos"
    RESEARCH = "realizacao_pesquisas"

class Project(Base):
    __tablename__ = "projects"
    
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    description = Column(Text)
    field = Column(Enum(ProjectField), nullable=False)
    status = Column(Enum(ProjectStatus), default=ProjectStatus.DRAFT)
    institution_name = Column(String)
    institution_cnpj = Column(String)
    total_budget = Column(Integer)  # Em centavos
    priority_area = Column(String)
    
    owner_id = Column(Integer, ForeignKey("users.id"))
    owner = relationship("User", back_populates="projects")
    
    anexos = relationship("Anexo", back_populates="project", cascade="all, delete-orphan")
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
