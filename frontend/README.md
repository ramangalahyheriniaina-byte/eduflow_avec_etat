# apk_web_eduflow

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.



#Modification pour l'integration de l'IA analyse pdf

lib/Administrateur/services/ia_service.dart : 
- Communication avec le backend IA
- Méthodes :
    - checkHealth() : Vérifie la connexion
    - analyserPdf() : Envoie PDF et reçoit données filtrées
    - analyserPdfDebug() : Version avec infos debug
    - testConnexion() : Utilitaire de test

lib/Administrateur/services/pdf_services.dart : 
- Utilise IAService pour l'analyse
- Méthode analyser() retourne données filtrées
- Vérification santé serveur avant envoi

lib/Administrateur/pages/Cours/view_models/cours_view_model.dart :
- SUPPRESSION des données mockées (referentielMatieres)
-  Mise à jour de genererDepuisPdf() pour utiliser l'IA
-  Gestion des erreurs améliorée
- Rafraîchissement auto après génération

lib/Administrateur/pages/Cours/view/upload_pdf.dar :
- Interface utilisateur améliorée
- Feedback visuel pendant l'analyse
- Messages d'erreur explicites
- Affichage statut serveur

lib/Administrateur/pages/Cours/view/cours_list_view.dart
-  SUPPRESSION des icônes de matières
- Interface plus épurée


Flux de données:
1.  UploadProgrammeView
   └── Sélection PDF → envoi à CoursViewModel

2.  CoursViewModel
   └── Appelle PdfAnalyseService.analyser()

3.  PdfAnalyseService
   └── Utilise IAService pour communiquer avec backend

4.  Backend IA (Python/Flask)
   ├── Reçoit PDF → /upload
   ├── Extrait texte avec pdf_extractor.py
   ├── Analyse par blocs avec Gemini
   ├── Filtre données (nom_matiere, total_hours)
   └── Retourne JSON filtré

5.  Flutter
   ├── Reçoit données filtrées
   ├── Supprime anciennes matières
   ├── Crée nouvelles matières dans BDD
   └── Affiche dans CoursListView


Configuration réseau
Backend IA
URL: http://192.168.88.238:5000 (IP locale)

Endpoints:

GET /health - Vérification santé

POST /upload - Analyse PDF

POST /debug - Version debug
