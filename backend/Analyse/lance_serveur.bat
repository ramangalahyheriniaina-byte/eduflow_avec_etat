@echo off
chcp 65001 >nul
title EduFlow IA - Serveur API
color 0A

echo ========================================
echo    EduFlow IA - Serveur API
echo    Lancement du serveur Flask
echo ========================================
echo.

:: 1. NETTOYAGE DU CACHE PYTHON
echo [1/4] Nettoyage du cache Python...

echo Suppression des fichiers .pyc et __pycache__...
del /s /q *.pyc 2>nul
for /d /r . %%d in (__pycache__) do @if exist "%%d" rmdir /s /q "%%d" 2>nul

echo Nettoyage du cache pip...
pip cache purge 2>nul

echo Suppression des fichiers temporaires...
del /s /q *.log 2>nul
del /s /q *.tmp 2>nul

echo [OK] Cache nettoye
echo.

:: 2. Verification Python 3.11
echo [2/4] Verification Python 3.11...
py -3.11 --version >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Python 3.11 n'est pas installe!
    echo.
    echo Telecharge Python 3.11: https://www.python.org/downloads/release/python-3119/
    pause
    exit /b 1
)
echo [OK] Python 3.11 trouve
echo.

:: 3. Creation/Activation environnement
echo [3/4] Preparation environnement...
if not exist venv (
    echo Creation de l'environnement virtuel...
    py -3.11 -m venv venv
) else (
    echo Environnement existant trouve
)
call venv\Scripts\activate
echo [OK] Environnement pret
echo.

:: 4. Installation des dependances
echo [4/4] Verification des dependances...
pip show flask >nul 2>&1
if errorlevel 1 (
    echo Installation des dependances pour le serveur...
    pip install --no-cache-dir pandas pdfplumber python-dotenv
    pip install --no-cache-dir google-genai==1.63.0
    pip install --no-cache-dir flask flask-cors werkzeug requests
) else (
    echo Dependances deja installees
)
echo.

:: 5. Creer le dossier uploads s'il n'existe pas
if not exist uploads mkdir uploads
echo [OK] Dossier uploads pret
echo.

:: 6. Obtenir l'IP locale
echo [INFO] Recherche de l'IP locale...
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4"') do set ip=%%a
set ip=%ip: =%
echo [INFO] IP locale: %ip%
echo.

:: 7. Lancement du serveur
echo.
echo ========================================
echo Lancement du serveur API...
echo ========================================
echo.
echo 📡 Le serveur sera accessible sur:
echo    - Local: http://localhost:5000
echo    - Reseau: http://%ip%:5000
echo.
echo 🔧 Pour Flutter, utilisez: http://%ip%:5000
echo.
echo ========================================
echo.

python main.py

echo.
echo ========================================
echo Serveur arrete
echo ========================================
echo.

pause