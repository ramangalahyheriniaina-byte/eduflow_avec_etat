"""
Schémas Pydantic pour la validation des données du professeur
"""
from pydantic import BaseModel, Field


class ProfBase(BaseModel):
    """Schéma de base pour le professeur"""
    nom_prof: str = Field(..., max_length=100, description="Nom du professeur")


class ProfCreate(ProfBase):
    """Schéma pour la création d'un professeur"""
    nb_abs: int = Field(default=0, ge=0, description="Nombre d'absences")


class ProfUpdate(BaseModel):
    """Schéma pour la mise à jour d'un professeur"""
    nom_prof: str | None = Field(None, max_length=100, description="Nom du professeur")
    nb_abs: int | None = Field(None, ge=0, description="Nombre d'absences")


class ProfResponse(ProfBase):
    """Schéma pour la réponse d'un professeur"""
    id_prof: int
    nb_abs: int

    class Config:
        from_attributes = True
