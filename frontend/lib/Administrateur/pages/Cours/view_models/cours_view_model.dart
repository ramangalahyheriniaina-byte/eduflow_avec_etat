// lib/Administrateur/pages/Cours/view_models/cours_view_model.dart
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:apk_web_eduflow/core/services/api_service.dart';
import '../services/cours_service.dart';
import '../../../core/status_enum.dart';
import '../models/annee_scolaire_model.dart';
import '../models/classe_model.dart';
import '../models/cours_model.dart';
import '../models/matiere_model.dart';
import '../models/prof_model.dart';
import '../../../services/pdf_services.dart';

class CoursViewModel extends ChangeNotifier {
  // ========== SERVICES ==========
  final CoursService _coursService = CoursService();
  final PdfAnalyseService _pdfService = PdfAnalyseService();

  // ========== DONNÉES ==========
  AnneeScolaire? _anneeScolaire;
  List<Classe> _classes = [];
  List<Prof> _profs = [];
  List<Cours> _cours = [];

  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  // ========== NOUVEAU : SETUP ==========
  bool _setupChecked = false;
  bool _needsSetup = true;

  bool get needsSetup => _needsSetup;
  bool get setupChecked => _setupChecked;

  // ========== GETTERS ==========
  AnneeScolaire? get anneeScolaire => _anneeScolaire;
  List<Classe> get classes => _classes;
  List<Prof> get profs => _profs;

  // GETTER : Retourne les cours avec leurs relations enrichies
  List<Cours> get coursList {
    return _cours.map((cours) {
      return cours.copyWith(
        matiere: getMatiereById(cours.idMatiere),
        prof: getProfById(cours.idProf),
        classe: _getClasseByMatiereId(cours.idMatiere),
      );
    }).toList();
  }

  List<Cours> get cours => coursList;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

  // ========== NOUVELLE MÉTHODE : CHECK SETUP ==========
  Future<bool> checkIfSetupNeeded() async {
    if (_setupChecked) return _needsSetup;

    _isLoading = true;
    notifyListeners();

    try {
      print('🔍 Vérification si configuration nécessaire...');

      final isComplete = await _coursService.isSetupComplete();

      if (isComplete) {
        print('✅ Système déjà configuré, chargement des données...');
        await loadInitialData();
        _needsSetup = false;
      } else {
        print('⚠️ Configuration requise');
        _needsSetup = true;
      }

      _setupChecked = true;
      _isLoading = false;
      notifyListeners();

      return _needsSetup;
    } catch (e) {
      print('❌ Erreur checkIfSetupNeeded: $e');
      _needsSetup = true;
      _setupChecked = true;
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  // ========== CHARGEMENT INITIAL DES DONNÉES ==========
  Future<void> loadInitialData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔄 Chargement des données depuis API...');

      final classesData = await _coursService.getAllClasses();
      final profsData = await _coursService.getAllProfs();
      final coursData = await _coursService.getAllCours();
      final anneesData = await _coursService.getAllAnneeScolaires();

      _classes = classesData;
      _profs = profsData;
      _cours = coursData;

      _anneeScolaire = anneesData.isNotEmpty
          ? anneesData.firstWhere(
              (a) => a.isActive,
              orElse: () => anneesData.first,
            )
          : null;

      // Mettre à jour needsSetup
      _needsSetup = !(_anneeScolaire != null &&
          _classes.isNotEmpty &&
          _profs.isNotEmpty);

      if (!_needsSetup) {
        print('✅ Données existantes trouvées, setup non nécessaire');
      }

      print('📊 Données chargées:');
      print('   - Classes: ${_classes.length}');
      print('   - Profs: ${_profs.length}');
      print('   - Cours: ${_cours.length}');
      print('   - Année scolaire: ${_anneeScolaire?.displayName ?? "Aucune"}');
      print('   - Needs setup: $_needsSetup');

      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des données: $e';
      print('❌ Erreur loadInitialData: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== INITIALISATION ANNÉE SCOLAIRE ==========
  Future<void> initialiserAnneeScolaire({
    required int startYear,
    required int endYear,
    required List<String> nomsClasses,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🚀 Initialisation nouvelle année scolaire...');

      final annee = AnneeScolaire(
        startYear: startYear,
        endYear: endYear,
        isActive: true,
      );

      _anneeScolaire = await _coursService.createAnneeScolaire(annee);
      print('✅ Année scolaire créée: ${_anneeScolaire!.displayName}');

      for (String nomClasse in nomsClasses) {
        final classe = Classe(nomClasse: nomClasse);
        final classeCreee = await _coursService.createClasse(classe);
        _classes.add(classeCreee);
      }

      // Après création, setup est complété (PDF matières attendu après)
      _needsSetup = false;
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();

      print('✅ Initialisation terminée avec succès!');
    } catch (e) {
      _error = 'Erreur lors de l\'initialisation: $e';
      print('❌ Erreur initialiserAnneeScolaire: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== RESET SETUP CHECK ==========
  void resetSetupCheck() {
    _setupChecked = false;
    notifyListeners();
  }

  // ========== GÉNÉRER LES MATIÈRES DEPUIS PDF (AVEC IA) ==========
  Future<void> genererDepuisPdf(Uint8List pdfBytes) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print(' Génération des matières depuis PDF via IA...');

      final List<Map<String, dynamic>> matieresIA = await _pdfService.analyser(pdfBytes);

      print(' Matières extraites par l\'IA: ${matieresIA.length}');

      if (matieresIA.isEmpty) {
        throw Exception('Aucune matière détectée dans le PDF');
      }

      for (var classe in _classes) {
        if (classe.matieres != null && classe.matieres!.isNotEmpty) {
          print(' Suppression des anciennes matières pour ${classe.nomClasse}');
          for (var ancienneMatiere in classe.matieres!) {
            final coursAssocies = _cours.where((c) => c.idMatiere == ancienneMatiere.idMatiere).toList();
            for (var cours in coursAssocies) {
              if (cours.idCours != null) {
                await _coursService.deleteCours(cours.idCours!);
                _cours.remove(cours);
              }
            }
          }
          classe.matieres?.clear();
        }
        classe.matieres ??= [];

        print(' Création des nouvelles matières pour ${classe.nomClasse}');
        for (var matiereData in matieresIA) {
          final nouvelleMatiere = Matiere(
            nomMatiere: matiereData['nom_matiere'],
            heureTotale: matiereData['total_hours'],
            idClasse: classe.idClasse!,
          );

          try {
            final matiereCreee = await _coursService.createMatiere(nouvelleMatiere);
            classe.matieres!.add(matiereCreee);
            print('    ${matiereCreee.nomMatiere} - ${matiereCreee.heureTotale}h');
          } catch (e) {
            print('    Erreur création ${nouvelleMatiere.nomMatiere}: $e');
          }
        }

        print(' ${classe.nomClasse}: ${classe.matieres?.length} matière(s) créées depuis IA');
      }

      await loadInitialData();
      _isLoading = false;
      notifyListeners();
      print(' Génération IA terminée avec succès');
    } catch (e) {
      _error = 'Erreur lors de la génération IA: $e';
      _isLoading = false;
      notifyListeners();
      print('❌ Erreur genererDepuisPdf: $e');
      rethrow;
    }
  }

  // ========== GESTION DES PROFS ==========
  Future<void> ajouterProf(String nomProf) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print(' Ajout professeur: $nomProf');

      final newProf = Prof(nomProf: nomProf, nbAbs: 0);
      final profCree = await _coursService.createProf(newProf);
      _profs.add(profCree);

      print(' Professeur ajouté: ${profCree.nomProf} (ID: ${profCree.idProf})');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de l\'ajout du professeur: $e';
      print('❌ Erreur ajouterProf: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> supprimerProf(int idProf) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print(' Suppression professeur ID: $idProf');

      final coursDuProf = _cours.where((c) => c.idProf == idProf).toList();
      for (var cours in coursDuProf) {
        if (cours.idCours != null) {
          await _coursService.deleteCours(cours.idCours!);
        }
      }

      await _coursService.deleteProf(idProf);
      _profs.removeWhere((p) => p.idProf == idProf);
      _cours.removeWhere((c) => c.idProf == idProf);

      print(' Professeur supprimé avec succès');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la suppression du professeur: $e';
      print('❌ Erreur supprimerProf: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== AFFECTATION PROF À MATIÈRE ==========
  Future<void> affecterProfAMatiere({required int idMatiere, required int idProf}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print(' Affectation prof $idProf à matière $idMatiere');

      final existingCoursIndex = _cours.indexWhere((c) => c.idMatiere == idMatiere);

      if (existingCoursIndex != -1) {
        final cours = _cours[existingCoursIndex];
        final coursUpdate = cours.copyWith(idProf: idProf);

        if (cours.idCours != null) {
          await _coursService.updateCours(cours.idCours!, coursUpdate);
          _cours[existingCoursIndex] = coursUpdate;
          print(' Cours mis à jour: ${cours.idCours}');
        }
      } else {
        final newCours = Cours(
          statut: StatutCours.nonCommence,
          idMatiere: idMatiere,
          idProf: idProf,
          cumul: 0,
        );

        final coursCree = await _coursService.createCours(newCours);
        _cours.add(coursCree);
        print(' Nouveau cours créé: ${coursCree.idCours}');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de l\'affectation: $e';
      print('❌ Erreur affecterProfAMatiere: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== UTILITAIRES ==========
  Classe? getClasseById(int id) {
    try {
      return _classes.firstWhere((c) => c.idClasse == id);
    } catch (e) {
      return null;
    }
  }

  Matiere? getMatiereById(int id) {
    for (var classe in _classes) {
      if (classe.matieres != null) {
        try {
          return classe.matieres!.firstWhere((m) => m.idMatiere == id);
        } catch (e) {
          continue;
        }
      }
    }
    return null;
  }

  Prof? getProfById(int id) {
    try {
      return _profs.firstWhere((p) => p.idProf == id);
    } catch (e) {
      return null;
    }
  }

  Classe? _getClasseByMatiereId(int idMatiere) {
    for (var classe in _classes) {
      if (classe.matieres != null) {
        if (classe.matieres!.any((m) => m.idMatiere == idMatiere)) {
          return classe;
        }
      }
    }
    return null;
  }

  Cours? getCoursForMatiere(int idMatiere) {
    try {
      final cours = _cours.firstWhere((c) => c.idMatiere == idMatiere);
      return cours.copyWith(
        matiere: getMatiereById(cours.idMatiere),
        prof: getProfById(cours.idProf),
        classe: _getClasseByMatiereId(cours.idMatiere),
      );
    } catch (e) {
      return null;
    }
  }

  int getTotalHeuresClasse(Classe classe) {
    if (classe.matieres == null) return 0;
    return classe.matieres!.fold(0, (sum, m) => sum + m.heureTotale);
  }

  // ========== STATISTIQUES ==========
  int get totalClasses => _classes.length;

  int get totalMatieres {
    return _classes.fold(0, (sum, c) => sum + (c.matieres?.length ?? 0));
  }

  int get totalCours => _cours.length;
  int get matieresAvecProf => _cours.length;
  int get matieresSansProf => totalMatieres - matieresAvecProf;

  // ========== MISE À JOUR DU CUMUL ==========
  Future<void> updateCumulHeures(int coursId, int nouvellesHeures) async {
    _isLoading = true;
    notifyListeners();

    try {
      final coursUpdate = await _coursService.updateCumul(coursId, nouvellesHeures);

      final index = _cours.indexWhere((c) => c.idCours == coursId);
      if (index != -1) {
        _cours[index] = coursUpdate;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur mise à jour cumul: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== RECHARGEMENT ==========
  Future<void> refreshData() async {
    await loadInitialData();
  }

  // ========== RESET ==========
  void reset() {
    _anneeScolaire = null;
    _classes.clear();
    _profs.clear();
    _cours.clear();
    _isInitialized = false;
    _error = null;
    notifyListeners();
  }

  // ========== GESTION DES ERREURS ==========
  void clearError() {
    _error = null;
    notifyListeners();
  }
}