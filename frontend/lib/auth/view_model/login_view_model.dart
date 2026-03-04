import 'package:flutter/material.dart';

import '../models/login_response.dart';
import '../services/auth_service.dart';
import 'package:apk_web_eduflow/Administrateur/app/routes.dart';
import 'package:apk_web_eduflow/Administrateur/layout/main_layout.dart';
import 'package:apk_web_eduflow/core/services/api_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;
  String? errorMessage;
  LoginResponse? loginResponse;

  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      loginResponse = await _authService.login(
        email: email,
        password: password,
      );

      if (loginResponse != null && loginResponse!.token.isNotEmpty) {
        ApiService().setToken(loginResponse!.token);
        print('Token JWT enregistré pour les appels API');
      } else {
        print('Aucun token reçu du backend login');
      }

      if (loginResponse == null || loginResponse!.user == null) {
        throw Exception("Réponse login invalide");
      }

      final user = loginResponse!.user!;
      final role = user.role;

      await Future.delayed(const Duration(milliseconds: 100));

      // CORRECTION: Utiliser name au lieu de username
      final userName = user.name.isNotEmpty ? user.name : 'Utilisateur';

      if (role == 'admin') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainLayout(
              userId: user.id.toString(),
              userName: userName,
            ),
          ),
        );
      } else if (role == 'prof') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainLayout(
              userId: user.id.toString(),
              userName: userName,
            ),
          ),
        );
      } else if (role == 'etudiant') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainLayout(
              userId: user.id.toString(),
              userName: userName,
            ),
          ),
        );
      } else {
        throw Exception("Rôle utilisateur inconnu: $role");
      }
    } catch (e) {
      errorMessage = e.toString();
      print('Login error in ViewModel: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    loginResponse = null;
    errorMessage = null;
    notifyListeners();
  }

  bool get isLoggedIn => loginResponse != null && loginResponse!.user != null;

  String? get currentUserRole => loginResponse?.user?.role;

  String? get currentUserName => loginResponse?.user?.name;

  String? get currentUserToken => loginResponse?.token;
}

