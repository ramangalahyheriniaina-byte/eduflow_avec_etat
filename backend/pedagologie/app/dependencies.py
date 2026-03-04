"""
Dépendances partagées de l'application
"""
from typing import Generator
from sqlalchemy.orm import Session
from app.database import SessionLocal


def get_db() -> Generator[Session, None, None]:
    """
    Générateur de session de base de données
    À utiliser comme dépendance dans les routes FastAPI
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
