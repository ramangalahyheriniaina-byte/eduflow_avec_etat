"""
Opérations CRUD pour la classe
"""
from sqlalchemy.orm import Session
from app.models.classe import Classe
from app.schemas.classe import ClasseCreate, ClasseUpdate


def get_classe(db: Session, classe_id: int):
    """Récupère une classe par son ID"""
    return db.query(Classe).filter(Classe.id_classe == classe_id).first()


def get_classes(db: Session, skip: int = 0, limit: int = 100):
    """Récupère toutes les classes avec pagination"""
    return db.query(Classe).offset(skip).limit(limit).all()


def get_classe_by_nom(db: Session, nom_classe: str):
    """Récupère une classe par son nom"""
    return db.query(Classe).filter(Classe.nom_classe == nom_classe).first()


def create_classe(db: Session, classe: ClasseCreate):
    """Crée une nouvelle classe"""
    db_classe = Classe(**classe.model_dump())
    db.add(db_classe)
    db.commit()
    db.refresh(db_classe)
    return db_classe


def update_classe(db: Session, classe_id: int, classe: ClasseUpdate):
    """Met à jour une classe"""
    db_classe = get_classe(db, classe_id)
    if db_classe:
        update_data = classe.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(db_classe, key, value)
        db.commit()
        db.refresh(db_classe)
    return db_classe


def delete_classe(db: Session, classe_id: int):
    """Supprime une classe"""
    db_classe = get_classe(db, classe_id)
    if db_classe:
        db.delete(db_classe)
        db.commit()
        return True
    return False
