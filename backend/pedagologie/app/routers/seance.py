"""
Routes API pour la gestion des séances
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload  # AJOUT: joinedload
from typing import List
from datetime import date

from app.dependencies import get_db
from app.schemas.seance import SeanceCreate, SeanceUpdate, SeanceResponse
from app.models.seance import Seance, StatutSeance  # AJOUT: Seance
from app.models.cours import Cours  # AJOUT: Cours
from app.models.matiere import Matiere  # Déjà présent
from app.crud import seance as crud
from app.crud import cours as crud_cours

router = APIRouter(
    prefix="/seances",
    tags=["Séances"]
)


@router.get("/", response_model=List[SeanceResponse])
def list_seances(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """Liste toutes les séances avec leurs relations"""
    return (
        db.query(Seance)
        .options(
            joinedload(Seance.cours)  # CORRECTION: pas de point après cours
            .joinedload(Cours.matiere),
            joinedload(Seance.cours)
            .joinedload(Cours.prof)
        )
        .offset(skip)
        .limit(limit)
        .all()
    )

@router.get("/cours/{cours_id}", response_model=List[SeanceResponse])
def list_seances_by_cours(cours_id: int, db: Session = Depends(get_db)):
    """Liste toutes les séances d'un cours"""
    # Vérifier que le cours existe
    cours = crud_cours.get_cours(db, cours_id)
    if not cours:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Cours {cours_id} non trouvé"
        )
    
    # Récupérer les séances avec les relations
    return (
        db.query(Seance)
        .options(
            joinedload(Seance.cours)
            .joinedload(Cours.matiere),
            joinedload(Seance.cours)
            .joinedload(Cours.prof)
        )
        .filter(Seance.id_cours == cours_id)
        .all()
    )


@router.get("/date/{date_seance}", response_model=List[SeanceResponse])
def list_seances_by_date(date_seance: date, db: Session = Depends(get_db)):
    """Liste toutes les séances d'une date donnée"""
    return (
        db.query(Seance)
        .options(
            joinedload(Seance.cours)
            .joinedload(Cours.matiere),
            joinedload(Seance.cours)
            .joinedload(Cours.prof)
        )
        .filter(Seance.date == date_seance)
        .all()
    )


@router.get("/statut/{statut}", response_model=List[SeanceResponse])
def list_seances_by_statut(statut: StatutSeance, db: Session = Depends(get_db)):
    """Liste toutes les séances avec un statut donné"""
    return (
        db.query(Seance)
        .options(
            joinedload(Seance.cours)
            .joinedload(Cours.matiere),
            joinedload(Seance.cours)
            .joinedload(Cours.prof)
        )
        .filter(Seance.statut == statut)
        .all()
    )


@router.get("/{seance_id}", response_model=SeanceResponse)
def get_seance(seance_id: int, db: Session = Depends(get_db)):
    """Récupère une séance par son ID"""
    seance = (
        db.query(Seance)
        .options(
            joinedload(Seance.cours)
            .joinedload(Cours.matiere),
            joinedload(Seance.cours)
            .joinedload(Cours.prof)
        )
        .filter(Seance.id_seance == seance_id)  # CORRECTION : id_seance
        .first()
    )
    
    if not seance:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Séance {seance_id} non trouvée"
        )
    return seance


@router.post("/", response_model=SeanceResponse, status_code=status.HTTP_201_CREATED)
def create_seance(seance: SeanceCreate, db: Session = Depends(get_db)):
    """Crée une nouvelle séance"""
    # Vérifier que le cours existe
    cours = crud_cours.get_cours(db, seance.id_cours)
    if not cours:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Cours {seance.id_cours} non trouvé"
        )
    
    # Vérifier que l'heure de fin est après l'heure de début
    if seance.heure_fin <= seance.heure_debut:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="L'heure de fin doit être après l'heure de début"
        )
    
    return crud.create_seance(db, seance)


@router.put("/{seance_id}", response_model=SeanceResponse)
def update_seance(
    seance_id: int,
    seance: SeanceUpdate,
    db: Session = Depends(get_db)
):
    """Met à jour une séance"""
    # Vérifier le cours si fourni
    if seance.id_cours is not None:
        cours = crud_cours.get_cours(db, seance.id_cours)
        if not cours:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Cours {seance.id_cours} non trouvé"
            )
    
    # Vérifier les heures si fournies
    if seance.heure_debut is not None and seance.heure_fin is not None:
        if seance.heure_fin <= seance.heure_debut:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="L'heure de fin doit être après l'heure de début"
            )
    
    db_seance = crud.update_seance(db, seance_id, seance)
    if not db_seance:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Séance {seance_id} non trouvée"
        )
    
    # Recharger avec les relations pour la réponse
    return get_seance(seance_id, db)


@router.delete("/{seance_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_seance(seance_id: int, db: Session = Depends(get_db)):
    """Supprime une séance"""
    if not crud.delete_seance(db, seance_id):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Séance {seance_id} non trouvée"
        )


@router.patch("/{seance_id}/annuler", response_model=SeanceResponse)
def cancel_seance(seance_id: int, db: Session = Depends(get_db)):
    """Annule une séance"""
    db_seance = crud.cancel_seance(db, seance_id)
    if not db_seance:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Séance {seance_id} non trouvée"
        )
    
    # Recharger avec les relations pour la réponse
    return get_seance(seance_id, db)