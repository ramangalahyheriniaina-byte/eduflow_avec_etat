import 'package:flutter/material.dart';
import 'package:apk_web_eduflow/core/services/api_service.dart';
import '../../edt/services/edt_service.dart';
import '../../Cours/services/cours_service.dart';
import '../../../core/status_enum.dart';
import '../../edt/Model/edtModel.dart';
import '../../Cours/models/cours_model.dart';
import '../../Cours/models/classe_model.dart';
import '../Model/dashboard_model.dart';

class DashboardViewModel extends ChangeNotifier {
  final EdtService _edtService = EdtService();
  final CoursService _coursService = CoursService();

  List<Edt> _seances = [];
  List<Cours> _cours = [];
  List<Classe> _classes = [];
  Classe? selectedClasse;

  bool _isLoading = false;
  String? _error;
  bool _showAllCours = false; // ← NOUVEAU : État pour afficher tous les cours

  List<Edt> get seances => _seances;
  List<Cours> get cours => _cours;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Classe> get classes => _classes;
  bool get showAllCours => _showAllCours; // ← NOUVEAU : Getter

  // ========== CHARGEMENT DES DONNÉES ==========
  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    print('📊 DashboardVM: Chargement initial des données...');

    try {
      // 1. Charger les séances
      print('📊 DashboardVM: Chargement des séances...');
      final seancesResponse = await _edtService.getAllSeances();
      print('📊 DashboardVM: ${seancesResponse.length} séances chargées');

      // 2. Extraire les cours
      final Set<Cours> coursSet = {};
      for (var seance in seancesResponse) {
        if (seance.cours != null) {
          coursSet.add(seance.cours!);
        }
      }

      // 3. Charger les classes
      print('📊 DashboardVM: Chargement des classes...');
      final classesResponse = await _coursService.getAllClasses();
      print('📊 DashboardVM: ${classesResponse.length} classes chargées');

      // 4. Assigner
      _seances = seancesResponse;
      _cours = coursSet.toList();
      _classes = classesResponse;

      print('📊 DashboardVM: Données mises à jour - ${_seances.length} séances, ${_cours.length} cours');

      _isLoading = false;
      notifyListeners();

    } catch (e) {
      _error = 'Erreur lors du chargement: $e';
      print('❌ DashboardVM: Erreur: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== ACTIONS POUR AFFICHAGE COURS ==========
  /// NOUVEAU : Basculer entre "cours en cours" et "tous les cours"
  void toggleShowAllCours() {
    _showAllCours = !_showAllCours;
    print('📊 DashboardVM: Mode showAllCours = $_showAllCours');
    notifyListeners();
  }

  /// NOUVEAU : Réinitialiser à "cours en cours seulement"
  void resetToCoursEnCours() {
    _showAllCours = false;
    notifyListeners();
  }

  /// MODIFIÉ : Cours d'aujourd'hui avec filtre selon le mode
  List<DashboardModel> getCoursAujourdhuiFiltered() {
    final maintenant = DateTime.now();
    final aujourdhui = DateTime(maintenant.year, maintenant.month, maintenant.day);

    // Filtrer les séances d'aujourd'hui
    final seancesAujourdhui = _seances.where((seance) {
      final dateSeance = seance.dateSeance;
      return dateSeance.year == aujourdhui.year &&
          dateSeance.month == aujourdhui.month &&
          dateSeance.day == aujourdhui.day;
    }).toList();

    // Créer les DashboardModels
    final List<DashboardModel> models = seancesAujourdhui.map((seance) {
      return DashboardModel(seance: seance);
    }).toList();

    // Si on est en mode "cours en cours seulement", filtrer
    if (!_showAllCours) {
      final coursEnCours = models.where((dm) {
        return dm.statutReel == StatutSeance.enCours;
      }).toList();

      print('📊 DashboardVM: Mode cours en cours - ${coursEnCours.length}/${models.length} séances');
      return coursEnCours;
    }

    // Sinon, retourner tous
    print('📊 DashboardVM: Mode voir tous - ${models.length} séances');
    return models;
  }

  /// ANCIENNE MÉTHODE (gardée pour compatibilité)
  List<DashboardModel> getAllCoursAujourdhui() {
    final maintenant = DateTime.now();
    final aujourdhui = DateTime(maintenant.year, maintenant.month, maintenant.day);

    final seancesAujourdhui = _seances.where((seance) {
      final dateSeance = seance.dateSeance;
      return dateSeance.year == aujourdhui.year &&
          dateSeance.month == aujourdhui.month &&
          dateSeance.day == aujourdhui.day;
    }).toList();

    print('📊 DashboardVM: ${seancesAujourdhui.length} séances aujourd\'hui');

    return seancesAujourdhui.map((seance) {
      return DashboardModel(seance: seance);
    }).toList();
  }

  // ========== ACTIONS SUR SÉANCES ==========
  Future<void> annulerSeance(DashboardModel dm) async {
    if (dm.seance.idSeance == null) {
      print('❌ DashboardVM: Impossible d\'annuler - ID séance null');
      return;
    }

    _isLoading = true;
    notifyListeners();

    print('🔄 DashboardVM: Annulation séance ${dm.seance.idSeance}...');

    try {
      // 1. Appeler l'API
      final updatedSeance = await _edtService.annulerSeance(dm.seance.idSeance!);
      print('✅ DashboardVM: API - Séance annulée avec succès');

      // 2. Mettre à jour LOCALEMENT immédiatement
      final index = _seances.indexWhere((s) => s.idSeance == dm.seance.idSeance);
      if (index != -1) {
        _seances[index] = updatedSeance;
        print('📊 DashboardVM: Mise à jour locale - index $index');
        notifyListeners();

        // 3. Attendre un peu et recharger pour synchronisation
        await Future.delayed(const Duration(milliseconds: 300));
        await loadInitialData();
      } else {
        print('⚠️ DashboardVM: Séance non trouvée dans la liste locale');
      }

      _isLoading = false;
      notifyListeners();

    } catch (e) {
      _error = 'Erreur annulation: $e';
      print('❌ DashboardVM: Erreur annulation: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> marquerEnCours(DashboardModel dm) async {
    if (dm.seance.idSeance == null) {
      print('❌ DashboardVM: Impossible de marquer en cours - ID séance null');
      return;
    }

    _isLoading = true;
    notifyListeners();

    print('🔄 DashboardVM: Marquer en cours ${dm.seance.idSeance}...');

    try {
      final seanceUpdate = dm.seance.copyWith(statut: StatutSeance.enCours);
      final updatedSeance = await _edtService.updateSeance(dm.seance.idSeance!, seanceUpdate);

      print('✅ DashboardVM: API - Séance marquée en cours');

      // Mettre à jour localement
      final index = _seances.indexWhere((s) => s.idSeance == dm.seance.idSeance);
      if (index != -1) {
        _seances[index] = updatedSeance;
        print('📊 DashboardVM: Mise à jour locale - index $index');
        notifyListeners();

        await Future.delayed(const Duration(milliseconds: 300));
        await loadInitialData();
      }

      _isLoading = false;
      notifyListeners();

    } catch (e) {
      _error = 'Erreur marquage en cours: $e';
      print('❌ DashboardVM: Erreur marquage en cours: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> terminerSeance(DashboardModel dm) async {
    if (dm.seance.idSeance == null) {
      print('❌ DashboardVM: Impossible de terminer - ID séance null');
      return;
    }

    _isLoading = true;
    notifyListeners();

    print('🔄 DashboardVM: Terminer séance ${dm.seance.idSeance}...');

    try {
      final seanceUpdate = dm.seance.copyWith(statut: StatutSeance.termine);
      final updatedSeance = await _edtService.updateSeance(dm.seance.idSeance!, seanceUpdate);

      print('✅ DashboardVM: API - Séance terminée');

      // Mettre à jour localement
      final index = _seances.indexWhere((s) => s.idSeance == dm.seance.idSeance);
      if (index != -1) {
        _seances[index] = updatedSeance;
        print('📊 DashboardVM: Mise à jour locale - index $index');
        notifyListeners();

        await Future.delayed(const Duration(milliseconds: 300));
        await loadInitialData();
      }

      _isLoading = false;
      notifyListeners();

    } catch (e) {
      _error = 'Erreur terminaison: $e';
      print('❌ DashboardVM: Erreur terminaison: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // ========== MÉTHODES POUR L'UI ==========
  List<AvancementCours> avancementParCours() {
    if (_cours.isEmpty) {
      return [];
    }

    return _cours.map((c) {
      return AvancementCours(
        nomClasse: c.matiere?.classe?.nomClasse ?? 'N/A',
        nomMatiere: c.matiere?.nomMatiere ?? 'N/A',
        progression: c.progression,
        couleur: _getCouleurProgression(c.progression),
      );
    }).toList();
  }

  Color _getCouleurProgression(double progression) {
    if (progression >= 75) return const Color(0xFF22C55E);
    if (progression >= 50) return const Color(0xFF3B82F6);
    if (progression >= 25) return const Color(0xFFF59E0B);
    return const Color(0xFF8B5CF6);
  }

  String get jourActuel {
    const jours = ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche"];
    return jours[DateTime.now().weekday - 1];
  }

  // ========== UTILITAIRES ==========
  void updateSeancesList(List<Edt> seances) {
    _seances = seances;
    print('📊 DashboardVM: Liste séances mise à jour - ${_seances.length} séances');
    notifyListeners();
  }

  void updateCoursList(List<Cours> cours) {
    _cours = cours;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// Model pour l'avancement d'un cours
class AvancementCours {
  final String nomClasse;
  final String nomMatiere;
  final double progression;
  final Color couleur;

  AvancementCours({
    required this.nomClasse,
    required this.nomMatiere,
    required this.progression,
    required this.couleur,
  });
}

/// Helper class pour représenter une heure
class TimeOfDay {
  final int hour;
  final int minute;

  TimeOfDay({required this.hour, required this.minute});

  @override
  String toString() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}