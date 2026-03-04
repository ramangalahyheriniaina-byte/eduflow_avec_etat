// frontend/lib/Administrateur/pages/edt/view_model/edt_view_model.dart
import 'package:flutter/material.dart';
import 'package:apk_web_eduflow/core/services/api_service.dart';
import '../services/edt_service.dart';
import '../../../core/status_enum.dart';
import '../../Cours/services/cours_service.dart';
import '../../Cours/models/cours_model.dart';
import '../../Cours/models/classe_model.dart';
import '../Model/edtModel.dart';

class EdtViewModel extends ChangeNotifier {
  // ========== SERVICES ==========
  final EdtService _edtService = EdtService();  // SERVICE pour endpoints EDT
  final CoursService _coursService = CoursService();  // SERVICE pour endpoints Cours/Classes

  // ========== DONNÉES ==========
  Classe? _selectedClasse;
  DateTime _lundiSemaineSelectionnee = DateTime.now();
  Cours? _coursSelectionne;
  List<Edt> _seances = [];
  List<Classe> _classes = [];
  List<Cours> _cours = [];

  bool _isLoading = false;
  String? _error;

  // ========== GETTERS ==========
  Classe? get selectedClasse => _selectedClasse;
  DateTime get lundiSemaineSelectionnee => _lundiSemaineSelectionnee;
  Cours? get coursSelectionne => _coursSelectionne;
  List<Edt> get seances => _seances;
  List<Classe> get classes => _classes;
  List<Cours> get cours => _cours;
  bool get isLoading => _isLoading;
  String? get error => _error;

  EdtViewModel() {
    _initDate();
  }

  void _initDate() {
    final now = DateTime.now();
    // Calculer le lundi de la semaine actuelle
    _lundiSemaineSelectionnee = now.subtract(Duration(days: now.weekday - 1));
  }

  // ========== CHARGEMENT DES DONNÉES ==========
  Future<void> loadInitialData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔄 Chargement des données EDT...');

      // 1. Charger les classes
      final classesResponse = await _coursService.getAllClasses();
      _classes = classesResponse is List ? classesResponse : [];

      // 2. Charger les cours
      final coursResponse = await _coursService.getAllCours();
      _cours = coursResponse is List ? coursResponse : [];

      // 3. ❌ CORRECTION : getAllSeances() retourne déjà List<Edt>
      // Plus besoin de conversion !
      _seances = await _edtService.getAllSeances();

      print('✅ Données EDT chargées:');
      print('   - Classes: ${_classes.length}');
      print('   - Cours: ${_cours.length}');
      print('   - Séances: ${_seances.length}');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des données EDT: $e';
      print('❌ Erreur loadInitialData EDT: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== GESTION CLASSE ==========
  void changerClasse(Classe classe) {
    _selectedClasse = classe;
    _coursSelectionne = null; // Reset le cours sélectionné
    notifyListeners();
  }

  // ========== GESTION SEMAINE ==========
  void changerSemaine(DateTime lundi) {
    _lundiSemaineSelectionnee = lundi;
    notifyListeners();
  }

  // Semaine suivante
  void semaineProchaine() {
    _lundiSemaineSelectionnee = _lundiSemaineSelectionnee.add(const Duration(days: 7));
    notifyListeners();
  }

  // Semaine précédente
  void semainePrecedente() {
    _lundiSemaineSelectionnee = _lundiSemaineSelectionnee.subtract(const Duration(days: 7));
    notifyListeners();
  }

  // Retour à la semaine actuelle
  void retourSemaineActuelle() {
    final now = DateTime.now();
    _lundiSemaineSelectionnee = now.subtract(Duration(days: now.weekday - 1));
    notifyListeners();
  }

  // ========== GESTION COURS ==========
  void selectionnerCours(Cours? cours) {
    _coursSelectionne = cours;
    notifyListeners();
  }

  // ========== GESTION SÉANCES ==========

  /// Ajouter une séance
  Future<void> ajouterSeance({
    required Cours cours,
    required DateTime dateSeance,
    required String heureDebut,
    required String heureFin,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔄 Ajout séance pour cours: ${cours.idCours}');

      // Vérifier si cours a un ID
      if (cours.idCours == null) {
        throw Exception('Le cours doit avoir un ID');
      }

      // Vérifier les conflits d'horaire
      if (verifierConflit(dateSeance: dateSeance, heureDebut: heureDebut, heureFin: heureFin)) {
        throw Exception('Conflit d\'horaire détecté');
      }

      // Créer la séance
      final nouvelleSeance = Edt(
        idCours: cours.idCours!,
        dateSeance: dateSeance,
        heureDebut: heureDebut,
        heureFin: heureFin,
        statut: StatutSeance.prevu,
        cours: cours,
      );

      // =================== ENDPOINT BACKEND ===================
      // 4. ENDPOINT: POST /seances (création d'une séance)
      final seanceCree = await _edtService.createSeance(nouvelleSeance);
      // ========================================================
      
      _seances.add(seanceCree);

      _coursSelectionne = null; // Reset après ajout
      _isLoading = false;

      print('✅ Séance ajoutée: ${seanceCree.idSeance}');
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de l\'ajout de la séance: $e';
      print('❌ Erreur ajouterSeance: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Supprimer une séance
  Future<void> supprimerSeance(int idSeance) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // =================== ENDPOINT BACKEND ===================
      // 5. ENDPOINT: DELETE /seances/{idSeance} (suppression)
      await _edtService.deleteSeance(idSeance);
      // ========================================================
      
      _seances.removeWhere((s) => s.idSeance == idSeance);

      print('✅ Séance supprimée: $idSeance');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la suppression de la séance: $e';
      print('❌ Erreur supprimerSeance: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Modifier le statut d'une séance
  Future<void> modifierStatut(int idSeance, StatutSeance nouveauStatut) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Si c'est pour annuler, utiliser annulerSeance
      if (nouveauStatut == StatutSeance.annule) {
        // =================== ENDPOINT BACKEND ===================
        // 6. ENDPOINT: POST /seances/{id}/annuler (ou équivalent)
        final seanceUpdate = await _edtService.annulerSeance(idSeance);
        // ========================================================

        // Mettre à jour localement
        final index = _seances.indexWhere((s) => s.idSeance == idSeance);
        if (index != -1) {
          _seances[index] = seanceUpdate;
        }
      } else {
        // Pour d'autres statuts, utiliser updateSeance
        final seance = _seances.firstWhere((s) => s.idSeance == idSeance);
        final seanceUpdate = seance.copyWith(statut: nouveauStatut);

        // =================== ENDPOINT BACKEND ===================
        // 7. ENDPOINT: PUT /seances/{idSeance} (mise à jour)
        await _edtService.updateSeance(idSeance, seanceUpdate);
        // ========================================================

        // Mettre à jour localement
        final index = _seances.indexWhere((s) => s.idSeance == idSeance);
        if (index != -1) {
          _seances[index] = seanceUpdate;
        }
      }

      print('✅ Statut mis à jour: $idSeance -> ${nouveauStatut.value}');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la modification du statut: $e';
      print('❌ Erreur modifierStatut: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== RÉCUPÉRATION SÉANCES ==========

  /// Récupérer toutes les séances de la semaine sélectionnée
  List<Edt> seancesDeLaSemaine() {
    final lundi = _lundiSemaineSelectionnee;
    final dimanche = lundi.add(const Duration(days: 6));

    final seancesSemaine = _seances.where((seance) {
      return seance.dateSeance.isAfter(lundi.subtract(const Duration(days: 1))) &&
          seance.dateSeance.isBefore(dimanche.add(const Duration(days: 1)));
    }).toList();

    // Filtrer par classe si une classe est sélectionnée
    if (_selectedClasse != null) {
      return seancesSemaine.where((seance) {
        return seance.cours?.matiere?.idClasse == _selectedClasse!.idClasse;
      }).toList();
    }

    return seancesSemaine;
  }

  /// Récupérer les séances d'un jour spécifique
  List<Edt> seancesDuJour(DateTime date) {
    final seancesJour = _seances.where((seance) =>
    seance.dateSeance.year == date.year &&
        seance.dateSeance.month == date.month &&
        seance.dateSeance.day == date.day).toList();

    // Filtrer par classe si une classe est sélectionnée
    if (_selectedClasse != null) {
      final seancesFiltrees = seancesJour.where((seance) {
        return seance.cours?.matiere?.idClasse == _selectedClasse!.idClasse;
      }).toList();

      // Trier par heure de début
      seancesFiltrees.sort((a, b) => a.heureDebut.compareTo(b.heureDebut));
      return seancesFiltrees;
    }

    // Trier par heure de début
    seancesJour.sort((a, b) => a.heureDebut.compareTo(b.heureDebut));
    return seancesJour;
  }

  /// Récupérer les séances par classe
  List<Edt> seancesParClasse(int idClasse) {
    return _seances.where((seance) {
      return seance.cours?.matiere?.idClasse == idClasse;
    }).toList();
  }

  /// Récupérer les séances d'un cours spécifique
  List<Edt> seancesParCours(int idCours) {
    return _seances.where((seance) {
      return seance.idCours == idCours;
    }).toList();
  }

  // ========== STATISTIQUES ==========

  /// Nombre de séances dans la semaine
  int nombreSeancesSemaine() {
    return seancesDeLaSemaine().length;
  }

  /// Nombre d'heures total dans la semaine
  double heuresTotalesSemaine() {
    final seances = seancesDeLaSemaine();
    double total = 0.0;

    for (var seance in seances) {
      final debut = _parseHeureToDateTime(seance.heureDebut, seance.dateSeance);
      final fin = _parseHeureToDateTime(seance.heureFin, seance.dateSeance);
      if (debut != null && fin != null) {
        total += fin.difference(debut).inMinutes / 60.0;
      }
    }

    return total;
  }

  /// Vérifier s'il y a un conflit d'horaire
  bool verifierConflit({
    required DateTime dateSeance,
    required String heureDebut,
    required String heureFin,
  }) {
    final seancesJour = seancesDuJour(dateSeance);

    for (var seance in seancesJour) {
      final debut1 = _parseHeureToDateTime(heureDebut, dateSeance);
      final fin1 = _parseHeureToDateTime(heureFin, dateSeance);
      final debut2 = _parseHeureToDateTime(seance.heureDebut, dateSeance);
      final fin2 = _parseHeureToDateTime(seance.heureFin, dateSeance);

      if (debut1 != null && fin1 != null && debut2 != null && fin2 != null) {
        // Vérifier le chevauchement
        if ((debut1.isBefore(fin2) && fin1.isAfter(debut2))) {
          return true; // Il y a un conflit
        }
      }
    }

    return false; // Pas de conflit
  }

  // ========== HELPERS ==========

  TimeOfDay? _parseHeure(String heure) {
    final parts = heure.split(':');
    if (parts.length != 2) return null;

    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);

    if (h == null || m == null) return null;

    return TimeOfDay(hour: h, minute: m);
  }

  DateTime? _parseHeureToDateTime(String heure, DateTime date) {
    final parts = heure.split(':');
    if (parts.length != 2) return null;

    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);

    if (h == null || m == null) return null;

    return DateTime(date.year, date.month, date.day, h, m);
  }

  // ========== CHARGEMENT SPÉCIFIQUE ==========

  /// Charger les séances d'une semaine spécifique
  Future<void> chargerSeancesSemaine(DateTime lundi) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dimanche = lundi.add(const Duration(days: 6));
      
      // =================== ENDPOINT BACKEND ===================
      // 8. ENDPOINT: GET /seances?startDate={lundi}&endDate={dimanche}
      final seancesSemaine = await _edtService.getSeancesByDateRange(lundi, dimanche);
      // ========================================================

      // Filtrer pour ne garder que les séances de la semaine (au cas où l'API retourne plus)
      _seances = seancesSemaine.where((seance) {
        return seance.dateSeance.isAfter(lundi.subtract(const Duration(days: 1))) &&
            seance.dateSeance.isBefore(dimanche.add(const Duration(days: 1)));
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des séances de la semaine: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charger les séances du jour
  Future<void> chargerSeancesAujourdhui() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final aujourdhui = DateTime.now();
      
      // =================== ENDPOINT BACKEND ===================
      // 9. ENDPOINT: GET /seances?date={aujourdhui}
      final seancesAujourdhui = await _edtService.getSeancesByDate(aujourdhui);
      // ========================================================

      // Mettre à jour seulement les séances d'aujourd'hui
      _seances.removeWhere((s) =>
      s.dateSeance.year == aujourdhui.year &&
          s.dateSeance.month == aujourdhui.month &&
          s.dateSeance.day == aujourdhui.day);

      _seances.addAll(seancesAujourdhui);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des séances d\'aujourd\'hui: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== RÉINITIALISATION ==========

  void reset() {
    _seances.clear();
    _selectedClasse = null;
    _coursSelectionne = null;
    _initDate();
    notifyListeners();
  }

  /// Reset uniquement les séances (garde la classe sélectionnée)
  void resetSeances() {
    _seances.clear();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}