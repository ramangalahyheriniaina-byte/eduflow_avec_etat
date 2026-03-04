"""
Application FastAPI principale pour EduFlow
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import get_settings
from app.database import engine, Base
from app.routers import (
    annee_scolaire,
    classe,
    prof,
    matiere,
    cours,
    seance,
    setup  # ✅ Ajout du router setup ici
)

settings = get_settings()

# Création des tables (en production, utiliser Alembic)
Base.metadata.create_all(bind=engine)

# Initialisation de l'application FastAPI
app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="API de gestion scolaire pour EduFlow"
)

# Configuration CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.BACKEND_CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Inclusion des routers
app.include_router(annee_scolaire.router, prefix=settings.API_V1_PREFIX)
app.include_router(classe.router, prefix=settings.API_V1_PREFIX)
app.include_router(prof.router, prefix=settings.API_V1_PREFIX)
app.include_router(matiere.router, prefix=settings.API_V1_PREFIX)
app.include_router(cours.router, prefix=settings.API_V1_PREFIX)
app.include_router(seance.router, prefix=settings.API_V1_PREFIX)
app.include_router(setup.router, prefix=settings.API_V1_PREFIX)  # ✅ Inclusion du router setup

@app.get("/")
def root():
    """Point d'entrée racine de l'API"""
    return {
        "message": "Bienvenue sur l'API EduFlow",
        "version": settings.VERSION,
        "docs": "/docs"
    }


@app.get("/health")
def health_check():
    """Endpoint de vérification de santé"""
    return {"status": "healthy"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True
    )