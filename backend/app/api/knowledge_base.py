from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database.session import get_db
from app.models.historical_case import HistoricalCase

router = APIRouter()

@router.get("/cases")
async def list_cases(approved_only: bool = None, db: Session = Depends(get_db)):
    query = db.query(HistoricalCase)
    if approved_only is not None:
        query = query.filter(HistoricalCase.is_approved == approved_only)
    return query.limit(50).all()

@router.get("/cases/{case_id}")
async def get_case(case_id: int, db: Session = Depends(get_db)):
    return db.query(HistoricalCase).filter(HistoricalCase.id == case_id).first()
