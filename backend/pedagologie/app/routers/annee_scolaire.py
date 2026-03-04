"""
Routes API pour la gestion des années scolaires
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app.dependencies import get_db
from app.schemas.annee_scolaire import AnneeScolaireCreate, AnneeScolaireUpdate, AnneeScolaireResponse
from app.crud import annee_scolaire as crud

router = APIRouter(
    prefix="/annees-scolaires",
    tags=["Années Scolaires"]
)


@router.get("/", response_model=List[AnneeScolaireResponse])
def list_annees_scolaires(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """Liste toutes les années scolaires"""
    return crud.get_annees_scolaires(db, skip=skip, limit=limit)


@router.get("/active", response_model=AnneeScolaireResponse)
def get_active_annee(db: Session = Depends(get_db)):
    """Récupère l'année scolaire active"""
    annee = crud.get_active_annee_scolaire(db)
    if not annee:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Aucune année scolaire active"
        )
    return annee


@router.get("/{annee_id}", response_model=AnneeScolaireResponse)
def get_annee_scolaire(annee_id: int, db: Session = Depends(get_db)):
    """Récupère une année scolaire par son ID"""
    annee = crud.get_annee_scolaire(db, annee_id)
    if not annee:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Année scolaire {annee_id} non trouvée"
        )
    return annee


@router.post("/", response_model=AnneeScolaireResponse, status_code=status.HTTP_201_CREATED)
def create_annee_scolaire(annee: AnneeScolaireCreate, db: Session = Depends(get_db)):
    """Crée une nouvelle année scolaire"""
    return crud.create_annee_scolaire(db, annee)


@router.put("/{annee_id}", response_model=AnneeScolaireResponse)
def update_annee_scolaire(
    annee_id: int,
    annee: AnneeScolaireUpdate,
    db: Session = Depends(get_db)
):
    """Met à jour une année scolaire"""
    db_annee = crud.update_annee_scolaire(db, annee_id, annee)
    if not db_annee:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Année scolaire {annee_id} non trouvée"
        )
    return db_annee


@router.delete("/{annee_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_annee_scolaire(annee_id: int, db: Session = Depends(get_db)):
    """Supprime une année scolaire"""
    if not crud.delete_annee_scolaire(db, annee_id):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Année scolaire {annee_id} non trouvée"
        )
