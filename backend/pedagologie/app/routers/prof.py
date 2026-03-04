"""
Routes API pour la gestion des professeurs
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app.dependencies import get_db
from app.schemas.prof import ProfCreate, ProfUpdate, ProfResponse
from app.crud import prof as crud

router = APIRouter(
    prefix="/professeurs",
    tags=["Professeurs"]
)


@router.get("/", response_model=List[ProfResponse])
def list_profs(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """Liste tous les professeurs"""
    return crud.get_profs(db, skip=skip, limit=limit)


@router.get("/{prof_id}", response_model=ProfResponse)
def get_prof(prof_id: int, db: Session = Depends(get_db)):
    """Récupère un professeur par son ID"""
    prof = crud.get_prof(db, prof_id)
    if not prof:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Professeur {prof_id} non trouvé"
        )
    return prof


@router.post("/", response_model=ProfResponse, status_code=status.HTTP_201_CREATED)
def create_prof(prof: ProfCreate, db: Session = Depends(get_db)):
    """Crée un nouveau professeur"""
    return crud.create_prof(db, prof)


@router.put("/{prof_id}", response_model=ProfResponse)
def update_prof(
    prof_id: int,
    prof: ProfUpdate,
    db: Session = Depends(get_db)
):
    """Met à jour un professeur"""
    db_prof = crud.update_prof(db, prof_id, prof)
    if not db_prof:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Professeur {prof_id} non trouvé"
        )
    return db_prof


@router.delete("/{prof_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_prof(prof_id: int, db: Session = Depends(get_db)):
    """Supprime un professeur"""
    if not crud.delete_prof(db, prof_id):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Professeur {prof_id} non trouvé"
        )


@router.post("/{prof_id}/absences", response_model=ProfResponse)
def increment_absences(prof_id: int, db: Session = Depends(get_db)):
    """Incrémente le nombre d'absences d'un professeur"""
    db_prof = crud.increment_absences(db, prof_id)
    if not db_prof:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Professeur {prof_id} non trouvé"
        )
    return db_prof
