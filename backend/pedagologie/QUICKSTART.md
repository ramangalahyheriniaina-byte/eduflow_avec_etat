# 🚀 Guide de Démarrage Rapide - EduFlow Backend

## Installation en 5 minutes

### 1. Cloner et configurer l'environnement

```bash
# Créer et activer l'environnement virtuel
python -m venv venv
source venv/bin/activate  # Linux/Mac
# ou
venv\Scripts\activate  # Windows

# Installer les dépendances
pip install -r requirements.txt
```

### 2. Configurer la base de données

**Option A : PostgreSQL (Recommandé pour la production)**
```bash
# Créer la base de données
createdb eduflow_db

# Créer le fichier .env
cp .env.example .env

# Modifier .env avec vos paramètres :
# DATABASE_URL=postgresql://votre_user:votre_password@localhost:5432/eduflow_db
```

**Option B : SQLite (Pour les tests rapides)**
```bash
# Dans .env, utiliser :
DATABASE_URL=sqlite:///./eduflow.db
```

### 3. Créer les tables

Les tables seront créées automatiquement au premier lancement grâce à cette ligne dans `main.py` :
```python
Base.metadata.create_all(bind=engine)
```

### 4. Démarrer le serveur

```bash
# Méthode 1 : Script de démarrage
python run.py

# Méthode 2 : Uvicorn directement
uvicorn app.main:app --reload

# Méthode 3 : Via le module main
python -m app.main
```

### 5. Tester l'API

Ouvrez votre navigateur :
- **Swagger UI** : http://localhost:8000/docs
- **ReDoc** : http://localhost:8000/redoc
- **Health Check** : http://localhost:8000/health

## 🎯 Premiers tests avec l'API

### Via Swagger UI (Interface graphique)

1. Allez sur http://localhost:8000/docs
2. Cliquez sur une route (ex: POST /api/v1/classes/)
3. Cliquez sur "Try it out"
4. Entrez les données JSON
5. Cliquez sur "Execute"

### Via curl (Ligne de commande)

```bash
# Créer une classe
curl -X POST "http://localhost:8000/api/v1/classes/" \
  -H "Content-Type: application/json" \
  -d '{"nom_classe": "Terminale S"}'

# Lister toutes les classes
curl "http://localhost:8000/api/v1/classes/"

# Créer un professeur
curl -X POST "http://localhost:8000/api/v1/professeurs/" \
  -H "Content-Type: application/json" \
  -d '{"nom_prof": "M. Dupont", "nb_abs": 0}'

# Créer une année scolaire
curl -X POST "http://localhost:8000/api/v1/annees-scolaires/" \
  -H "Content-Type: application/json" \
  -d '{"start_year": 2024, "end_year": 2025, "is_active": true}'
```

### Via Python (requests)

```python
import requests

BASE_URL = "http://localhost:8000/api/v1"

# Créer une classe
response = requests.post(
    f"{BASE_URL}/classes/",
    json={"nom_classe": "Première ES"}
)
print(response.json())

# Lister les classes
response = requests.get(f"{BASE_URL}/classes/")
print(response.json())
```

## 📊 Scénario complet

Voici un exemple de workflow complet :

```bash
# 1. Créer une année scolaire
curl -X POST "http://localhost:8000/api/v1/annees-scolaires/" \
  -H "Content-Type: application/json" \
  -d '{"start_year": 2024, "end_year": 2025, "is_active": true}'

# 2. Créer une classe
curl -X POST "http://localhost:8000/api/v1/classes/" \
  -H "Content-Type: application/json" \
  -d '{"nom_classe": "Terminale S"}'

# Supposons que la classe créée a l'ID 1

# 3. Créer une matière pour cette classe
curl -X POST "http://localhost:8000/api/v1/matieres/" \
  -H "Content-Type: application/json" \
  -d '{"nom_matiere": "Mathématiques", "heure_totale": 120, "id_classe": 1}'

# 4. Créer un professeur
curl -X POST "http://localhost:8000/api/v1/professeurs/" \
  -H "Content-Type: application/json" \
  -d '{"nom_prof": "M. Durand", "nb_abs": 0}'

# Supposons matière ID=1 et prof ID=1

# 5. Créer un cours (lier prof et matière)
curl -X POST "http://localhost:8000/api/v1/cours/" \
  -H "Content-Type: application/json" \
  -d '{"id_matiere": 1, "id_prof": 1, "cumul": 0, "statut": "non_commence"}'

# Supposons cours ID=1

# 6. Créer une séance pour ce cours
curl -X POST "http://localhost:8000/api/v1/seances/" \
  -H "Content-Type: application/json" \
  -d '{
    "id_cours": 1,
    "date_seance": "2025-02-01",
    "heure_debut": "08:00:00",
    "heure_fin": "10:00:00",
    "statut": "prevu"
  }'
```

## 🧪 Exécuter les tests

```bash
# Tous les tests
pytest

# Tests avec couverture
pytest --cov=app tests/

# Tests spécifiques
pytest tests/test_annee_scolaire.py -v

# Tests en mode verbeux
pytest -v
```

## 🔧 Configuration avancée

### Utiliser Alembic pour les migrations

```bash
# Initialiser Alembic
python init_alembic.py

# Créer une migration
alembic revision --autogenerate -m "Initial migration"

# Appliquer les migrations
alembic upgrade head

# Revenir en arrière
alembic downgrade -1
```

### Variables d'environnement

Créez un fichier `.env` avec :

```env
# Base de données
DATABASE_URL=postgresql://user:password@localhost:5432/eduflow_db

# API
API_V1_PREFIX=/api/v1
PROJECT_NAME=EduFlow API
VERSION=1.0.0

# CORS (séparer par des virgules)
BACKEND_CORS_ORIGINS=http://localhost:3000,http://localhost:8080

# Pour le développement
DEBUG=True
```

## 🐳 Docker (Optionnel)

Si vous préférez utiliser Docker :

```dockerfile
# Dockerfile (à créer)
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

```yaml
# docker-compose.yml (à créer)
version: '3.8'

services:
  db:
    image: postgres:15
    environment:
      POSTGRES_USER: eduflow
      POSTGRES_PASSWORD: eduflow123
      POSTGRES_DB: eduflow_db
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  api:
    build: .
    ports:
      - "8000:8000"
    environment:
      DATABASE_URL: postgresql://eduflow:eduflow123@db:5432/eduflow_db
    depends_on:
      - db

volumes:
  postgres_data:
```

Puis lancer :
```bash
docker-compose up
```

## 📚 Ressources utiles

- **FastAPI Documentation** : https://fastapi.tiangolo.com/
- **SQLAlchemy Documentation** : https://docs.sqlalchemy.org/
- **Pydantic Documentation** : https://docs.pydantic.dev/
- **PostgreSQL Documentation** : https://www.postgresql.org/docs/

## 🆘 Problèmes courants

### Erreur : "No module named 'app'"
```bash
# Solution : Assurez-vous d'être à la racine du projet
cd eduflow_backend
python run.py
```

### Erreur : "Could not connect to database"
```bash
# Vérifiez que PostgreSQL est lancé
sudo service postgresql start  # Linux
brew services start postgresql  # Mac

# Vérifiez la connexion
psql -U postgres -d eduflow_db
```

### Erreur : Import circulaire
Consultez le fichier `IMPORTS_GUIDE.md` pour comprendre comment éviter ce problème.

## 🎉 C'est tout !

Vous êtes prêt à développer avec EduFlow Backend !

Pour toute question, consultez :
- `README.md` : Documentation complète
- `IMPORTS_GUIDE.md` : Guide sur les imports circulaires
- `/docs` : Documentation interactive de l'API
