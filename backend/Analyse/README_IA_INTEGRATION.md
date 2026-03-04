#  Intégration IA - EduFlow

## Résumé des modifications

### Date : 21 Février 2026
### Objectif : Remplacer les données mockées par une analyse IA de PDF

---

## 🔧 **1. Backend IA (Python/Flask)**

### Fichiers modifiés/créés :

#### `main.py` (backend IA)
```python
- Ajout des endpoints /upload, /debug, /health
- Gestion des fichiers PDF uploadés
- Analyse par blocs avec Gemini
- Filtrage des données (nom_matiere, total_hours)
- Données de secours en cas d'échec
- Correction du parsing JSON (double parsing évité)




gemini_client.py (modifié) :
- Configuration avec response_mime_type: "application/json"
- Retourne directement un dict Python (pas de double parsing)
- Gestion des erreurs API


Creation : requirements.txt
pandas==2.0.3
pdfplumber==0.10.3
python-dotenv==1.0.0
google-genai==1.63.0
Flask==2.3.3
Flask-CORS==4.0.0
werkzeug==2.3.7


Scripts de lancement :
lance.bat - Version originale (analyse simple)
lance_serveur.bat - Version serveur API

