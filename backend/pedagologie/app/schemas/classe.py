"""
Schémas Pydantic pour la validation des données de la classe
"""
from pydantic import BaseModel, Field


class ClasseBase(BaseModel):
    """Schéma de base pour la classe"""
    nom_classe: str = Field(..., max_length=100, description="Nom de la classe")


class ClasseCreate(ClasseBase):
    """Schéma pour la création d'une classe"""
    pass


class ClasseUpdate(BaseModel):
    """Schéma pour la mise à jour d'une classe"""
    nom_classe: str | None = Field(None, max_length=100, description="Nom de la classe")


class ClasseResponse(ClasseBase):
    """Schéma pour la réponse d'une classe"""
    id_classe: int

    class Config:
        from_attributes = True
