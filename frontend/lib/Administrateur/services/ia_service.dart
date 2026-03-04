// lib/Administrateur/services/ia_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class IAService {
  // Utilisez l'IP 
  static const String baseUrl = 'http://192.168.88.239:5000';

  // Timeout plus long pour l'analyse PDF
  static const int timeoutSeconds = 120;

  /// Vérifie si le serveur IA est accessible
  Future<bool> checkHealth() async {
    try {
      print(' Vérification santé serveur IA...');

      // CORRECTION: Utiliser withTimeout au lieu de timeout param
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
      ).timeout(const Duration(seconds: 5));

      final ok = response.statusCode == 200;
      if (ok) {
        print('Serveur IA accessible');
      } else {
        print('Serveur IA répond mais avec code ${response.statusCode}');
      }
      return ok;

    } catch (e) {
      print(' Serveur IA inaccessible: $e');
      return false;
    }
  }

  /// Envoie le PDF à l'IA et récupère les matières filtrées
  Future<List<Map<String, dynamic>>> analyserPdf(Uint8List pdfBytes) async {
    try {
      print(' Envoi du PDF à l\'IA (${pdfBytes.length} octets)...');

      // Créer la requête multipart
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));

      // Ajouter le fichier PDF
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        pdfBytes,
        filename: 'programme_${DateTime.now().millisecondsSinceEpoch}.pdf',
      ));

      // CORRECTION: Utiliser send() avec timeout
      final streamedResponse = await request.send().timeout(
        Duration(seconds: timeoutSeconds),
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);

        // CORRECTION: Vérifier le type correctement
        if (jsonData is List) {
          print('IA a retourné ${jsonData.length} matières');

          // Afficher un aperçu
          for (var i = 0; i < jsonData.length && i < 3; i++) {
            final item = jsonData[i] as Map<String, dynamic>;
            print('   - ${item['nom_matiere']}: ${item['total_hours']}h');
          }
          if (jsonData.length > 3) {
            print('   - ... et ${jsonData.length - 3} autres');
          }

          return List<Map<String, dynamic>>.from(jsonData);
        } else {
          print(' Format de réponse inattendu: ${jsonData.runtimeType}');
          throw Exception('Format de réponse invalide');
        }

      } else {
        String errorBody = response.body;
        print(' Erreur IA ${response.statusCode}: $errorBody');

        // Essayer de parser l'erreur
        try {
          final errorJson = json.decode(errorBody);
          if (errorJson is Map && errorJson.containsKey('error')) {
            throw Exception(errorJson['error']);
          }
        } catch (_) {}

        throw Exception('Erreur IA: ${response.statusCode}');
      }

    } catch (e) {
      print(' Erreur communication IA: $e');
      rethrow;
    }
  }

  /// Version debug qui retourne plus d'informations
  Future<Map<String, dynamic>> analyserPdfDebug(Uint8List pdfBytes) async {
    try {
      print(' [DEBUG] Envoi du PDF à l\'IA...');

      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/debug'));
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        pdfBytes,
        filename: 'debug_${DateTime.now().millisecondsSinceEpoch}.pdf',
      ));

      final streamedResponse = await request.send().timeout(
        Duration(seconds: timeoutSeconds),
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);
        print(' [DEBUG] Réponse IA reçue');

        // CORRECTION: Retourner le bon type
        if (jsonData is Map) {
          // Convertir Map<dynamic, dynamic> en Map<String, dynamic>
          return Map<String, dynamic>.from(jsonData);
        } else if (jsonData is List) {
          // Si c'est une liste, l'emballer dans un Map
          return {
            'matieres': jsonData,
            'count': jsonData.length,
          };
        } else {
          return {'data': jsonData};
        }
      } else {
        throw Exception('Erreur IA: ${response.statusCode}');
      }

    } catch (e) {
      print(' Erreur debug IA: $e');
      rethrow;
    }
  }

  /// Méthode utilitaire pour tester la connexion
  Future<Map<String, dynamic>> testConnexion() async {
    try {
      final health = await checkHealth();

      if (health) {
        return {
          'status': 'ok',
          'message': 'Connecté au serveur IA',
          'url': baseUrl,
        };
      } else {
        return {
          'status': 'error',
          'message': 'Serveur IA injoignable',
          'url': baseUrl,
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Erreur: $e',
        'url': baseUrl,
      };
    }
  }
}