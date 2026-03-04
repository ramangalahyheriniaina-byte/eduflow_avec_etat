"""
Schémas Pydantic pour la validation des données de la séance
"""
from pydantic import BaseModel, Field
from datetime import date, time
from typing import Optional
from app.models.seance import StatutSeance

# Import des schémas de relations
from app.schemas.cours import CoursResponse  # AJOUT IMPORTANT


class SeanceBase(BaseModel):
    """Schéma de base pour la séance"""
    id_cours: int = Field(..., description="ID du cours")
    date_seance: date = Field(..., description="Date de la séance")
    heure_debut: time = Field(..., description="Heure de début")
    heure_fin: time = Field(..., description="Heure de fin")


class SeanceCreate(SeanceBase):
    """Schéma pour la création d'une séance"""
    statut: StatutSeance = Field(default=StatutSeance.PREVU, description="Statut de la séance")


class SeanceUpdate(BaseModel):
    """Schéma pour la mise à jour d'une séance"""
    id_cours: int | None = Field(None, description="ID du cours")
    date_seance: date | None = Field(None, description="Date de la séance")
    heure_debut: time | None = Field(None, description="Heure de début")
    heure_fin: time | None = Field(None, description="Heure de fin")
    statut: StatutSeance | None = Field(None, description="Statut de la séance")


class SeanceResponse(SeanceBase):
    """Schéma pour la réponse d'une séance"""
    id_seance: int
    statut: StatutSeance
    cours: Optional[CoursResponse] = None  # AJOUT CRITIQUE ! (avec 's' à cours)

    class Config:
        from_attributes = True