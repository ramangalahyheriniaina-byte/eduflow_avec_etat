"""
Opérations CRUD pour la séance
"""
from sqlalchemy.orm import Session
from datetime import date
from app.models.seance import Seance, StatutSeance
from app.schemas.seance import SeanceCreate, SeanceUpdate


def get_seance(db: Session, seance_id: int):
    """Récupère une séance par son ID"""
    return db.query(Seance).filter(Seance.id_seance == seance_id).first()


def get_seances(db: Session, skip: int = 0, limit: int = 100):
    """Récupère toutes les séances avec pagination"""
    return db.query(Seance).offset(skip).limit(limit).all()


def get_seances_by_cours(db: Session, cours_id: int):
    """Récupère toutes les séances d'un cours"""
    return db.query(Seance).filter(Seance.id_cours == cours_id).all()


def get_seances_by_date(db: Session, date_seance: date):
    """Récupère toutes les séances d'une date donnée"""
    return db.query(Seance).filter(Seance.date_seance == date_seance).all()


def get_seances_by_statut(db: Session, statut: StatutSeance):
    """Récupère toutes les séances avec un statut donné"""
    return db.query(Seance).filter(Seance.statut == statut).all()


def create_seance(db: Session, seance: SeanceCreate):
    """Crée une nouvelle séance"""
    db_seance = Seance(**seance.model_dump())
    db.add(db_seance)
    db.commit()
    db.refresh(db_seance)
    return db_seance


def update_seance(db: Session, seance_id: int, seance: SeanceUpdate):
    """Met à jour une séance"""
    db_seance = get_seance(db, seance_id)
    if db_seance:
        update_data = seance.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(db_seance, key, value)
        db.commit()
        db.refresh(db_seance)
    return db_seance


def delete_seance(db: Session, seance_id: int):
    """Supprime une séance"""
    db_seance = get_seance(db, seance_id)
    if db_seance:
        db.delete(db_seance)
        db.commit()
        return True
    return False


def cancel_seance(db: Session, seance_id: int):
    """Annule une séance"""
    db_seance = get_seance(db, seance_id)
    if db_seance:
        db_seance.statut = StatutSeance.ANNULE
        db.commit()
        db.refresh(db_seance)
    return db_seance