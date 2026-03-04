# Maintenance

EduFlow - Documentation des modifications pour la persistance de l'état d'initialisation

Contexte du problème : 
Problème initial : Après déconnexion et reconnexion, l'admin devait toujours repasser par les étapes d'initialisation (welcome → init → upload PDF) même si le système était déjà configuré.

Objectif : Créer un système de persistance qui détecte automatiquement si l'initialisation des cours a déjà été effectuée et redirige l'utilisateur vers la page appropriée.


=======================================
|| Architecture de la solution ||
=======================================
Backend (FastAPI)
Nouvel endpoint /setup/status qui vérifie l'existence des données

Vérification basée sur : année active + classes + matières + professeurs

Frontend (Flutter)
Nouvelle méthode checkIfSetupNeeded() dans CoursViewModel

Nouvelle méthode isSetupComplete() dans CoursService

Logique de redirection intelligente dans MainLayout

Gestion des paramètres utilisateur dans les routes





=========================================
|| Fichiers modifiés/créés
=========================================
1. Backend - Nouvel endpoint de vérification
Fichier : backend/pedagogie/app/routers/setup.py (NOUVEAU) ||

2. Modification : backend/pedagogie/app/main.py
# Ajout de l'import et du router
from app.routers import setup
app.include_router(setup.router)


===========================================
\\ . Frontend \\
==========================================
Méthodes AJOUTÉES : lib/Administrateur/pages/Cours/services/cours_service.dart 

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

// ========== ANNÉES SCOLAIRES ==========
// Méthode createAnneeScolaire déjà existante mais vérifiée
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




=Variable ajouter :lib/Administrateur/pages/Cours/view_models/cours_view_model.dart :
 bool _setupChecked = false;
bool _needsSetup = true;

bool get needsSetup => _needsSetup;
bool get setupChecked => _setupChecked;

======Methode et modifier ========:
// ========== NOUVELLE MÉTHODE : CHECK SETUP ==========
Future<bool> checkIfSetupNeeded() async {
  if (_setupChecked) return _needsSetup;

  _isLoading = true;
  notifyListeners();

  try {
    print('🔍 Vérification si configuration nécessaire...');

    final isComplete = await _coursService.isSetupComplete();

    if (isComplete) {
      print('✅ Système déjà configuré, chargement des données...');
      await loadInitialData();
      _needsSetup = false;
    } else {
      print('⚠️ Configuration requise');
      _needsSetup = true;
    }

    _setupChecked = true;
    _isLoading = false;
    notifyListeners();

    return _needsSetup;
  } catch (e) {
    print('❌ Erreur checkIfSetupNeeded: $e');
    _needsSetup = true;
    _setupChecked = true;
    _isLoading = false;
    notifyListeners();
    return true;
  }
}

// ========== RESET SETUP CHECK ==========
void resetSetupCheck() {
  _setupChecked = false;
  notifyListeners();
}

// ========== CHARGEMENT INITIAL MODIFIÉ ==========
Future<void> loadInitialData() async {
  // ... code existant ...
  
  // AJOUT : Mettre à jour needsSetup
  _needsSetup = !(_anneeScolaire != null &&
      _classes.isNotEmpty &&
      _profs.isNotEmpty);

  if (!_needsSetup) {
    print('✅ Données existantes trouvées, setup non nécessaire');
  }
  
  // ... suite du code ...
}

// ========== INITIALISATION MODIFIÉE ==========
Future<void> initialiserAnneeScolaire({
  required int startYear,
  required int endYear,
  required List<String> nomsClasses,
}) async {
  // ... code existant ...
  
  // AJOUT : Après création, setup est complété
  _needsSetup = false;
  _isInitialized = true;
  
  // ... suite du code ...
}




========================
Frontend - Layout Principal
============================
lib/Administrateur/layout/main_layout.dart :
Modification : 
class MainLayout extends StatefulWidget {
  final String userId;
  final String userName;

  const MainLayout({
    super.key,
    required this.userId,
    required this.userName,
  });
  // ...
}

class _MainLayoutState extends State<MainLayout> {
  String? _anneeEnCours;
  bool _isLoading = true;
  bool _needsInitialization = false;
  bool _needsUpload = false;
  bool _isCheckingSetup = true;  // NOUVEAU

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSetupStatus();  // MODIFIÉ : utilise la nouvelle méthode
    });
  }

  // NOUVELLE MÉTHODE : Vérification intelligente du setup
  Future<void> _checkSetupStatus() async {
    final coursVM = context.read<CoursViewModel>();

    try {
      coursVM.resetSetupCheck();
      final needsSetup = await coursVM.checkIfSetupNeeded();

      if (!mounted) return;

      if (needsSetup) {
        setState(() {
          _needsInitialization = true;
          _needsUpload = false;
          _anneeEnCours = null;
          _isLoading = false;
          _isCheckingSetup = false;
        });
      } else {
        if (!coursVM.isInitialized) {
          await coursVM.loadInitialData();
        }

        setState(() {
          _anneeEnCours = coursVM.anneeScolaire?.displayName;
          _needsInitialization = false;
          _needsUpload = false;
          _isLoading = false;
          _isCheckingSetup = false;
        });
      }
    } catch (e) {
      setState(() {
        _needsInitialization = true;
        _isLoading = false;
        _isCheckingSetup = false;
      });
    }
  }

  // ... reste du code ...
}


=========================
 Frontend - Routes Modifier
=============================
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    
    // AJOUT : Récupérer les arguments passés
    final args = settings.arguments as Map<String, String>?;
    
    switch (settings.name) {
      case AppRoutes.admin:
        return MaterialPageRoute(
          builder: (_) => MainLayout(
            userId: args?['userId'] ?? '',
            userName: args?['userName'] ?? '',
          ),
        );
      // ... autres cas similaires
    }
  }
}


======================
Frontend - Login ViewModel Modification
=====================
// Dans la méthode login()
if (role == 'admin') {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (context) => MainLayout(
        userId: user.id.toString(),
        userName: user.name.isNotEmpty ? user.name : 'Utilisateur',
      ),
    ),
  );
}
// ... autres rôles similaires


===================
Main App  modifier
+===================
class EduFlowApp extends StatelessWidget {
  const EduFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EduFlow',
      initialRoute: '/welcome',
      onGenerateRoute: AppRouter.generateRoute,  // AJOUT
      routes: {
        '/welcome': (context) => const WelcomeView(),
      },
    );
  }
}

#   G e s t i o n d - e t a t p o u r e d u f l o w s  
 #   G e s t i o n d - e t a t p o u r e d u f l o w s  
 