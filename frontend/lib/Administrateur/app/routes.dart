import 'package:flutter/material.dart';
import 'package:apk_web_eduflow/auth/view/login.dart';
import '../layout/main_layout.dart';

// ===============================
/// NOMS DES ROUTES (App globale)
// ===============================
class AppRoutes {
  // Authentification
  static const String login = '/';
  static const String logout = '/logout';

  // Admin (Layout unique)
  static const String admin = '/admin';

  // Prof 
  static const String profHome = '/prof/home';

  // Étudiant 
  static const String etudiantHome = '/etudiant/home';
}

// ===============================
/// ROUTER CENTRAL (Navigation globale)
// ===============================
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {

    // Récupérer les arguments passés
    final args = settings.arguments as Map<String, String>?;

    switch (settings.name) {

    // =====================
    /// AUTH
    // =====================
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

    // =====================
    /// ADMIN
    // =====================
      case AppRoutes.admin:
        return MaterialPageRoute(
          builder: (_) => MainLayout(
            userId: args?['userId'] ?? '',
            userName: args?['userName'] ?? '',
          ),
        );

    // =====================
    /// PROF
    // =====================
      case AppRoutes.profHome:
        return MaterialPageRoute(
          builder: (_) => MainLayout(
            userId: args?['userId'] ?? '',
            userName: args?['userName'] ?? '',
          ),
        );

    // =====================
    /// ETUDIANT
    // =====================
      case AppRoutes.etudiantHome:
        return MaterialPageRoute(
          builder: (_) => MainLayout(
            userId: args?['userId'] ?? '',
            userName: args?['userName'] ?? '',
          ),
        );

    // =====================
    /// DEFAULT
    // =====================
      default:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
    }
  }
}

// ===============================
/// Routes internes au MainLayout
// ===============================
class Routes {
  static const String cours = 'cours';
  static const String programme = 'edt';
  static const String dashboard = 'dashboard';
  static const String logout = '/logout';
}