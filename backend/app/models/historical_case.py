from sqlalchemy import Column, Integer, String, DateTime, Text, Boolean, JSON
from datetime import datetime
from app.database.session import Base

class HistoricalCase(Base):
    __tablename__ = "historical_cases"
    
    id = Column(Integer, primary_key=True, index=True)
    project_title = Column(String)
    institution_name = Column(String)
    year = Column(Integer)
    field = Column(String)
    priority_area = Column(String)
    is_approved = Column(Boolean)
    score = Column(Integer)
    budget = Column(Integer)
    
    full_text = Column(Text)
    summary = Column(Text)
    key_points = Column(JSON)
    rejection_reasons = Column(JSON)
    
    vector_id = Column(String)  # ID no Qdrant
    
    created_at = Column(DateTime, default=datetime.utcnow)
