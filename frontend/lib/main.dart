import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Administrateur/core/navigation_view_model.dart';
import 'Administrateur/layout/main_layout.dart';
import 'Administrateur/pages/Cours/view_models/cours_view_model.dart';
import 'Administrateur/pages/Dashboard/view_model/dashboard_view_model.dart';
import 'Administrateur/pages/edt/view_model/edt_view_model.dart';

import 'auth/view/login.dart';
import 'auth/view/welcome_view.dart';
import 'auth/view_model/login_view_model.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationViewModel()),
        ChangeNotifierProvider(create: (_) => CoursViewModel()),
        ChangeNotifierProvider(create: (_) => EdtViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
      ],
      child: const EduFlowApp(),
    ),
  );
}

class EduFlowApp extends StatelessWidget {
  const EduFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EduFlow',
      initialRoute: '/welcome',

      // Utilisation de onGenerateRoute pour gérer les paramètres
      onGenerateRoute: (settings) {
        // Route welcome
        if (settings.name == '/welcome') {
          return MaterialPageRoute(
            builder: (context) => const WelcomeView(),
          );
        }

        // Route login
        if (settings.name == '/') {
          return MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          );
        }

        // Routes admin avec paramètres
        if (settings.name == '/admin' ||
            settings.name == '/prof/home' ||
            settings.name == '/etudiant/home') {

          // Récupérer les arguments passés
          final args = settings.arguments as Map<String, String>?;

          return MaterialPageRoute(
            builder: (context) => MainLayout(
              userId: args?['userId'] ?? '',
              userName: args?['userName'] ?? '',
            ),
          );
        }

        // Route par défaut
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text('Route non trouvée'),
            ),
          ),
        );
      },

      // Garder routes pour la compatibilité
      routes: {
        '/welcome': (context) => const WelcomeView(),
        '/': (context) => const LoginScreen(),
      },
    );
  }
}