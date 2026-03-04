"""
Schémas Pydantic pour la validation des données de l'année scolaire
"""
from pydantic import BaseModel, Field, field_validator


class AnneeScolaireBase(BaseModel):
    """Schéma de base pour l'année scolaire"""
    start_year: int = Field(..., description="Année de début")
    end_year: int = Field(..., description="Année de fin")
    is_active: bool = Field(default=True, description="Statut actif")

    @field_validator('end_year')
    @classmethod
    def validate_years(cls, v, info):
        """Valide que end_year = start_year + 1"""
        if 'start_year' in info.data and v != info.data['start_year'] + 1:
            raise ValueError('end_year doit être égal à start_year + 1')
        return v


class AnneeScolaireCreate(AnneeScolaireBase):
    """Schéma pour la création d'une année scolaire"""
    pass


class AnneeScolaireUpdate(BaseModel):
    """Schéma pour la mise à jour d'une année scolaire"""
    is_active: bool | None = None


class AnneeScolaireResponse(AnneeScolaireBase):
    """Schéma pour la réponse d'une année scolaire"""
    id_annee_scolaire: int

    class Config:
        from_attributes = True
