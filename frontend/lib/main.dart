import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Administrateur/core/navigation_view_model.dart';
import 'Administrateur/layout/main_layout.dart';
import 'Administrateur/pages/Cours/view_models/cours_view_model.dart';
import 'Administrateur/pages/Dashboard/view_model/dashboard_view_model.dart';
import 'Administrateur/pages/edt/view_model/edt_view_model.dart';

import 'auth/view/login.dart';
import 'auth/view/welcome_view.dart'; // NOUVEAU : Import de la page d'accueil
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

      // Routes
      initialRoute: '/welcome', // MODIFIÉ : La route initiale devient '/welcome'
      routes: {
        '/welcome': (context) => const WelcomeView(), // NOUVEAU : Page d'accueil
        '/': (context) => const LoginScreen(), // MODIFIÉ : Route '/login' au lieu de '/'
        '/admin': (context) => MainLayout(),
        '/prof/home': (context) => MainLayout(),
        '/etudiant/home': (context) => MainLayout(),
      },
    );
  }
}