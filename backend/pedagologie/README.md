# EduFlow Backend

API backend pour la gestion scolaire EduFlow, construite avec FastAPI et SQLAlchemy.

## 📋 Table des matières

- [Fonctionnalités](#fonctionnalités)
- [Architecture](#architecture)
- [Installation](#installation)
- [Configuration](#configuration)
- [Utilisation](#utilisation)
- [API Endpoints](#api-endpoints)
- [Tests](#tests)
- [Structure du projet](#structure-du-projet)

## ✨ Fonctionnalités

- Gestion des années scolaires
- Gestion des classes
- Gestion des professeurs
- Gestion des matières
- Gestion des cours (liaison prof-matière)
- Gestion des séances
- API RESTful avec FastAPI
- Validation des données avec Pydantic
- Base de données PostgreSQL avec SQLAlchemy
- Documentation interactive (Swagger/OpenAPI)

## 🏗️ Architecture

Le projet suit une architecture en couches :

- **Models** : Modèles SQLAlchemy pour la base de données
- **Schemas** : Schémas Pydantic pour la validation des données
- **CRUD** : Opérations de base de données
- **Routers** : Endpoints de l'API
- **Database** : Configuration de la connexion à la base de données
- **Config** : Configuration de l'application

## 📦 Installation

### Prérequis

- Python 3.10+
- PostgreSQL 13+

### Étapes d'installation

1. Cloner le repository

```bash
git clone <repository-url>
cd eduflow_backend
```

2. Créer un environnement virtuel

```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
# ou
venv\Scripts\activate  # Windows
```

3. Installer les dépendances

```bash
pip install -r requirements.txt
```

4. Créer la base de données PostgreSQL

```bash
createdb eduflow_db
```

5. Configurer les variables d'environnement (voir section Configuration)

## ⚙️ Configuration

Créer un fichier `.env` à la racine du projet :

```env
DATABASE_URL=postgresql://user:password@localhost:5432/eduflow_db
API_V1_PREFIX=/api/v1
PROJECT_NAME=EduFlow API
VERSION=1.0.0
BACKEND_CORS_ORIGINS=["http://localhost:3000", "http://localhost:8080"]
```

## 🚀 Utilisation

### Démarrage du serveur

```bash
# Mode développement avec rechargement automatique
uvicorn app.main:app --reload

# Ou directement avec Python
python -p app/main.py
```

Le serveur démarre sur `http://localhost:8000`

### Documentation interactive

- Swagger UI : `http://localhost:8000/docs`
- ReDoc : `http://localhost:8000/redoc`

## 📚 API Endpoints

### Années Scolaires

- `GET /api/v1/annees-scolaires/` - Liste toutes les années scolaires
- `GET /api/v1/annees-scolaires/{id}` - Récupère une année scolaire
- `GET /api/v1/annees-scolaires/active` - Récupère l'année scolaire active
- `POST /api/v1/annees-scolaires/` - Crée une année scolaire
- `PUT /api/v1/annees-scolaires/{id}` - Met à jour une année scolaire
- `DELETE /api/v1/annees-scolaires/{id}` - Supprime une année scolaire

### Classes

- `GET /api/v1/classes/` - Liste toutes les classes
- `GET /api/v1/classes/{id}` - Récupère une classe
- `POST /api/v1/classes/` - Crée une classe
- `PUT /api/v1/classes/{id}` - Met à jour une classe
- `DELETE /api/v1/classes/{id}` - Supprime une classe

### Professeurs

- `GET /api/v1/professeurs/` - Liste tous les professeurs
- `GET /api/v1/professeurs/{id}` - Récupère un professeur
- `POST /api/v1/professeurs/` - Crée un professeur
- `PUT /api/v1/professeurs/{id}` - Met à jour un professeur
- `DELETE /api/v1/professeurs/{id}` - Supprime un professeur
- `POST /api/v1/professeurs/{id}/absences` - Incrémente les absences

### Matières

- `GET /api/v1/matieres/` - Liste toutes les matières
- `GET /api/v1/matieres/{id}` - Récupère une matière
- `GET /api/v1/matieres/classe/{classe_id}` - Liste les matières d'une classe
- `POST /api/v1/matieres/` - Crée une matière
- `PUT /api/v1/matieres/{id}` - Met à jour une matière
- `DELETE /api/v1/matieres/{id}` - Supprime une matière

### Cours

- `GET /api/v1/cours/` - Liste tous les cours
- `GET /api/v1/cours/{id}` - Récupère un cours
- `GET /api/v1/cours/professeur/{prof_id}` - Liste les cours d'un prof
- `GET /api/v1/cours/matiere/{matiere_id}` - Liste les cours d'une matière
- `GET /api/v1/cours/statut/{statut}` - Liste les cours par statut
- `POST /api/v1/cours/` - Crée un cours
- `PUT /api/v1/cours/{id}` - Met à jour un cours
- `DELETE /api/v1/cours/{id}` - Supprime un cours
- `PATCH /api/v1/cours/{id}/cumul` - Met à jour le cumul d'heures

### Séances

- `GET /api/v1/seances/` - Liste toutes les séances
- `GET /api/v1/seances/{id}` - Récupère une séance
- `GET /api/v1/seances/cours/{cours_id}` - Liste les séances d'un cours
- `GET /api/v1/seances/date/{date}` - Liste les séances d'une date
- `GET /api/v1/seances/statut/{statut}` - Liste les séances par statut
- `POST /api/v1/seances/` - Crée une séance
- `PUT /api/v1/seances/{id}` - Met à jour une séance
- `DELETE /api/v1/seances/{id}` - Supprime une séance
- `PATCH /api/v1/seances/{id}/annuler` - Annule une séance

## 🧪 Tests

Exécuter les tests :

```bash
pytest

# Avec couverture
pytest --cov=app tests/

# Tests spécifiques
pytest tests/test_annee_scolaire.py
```

## 📁 Structure du projet

```
eduflow_backend/
│
├── app/
│   ├── __init__.py
│   ├── main.py                # Point d'entrée FastAPI
│   ├── config.py              # Configuration de l'application
│   ├── database.py            # Configuration SQLAlchemy
│   ├── dependencies.py        # Dépendances partagées
│   │
│   ├── models/                # Modèles SQLAlchemy
│   │   ├── __init__.py
│   │   ├── annee_scolaire.py
│   │   ├── classe.py
│   │   ├── prof.py
│   │   ├── matiere.py
│   │   ├── cours.py
│   │   └── seance.py
│   │
│   ├── schemas/               # Schémas Pydantic
│   │   ├── __init__.py
│   │   ├── annee_scolaire.py
│   │   ├── classe.py
│   │   ├── prof.py
│   │   ├── matiere.py
│   │   ├── cours.py
│   │   └── seance.py
│   │
│   ├── crud/                  # Opérations CRUD
│   │   ├── __init__.py
│   │   ├── annee_scolaire.py
│   │   ├── classe.py
│   │   ├── prof.py
│   │   ├── matiere.py
│   │   ├── cours.py
│   │   └── seance.py
│   │
│   └── routers/               # Endpoints API
│       ├── __init__.py
│       ├── annee_scolaire.py
│       ├── classe.py
│       ├── prof.py
│       ├── matiere.py
│       ├── cours.py
│       └── seance.py
│
├── tests/                     # Tests
│   ├── __init__.py
│   └── test_annee_scolaire.py
│
├── requirements.txt
└── README.md
```

## 🔑 Points clés pour éviter les imports circulaires

1. **Séparation stricte des couches** : Models → Schemas → CRUD → Routers
2. **Imports dans les fonctions** : Quand nécessaire, importer dans les fonctions plutôt qu'au niveau module
3. **Utilisation de `from_attributes`** : Dans les schémas Pydantic pour la compatibilité avec SQLAlchemy
4. **Relations définies avec des strings** : Dans SQLAlchemy (ex: `relationship("Classe")`)
5. **Fichiers `__init__.py` bien structurés** : Exports explicites avec `__all__`
