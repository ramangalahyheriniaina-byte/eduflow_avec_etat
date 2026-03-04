import 'package:apk_web_eduflow/core/services/api_service.dart';
import '../models/cours_model.dart';
import '../models/matiere_model.dart';
import '../models/prof_model.dart';
import '../models/classe_model.dart';
import '../models/annee_scolaire_model.dart';

class CoursService {
  final ApiService _api = ApiService();

  // ========== COURS ==========
  Future<List<Cours>> getAllCours({int skip = 0, int limit = 100, bool includeRelations = true}) async {
    try {
      print(' GET /cours?skip=$skip&limit=$limit');

      //  AJOUTEZ ces paramètres pour demander les relations
      Map<String, String> queryParams = {
        'skip': skip.toString(),
        'limit': limit.toString(),
      };

      //  UTILISEZ LES NOUVEAUX PARAMÈTRES
      if (includeRelations) {
        queryParams['include_matiere'] = 'true';
        queryParams['include_prof'] = 'true';
        queryParams['include_classe'] = 'true';
      }

      final response = await _api.get('/cours', queryParams: queryParams);

      print('📦 Cours response type: ${response.runtimeType}');

      //  Vérifier le type AVANT de traiter
      if (response is List) {
        print(' Format: Direct List (${response.length} items)');
        final cours = _parseCoursList(response);

        // DEBUG: Vérifier les relations chargées
        if (cours.isNotEmpty) {
          print('🔍 Vérification relations du premier cours:');
          final premierCours = cours[0];
          print('   - Matière: ${premierCours.matiere != null ? "OUI" : "NON"}');
          print('   - Prof: ${premierCours.prof != null ? "OUI" : "NON"}');
          print('   - Classe: ${premierCours.classe != null ? "OUI" : "NON"}');
        }

        return cours;
      }

      if (response is Map) {
        // Vérifier les clés possibles
        if (response.containsKey('data')) {
          print(' Format: Map with data field');
          final data = response['data'];
          if (data is List) {
            return _parseCoursList(data);
          }
        } else if (response.containsKey('cours')) {
          print(' Format: Map with cours field');
          final data = response['cours'];
          if (data is List) {
            return _parseCoursList(data);
          }
        } else if (response.containsKey('items')) {
          print(' Format: Map with items field');
          final data = response['items'];
          if (data is List) {
            return _parseCoursList(data);
          }
        }
      }

      // Si vide ou autre format
      if (response is Map && response.isEmpty) {
        print('ℹ Empty response, no cours');
        return [];
      }

      print(' Unexpected format: $response');
      throw Exception('Format de réponse inattendu pour /cours');

    } catch (e) {
      print(' Erreur getAllCours: $e');
      rethrow;
    }
  }

  // Helper pour parser une liste de cours
  List<Cours> _parseCoursList(dynamic list) {
    final List<Cours> coursList = [];

    if (list is List) {
      for (var item in list) {
        try {
          if (item is Map<String, dynamic>) {
            coursList.add(Cours.fromJson(item));
          } else if (item is Map) {
            // Convertir Map<dynamic, dynamic> en Map<String, dynamic>
            final Map<String, dynamic> jsonMap = {};
            item.forEach((key, value) {
              jsonMap[key.toString()] = value;
            });
            coursList.add(Cours.fromJson(jsonMap));
          }
        } catch (e) {
          print(' Skipping invalid cours item: $e');
          print(' Item was: $item');
        }
      }
    }

    print(' Parsed ${coursList.length} cours');
    return coursList;
  }

  Future<Cours> getCoursById(int id) async {
    try {
      print(' GET /cours/$id');
      final response = await _api.get('/cours/$id');

      if (response is Map<String, dynamic>) {
        return Cours.fromJson(response);
      } else if (response is Map) {
        // Convertir
        final Map<String, dynamic> jsonMap = {};
        (response as Map).forEach((key, value) {
          jsonMap[key.toString()] = value;
        });
        return Cours.fromJson(jsonMap);
      }

      throw Exception('Format inattendu pour cours by id');
    } catch (e) {
      print(' Erreur getCoursById: $e');
      rethrow;
    }
  }

  Future<List<Cours>> getCoursByProf(int profId) async {
    try {
      print(' GET /cours/professeur/$profId');
      final response = await _api.get('/cours/professeur/$profId');

      if (response is List) {
        return _parseCoursList(response);
      }

      throw Exception('Format inattendu pour cours par prof');
    } catch (e) {
      print(' Erreur getCoursByProf: $e');
      rethrow;
    }
  }

  Future<List<Cours>> getCoursByMatiere(int matiereId) async {
    try {
      print(' GET /cours/matiere/$matiereId');
      final response = await _api.get('/cours/matiere/$matiereId');

      if (response is List) {
        return _parseCoursList(response);
      }

      throw Exception('Format inattendu pour cours par matiere');
    } catch (e) {
      print(' Erreur getCoursByMatiere: $e');
      rethrow;
    }
  }

  Future<Cours> createCours(Cours cours) async {
    try {
      print(' POST /cours');
      final data = {
        'id_matiere': cours.idMatiere,
        'id_prof': cours.idProf,
        'statut': cours.statut?.value ?? 'non_commence',
        'cumul': cours.cumul ?? 0,
      };

      print('📦 Request data: $data');
      final response = await _api.post('/cours', data);

      if (response is Map<String, dynamic>) {
        return Cours.fromJson(response);
      } else if (response is Map) {
        final Map<String, dynamic> jsonMap = {};
        (response as Map).forEach((key, value) {
          jsonMap[key.toString()] = value;
        });
        return Cours.fromJson(jsonMap);
      }

      throw Exception('Format inattendu après création');
    } catch (e) {
      print(' Erreur createCours: $e');
      rethrow;
    }
  }

  Future<Cours> updateCours(int id, Cours cours) async {
    try {
      print(' PUT /cours/$id');
      final data = <String, dynamic>{};

      if (cours.statut != null) data['statut'] = cours.statut!.value;
      if (cours.idMatiere != null) data['id_matiere'] = cours.idMatiere;
      if (cours.idProf != null) data['id_prof'] = cours.idProf;
      if (cours.cumul != null) data['cumul'] = cours.cumul;

      print('📦 Update data: $data');
      final response = await _api.put('/cours/$id', data);

      if (response is Map<String, dynamic>) {
        return Cours.fromJson(response);
      } else if (response is Map) {
        final Map<String, dynamic> jsonMap = {};
        (response as Map).forEach((key, value) {
          jsonMap[key.toString()] = value;
        });
        return Cours.fromJson(jsonMap);
      }

      throw Exception('Format inattendu après update');
    } catch (e) {
      print(' Erreur updateCours: $e');
      rethrow;
    }
  }

  Future<void> deleteCours(int id) async {
    try {
      print(' DELETE /cours/$id');
      await _api.delete('/cours/$id');
      print(' Cours $id supprimé');
    } catch (e) {
      print(' Erreur deleteCours: $e');
      rethrow;
    }
  }

  Future<Cours> updateCumul(int coursId, int heures) async {
    try {
      print(' PATCH /cours/$coursId/cumul');
      final response = await _api.patch('/cours/$coursId/cumul', {'heures': heures});

      if (response is Map<String, dynamic>) {
        return Cours.fromJson(response);
      } else if (response is Map) {
        final Map<String, dynamic> jsonMap = {};
        (response as Map).forEach((key, value) {
          jsonMap[key.toString()] = value;
        });
        return Cours.fromJson(jsonMap);
      }

      throw Exception('Format inattendu après update cumul');
    } catch (e) {
      print('❌ Erreur updateCumul: $e');
      rethrow;
    }
  }

  // ========== MATIÈRES ==========
  Future<List<Matiere>> getAllMatieres({int skip = 0, int limit = 100}) async {
    try {
      print(' GET /matieres?skip=$skip&limit=$limit');
      final response = await _api.get('/matieres', queryParams: {
        'skip': skip.toString(),
        'limit': limit.toString(),
      });

      print('📦 Matieres response type: ${response.runtimeType}');

      if (response is List) {
        return _parseMatieresList(response);
      }

      if (response is Map) {
        if (response.containsKey('data')) {
          final data = response['data'];
          if (data is List) {
            return _parseMatieresList(data);
          }
        }
      }

      return [];
    } catch (e) {
      print(' Erreur getAllMatieres: $e');
      rethrow;
    }
  }

  List<Matiere> _parseMatieresList(dynamic list) {
    final List<Matiere> matieres = [];

    if (list is List) {
      for (var item in list) {
        try {
          if (item is Map<String, dynamic>) {
            matieres.add(Matiere.fromJson(item));
          } else if (item is Map) {
            final Map<String, dynamic> jsonMap = {};
            item.forEach((key, value) {
              jsonMap[key.toString()] = value;
            });
            matieres.add(Matiere.fromJson(jsonMap));
          }
        } catch (e) {
          print(' Skipping invalid matiere: $e');
        }
      }
    }

    return matieres;
  }

  Future<Matiere> getMatiereById(int id) async {
    try {
      print(' GET /matieres/$id');
      final response = await _api.get('/matieres/$id');

      if (response is Map<String, dynamic>) {
        return Matiere.fromJson(response);
      } else if (response is Map) {
        final Map<String, dynamic> jsonMap = {};
        (response as Map).forEach((key, value) {
          jsonMap[key.toString()] = value;
        });
        return Matiere.fromJson(jsonMap);
      }

      throw Exception('Format inattendu pour matiere by id');
    } catch (e) {
      print(' Erreur getMatiereById: $e');
      rethrow;
    }
  }

  Future<Matiere> createMatiere(Matiere matiere) async {
    try {
      print(' POST /matieres');
      final data = {
        'nom_matiere': matiere.nomMatiere,
        'heure_totale': matiere.heureTotale,
        'id_classe': matiere.idClasse,
      };

      final response = await _api.post('/matieres', data);

      if (response is Map<String, dynamic>) {
        return Matiere.fromJson(response);
      } else if (response is Map) {
        final Map<String, dynamic> jsonMap = {};
        (response as Map).forEach((key, value) {
          jsonMap[key.toString()] = value;
        });
        return Matiere.fromJson(jsonMap);
      }

      throw Exception('Format inattendu après création matiere');
    } catch (e) {
      print(' Erreur createMatiere: $e');
      rethrow;
    }
  }

  // ========== PROFS ==========
  Future<List<Prof>> getAllProfs({int skip = 0, int limit = 100}) async {
    try {
      print(' GET /professeurs?skip=$skip&limit=$limit');
      final response = await _api.get('/professeurs', queryParams: {
        'skip': skip.toString(),
        'limit': limit.toString(),
      });

      print('📦 Profs response type: ${response.runtimeType}');

      if (response is List) {
        return _parseProfsList(response);
      }

      if (response is Map && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          return _parseProfsList(data);
        }
      }

      return [];
    } catch (e) {
      print(' Erreur getAllProfs: $e');
      rethrow;
    }
  }

  List<Prof> _parseProfsList(dynamic list) {
    final List<Prof> profs = [];

    if (list is List) {
      for (var item in list) {
        try {
          if (item is Map<String, dynamic>) {
            profs.add(Prof.fromJson(item));
          } else if (item is Map) {
            final Map<String, dynamic> jsonMap = {};
            item.forEach((key, value) {
              jsonMap[key.toString()] = value;
            });
            profs.add(Prof.fromJson(jsonMap));
          }
        } catch (e) {
          print(' Skipping invalid prof: $e');
        }
      }
    }

    return profs;
  }

  Future<Prof> getProfById(int id) async {
    try {
      print(' GET /professeurs/$id');
      final response = await _api.get('/professeurs/$id');

      if (response is Map<String, dynamic>) {
        return Prof.fromJson(response);
      } else if (response is Map) {
        final Map<String, dynamic> jsonMap = {};
        (response as Map).forEach((key, value) {
          jsonMap[key.toString()] = value;
        });
        return Prof.fromJson(jsonMap);
      }

      throw Exception('Format inattendu pour prof by id');
    } catch (e) {
      print(' Erreur getProfById: $e');
      rethrow;
    }
  }

  Future<Prof> createProf(Prof prof) async {
    try {
      print(' POST /professeurs');
      final data = {
        'nom_prof': prof.nomProf,
        'nb_abs': prof.nbAbs ?? 0,
      };

      final response = await _api.post('/professeurs', data);

      if (response is Map<String, dynamic>) {
        return Prof.fromJson(response);
      } else if (response is Map) {
        final Map<String, dynamic> jsonMap = {};
        (response as Map).forEach((key, value) {
          jsonMap[key.toString()] = value;
        });
        return Prof.fromJson(jsonMap);
      }

      throw Exception('Format inattendu après création prof');
    } catch (e) {
      print(' Erreur createProf: $e');
      rethrow;
    }
  }

  Future<void> deleteProf(int id) async {
    try {
      print(' DELETE /professeurs/$id');
      await _api.delete('/professeurs/$id');
      print(' Prof $id supprimé');
    } catch (e) {
      print(' Erreur deleteProf: $e');
      rethrow;
    }
  }

  Future<Prof> updateProf(int id, Prof prof) async {
    try {
      print(' PUT /professeurs/$id');
      final data = {
        'nom_prof': prof.nomProf,
        'nb_abs': prof.nbAbs ?? 0,
      };

      final response = await _api.put('/professeurs/$id', data);

      if (response is Map<String, dynamic>) {
        return Prof.fromJson(response);
      } else if (response is Map) {
        final Map<String, dynamic> jsonMap = {};
        (response as Map).forEach((key, value) {
          jsonMap[key.toString()] = value;
        });
        return Prof.fromJson(jsonMap);
      }

      throw Exception('Format inattendu après update prof');
    } catch (e) {
      print(' Erreur updateProf: $e');
      rethrow;
    }
  }

  // ========== CLASSES ==========
  Future<List<Classe>> getAllClasses({int skip = 0, int limit = 100}) async {
    try {
      print(' GET /classes?skip=$skip&limit=$limit');
      final response = await _api.get('/classes', queryParams: {
        'skip': skip.toString(),
        'limit': limit.toString(),
      });

      print('📦 Classes response type: ${response.runtimeType}');

      List<Classe> classes = [];

      if (response is List) {
        classes = _parseClassesList(response);
      } else if (response is Map && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          classes = _parseClassesList(data);
        }
      }

      print(' Found ${classes.length} classes');

      // Charger les matières pour chaque classe
      for (var classe in classes) {
        try {
          final matieres = await getMatieresByClasse(classe.idClasse!);
          classe.matieres = matieres;
          print('   - ${classe.nomClasse}: ${matieres.length} matières');
        } catch (e) {
          print(' Erreur chargement matières pour ${classe.nomClasse}: $e');
        }
      }

      return classes;
    } catch (e) {
      print(' Erreur getAllClasses: $e');
      rethrow;
    }
  }

  List<Classe> _parseClassesList(dynamic list) {
    final List<Classe> classes = [];

    if (list is List) {
      for (var item in list) {
        try {
          if (item is Map<String, dynamic>) {
            classes.add(Classe.fromJson(item));
          } else if (item is Map) {
            final Map<String, dynamic> jsonMap = {};
            item.forEach((key, value) {
              jsonMap[key.toString()] = value;
            });
            classes.add(Classe.fromJson(jsonMap));
          }
        } catch (e) {
          print(' Skipping invalid classe: $e');
        }
      }
    }

    return classes;
  }

  Future<Classe> getClasseById(int id) async {
    try {
      print(' GET /classes/$id');
      final response = await _api.get('/classes/$id');

      if (response is Map<String, dynamic>) {
        return Classe.fromJson(response);
      } else if (response is Map) {
        final Map<String, dynamic> jsonMap = {};
        (response as Map).forEach((key, value) {
          jsonMap[key.toString()] = value;
        });
        return Classe.fromJson(jsonMap);
      }

      throw Exception('Format inattendu pour classe by id');
    } catch (e) {
      print(' Erreur getClasseById: $e');
      rethrow;
    }
  }

  Future<Classe> createClasse(Classe classe) async {
    try {
      print(' POST /classes');
      final data = {
        'nom_classe': classe.nomClasse,
      };

      final response = await _api.post('/classes', data);

      if (response is Map<String, dynamic>) {
        return Classe.fromJson(response);
      } else if (response is Map) {
        final Map<String, dynamic> jsonMap = {};
        (response as Map).forEach((key, value) {
          jsonMap[key.toString()] = value;
        });
        return Classe.fromJson(jsonMap);
      }

      throw Exception('Format inattendu après création classe');
    } catch (e) {
      print(' Erreur createClasse: $e');
      rethrow;
    }
  }

  // ========== ANNÉES SCOLAIRES ==========
  Future<List<AnneeScolaire>> getAllAnneeScolaires({int skip = 0, int limit = 100}) async {
    try {
      print(' GET /annees-scolaires?skip=$skip&limit=$limit');
      final response = await _api.get('/annees-scolaires', queryParams: {
        'skip': skip.toString(),
        'limit': limit.toString(),
      });

      print('📦 Annees response type: ${response.runtimeType}');

      if (response is List) {
        return _parseAnneeScolairesList(response);
      }

      if (response is Map && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          return _parseAnneeScolairesList(data);
        }
      }

      return [];
    } catch (e) {
      print(' Erreur getAllAnneeScolaires: $e');
      rethrow;
    }
  }

  List<AnneeScolaire> _parseAnneeScolairesList(dynamic list) {
    final List<AnneeScolaire> annees = [];

    if (list is List) {
      for (var item in list) {
        try {
          if (item is Map<String, dynamic>) {
            annees.add(AnneeScolaire.fromJson(item));
          } else if (item is Map) {
            final Map<String, dynamic> jsonMap = {};
            item.forEach((key, value) {
              jsonMap[key.toString()] = value;
            });
            annees.add(AnneeScolaire.fromJson(jsonMap));
          }
        } catch (e) {
          print(' Skipping invalid annee: $e');
        }
      }
    }

    return annees;
  }

  Future<AnneeScolaire> getAnneeScolaireById(int id) async {
    try {
      print(' GET /annees-scolaires/$id');
      final response = await _api.get('/annees-scolaires/$id');

      if (response is Map<String, dynamic>) {
        return AnneeScolaire.fromJson(response);
      } else if (response is Map) {
        final Map<String, dynamic> jsonMap = {};
        (response as Map).forEach((key, value) {
          jsonMap[key.toString()] = value;
        });
        return AnneeScolaire.fromJson(jsonMap);
      }

      throw Exception('Format inattendu pour annee by id');
    } catch (e) {
      print(' Erreur getAnneeScolaireById: $e');
      rethrow;
    }
  }

  Future<AnneeScolaire> createAnneeScolaire(AnneeScolaire annee) async {
    try {
      print(' POST /annees-scolaires');
      final data = {
        'start_year': annee.startYear,
        'end_year': annee.endYear,
        'is_active': annee.isActive,
      };

      final response = await _api.post('/annees-scolaires', data);

      if (response is Map<String, dynamic>) {
        return AnneeScolaire.fromJson(response);
      } else if (response is Map) {
        final Map<String, dynamic> jsonMap = {};
        (response as Map).forEach((key, value) {
          jsonMap[key.toString()] = value;
        });
        return AnneeScolaire.fromJson(jsonMap);
      }

      throw Exception('Format inattendu après création annee');
    } catch (e) {
      print(' Erreur createAnneeScolaire: $e');
      rethrow;
    }
  }

  Future<AnneeScolaire> updateAnneeScolaire(int id, AnneeScolaire annee) async {
    try {
      print(' PUT /annees-scolaires/$id');
      final data = {
        'start_year': annee.startYear,
        'end_year': annee.endYear,
        'is_active': annee.isActive,
      };

      final response = await _api.put('/annees-scolaires/$id', data);

      if (response is Map<String, dynamic>) {
        return AnneeScolaire.fromJson(response);
      } else if (response is Map) {
        final Map<String, dynamic> jsonMap = {};
        (response as Map).forEach((key, value) {
          jsonMap[key.toString()] = value;
        });
        return AnneeScolaire.fromJson(jsonMap);
      }

      throw Exception('Format inattendu après update annee');
    } catch (e) {
      print(' Erreur updateAnneeScolaire: $e');
      rethrow;
    }
  }

  // ========== MATIÈRES PAR CLASSE ==========
  Future<List<Matiere>> getMatieresByClasse(int classeId) async {
    try {
      print(' GET /matieres/classe/$classeId');
      final response = await _api.get('/matieres/classe/$classeId');

      if (response is List) {
        return _parseMatieresList(response);
      }

      if (response is Map && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          return _parseMatieresList(data);
        }
      }

      return [];
    } catch (e) {
      print(' Erreur getMatieresByClasse: $e');
      return [];
    }
  }
}