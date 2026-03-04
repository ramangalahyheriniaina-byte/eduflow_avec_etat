#!/bin/bash

# ========================================
#    EduFlow IA - Serveur API
#    Lancement du serveur Flask
# ========================================

echo "========================================"
echo "   EduFlow IA - Serveur API"
echo "   Lancement du serveur Flask"
echo "========================================"
echo

# 1. NETTOYAGE DU CACHE PYTHON
echo "[1/4] Nettoyage du cache Python..."

echo "Suppression des fichiers .pyc et __pycache__..."
find . -type f -name "*.pyc" -delete 2>/dev/null
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null

echo "Nettoyage du cache pip..."
pip cache purge 2>/dev/null

echo "Suppression des fichiers temporaires..."
find . -type f -name "*.log" -delete 2>/dev/null
find . -type f -name "*.tmp" -delete 2>/dev/null

echo "[OK] Cache nettoyé"
echo

# 2. Vérification Python 3.11
echo "[2/4] Vérification Python 3.11..."

if ! command -v python3.11 &> /dev/null
then
    echo "[ERREUR] Python 3.11 n'est pas installé !"
    echo
    echo "Installe-le avec :"
    echo "sudo apt install python3.11 python3.11-venv"
    exit 1
fi

echo "[OK] Python 3.11 trouvé"
echo

# 3. Création / Activation environnement
echo "[3/4] Préparation environnement..."

if [ ! -d "venv" ]; then
    echo "Création de l'environnement virtuel..."
    python3.11 -m venv venv
else
    echo "Environnement existant trouvé"
fi

source venv/bin/activate
echo "[OK] Environnement prêt"
echo

# 4. Installation des dépendances
echo "[4/4] Vérification des dépendances..."

if ! pip show flask &> /dev/null
then
    echo "Installation des dépendances pour le serveur..."
    pip install --no-cache-dir pandas pdfplumber python-dotenv
    pip install --no-cache-dir google-genai==1.63.0
    pip install --no-cache-dir flask flask-cors werkzeug requests
else
    echo "Dépendances déjà installées"
fi

echo

# 5. Créer le dossier uploads s'il n'existe pas
mkdir -p uploads
echo "[OK] Dossier uploads prêt"
echo

# 6. Obtenir l'IP locale
echo "[INFO] Recherche de l'IP locale..."
ip=$(hostname -I | awk '{print $1}')
echo "[INFO] IP locale: $ip"
echo

# 7. Lancement du serveur
echo
echo "========================================"
echo "Lancement du serveur API..."
echo "========================================"
echo
echo "📡 Le serveur sera accessible sur:"
echo "   - Local: http://localhost:5000"
echo "   - Réseau: http://$ip:5000"
echo
echo "🔧 Pour Flutter, utilisez: http://$ip:5000"
echo
echo "========================================"
echo

python main.py

echo
echo "========================================"
echo "Serveur arrêté"
echo "========================================"
echo
