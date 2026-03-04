"""
Routes API pour la gestion des classes
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app.dependencies import get_db
from app.schemas.classe import ClasseCreate, ClasseUpdate, ClasseResponse
from app.crud import classe as crud

router = APIRouter(
    prefix="/classes",
    tags=["Classes"]
)


@router.get("/", response_model=List[ClasseResponse])
def list_classes(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """Liste toutes les classes"""
    return crud.get_classes(db, skip=skip, limit=limit)


@router.get("/{classe_id}", response_model=ClasseResponse)
def get_classe(classe_id: int, db: Session = Depends(get_db)):
    """Récupère une classe par son ID"""
    classe = crud.get_classe(db, classe_id)
    if not classe:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Classe {classe_id} non trouvée"
        )
    return classe


@router.post("/", response_model=ClasseResponse, status_code=status.HTTP_201_CREATED)
def create_classe(classe: ClasseCreate, db: Session = Depends(get_db)):
    """Crée une nouvelle classe"""
    # Vérifier si une classe avec le même nom existe déjà
    existing_classe = crud.get_classe_by_nom(db, classe.nom_classe)
    if existing_classe:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Une classe avec le nom '{classe.nom_classe}' existe déjà"
        )
    return crud.create_classe(db, classe)


@router.put("/{classe_id}", response_model=ClasseResponse)
def update_classe(
    classe_id: int,
    classe: ClasseUpdate,
    db: Session = Depends(get_db)
):
    """Met à jour une classe"""
    db_classe = crud.update_classe(db, classe_id, classe)
    if not db_classe:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Classe {classe_id} non trouvée"
        )
    return db_classe


@router.delete("/{classe_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_classe(classe_id: int, db: Session = Depends(get_db)):
    """Supprime une classe"""
    if not crud.delete_classe(db, classe_id):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Classe {classe_id} non trouvée"
        )
