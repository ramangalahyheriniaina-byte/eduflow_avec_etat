# 🚀 DÉMARRAGE RAPIDE - 1 COMMANDE

## Pour Linux/Mac

```bash
chmod +x start.sh && ./start.sh
```

C'est tout ! Le script va :
1. ✅ Créer l'environnement virtuel si nécessaire
2. ✅ Installer toutes les dépendances
3. ✅ Créer le fichier .env avec SQLite
4. ✅ Démarrer le serveur sur http://localhost:8000

---

## Pour Windows

```cmd
start.bat
```

C'est tout ! Le script fait tout automatiquement.

---

## OU Manuellement (3 commandes)

### Linux/Mac
```bash
python3 -m venv venv
source venv/bin/activate
export DATABASE_URL="sqlite:///./eduflow.db" && python run.py
```

### Windows
```cmd
python -m venv venv
venv\Scripts\activate
set DATABASE_URL=sqlite:///./eduflow.db && python run.py
```

---

## Vérifier que ça marche

Une fois le serveur démarré, ouvrez votre navigateur :

**Interface de test :**
- http://localhost:8000/docs (Swagger UI - interface graphique)
- http://localhost:8000/redoc (Documentation alternative)

**Endpoints de test :**
- http://localhost:8000/ (Message de bienvenue)
- http://localhost:8000/health (Vérification de santé)

---

## Premier test dans Swagger

1. Allez sur http://localhost:8000/docs
2. Cliquez sur `POST /api/v1/classes/`
3. Cliquez sur "Try it out"
4. Entrez dans la zone de texte :
```json
{
  "nom_classe": "Terminale S"
}
```
5. Cliquez sur "Execute"
6. Vous devriez voir une réponse 201 avec votre classe créée !

---

## En cas de problème

### Erreur : "Permission denied"
```bash
chmod +x start.sh
./start.sh
```

### Erreur : "command not found: python3"
Essayez avec `python` au lieu de `python3`:
```bash
python -m venv venv
source venv/bin/activate
export DATABASE_URL="sqlite:///./eduflow.db" && python run.py
```

### Le serveur ne démarre pas
```bash
# Vérifier que vous êtes dans le bon dossier
pwd  # Devrait afficher .../eduflow_backend

# Vérifier que le venv est activé
which python  # Devrait afficher .../venv/bin/python

# Réinstaller les dépendances
pip install --force-reinstall -r requirements.txt
```

### Autre problème
Consultez `TROUBLESHOOTING.md` pour plus de solutions.

---

## C'est tout !

Votre API est maintenant accessible sur http://localhost:8000

Documentation interactive : http://localhost:8000/docs

🎉 Bon développement !
