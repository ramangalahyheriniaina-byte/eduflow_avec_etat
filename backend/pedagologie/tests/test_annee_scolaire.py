"""
Tests pour les endpoints de l'année scolaire
"""
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.main import app
from app.database import Base
from app.dependencies import get_db

# Base de données de test en mémoire
SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Créer les tables
Base.metadata.create_all(bind=engine)


def override_get_db():
    """Override de la dépendance get_db pour les tests"""
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db] = override_get_db
client = TestClient(app)


def test_create_annee_scolaire():
    """Test de création d'une année scolaire"""
    response = client.post(
        "/api/v1/annees-scolaires/",
        json={"start_year": 2024, "end_year": 2025, "is_active": True}
    )
    assert response.status_code == 201
    data = response.json()
    assert data["start_year"] == 2024
    assert data["end_year"] == 2025
    assert data["is_active"] is True
    assert "id_annee_scolaire" in data


def test_get_annee_scolaire():
    """Test de récupération d'une année scolaire"""
    # Créer d'abord une année scolaire
    create_response = client.post(
        "/api/v1/annees-scolaires/",
        json={"start_year": 2023, "end_year": 2024, "is_active": False}
    )
    annee_id = create_response.json()["id_annee_scolaire"]
    
    # Récupérer l'année scolaire
    response = client.get(f"/api/v1/annees-scolaires/{annee_id}")
    assert response.status_code == 200
    data = response.json()
    assert data["id_annee_scolaire"] == annee_id
    assert data["start_year"] == 2023
    assert data["end_year"] == 2024


def test_list_annees_scolaires():
    """Test de liste des années scolaires"""
    response = client.get("/api/v1/annees-scolaires/")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)


def test_update_annee_scolaire():
    """Test de mise à jour d'une année scolaire"""
    # Créer d'abord une année scolaire
    create_response = client.post(
        "/api/v1/annees-scolaires/",
        json={"start_year": 2022, "end_year": 2023, "is_active": False}
    )
    annee_id = create_response.json()["id_annee_scolaire"]
    
    # Mettre à jour
    response = client.put(
        f"/api/v1/annees-scolaires/{annee_id}",
        json={"is_active": True}
    )
    assert response.status_code == 200
    data = response.json()
    assert data["is_active"] is True


def test_delete_annee_scolaire():
    """Test de suppression d'une année scolaire"""
    # Créer d'abord une année scolaire
    create_response = client.post(
        "/api/v1/annees-scolaires/",
        json={"start_year": 2021, "end_year": 2022, "is_active": False}
    )
    annee_id = create_response.json()["id_annee_scolaire"]
    
    # Supprimer
    response = client.delete(f"/api/v1/annees-scolaires/{annee_id}")
    assert response.status_code == 204
    
    # Vérifier que c'est bien supprimé
    get_response = client.get(f"/api/v1/annees-scolaires/{annee_id}")
    assert get_response.status_code == 404


def test_invalid_year_range():
    """Test avec une plage d'années invalide"""
    response = client.post(
        "/api/v1/annees-scolaires/",
        json={"start_year": 2024, "end_year": 2026, "is_active": True}
    )
    assert response.status_code == 422  # Validation error
