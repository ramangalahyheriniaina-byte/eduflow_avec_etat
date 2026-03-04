"""
Configuration de l'application EduFlow
"""
import os
from functools import lru_cache
from typing import List


class Settings:
    """
    Paramètres de configuration de l'application
    """
    def __init__(self):
        # Base de données - SQLite par défaut (pas besoin de PostgreSQL pour démarrer)
        self.DATABASE_URL: str = os.getenv(
            "DATABASE_URL", 
            "sqlite:///./eduflow.db"  # SQLite par défaut
        )
        
        # Configuration API
        self.API_V1_PREFIX: str = os.getenv("API_V1_PREFIX", "/api/v1")
        self.PROJECT_NAME: str = os.getenv("PROJECT_NAME", "EduFlow API")
        self.VERSION: str = os.getenv("VERSION", "1.0.0")
        
        # Configuration CORS
        cors_origins = os.getenv(
            "BACKEND_CORS_ORIGINS", 
            #"http://localhost:3000,http://localhost:8080"
            "http://localhost:3000,http://localhost:8080,http://localhost:8000"  # AJOUTEZ 8080
        )
        self.BACKEND_CORS_ORIGINS: List[str] = [
            origin.strip() for origin in cors_origins.split(",")
        ]


@lru_cache()
def get_settings() -> Settings:
    """
    Retourne une instance unique des paramètres (pattern singleton)
    """
    return Settings()
