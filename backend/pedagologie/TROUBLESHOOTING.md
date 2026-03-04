# 🔧 Guide de Dépannage - EduFlow Backend

## ❌ Erreur : ModuleNotFoundError: No module named 'pydantic_settings'

### Problème
Vous utilisez Python système au lieu d'un environnement virtuel.

### Solution (RECOMMANDÉE)
```bash
# 1. Créer un environnement virtuel
python3.11 -m venv venv

# 2. Activer l'environnement virtuel
source venv/bin/activate  # Linux/Mac
# OU
venv\Scripts\activate  # Windows

# 3. Vérifier que vous êtes dans le venv
which python  # Doit afficher le chemin vers venv/bin/python

# 4. Installer les dépendances
pip install -r requirements.txt

# 5. Lancer le serveur
python run.py
```

---

## ❌ Erreur : Could not connect to database

### Problème
La base de données PostgreSQL n'est pas disponible ou mal configurée.

### Solution rapide : Utiliser SQLite
```bash
# Modifier le fichier .env
DATABASE_URL=sqlite:///./eduflow.db

# Ou définir la variable d'environnement
export DATABASE_URL="sqlite:///./eduflow.db"

# Puis lancer
python run.py
```

### Solution PostgreSQL
```bash
# 1. Vérifier que PostgreSQL est installé et démarré
sudo service postgresql status  # Linux
brew services list  # Mac

# 2. Créer la base de données
createdb eduflow_db

# 3. Configurer le .env
DATABASE_URL=postgresql://votre_user:votre_password@localhost:5432/eduflow_db
```

---

## ❌ Erreur : ImportError: circular import

### Problème
Import circulaire entre modules.

### Solution
Ce projet est conçu pour éviter les imports circulaires. Si vous en rencontrez un :

1. **Vérifiez l'ordre des imports** dans `__init__.py`
2. **Utilisez des strings** dans les relations SQLAlchemy
3. **Importez des modules** plutôt que des classes
4. Consultez `IMPORTS_GUIDE.md`

---

## ❌ Erreur : Address already in use

### Problème
Le port 8000 est déjà utilisé.

### Solution
```bash
# Option 1 : Utiliser un autre port
python run.py --port 8080

# Option 2 : Tuer le processus sur le port 8000
# Linux/Mac
lsof -ti:8000 | xargs kill -9

# Windows
netstat -ano | findstr :8000
taskkill /PID <PID> /F
```

---

## ❌ Erreur : psycopg2.OperationalError

### Problème
Problème de connexion PostgreSQL.

### Solution
```bash
# Installer psycopg2-binary
pip install psycopg2-binary

# Ou passer à SQLite temporairement
DATABASE_URL=sqlite:///./eduflow.db
```

---

## ✅ Vérification de l'installation

### Test rapide
```bash
# 1. Vérifier Python
python --version  # Devrait être 3.10+

# 2. Vérifier les dépendances
pip list | grep fastapi
pip list | grep sqlalchemy

# 3. Tester l'import
python -c "from app.main import app; print('OK')"

# 4. Lancer les tests
pytest tests/ -v
```

---

## 🚀 Démarrage sans erreur

### Configuration minimale (SQLite - Aucune installation requise)
```bash
# 1. Créer venv
python3 -m venv venv
source venv/bin/activate

# 2. Installer
pip install -r requirements.txt

# 3. Configurer pour SQLite (déjà fait dans .env)
# DATABASE_URL=sqlite:///./eduflow.db

# 4. Lancer
python run.py
```

### Vérifier que ça fonctionne
```bash
# Dans un autre terminal
curl http://localhost:8000/
# Doit retourner : {"message":"Bienvenue sur l'API EduFlow",...}

curl http://localhost:8000/health
# Doit retourner : {"status":"healthy"}
```

---

## 📊 Erreurs courantes avec SQLAlchemy

### Erreur : "Table already exists"
```bash
# Supprimer la base de données
rm eduflow.db

# Ou utiliser Alembic pour les migrations
alembic upgrade head
```

### Erreur : "No such table"
```python
# Vérifier que les tables sont créées
# Dans main.py, cette ligne doit être présente :
Base.metadata.create_all(bind=engine)
```

---

## 🔍 Mode Debug

### Activer les logs détaillés
```python
# Dans database.py
engine = create_engine(
    settings.DATABASE_URL,
    echo=True  # Active les logs SQL
)
```

### Tester une route spécifique
```bash
# Avec curl
curl -v http://localhost:8000/api/v1/classes/

# Avec httpie (plus lisible)
pip install httpie
http http://localhost:8000/api/v1/classes/
```

---

## 📞 Si rien ne fonctionne

### Réinstallation complète
```bash
# 1. Supprimer venv
rm -rf venv

# 2. Supprimer cache Python
find . -type d -name __pycache__ -exec rm -rf {} +
find . -type f -name "*.pyc" -delete

# 3. Recréer venv
python3 -m venv venv
source venv/bin/activate

# 4. Réinstaller
pip install --upgrade pip
pip install -r requirements.txt

# 5. Relancer
python run.py
```

---

## 🎯 Checklist de démarrage

- [ ] Python 3.10+ installé
- [ ] Environnement virtuel créé et activé
- [ ] Dépendances installées (`pip install -r requirements.txt`)
- [ ] Fichier `.env` configuré
- [ ] Base de données accessible (SQLite ou PostgreSQL)
- [ ] Port 8000 disponible
- [ ] Tests passent (`pytest`)

---

## 💡 Astuces

### Utiliser SQLite pour le développement
C'est plus simple et ne nécessite aucune installation :
```bash
DATABASE_URL=sqlite:///./eduflow.db
```

### Passer à PostgreSQL en production
```bash
# Installer PostgreSQL
sudo apt install postgresql  # Ubuntu
brew install postgresql  # Mac

# Créer DB
createdb eduflow_db

# Configurer
DATABASE_URL=postgresql://user:password@localhost/eduflow_db
```

### Activer le rechargement automatique
```bash
# Déjà activé avec
python run.py

# Ou manuellement
uvicorn app.main:app --reload
```

---

Besoin d'aide supplémentaire ? Consultez :
- `README.md` - Documentation complète
- `QUICKSTART.md` - Guide de démarrage
- `IMPORTS_GUIDE.md` - Guide sur les imports
