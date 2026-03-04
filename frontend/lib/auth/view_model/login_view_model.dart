import 'package:flutter/material.dart';

import '../models/login_response.dart';
import '../services/auth_service.dart';
import 'package:apk_web_eduflow/Administrateur/app/routes.dart';
// AJOUTEZ CET IMPORT
import 'package:apk_web_eduflow/Administrateur/layout/main_layout.dart';
// AJOUTEZ CETTE LIGNE APRÈS LES AUTRES IMPORTS
import 'package:apk_web_eduflow/core/services/api_service.dart';

/// ===============================
/// LoginViewModel
/// - appelle le backend
/// - gère le loading / erreur
/// - stocke la réponse login
/// - redirige selon le rôle
/// ===============================
class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;
  String? errorMessage;
  LoginResponse? loginResponse;

  /// LOGIN PRINCIPAL
  /// LOGIN PRINCIPAL
  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Appel backend
      loginResponse = await _authService.login(
        email: email,
        password: password,
      );

      // ✅ AJOUTEZ CES 4 LIGNES : Stocker le token JWT
      if (loginResponse != null && loginResponse!.token.isNotEmpty) {
        ApiService().setToken(loginResponse!.token);
        print('✅ Token JWT enregistré pour les appels API');
      } else {
        print('⚠️ Aucun token reçu du backend login');
      }

      // Vérification sécurité
      if (loginResponse == null || loginResponse!.user == null) {
        throw Exception("Réponse login invalide");
      }

      final user = loginResponse!.user!;
      final role = user.role;

      // Petite pause pour l'UI
      await Future.delayed(const Duration(milliseconds: 100));

      // CORRECTION : Utilisez pushReplacementNamed au lieu de MaterialPageRoute
      // REDIRECTION SELON ROLE
      if (role == 'admin') {
        Navigator.of(context).pushReplacementNamed(AppRoutes.admin);
      } else if (role == 'prof') {
        Navigator.of(context).pushReplacementNamed(AppRoutes.profHome);
      } else if (role == 'etudiant') {
        Navigator.of(context).pushReplacementNamed(AppRoutes.etudiantHome);
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

  /// Méthode pour déconnexion
  void logout() {
    // AJOUTEZ CETTE LIGNE : Effacer le token
   // ApiService().clearToken();
    loginResponse = null;
    errorMessage = null;
    notifyListeners();
  }

  /// Vérifie si l'utilisateur est connecté
  bool get isLoggedIn => loginResponse != null && loginResponse!.user != null;

  /// Récupère le rôle de l'utilisateur connecté
  String? get currentUserRole => loginResponse?.user?.role;

  /// Récupère le nom de l'utilisateur connecté
  String? get currentUserName => loginResponse?.user?.name;

  /// Récupère le token d'authentification
  String? get currentUserToken => loginResponse?.token;
}


