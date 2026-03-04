"""
Opérations CRUD pour le cours
"""
from sqlalchemy.orm import Session, joinedload
from app.models.cours import Cours, StatutCours
from app.models.matiere import Matiere  # IMPORT AJOUTÉ
from app.schemas.cours import CoursCreate, CoursUpdate


def get_cours(db: Session, cours_id: int):
    """Récupère un cours par son ID avec ses relations"""
    return (
        db.query(Cours)
        .options(
            joinedload(Cours.matiere).joinedload(Matiere.classe),  # CORRIGÉ
            joinedload(Cours.prof)
        )
        .filter(Cours.id_cours == cours_id)
        .first()
    )


def get_all_cours(db: Session, skip: int = 0, limit: int = 100):
    """Récupère tous les cours avec leurs relations"""
    return (
        db.query(Cours)
        .options(
            joinedload(Cours.matiere).joinedload(Matiere.classe),  # CORRIGÉ
            joinedload(Cours.prof)
        )
        .offset(skip)
        .limit(limit)
        .all()
    )


def get_cours_by_prof(db: Session, prof_id: int):
    """Récupère tous les cours d'un professeur avec relations"""
    return (
        db.query(Cours)
        .options(
            joinedload(Cours.matiere).joinedload(Matiere.classe),  # CORRIGÉ
            joinedload(Cours.prof)
        )
        .filter(Cours.id_prof == prof_id)
        .all()
    )


def get_cours_by_matiere(db: Session, matiere_id: int):
    """Récupère tous les cours d'une matière avec relations"""
    return (
        db.query(Cours)
        .options(
            joinedload(Cours.matiere).joinedload(Matiere.classe),  # CORRIGÉ
            joinedload(Cours.prof)
        )
        .filter(Cours.id_matiere == matiere_id)
        .all()
    )


def get_cours_by_statut(db: Session, statut: StatutCours):
    """Récupère tous les cours avec un statut donné"""
    return (
        db.query(Cours)
        .options(
            joinedload(Cours.matiere).joinedload(Matiere.classe),  # CORRIGÉ
            joinedload(Cours.prof)
        )
        .filter(Cours.statut == statut)
        .all()
    )


def create_cours(db: Session, cours: CoursCreate):
    """Crée un nouveau cours"""
    db_cours = Cours(**cours.model_dump())
    db.add(db_cours)
    db.commit()
    db.refresh(db_cours)
    return db_cours


def update_cours(db: Session, cours_id: int, cours: CoursUpdate):
    """Met à jour un cours"""
    db_cours = get_cours(db, cours_id)
    if db_cours:
        update_data = cours.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(db_cours, key, value)
        db.commit()
        db.refresh(db_cours)
    return db_cours


def delete_cours(db: Session, cours_id: int):
    """Supprime un cours"""
    db_cours = get_cours(db, cours_id)
    if db_cours:
        db.delete(db_cours)
        db.commit()
        return True
    return False


def update_cumul(db: Session, cours_id: int, heures: int):
    """Met à jour le cumul d'heures d'un cours"""
    db_cours = get_cours(db, cours_id)
    if db_cours:
        db_cours.cumul = (db_cours.cumul or 0) + heures
        db.commit()
        db.refresh(db_cours)
    return db_cours

