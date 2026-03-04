"""
Module des schémas Pydantic
"""
from app.schemas.annee_scolaire import (
    AnneeScolaireCreate,
    AnneeScolaireUpdate,
    AnneeScolaireResponse
)
from app.schemas.classe import (
    ClasseCreate,
    ClasseUpdate,
    ClasseResponse
)
from app.schemas.prof import (
    ProfCreate,
    ProfUpdate,
    ProfResponse
)
from app.schemas.matiere import (
    MatiereCreate,
    MatiereUpdate,
    MatiereResponse
)
from app.schemas.cours import (
    CoursCreate,
    CoursUpdate,
    CoursResponse
)
from app.schemas.seance import (
    SeanceCreate,
    SeanceUpdate,
    SeanceResponse
)

__all__ = [
    "AnneeScolaireCreate",
    "AnneeScolaireUpdate",
    "AnneeScolaireResponse",
    "ClasseCreate",
    "ClasseUpdate",
    "ClasseResponse",
    "ProfCreate",
    "ProfUpdate",
    "ProfResponse",
    "MatiereCreate",
    "MatiereUpdate",
    "MatiereResponse",
    "CoursCreate",
    "CoursUpdate",
    "CoursResponse",
    "SeanceCreate",
    "SeanceUpdate",
    "SeanceResponse"
]
