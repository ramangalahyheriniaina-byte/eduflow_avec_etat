import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/login_response.dart';

class AuthService {
  // Flutter web => localhost OK
  static const String baseUrl = 'http://localhost:3000/api/auth';

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      // ✅ Vérification body non vide
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;

        return LoginResponse.fromJson(data);
      } else {
        // ✅ Gestion erreur backend
        if (response.body.isNotEmpty) {
          final Map<String, dynamic> error =
          jsonDecode(response.body) as Map<String, dynamic>;
          throw Exception(error['message'] ?? 'Erreur login');
        } else {
          throw Exception('Erreur login (réponse vide)');
        }
      }
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }
}
