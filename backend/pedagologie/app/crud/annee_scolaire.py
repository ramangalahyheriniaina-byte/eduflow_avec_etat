"""
Opérations CRUD pour l'année scolaire
"""
from sqlalchemy.orm import Session
from app.models.annee_scolaire import AnneeScolaire
from app.schemas.annee_scolaire import AnneeScolaireCreate, AnneeScolaireUpdate


def get_annee_scolaire(db: Session, annee_id: int):
    """Récupère une année scolaire par son ID"""
    return db.query(AnneeScolaire).filter(AnneeScolaire.id_annee_scolaire == annee_id).first()


def get_annees_scolaires(db: Session, skip: int = 0, limit: int = 100):
    """Récupère toutes les années scolaires avec pagination"""
    return db.query(AnneeScolaire).offset(skip).limit(limit).all()


def get_active_annee_scolaire(db: Session):
    """Récupère l'année scolaire active"""
    return db.query(AnneeScolaire).filter(AnneeScolaire.is_active == True).first()


def create_annee_scolaire(db: Session, annee: AnneeScolaireCreate):
    """Crée une nouvelle année scolaire"""
    db_annee = AnneeScolaire(**annee.model_dump())
    db.add(db_annee)
    db.commit()
    db.refresh(db_annee)
    return db_annee


def update_annee_scolaire(db: Session, annee_id: int, annee: AnneeScolaireUpdate):
    """Met à jour une année scolaire"""
    db_annee = get_annee_scolaire(db, annee_id)
    if db_annee:
        update_data = annee.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(db_annee, key, value)
        db.commit()
        db.refresh(db_annee)
    return db_annee


def delete_annee_scolaire(db: Session, annee_id: int):
    """Supprime une année scolaire"""
    db_annee = get_annee_scolaire(db, annee_id)
    if db_annee:
        db.delete(db_annee)
        db.commit()
        return True
    return False
