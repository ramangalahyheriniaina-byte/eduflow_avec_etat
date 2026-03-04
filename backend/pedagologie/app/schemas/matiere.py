"""
Schémas Pydantic pour la validation des données de la matière
"""
from pydantic import BaseModel, Field
from typing import Optional
from app.schemas.classe import ClasseResponse


class MatiereBase(BaseModel):
    """Schéma de base pour la matière"""
    nom_matiere: str = Field(..., max_length=100, description="Nom de la matière")
    heure_totale: int = Field(..., ge=0, description="Nombre total d'heures")
    id_classe: int = Field(..., description="ID de la classe")


class MatiereCreate(MatiereBase):
    """Schéma pour la création d'une matière"""
    pass


class MatiereUpdate(BaseModel):
    """Schéma pour la mise à jour d'une matière"""
    nom_matiere: str | None = Field(None, max_length=100, description="Nom de la matière")
    heure_totale: int | None = Field(None, ge=0, description="Nombre total d'heures")
    id_classe: int | None = Field(None, description="ID de la classe")


class MatiereResponse(MatiereBase):
    """Schéma pour la réponse d'une matière"""
    id_matiere: int
    classe: Optional[ClasseResponse] = None

    class Config:
        from_attributes = True
