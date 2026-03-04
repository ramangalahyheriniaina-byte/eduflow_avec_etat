"""
Script pour initialiser Alembic pour les migrations de base de données

Pour utiliser ce script :
1. Installer alembic : pip install alembic
2. Exécuter : python init_alembic.py
3. Créer une migration : alembic revision --autogenerate -m "description"
4. Appliquer les migrations : alembic upgrade head
"""

import os
import subprocess

def init_alembic():
    """Initialise Alembic dans le projet"""
    print("Initialisation d'Alembic...")
    
    # Initialiser Alembic
    subprocess.run(["alembic", "init", "alembic"])
    
    print("✓ Alembic initialisé")
    print("\nProchaines étapes :")
    print("1. Modifier alembic.ini pour configurer la connexion à la base de données")
    print("2. Modifier alembic/env.py pour importer vos modèles")
    print("3. Créer votre première migration : alembic revision --autogenerate -m 'Initial migration'")
    print("4. Appliquer la migration : alembic upgrade head")

if __name__ == "__main__":
    init_alembic()
