"""
Schémas Pydantic pour la validation des données du cours
"""
from pydantic import BaseModel, Field
from typing import Optional
from app.models.cours import StatutCours
from app.schemas.matiere import MatiereResponse
from app.schemas.prof import ProfResponse
from app.schemas.classe import ClasseResponse


class CoursBase(BaseModel):
    """Schéma de base pour le cours"""
    id_matiere: int = Field(..., description="ID de la matière")
    id_prof: int = Field(..., description="ID du professeur")
    cumul: int | None = Field(None, ge=0, description="Cumul d'heures")


class CoursCreate(CoursBase):
    """Schéma pour la création d'un cours"""
    statut: StatutCours = Field(default=StatutCours.NON_COMMENCE, description="Statut du cours")


class CoursUpdate(BaseModel):
    """Schéma pour la mise à jour d'un cours"""
    statut: StatutCours | None = Field(None, description="Statut du cours")
    id_matiere: int | None = Field(None, description="ID de la matière")
    id_prof: int | None = Field(None, description="ID du professeur")
    cumul: int | None = Field(None, ge=0, description="Cumul d'heures")


class CoursResponse(CoursBase):
    """Schéma pour la réponse d'un cours avec relations"""
    id_cours: int
    statut: StatutCours
    matiere: Optional[MatiereResponse] = None
    prof: Optional[ProfResponse] = None
    classe: Optional[ClasseResponse] = None

    class Config:
        from_attributes = True