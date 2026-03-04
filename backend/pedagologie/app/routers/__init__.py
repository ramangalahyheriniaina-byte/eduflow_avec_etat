"""
Module des routers FastAPI
"""
from app.routers import annee_scolaire
from app.routers import classe
from app.routers import prof
from app.routers import matiere
from app.routers import cours
from app.routers import seance

__all__ = [
    "annee_scolaire",
    "classe",
    "prof",
    "matiere",
    "cours",
    "seance"
]
