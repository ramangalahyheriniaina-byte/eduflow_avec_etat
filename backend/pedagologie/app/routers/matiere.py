"""
Routes API pour la gestion des matières
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app.dependencies import get_db
from app.schemas.matiere import MatiereCreate, MatiereUpdate, MatiereResponse
from app.crud import matiere as crud
from app.crud import classe as crud_classe

router = APIRouter(
    prefix="/matieres",
    tags=["Matières"]
)


@router.get("/", response_model=List[MatiereResponse])
def list_matieres(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """Liste toutes les matières"""
    return crud.get_matieres(db, skip=skip, limit=limit)


@router.get("/classe/{classe_id}", response_model=List[MatiereResponse])
def list_matieres_by_classe(classe_id: int, db: Session = Depends(get_db)):
    """Liste toutes les matières d'une classe"""
    # Vérifier que la classe existe
    classe = crud_classe.get_classe(db, classe_id)
    if not classe:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Classe {classe_id} non trouvée"
        )
    return crud.get_matieres_by_classe(db, classe_id)


@router.get("/{matiere_id}", response_model=MatiereResponse)
def get_matiere(matiere_id: int, db: Session = Depends(get_db)):
    """Récupère une matière par son ID"""
    matiere = crud.get_matiere(db, matiere_id)
    if not matiere:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Matière {matiere_id} non trouvée"
        )
    return matiere


@router.post("/", response_model=MatiereResponse, status_code=status.HTTP_201_CREATED)
def create_matiere(matiere: MatiereCreate, db: Session = Depends(get_db)):
    """Crée une nouvelle matière"""
    # Vérifier que la classe existe
    classe = crud_classe.get_classe(db, matiere.id_classe)
    if not classe:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Classe {matiere.id_classe} non trouvée"
        )
    return crud.create_matiere(db, matiere)


@router.put("/{matiere_id}", response_model=MatiereResponse)
def update_matiere(
    matiere_id: int,
    matiere: MatiereUpdate,
    db: Session = Depends(get_db)
):
    """Met à jour une matière"""
    # Si id_classe est fourni, vérifier qu'elle existe
    if matiere.id_classe is not None:
        classe = crud_classe.get_classe(db, matiere.id_classe)
        if not classe:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Classe {matiere.id_classe} non trouvée"
            )
    
    db_matiere = crud.update_matiere(db, matiere_id, matiere)
    if not db_matiere:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Matière {matiere_id} non trouvée"
        )
    return db_matiere


@router.delete("/{matiere_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_matiere(matiere_id: int, db: Session = Depends(get_db)):
    """Supprime une matière"""
    if not crud.delete_matiere(db, matiere_id):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Matière {matiere_id} non trouvée"
        )
