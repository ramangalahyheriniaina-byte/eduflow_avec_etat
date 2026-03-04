#!/bin/bash

# Script de démarrage automatique pour EduFlow Backend
# Usage: ./start.sh

echo "╔════════════════════════════════════════╗"
echo "║    EduFlow Backend - Auto Start        ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. Vérifier si venv existe
if [ ! -d "venv" ]; then
    echo -e "${YELLOW}⚠️  Environnement virtuel non trouvé. Création...${NC}"
    python3 -m venv venv
    echo -e "${GREEN}✓ Environnement virtuel créé${NC}"
fi

# 2. Activer venv
echo "🔧 Activation de l'environnement virtuel..."
source venv/bin/activate

# 3. Installer/mettre à jour les dépendances
echo "📦 Vérification des dépendances..."
pip install -q -r requirements.txt
echo -e "${GREEN}✓ Dépendances installées${NC}"

# 4. Créer le fichier .env s'il n'existe pas
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}⚠️  Fichier .env non trouvé. Création...${NC}"
    cat > .env << 'EOF'
# Configuration EduFlow Backend
DATABASE_URL=sqlite:///./eduflow.db
API_V1_PREFIX=/api/v1
PROJECT_NAME=EduFlow API
VERSION=1.0.0
BACKEND_CORS_ORIGINS=http://localhost:3000,http://localhost:8080
EOF
    echo -e "${GREEN}✓ Fichier .env créé${NC}"
fi

# 5. Exporter les variables d'environnement
export DATABASE_URL="sqlite:///./eduflow.db"

echo ""
echo -e "${GREEN}✓ Configuration terminée !${NC}"
echo ""

# 6. Démarrer le serveur
python run.py
