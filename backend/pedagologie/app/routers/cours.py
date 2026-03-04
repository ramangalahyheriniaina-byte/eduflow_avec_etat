"""
Routes API pour la gestion des cours
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app.dependencies import get_db
from app.schemas.cours import CoursCreate, CoursUpdate, CoursResponse
from app.models.cours import StatutCours
from app.crud import cours as crud
from app.crud import matiere as crud_matiere
from app.crud import prof as crud_prof

router = APIRouter(
    prefix="/cours",
    tags=["Cours"]
)


@router.get("/", response_model=List[CoursResponse])
def list_cours(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """Liste tous les cours"""
    return crud.get_all_cours(db, skip=skip, limit=limit)


@router.get("/professeur/{prof_id}", response_model=List[CoursResponse])
def list_cours_by_prof(prof_id: int, db: Session = Depends(get_db)):
    """Liste tous les cours d'un professeur"""
    # Vérifier que le professeur existe
    prof = crud_prof.get_prof(db, prof_id)
    if not prof:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Professeur {prof_id} non trouvé"
        )
    return crud.get_cours_by_prof(db, prof_id)


@router.get("/matiere/{matiere_id}", response_model=List[CoursResponse])
def list_cours_by_matiere(matiere_id: int, db: Session = Depends(get_db)):
    """Liste tous les cours d'une matière"""
    # Vérifier que la matière existe
    matiere = crud_matiere.get_matiere(db, matiere_id)
    if not matiere:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Matière {matiere_id} non trouvée"
        )
    return crud.get_cours_by_matiere(db, matiere_id)


@router.get("/statut/{statut}", response_model=List[CoursResponse])
def list_cours_by_statut(statut: StatutCours, db: Session = Depends(get_db)):
    """Liste tous les cours avec un statut donné"""
    return crud.get_cours_by_statut(db, statut)


@router.get("/{cours_id}", response_model=CoursResponse)
def get_cours(cours_id: int, db: Session = Depends(get_db)):
    """Récupère un cours par son ID"""
    cours = crud.get_cours(db, cours_id)
    if not cours:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Cours {cours_id} non trouvé"
        )
    return cours


@router.post("/", response_model=CoursResponse, status_code=status.HTTP_201_CREATED)
def create_cours(cours: CoursCreate, db: Session = Depends(get_db)):
    """Crée un nouveau cours"""
    # Vérifier que la matière existe
    matiere = crud_matiere.get_matiere(db, cours.id_matiere)
    if not matiere:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Matière {cours.id_matiere} non trouvée"
        )
    
    # Vérifier que le professeur existe
    prof = crud_prof.get_prof(db, cours.id_prof)
    if not prof:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Professeur {cours.id_prof} non trouvé"
        )
    
    return crud.create_cours(db, cours)


@router.put("/{cours_id}", response_model=CoursResponse)
def update_cours(
    cours_id: int,
    cours: CoursUpdate,
    db: Session = Depends(get_db)
):
    """Met à jour un cours"""
    # Vérifier les références si elles sont fournies
    if cours.id_matiere is not None:
        matiere = crud_matiere.get_matiere(db, cours.id_matiere)
        if not matiere:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Matière {cours.id_matiere} non trouvée"
            )
    
    if cours.id_prof is not None:
        prof = crud_prof.get_prof(db, cours.id_prof)
        if not prof:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Professeur {cours.id_prof} non trouvé"
            )
    
    db_cours = crud.update_cours(db, cours_id, cours)
    if not db_cours:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Cours {cours_id} non trouvé"
        )
    return db_cours


@router.delete("/{cours_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_cours(cours_id: int, db: Session = Depends(get_db)):
    """Supprime un cours"""
    if not crud.delete_cours(db, cours_id):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Cours {cours_id} non trouvé"
        )


@router.patch("/{cours_id}/cumul", response_model=CoursResponse)
def update_cumul(
    cours_id: int,
    heures: int,
    db: Session = Depends(get_db)
):
    """Met à jour le cumul d'heures d'un cours"""
    db_cours = crud.update_cumul(db, cours_id, heures)
    if not db_cours:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Cours {cours_id} non trouvé"
        )
    return db_cours