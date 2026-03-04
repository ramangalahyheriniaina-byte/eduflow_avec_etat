// frontend/lib/core/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Configuration
  static const String baseUrl = 'http://localhost:8000'; // FastAPI pédagogie
  static const String apiVersion = '/api/v1';

  // Stockage du token (vous pouvez adapter avec SharedPreferences si besoin)
  String? _token;

  // Méthode pour définir le token après login
  void setToken(String token) {
    _token = token;
    if (kDebugMode) {
      print('Token défini pour API: ${_token?.substring(0, 20)}...');
    }
  }

  // Méthode pour récupérer le token depuis LoginViewModel
  void setTokenFromLogin(String? token) {
    if (token != null) {
      _token = token;
    }
  }

  // Clear token (logout)
  void clearToken() {
    _token = null;
  }

  // Headers avec token JWT
  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  // Méthodes HTTP génériques
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    try {
      Uri uri = Uri.parse('$baseUrl$apiVersion$endpoint');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams.map((key, value) => MapEntry(key, value.toString())));
      }

      final response = await http.get(uri, headers: _getHeaders());

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erreur GET $endpoint: $e');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      // ⚠️ AJOUTEZ CES LIGNES DE DEBUG
      final fullUrl = '$baseUrl$apiVersion$endpoint';
      print('🌐 POST URL construite: $fullUrl');
      print('📦 POST Data: $data');
      print('🔍 Endpoint reçu: "$endpoint"');

      // Vérifiez que endpoint ne contient pas :1
      if (endpoint.contains(':')) {
        print('⚠️ ATTENTION: endpoint contient ":" -> $endpoint');
      }

      final response = await http.post(
        Uri.parse(fullUrl),
        headers: _getHeaders(),
        body: jsonEncode(data),
      );

      print('📡 POST Response Status: ${response.statusCode}');
      print('📡 POST Response Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ POST Error: $e');
      throw Exception('Erreur POST $endpoint: $e');
    }
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$apiVersion$endpoint'),
        headers: _getHeaders(),
        body: jsonEncode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erreur PUT $endpoint: $e');
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$apiVersion$endpoint'),
        headers: _getHeaders(),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erreur DELETE $endpoint: $e');
    }
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic> data) async {
  try {
    // ⭐ AJOUTE CES 3 LIGNES DE LOG
    final fullUrl = '$baseUrl$apiVersion$endpoint';
    print('🌐 PATCH URL construite: $fullUrl');
    print('📦 PATCH Data: $data');

    final response = await http.patch(
      Uri.parse(fullUrl),
      headers: _getHeaders(),
      body: jsonEncode(data),
    );

    print('📡 PATCH Response Status: ${response.statusCode}');
    
    return _handleResponse(response);
  } catch (e) {
    print('❌ PATCH Error: $e');
    throw Exception('Erreur PATCH $endpoint: $e');
  }
}
  // Gestion des réponses
  // Dans frontend/lib/core/services/api_service.dart
  dynamic _handleResponse(http.Response response) {
  print('📡 Status: ${response.statusCode}');
  
  if (response.statusCode >= 200 && response.statusCode < 300) {
    if (response.body.isEmpty) {
      print('✅ Empty response body');
      return {};
    }

    try {
      final decoded = jsonDecode(response.body);
      print('📦 Decoded type: ${decoded.runtimeType}');
      
      // ⚠️ CORRECTION : Si c'est déjà une List, retourner directement
      if (decoded is List) {
        print('✅ Response is a List');
        return decoded;
      }
      
      // Sinon retourner tel quel
      return decoded;
      
    } catch (e) {
      print('❌ JSON decode error: $e');
      throw Exception('Erreur de parsing JSON: $e');
    }
    
  } else if (response.statusCode == 401) {
    throw Exception('Non autorisé - Token invalide ou expiré');
  } else if (response.statusCode == 404) {
    throw Exception('Ressource non trouvée');
  } else {
    print('❌ Error response: ${response.body}');
    try {
      final error = jsonDecode(response.body);
      if (error is Map && error.containsKey('detail')) {
        throw Exception(error['detail']);
      }
      throw Exception('Erreur ${response.statusCode}: $error');
    } catch (_) {
      throw Exception('Erreur ${response.statusCode}: ${response.body}');
    }
  }
}
}