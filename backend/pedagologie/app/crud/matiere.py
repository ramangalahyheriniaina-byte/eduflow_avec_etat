"""
Opérations CRUD pour la matière
"""
from sqlalchemy.orm import Session
from app.models.matiere import Matiere
from app.schemas.matiere import MatiereCreate, MatiereUpdate


def get_matiere(db: Session, matiere_id: int):
    """Récupère une matière par son ID"""
    return db.query(Matiere).filter(Matiere.id_matiere == matiere_id).first()


def get_matieres(db: Session, skip: int = 0, limit: int = 100):
    """Récupère toutes les matières avec pagination"""
    return db.query(Matiere).offset(skip).limit(limit).all()


def get_matieres_by_classe(db: Session, classe_id: int):
    """Récupère toutes les matières d'une classe"""
    return db.query(Matiere).filter(Matiere.id_classe == classe_id).all()


def create_matiere(db: Session, matiere: MatiereCreate):
    """Crée une nouvelle matière"""
    db_matiere = Matiere(**matiere.model_dump())
    db.add(db_matiere)
    db.commit()
    db.refresh(db_matiere)
    return db_matiere


def update_matiere(db: Session, matiere_id: int, matiere: MatiereUpdate):
    """Met à jour une matière"""
    db_matiere = get_matiere(db, matiere_id)
    if db_matiere:
        update_data = matiere.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(db_matiere, key, value)
        db.commit()
        db.refresh(db_matiere)
    return db_matiere


def delete_matiere(db: Session, matiere_id: int):
    """Supprime une matière"""
    db_matiere = get_matiere(db, matiere_id)
    if db_matiere:
        db.delete(db_matiere)
        db.commit()
        return True
    return False
