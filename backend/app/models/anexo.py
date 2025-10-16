from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Text, JSON
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database.session import Base

class Anexo(Base):
    __tablename__ = "anexos"
    
    id = Column(Integer, primary_key=True, index=True)
    project_id = Column(Integer, ForeignKey("projects.id"), nullable=False)
    tipo = Column(String, nullable=False)  # ANEXO_I, ANEXO_II, etc
    nome = Column(String)
    dados = Column(JSON, default={})
    completion_score = Column(Integer, default=0)  # 0-100
    validation_status = Column(String, default="pending")
    ai_suggestions = Column(JSON, default=[])
    
    project = relationship("Project", back_populates="anexos")
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
