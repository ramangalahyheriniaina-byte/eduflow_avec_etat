@echo off
chcp 65001 >nul
title EduFlow IA - Lancement avec nettoyage
color 0A

echo ========================================
echo    EduFlow IA - Lancement
echo    Code original avec correction manuelle
echo    + Nettoyage du cache
echo ========================================
echo.

:: 1. NETTOYAGE DU CACHE PYTHON
echo [1/4] Nettoyage du cache Python...

:: Supprimer les fichiers .pyc et dossiers __pycache__
echo Suppression des fichiers .pyc et __pycache__...
del /s /q *.pyc 2>nul
for /d /r . %%d in (__pycache__) do @if exist "%%d" rmdir /s /q "%%d" 2>nul

:: Supprimer le cache pip
echo Nettoyage du cache pip...
pip cache purge 2>nul

:: Supprimer les fichiers temporaires
echo Nettoyage des fichiers temporaires...
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

:: 4. Installation des dependances (une seule fois)
echo [4/4] Verification des dependances...
pip show google-genai >nul 2>&1
if errorlevel 1 (
    echo Installation des dependances...
    pip install --no-cache-dir pandas pdfplumber python-dotenv
    pip install --no-cache-dir google-genai==1.63.0
) else (
    echo Dependances deja installees
)
echo.

:: 5. Lancement du programme
echo.
echo ========================================
echo Lancement du programme...
echo ========================================
echo.

python main.py

echo.
echo ========================================
echo Programme termine
echo ========================================
echo.

pause