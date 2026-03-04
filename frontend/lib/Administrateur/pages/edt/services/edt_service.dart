import 'package:apk_web_eduflow/core/services/api_service.dart';
import '../Model/edtModel.dart';
import '../../Cours/services/cours_service.dart';
import '../../Cours/models/cours_model.dart';    // ⚠️ AJOUT
import '../../Cours/models/matiere_model.dart';  // ⚠️ AJOUT
import '../../Cours/models/prof_model.dart';     // ⚠️ AJOUT
import '../../Cours/models/classe_model.dart';   // ⚠️ AJOUT

import 'package:apk_web_eduflow/core/services/api_service.dart';
import '../Model/edtModel.dart';
import '../../Cours/models/cours_model.dart';
import '../../Cours/models/matiere_model.dart';
import '../../Cours/models/prof_model.dart';
import '../../Cours/models/classe_model.dart';
import 'package:apk_web_eduflow/Administrateur/core/status_enum.dart';

class EdtService {
  final ApiService _api = ApiService();
  final CoursService _coursService = CoursService();

  // ========== SÉANCES ==========
  // Dans edt_service.dart, méthode getAllSeances() :

Future<List<Edt>> getAllSeances() async {
  try {
    print('🔄 GET /seances');
    final response = await _api.get('/seances');
    
    print('📦 Response type: ${response.runtimeType}');
    
    if (response is List) {
      final List<Edt> seances = [];
      
      for (var item in response) {
        try {
          if (item is Map<String, dynamic>) {
            final edt = Edt.fromJson(item);
            seances.add(edt);
            
            // DEBUG
            print('   Séance ${edt.idSeance}:');
            print('   - Cours présent: ${edt.cours != null ? "OUI" : "NON"}');
            print('   - Matière: ${edt.nomMatiere}');
            print('   - Prof: ${edt.nomProf}');
            print('   - Classe: ${edt.nomClasse}');
          }
        } catch (e) {
          print('⚠️ Erreur parsing séance: $e');
        }
      }
      
      print('✅ ${seances.length} séances chargées');
      return seances;
    }
    
    return [];
  } catch (e) {
    print('❌ Erreur getAllSeances: $e');
    rethrow;
  }
}

  // ⚠️ CORRECTION : Méthode pour créer un cours vide
  Cours _creerCoursVide(int coursId) {
    return Cours(
      idCours: coursId,
      idMatiere: 0,
      idProf: 0,
      statut: StatutCours.nonCommence,
      cumul: 0,
      matiere: null,
      prof: null,
    );
  }

  // ⚠️ NOUVELLE MÉTHODE : Charger les données des cours pour les séances
  Future<void> _chargerDonneesCoursPourSeances(List<Edt> seances) async {
    try {
      print('🔄 CHARGEMENT COMPLET DES DONNÉES POUR SÉANCES');
      print('   Nombre de séances: ${seances.length}');

      if (seances.isEmpty) {
        print('   ⚠️ Aucune séance à traiter');
        return;
      }

      // 1. COLLECTER TOUS LES IDs DE COURS UNIQUES
      final Set<int> coursIds = {};
      for (var seance in seances) {
        if (seance.idCours != null && seance.idCours > 0) {
          coursIds.add(seance.idCours!);
          print('   📌 Séance ${seance.idSeance} → Cours ID: ${seance.idCours}');
        }
      }

      print('   📦 IDs de cours uniques: ${coursIds.length}');
      if (coursIds.isEmpty) {
        print('   ⚠️ Aucun ID de cours trouvé');
        return;
      }

      // 2. CHARGER TOUTES LES DONNÉES NÉCESSAIRES
      print('   🔄 Chargement des cours...');
      final List<Cours> tousLesCours = await _coursService.getAllCours();

      print('   🔄 Chargement des matières...');
      final List<Matiere> toutesMatieres = await _coursService.getAllMatieres();

      print('   🔄 Chargement des professeurs...');
      final List<Prof> tousProfs = await _coursService.getAllProfs();

      print('   🔄 Chargement des classes...');
      final List<Classe> toutesClasses = await _coursService.getAllClasses();

      print('   📊 Données chargées:');
      print('      - Cours: ${tousLesCours.length}');
      print('      - Matières: ${toutesMatieres.length}');
      print('      - Profs: ${tousProfs.length}');
      print('      - Classes: ${toutesClasses.length}');

      // 3. CRÉER UN MAP POUR FACILITER LES RECHERCHES
      final Map<int, Cours> coursMap = {};
      final Map<int, Matiere> matieresMap = {};
      final Map<int, Prof> profsMap = {};
      final Map<int, Classe> classesMap = {};

      for (var cours in tousLesCours) {
        if (cours.idCours != null) {
          coursMap[cours.idCours!] = cours;
        }
      }

      for (var matiere in toutesMatieres) {
        if (matiere.idMatiere != null) {
          matieresMap[matiere.idMatiere!] = matiere;
        }
      }

      for (var prof in tousProfs) {
        if (prof.idProf != null) {
          profsMap[prof.idProf!] = prof;
        }
      }

      for (var classe in toutesClasses) {
        if (classe.idClasse != null) {
          classesMap[classe.idClasse!] = classe;
        }
      }

      // 4. ASSOCIER LES DONNÉES À CHAQUE SÉANCE
      int associations = 0;

      for (var i = 0; i < seances.length; i++) {
        final seance = seances[i];

        if (seance.idCours == null || seance.idCours! <= 0) {
          print('   ⚠️ Séance ${seance.idSeance}: Pas d\'ID cours');
          continue;
        }

        // A. TROUVER LE COURS
        Cours? cours = coursMap[seance.idCours!];

        if (cours == null) {
          print('      ❌ Cours ${seance.idCours} non trouvé');
          cours = _creerCoursVide(seance.idCours!);
        }

        // B. ASSOCIER LA MATIÈRE AU COURS
        if (cours.idMatiere != null && cours.idMatiere! > 0) {
          final matiere = matieresMap[cours.idMatiere!];

          if (matiere != null) {
            cours.matiere = matiere;

            // C. ASSOCIER LA CLASSE À LA MATIÈRE
            if (matiere.idClasse != null && matiere.idClasse! > 0) {
              final classe = classesMap[matiere.idClasse!];
              if (classe != null) {
                matiere.classe = classe;
              }
            }
          }
        }

        // D. ASSOCIER LE PROFESSEUR AU COURS
        if (cours.idProf != null && cours.idProf! > 0) {
          final prof = profsMap[cours.idProf!];
          if (prof != null) {
            cours.prof = prof;
          }
        }

        // E. METTRE À JOUR LA SÉANCE
        seances[i] = seance.copyWith(cours: cours);
        associations++;

        // DEBUG: Afficher ce qui a été trouvé
        print('   ✅ Séance ${seance.idSeance} mise à jour:');
        print('      - Matière: ${cours.matiere?.nomMatiere ?? "Inconnu"}');
        print('      - Prof: ${cours.prof?.nomProf ?? "Inconnu"}');
        print('      - Classe: ${cours.matiere?.classe?.nomClasse ?? "Inconnu"}');
      }

      print('\n   🎯 RÉSULTAT FINAL:');
      print('      Associations réussies: $associations/${seances.length}');
      print('========================================\n');

    } catch (e) {
      print('❌ ERREUR dans _chargerDonneesCoursPourSeances:');
      print('   $e');
    }
  }

  // Helper pour parser une liste de séances
  List<Edt> _parseSeancesList(dynamic list) {
    final List<Edt> seances = [];

    if (list is List) {
      for (var item in list) {
        try {
          if (item is Map<String, dynamic>) {
            seances.add(Edt.fromJson(item));
          } else if (item is Map) {
            // Convertir Map<dynamic, dynamic> en Map<String, dynamic>
            final Map<String, dynamic> jsonMap = {};
            item.forEach((key, value) {
              jsonMap[key.toString()] = value;
            });
            seances.add(Edt.fromJson(jsonMap));
          }
        } catch (e) {
          print('⚠️ Skipping invalid seance item: $e');
        }
      }
    }

    print('✅ Parsed ${seances.length} seances');
    return seances;
  }

  Future<List<Edt>> getSeancesByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      print('🔄 GET /seances par date range');
      final response = await _api.get('/seances', queryParams: {
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate.toIso8601String().split('T')[0],
      });

      if (response is List) {
        return _parseSeancesList(response);
      }

      if (response is Map && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          return _parseSeancesList(data);
        }
      }

      throw Exception('Format inattendu pour date range');
    } catch (e) {
      print('❌ Erreur getSeancesByDateRange: $e');
      rethrow;
    }
  }

  Future<List<Edt>> getSeancesByClasse(int classeId) async {
    try {
      print('🔄 GET /seances/classe/$classeId');
      final response = await _api.get('/seances/classe/$classeId');

      if (response is List) {
        return _parseSeancesList(response);
      }

      throw Exception('Format inattendu pour classe');
    } catch (e) {
      print('❌ Erreur getSeancesByClasse: $e');
      rethrow;
    }
  }

  Future<List<Edt>> getSeancesByCours(int coursId) async {
    try {
      print('🔄 GET /seances/cours/$coursId');
      final response = await _api.get('/seances/cours/$coursId');

      if (response is List) {
        return _parseSeancesList(response);
      }

      throw Exception('Format inattendu pour cours');
    } catch (e) {
      print('❌ Erreur getSeancesByCours: $e');
      rethrow;
    }
  }

  Future<List<Edt>> getSeancesByDate(DateTime date) async {
    try {
      final dateStr = _formatDate(date);
      print('🔄 GET /seances/date/$dateStr');
      final response = await _api.get('/seances/date/$dateStr');

      if (response is List) {
        return _parseSeancesList(response);
      }

      throw Exception('Format inattendu pour date');
    } catch (e) {
      print('❌ Erreur getSeancesByDate: $e');
      rethrow;
    }
  }

  Future<Edt> getSeanceById(int id) async {
    try {
      print('🔄 GET /seances/$id');
      final response = await _api.get('/seances/$id');

      if (response is Map<String, dynamic>) {
        return Edt.fromJson(response);
      } else if (response is Map) {
        // Convertir
        final Map<String, dynamic> jsonMap = {};
        (response as Map).forEach((key, value) {
          jsonMap[key.toString()] = value;
        });
        return Edt.fromJson(jsonMap);
      }

      throw Exception('Format inattendu pour seance by id');
    } catch (e) {
      print('❌ Erreur getSeanceById: $e');
      rethrow;
    }
  }

  Future<Edt> createSeance(Edt seance) async {
    try {
      print('🔄 POST /seances');
      print('📦 Seance data: ${seance.toJson()}');

      final data = seance.toJson();
      final response = await _api.post('/seances', data);

      print('📦 Create response: $response');

      // ⚠️ CORRECTION : Gérer le format de réponse
      Map<String, dynamic> seanceJson;

      if (response is Map<String, dynamic>) {
        seanceJson = response;
      } else if (response is Map) {
        seanceJson = {};
        (response as Map).forEach((key, value) {
          seanceJson[key.toString()] = value;
        });
      } else {
        throw Exception('Format de réponse invalide après création');
      }

      return Edt.fromJson(seanceJson);
    } catch (e) {
      print('❌ Erreur createSeance: $e');
      rethrow;
    }
  }

  Future<Edt> updateSeance(int id, Edt seance) async {
    try {
      print('🔄 PUT /seances/$id');
      final data = seance.toJson();
      final response = await _api.put('/seances/$id', data);

      if (response is Map<String, dynamic>) {
        return Edt.fromJson(response);
      } else if (response is Map) {
        final Map<String, dynamic> jsonMap = {};
        (response as Map).forEach((key, value) {
          jsonMap[key.toString()] = value;
        });
        return Edt.fromJson(jsonMap);
      }

      throw Exception('Format inattendu après update');
    } catch (e) {
      print('❌ Erreur updateSeance: $e');
      rethrow;
    }
  }

  Future<void> deleteSeance(int id) async {
    try {
      print('🔄 DELETE /seances/$id');
      await _api.delete('/seances/$id');
      print('✅ Seance $id supprimée');
    } catch (e) {
      print('❌ Erreur deleteSeance: $e');
      rethrow;
    }
  }

  Future<Edt> annulerSeance(int id) async {
    try {
      print('🔄 PATCH /seances/$id/annuler');
      final response = await _api.patch('/seances/$id/annuler', {});

      if (response is Map<String, dynamic>) {
        return Edt.fromJson(response);
      } else if (response is Map) {
        final Map<String, dynamic> jsonMap = {};
        (response as Map).forEach((key, value) {
          jsonMap[key.toString()] = value;
        });
        return Edt.fromJson(jsonMap);
      }

      throw Exception('Format inattendu après annulation');
    } catch (e) {
      print('❌ Erreur annulerSeance: $e');
      rethrow;
    }
  }

  // ========== STATISTIQUES ==========
  Future<Map<String, dynamic>> getSeancesStats() async {
    try {
      final response = await _api.get('/seances/stats');

      if (response is Map<String, dynamic>) {
        return response;
      } else if (response is Map) {
        final Map<String, dynamic> stats = {};
        (response as Map).forEach((key, value) {
          stats[key.toString()] = value;
        });
        return stats;
      }

      throw Exception('Format inattendu pour stats');
    } catch (e) {
      print('❌ Erreur getSeancesStats: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getTodaySeancesStats() async {
    try {
      final response = await _api.get('/seances/stats/today');

      if (response is Map<String, dynamic>) {
        return response;
      } else if (response is Map) {
        final Map<String, dynamic> stats = {};
        (response as Map).forEach((key, value) {
          stats[key.toString()] = value;
        });
        return stats;
      }

      throw Exception('Format inattendu pour today stats');
    } catch (e) {
      print('❌ Erreur getTodaySeancesStats: $e');
      rethrow;
    }
  }

  // Helper pour formater la date
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}