"""
Routes API pour vérifier l'état d'initialisation du système
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func

from app.dependencies import get_db
from app.models.annee_scolaire import AnneeScolaire
from app.models.classe import Classe
from app.models.matiere import Matiere
from app.models.cours import Cours
from app.models.prof import Prof

router = APIRouter(
    prefix="/setup",
    tags=["Configuration"]
)


@router.get("/status")
def get_setup_status(db: Session = Depends(get_db)):
    """
    Vérifie si le système a déjà été initialisé
    Retourne:
    - is_initialized: true/false
    - details: ce qui manque ou ce qui existe
    """
    
    # Vérifier année scolaire active
    annee_active = db.query(AnneeScolaire).filter(AnneeScolaire.is_active == True).first()
    
    # Vérifier s'il y a des classes
    classes_count = db.query(func.count(Classe.id_classe)).scalar()
    
    # Vérifier s'il y a des matières
    matieres_count = db.query(func.count(Matiere.id_matiere)).scalar()
    
    # Vérifier s'il y a des professeurs
    profs_count = db.query(func.count(Prof.id_prof)).scalar()
    
    # Vérifier s'il y a des cours (affectations prof-matière)
    cours_count = db.query(func.count(Cours.id_cours)).scalar()
    
    # Déterminer si l'initialisation est complète
    # Critères: année active + classes + matières + au moins 1 prof
    is_initialized = (
        annee_active is not None and
        classes_count > 0 and
        matieres_count > 0 and
        profs_count > 0
    )
    
    return {
        "is_initialized": is_initialized,
        "details": {
            "has_active_year": annee_active is not None,
            "active_year": {
                "id": annee_active.id_annee_scolaire if annee_active else None,
                "start_year": annee_active.start_year if annee_active else None,
                "end_year": annee_active.end_year if annee_active else None
            } if annee_active else None,
            "classes_count": classes_count,
            "matieres_count": matieres_count,
            "profs_count": profs_count,
            "cours_count": cours_count
        },
        "message": "Système déjà initialisé" if is_initialized else "Configuration requise"
    }


@router.get("/requirements")
def get_setup_requirements(db: Session = Depends(get_db)):
    """
    Liste ce qui manque pour une configuration complète
    """
    missing = []
    
    # Vérifier année active
    annee_active = db.query(AnneeScolaire).filter(AnneeScolaire.is_active == True).first()
    if not annee_active:
        missing.append("annee_scolaire")
    
    # Vérifier classes
    classes_count = db.query(func.count(Classe.id_classe)).scalar()
    if classes_count == 0:
        missing.append("classes")
    
    # Vérifier matières
    matieres_count = db.query(func.count(Matiere.id_matiere)).scalar()
    if matieres_count == 0:
        missing.append("matieres")
    
    # Vérifier professeurs
    profs_count = db.query(func.count(Prof.id_prof)).scalar()
    if profs_count == 0:
        missing.append("professeurs")
    
    return {
        "setup_complete": len(missing) == 0,
        "missing_items": missing
    }