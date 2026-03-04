"""
Tests pour les endpoints de classe
"""
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.main import app
from app.database import Base
from app.dependencies import get_db

# Base de données de test en mémoire
SQLALCHEMY_DATABASE_URL = "sqlite:///./test_classe.db"
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


def test_create_classe():
    """Test de création d'une classe"""
    response = client.post(
        "/api/v1/classes/",
        json={"nom_classe": "Terminale S"}
    )
    assert response.status_code == 201
    data = response.json()
    assert data["nom_classe"] == "Terminale S"
    assert "id_classe" in data


def test_create_duplicate_classe():
    """Test de création d'une classe avec un nom déjà existant"""
    # Créer la première classe
    client.post(
        "/api/v1/classes/",
        json={"nom_classe": "Première ES"}
    )
    
    # Essayer de créer une classe avec le même nom
    response = client.post(
        "/api/v1/classes/",
        json={"nom_classe": "Première ES"}
    )
    assert response.status_code == 400


def test_get_classe():
    """Test de récupération d'une classe"""
    # Créer d'abord une classe
    create_response = client.post(
        "/api/v1/classes/",
        json={"nom_classe": "Seconde A"}
    )
    classe_id = create_response.json()["id_classe"]
    
    # Récupérer la classe
    response = client.get(f"/api/v1/classes/{classe_id}")
    assert response.status_code == 200
    data = response.json()
    assert data["id_classe"] == classe_id
    assert data["nom_classe"] == "Seconde A"


def test_list_classes():
    """Test de liste des classes"""
    response = client.get("/api/v1/classes/")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)


def test_update_classe():
    """Test de mise à jour d'une classe"""
    # Créer d'abord une classe
    create_response = client.post(
        "/api/v1/classes/",
        json={"nom_classe": "Troisième B"}
    )
    classe_id = create_response.json()["id_classe"]
    
    # Mettre à jour
    response = client.put(
        f"/api/v1/classes/{classe_id}",
        json={"nom_classe": "Troisième C"}
    )
    assert response.status_code == 200
    data = response.json()
    assert data["nom_classe"] == "Troisième C"


def test_delete_classe():
    """Test de suppression d'une classe"""
    # Créer d'abord une classe
    create_response = client.post(
        "/api/v1/classes/",
        json={"nom_classe": "Quatrième D"}
    )
    classe_id = create_response.json()["id_classe"]
    
    # Supprimer
    response = client.delete(f"/api/v1/classes/{classe_id}")
    assert response.status_code == 204
    
    # Vérifier que c'est bien supprimé
    get_response = client.get(f"/api/v1/classes/{classe_id}")
    assert get_response.status_code == 404


def test_get_nonexistent_classe():
    """Test de récupération d'une classe inexistante"""
    response = client.get("/api/v1/classes/99999")
    assert response.status_code == 404
