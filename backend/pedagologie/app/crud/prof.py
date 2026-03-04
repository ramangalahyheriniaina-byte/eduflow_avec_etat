"""
Opérations CRUD pour le professeur
"""
from sqlalchemy.orm import Session
from app.models.prof import Prof
from app.schemas.prof import ProfCreate, ProfUpdate


def get_prof(db: Session, prof_id: int):
    """Récupère un professeur par son ID"""
    return db.query(Prof).filter(Prof.id_prof == prof_id).first()


def get_profs(db: Session, skip: int = 0, limit: int = 100):
    """Récupère tous les professeurs avec pagination"""
    return db.query(Prof).offset(skip).limit(limit).all()


def get_prof_by_nom(db: Session, nom_prof: str):
    """Récupère un professeur par son nom"""
    return db.query(Prof).filter(Prof.nom_prof == nom_prof).first()


def create_prof(db: Session, prof: ProfCreate):
    """Crée un nouveau professeur"""
    db_prof = Prof(**prof.model_dump())
    db.add(db_prof)
    db.commit()
    db.refresh(db_prof)
    return db_prof


def update_prof(db: Session, prof_id: int, prof: ProfUpdate):
    """Met à jour un professeur"""
    db_prof = get_prof(db, prof_id)
    if db_prof:
        update_data = prof.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(db_prof, key, value)
        db.commit()
        db.refresh(db_prof)
    return db_prof


def delete_prof(db: Session, prof_id: int):
    """Supprime un professeur"""
    db_prof = get_prof(db, prof_id)
    if db_prof:
        db.delete(db_prof)
        db.commit()
        return True
    return False


def increment_absences(db: Session, prof_id: int):
    """Incrémente le nombre d'absences d'un professeur"""
    db_prof = get_prof(db, prof_id)
    if db_prof:
        db_prof.nb_abs += 1
        db.commit()
        db.refresh(db_prof)
    return db_prof
