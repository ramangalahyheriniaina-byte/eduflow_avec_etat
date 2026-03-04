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
      print('GET /cours?skip=$skip&limit=$limit');
      Map<String, String> queryParams = {
        'skip': skip.toString(),
        'limit': limit.toString(),
      };
      if (includeRelations) {
        queryParams['include_matiere'] = 'true';
        queryParams['include_prof'] = 'true';
        queryParams['include_classe'] = 'true';
      }
      final response = await _api.get('/cours', queryParams: queryParams);
      if (response is List) {
        return _parseCoursList(response);
      }
      if (response is Map && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) return _parseCoursList(data);
      }
      if (response is Map && response.containsKey('cours')) {
        final data = response['cours'];
        if (data is List) return _parseCoursList(data);
      }
      if (response is Map && response.containsKey('items')) {
        final data = response['items'];
        if (data is List) return _parseCoursList(data);
      }
      if (response is Map && response.isEmpty) return [];
      throw Exception('Format de réponse inattendu pour /cours');
    } catch (e) {
      print('Erreur getAllCours: $e');
      rethrow;
    }
  }

  List<Cours> _parseCoursList(dynamic list) {
    final List<Cours> coursList = [];
    if (list is List) {
      for (var item in list) {
        try {
          if (item is Map<String, dynamic>) {
            coursList.add(Cours.fromJson(item));
          } else if (item is Map) {
            final Map<String, dynamic> jsonMap = {};
            (item as Map).forEach((key, value) {
              jsonMap[key.toString()] = value;
            });
            coursList.add(Cours.fromJson(jsonMap));
          }
        } catch (e) {
          print('Skipping invalid cours item: $e');
        }
      }
    }
    return coursList;
  }

  Future<Cours> getCoursById(int id) async {
    try {
      final response = await _api.get('/cours/$id');
      if (response is Map<String, dynamic>) return Cours.fromJson(response);
      if (response is Map) {
        final Map<String, dynamic> jsonMap = {};
        (response as Map).forEach((key, value) {
          jsonMap[key.toString()] = value;
        });
        return Cours.fromJson(jsonMap);
      }
      throw Exception('Format inattendu pour cours by id');
    } catch (e) {
      print('Erreur getCoursById: $e');
      rethrow;
    }
  }

  Future<List<Cours>> getCoursByProf(int profId) async {
    try {
      final response = await _api.get('/cours/professeur/$profId');
      if (response is List) return _parseCoursList(response);
      throw Exception('Format inattendu pour cours par prof');
    } catch (e) {
      print('Erreur getCoursByProf: $e');
      rethrow;
    }
  }

  Future<List<Cours>> getCoursByMatiere(int matiereId) async {
    try {
      final response = await _api.get('/cours/matiere/$matiereId');
      if (response is List) return _parseCoursList(response);
      throw Exception('Format inattendu pour cours par matiere');
    } catch (e) {
      print('Erreur getCoursByMatiere: $e');
      rethrow;
    }
  }

  Future<Cours> createCours(Cours cours) async {
    try {
      final data = {
        'id_matiere': cours.idMatiere,
        'id_prof': cours.idProf,
        'statut': cours.statut?.value ?? 'non_commence',
        'cumul': cours.cumul ?? 0,
      };
      final response = await _api.post('/cours', data);
      if (response is Map<String, dynamic>) return Cours.fromJson(response);
      if (response is Map) {
        final Map<String, dynamic> jsonMap = {};
        (response as Map).forEach((key, value) {
          jsonMap[key.toString()] = value;
        });
        return Cours.fromJson(jsonMap);
      }
      throw Exception('Format inattendu après création');
    } catch (e) {
      print('Erreur createCours: $e');
      rethrow;
    }
  }

  Future<Cours> updateCours(int id, Cours cours) async {
    try {
      final data = <String, dynamic>{};
      if (cours.statut != null) data['statut'] = cours.statut!.value;
      if (cours.idMatiere != null) data['id_matiere'] = cours.idMatiere;
      if (cours.idProf != null) data['id_prof'] = cours.idProf;
      if (cours.cumul != null) data['cumul'] = cours.cumul;
      final response = await _api.put('/cours/$id', data);
      if (response is Map<String, dynamic>) return Cours.fromJson(response);
      if (response is Map) {
        final Map<String, dynamic> jsonMap = {};
        (response as Map).forEach((key, value) {
          jsonMap[key.toString()] = value;
        });
        return Cours.fromJson(jsonMap);
      }
      throw Exception('Format inattendu après update');
    } catch (e) {
      print('Erreur updateCours: $e');
      rethrow;
    }
  }

  Future<void> deleteCours(int id) async {
    try {
      await _api.delete('/cours/$id');
    } catch (e) {
      print('Erreur deleteCours: $e');
      rethrow;
    }
  }

  Future<Cours> updateCumul(int coursId, int heures) async {
    try {
      final response = await _api.patch('/cours/$coursId/cumul', {'heures': heures});
      if (response is Map<String, dynamic>) return Cours.fromJson(response);
      if (response is Map) {
        final Map<String, dynamic> jsonMap = {};
        (response as Map).forEach((key, value) {
          jsonMap[key.toString()] = value;
        });
        return Cours.fromJson(jsonMap);
      }
      throw Exception('Format inattendu après update cumul');
    } catch (e) {
      print('Erreur updateCumul: $e');
      rethrow;
    }
  }

  // ========== MATIÈRES ==========
  Future<List<Matiere>> getAllMatieres({int skip = 0, int limit = 100}) async {
    try {
      final response = await _api.get('/matieres', queryParams: {
        'skip': skip.toString(),
        'limit': limit.toString(),
      });
      if (response is List) return _parseMatieresList(response);
      if (response is Map && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) return _parseMatieresList(data);
      }
      return [];
    } catch (e) {
      print('Erreur getAllMatieres: $e');
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
        } catch (_) {}
      }
    }
    return matieres;
  }

  Future<Matiere> getMatiereById(int id) async {
    try {
      final response = await _api.get('/matieres/$id');
      if (response is Map<String, dynamic>) return Matiere.fromJson(response);
      if (response is Map) {
        final Map<String, dynamic> jsonMap = {};
        (response as Map).forEach((key, value) {
          jsonMap[key.toString()] = value;
        });
        return Matiere.fromJson(jsonMap);
      }
      throw Exception('Format inattendu pour matiere by id');
    } catch (e) {
      print('Erreur getMatiereById: $e');
      rethrow;
    }
  }

  Future<Matiere> createMatiere(Matiere matiere) async {
    try {
      final data = {
        'nom_matiere': matiere.nomMatiere,
        'heure_totale': matiere.heureTotale,
        'id_classe': matiere.idClasse,
      };
      final response = await _api.post('/matieres', data);
      if (response is Map<String, dynamic>) return Matiere.fromJson(response);
      if (response is Map) {
        final Map<String, dynamic> jsonMap = {};
        (response as Map).forEach((key, value) {
          jsonMap[key.toString()] = value;
        });
        return Matiere.fromJson(jsonMap);
      }
      throw Exception('Format inattendu après création matiere');
    } catch (e) {
      print('Erreur createMatiere: $e');
      rethrow;
    }
  }

  Future<List<Matiere>> getMatieresByClasse(int classeId) async {
    try {
      final response = await _api.get('/matieres/classe/$classeId');
      if (response is List) return _parseMatieresList(response);
      if (response is Map && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) return _parseMatieresList(data);
      }
      return [];
    } catch (e) {
      print('Erreur getMatieresByClasse: $e');
      return [];
    }
  }

  // ========== PROFS ==========
  Future<List<Prof>> getAllProfs({int skip = 0, int limit = 100}) async {
    try {
      final response = await _api.get('/professeurs', queryParams: {
        'skip': skip.toString(),
        'limit': limit.toString(),
      });
      if (response is List) return _parseProfsList(response);
      if (response is Map && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) return _parseProfsList(data);
      }
      return [];
    } catch (e) {
      print('Erreur getAllProfs: $e');
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
        } catch (_) {}
      }
    }
    return profs;
  }

  Future<Prof> getProfById(int id) async {
    try {
      final response = await _api.get('/professeurs/$id');
      if (response is Map<String, dynamic>) return Prof.fromJson(response);
      if (response is Map) {
        final Map<String, dynamic> jsonMap = {};
        (response as Map).forEach((key, value) {
          jsonMap[key.toString()] = value;
        });
        return Prof.fromJson(jsonMap);
      }
      throw Exception('Format inattendu pour prof by id');
    } catch (e) {
      print('Erreur getProfById: $e');
      rethrow;
    }
  }

  Future<Prof> createProf(Prof prof) async {
    try {
      final data = {
        'nom_prof': prof.nomProf,
        'nb_abs': prof.nbAbs ?? 0,
      };
      final response = await _api.post('/professeurs', data);
      if (response is Map<String, dynamic>) return Prof.fromJson(response);
      if (response is Map) {
        final Map<String, dynamic> jsonMap = {};
        (response as Map).forEach((key, value) {
          jsonMap[key.toString()] = value;
        });
        return Prof.fromJson(jsonMap);
      }
      throw Exception('Format inattendu après création prof');
    } catch (e) {
      print('Erreur createProf: $e');
      rethrow;
    }
  }

  Future<void> deleteProf(int id) async {
    try {
      await _api.delete('/professeurs/$id');
    } catch (e) {
      print('Erreur deleteProf: $e');
      rethrow;
    }
  }

  Future<Prof> updateProf(int id, Prof prof) async {
    try {
      final data = {
        'nom_prof': prof.nomProf,
        'nb_abs': prof.nbAbs ?? 0,
      };
      final response = await _api.put('/professeurs/$id', data);
      if (response is Map<String, dynamic>) return Prof.fromJson(response);
      if (response is Map) {
        final Map<String, dynamic> jsonMap = {};
        (response as Map).forEach((key, value) {
          jsonMap[key.toString()] = value;
        });
        return Prof.fromJson(jsonMap);
      }
      throw Exception('Format inattendu après update prof');
    } catch (e) {
      print('Erreur updateProf: $e');
      rethrow;
    }
  }

  // ========== CLASSES ==========
  Future<List<Classe>> getAllClasses({int skip = 0, int limit = 100}) async {
    try {
      final response = await _api.get('/classes', queryParams: {
        'skip': skip.toString(),
        'limit': limit.toString(),
      });
      List<Classe> classes = [];
      if (response is List) {
        classes = _parseClassesList(response);
      } else if (response is Map && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) classes = _parseClassesList(data);
      }
      for (var classe in classes) {
        try {
          final matieres = await getMatieresByClasse(classe.idClasse!);
          classe.matieres = matieres;
        } catch (e) {
          print('Erreur chargement matières pour ${classe.nomClasse}: $e');
        }
      }
      return classes;
    } catch (e) {
      print('Erreur getAllClasses: $e');
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
        } catch (_) {}
      }
    }
    return classes;
  }

  Future<Classe> getClasseById(int id) async {
    try {
      final response = await _api.get('/classes/$id');
      if (response is Map<String, dynamic>) return Classe.fromJson(response);
      if (response is Map) {
        final Map<String, dynamic> jsonMap = {};
        (response as Map).forEach((key, value) {
          jsonMap[key.toString()] = value;
        });
        return Classe.fromJson(jsonMap);
      }
      throw Exception('Format inattendu pour classe by id');
    } catch (e) {
      print('Erreur getClasseById: $e');
      rethrow;
    }
  }

  Future<Classe> createClasse(Classe classe) async {
    try {
      final data = {
        'nom_classe': classe.nomClasse,
      };
      final response = await _api.post('/classes', data);
      if (response is Map<String, dynamic>) return Classe.fromJson(response);
      if (response is Map) {
        final Map<String, dynamic> jsonMap = {};
        (response as Map).forEach((key, value) {
          jsonMap[key.toString()] = value;
        });
        return Classe.fromJson(jsonMap);
      }
      throw Exception('Format inattendu après création classe');
    } catch (e) {
      print('Erreur createClasse: $e');
      rethrow;
    }
  }

  // ========== ANNÉES SCOLAIRES ==========
  Future<List<AnneeScolaire>> getAllAnneeScolaires({int skip = 0, int limit = 100}) async {
    try {
      final response = await _api.get('/annees-scolaires', queryParams: {
        'skip': skip.toString(),
        'limit': limit.toString(),
      });
      if (response is List) return _parseAnneeScolairesList(response);
      if (response is Map && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) return _parseAnneeScolairesList(data);
      }
      return [];
    } catch (e) {
      print('Erreur getAllAnneeScolaires: $e');
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
        } catch (_) {}
      }
    }
    return annees;
  }

  Future<AnneeScolaire> getAnneeScolaireById(int id) async {
    try {
      final response = await _api.get('/annees-scolaires/$id');
      if (response is Map<String, dynamic>) return AnneeScolaire.fromJson(response);
      if (response is Map) {
        final Map<String, dynamic> jsonMap = {};
        (response as Map).forEach((key, value) {
          jsonMap[key.toString()] = value;
        });
        return AnneeScolaire.fromJson(jsonMap);
      }
      throw Exception('Format inattendu pour année scolaire by id');
    } catch (e) {
      print('Erreur getAnneeScolaireById: $e');
      rethrow;
    }
  }

  Future<AnneeScolaire> createAnneeScolaire(AnneeScolaire annee) async {
    try {
      print('POST /annees-scolaires');
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
      print('Erreur createAnneeScolaire: $e');
      rethrow;
    }
  }

  // ========== SETUP STATUS ==========
  Future<bool> isSetupComplete() async {
    try {
      print('Vérification statut initialisation...');
      final response = await _api.get('/setup/status');

      if (response is Map<String, dynamic>) {
        return response['is_initialized'] == true;
      } else if (response is Map) {
        final Map<String, dynamic> jsonMap = {};
        (response as Map).forEach((key, value) {
          jsonMap[key.toString()] = value;
        });
        return jsonMap['is_initialized'] == true;
      }

      return false;
    } catch (e) {
      print('Erreur isSetupComplete: $e');
      return false;
    }
  }
}