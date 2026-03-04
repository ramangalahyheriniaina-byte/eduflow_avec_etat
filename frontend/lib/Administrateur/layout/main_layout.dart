import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/navigation_view_model.dart';
import '../app/routes.dart';

import '../pages/Cours/view/cours_init_view.dart';
import '../pages/Cours/view/cours_list_view.dart';
import '../pages/Cours/view/upload_pdf.dart';
import '../pages/edt/view/edt_view.dart';
import '../pages/Dashboard/view/dashboard_view.dart';

import '../pages/Cours/view_models/cours_view_model.dart';
import '../pages/edt/view_model/edt_view_model.dart';
import '../pages/Dashboard/view_model/dashboard_view_model.dart';
import '../../../auth/view/login.dart';

class MainLayout extends StatefulWidget {
  final String userId;
  final String userName;

  const MainLayout({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  String? _anneeEnCours;
  bool _isLoading = true;
  bool _needsInitialization = false;
  bool _needsUpload = false;
  bool _isCheckingSetup = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSetupStatus();
    });
  }

  // Force la mise à jour de la navigation
  void _forceNavigationRefresh() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  // Vérification intelligente du setup
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
        print('Système non configuré, redirection vers initialisation');
      } else {
        if (!coursVM.isInitialized) {
          await coursVM.loadInitialData();
        }

        if (!mounted) return;

        setState(() {
          _anneeEnCours = coursVM.anneeScolaire?.displayName;
          _needsInitialization = false;
          _needsUpload = false;
          _isLoading = false;
          _isCheckingSetup = false;
        });

        _forceNavigationRefresh();
        print('Système déjà configuré, affichage du dashboard');
      }
    } catch (e) {
      print('Erreur vérification setup: $e');
      if (!mounted) return;

      setState(() {
        _needsInitialization = true;
        _isLoading = false;
        _isCheckingSetup = false;
      });
    }
  }

  void _onInitializationComplete() {
    setState(() {
      _needsInitialization = false;
      _needsUpload = true;
    });
    _forceNavigationRefresh();
  }

  void _onUploadComplete() {
    final coursVM = context.read<CoursViewModel>();
    final navVM = context.read<NavigationViewModel>(); // AJOUT

    setState(() {
      _needsUpload = false;
      _anneeEnCours = coursVM.anneeScolaire?.displayName;
    });

    // FORCER LA NAVIGATION VERS LA LISTE DES COURS
    navVM.setCurrentRoute(Routes.cours);

    _forceNavigationRefresh();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuration terminée avec succès!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Se déconnecter', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _performLogout();
    }
  }

  void _performLogout() {
    final coursVM = context.read<CoursViewModel>();
    coursVM.reset();
    coursVM.resetSetupCheck();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Écran de chargement
    if (_isLoading || _isCheckingSetup) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF629EB9)),
              ),
              const SizedBox(height: 24),
              Text(
                _isCheckingSetup ? 'Vérification de la configuration...' : 'Chargement...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final navVM = context.watch<NavigationViewModel>();
    final coursVM = context.watch<CoursViewModel>();
    final edtVM = context.watch<EdtViewModel>();
    final dashboardVM = context.watch<DashboardViewModel>();

    // Mise à jour des données
    dashboardVM.updateSeancesList(edtVM.seances);
    dashboardVM.updateCoursList(coursVM.cours);

    // Mise à jour des flags de navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (edtVM.seances.isNotEmpty) {
        navVM.markEdtExists(true);
      }
      if (coursVM.cours.isNotEmpty) {
        navVM.markCoursExists(true);
      }
    });

    // ========== SOLUTION : DÉTERMINATION DU CONTENU À AFFICHER ==========
    Widget content;

    if (_needsInitialization) {
      print('📋 Affichage: Initialisation');
      content = CoursInitView(onComplete: _onInitializationComplete);
    } else if (_needsUpload) {
      print('📤 Affichage: Upload PDF');
      content = UploadProgrammeView(onComplete: _onUploadComplete);
    } else {
      print('🖥️ Navigation normale - Route: ${navVM.currentRoute}');

      switch (navVM.currentRoute) {
        case Routes.programme:
          content = EdtView();
          break;
        case Routes.dashboard:
          content = const DashboardView();
          break;
        case Routes.cours:
        // SOLUTION SIMPLE : TOUJOURS ALLER VERS LISTE VIEW
          print('📋 Navigation vers CoursListView');
          content = const CoursListView();
          break;
        default:
          content = const DashboardView();
      }
    }

    return Scaffold(
      body: Row(
        children: [
          SidebarWithYear(
            anneeEnCours: _anneeEnCours,
            userName: widget.userName,
            userId: widget.userId,
            onLogout: () => _showLogoutDialog(context),
            needsInitialization: _needsInitialization || _needsUpload,
          ),
          Expanded(child: content),
        ],
      ),
    );
  }
}

// ========== Sidebar améliorée ==========
class SidebarWithYear extends StatelessWidget {
  final String? anneeEnCours;
  final String userName;
  final String userId;
  final VoidCallback onLogout;
  final bool needsInitialization;

  const SidebarWithYear({
    super.key,
    this.anneeEnCours,
    required this.userName,
    required this.userId,
    required this.onLogout,
    this.needsInitialization = false,
  });

  @override
  Widget build(BuildContext context) {
    final navVM = context.watch<NavigationViewModel>();
    final coursVM = context.watch<CoursViewModel>();

    return Container(
      width: 280,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F3057), Color(0xFF1B6B75)],
        ),
      ),
      child: Column(
        children: [
          // Header avec infos utilisateur
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: 1.25,
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 180,
                    height: 170,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.school_rounded, size: 80, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'EduFlow',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Admin: $userName',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.8),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: $userId',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
                if (anneeEnCours != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.white.withOpacity(0.9)),
                        const SizedBox(width: 6),
                        Text(
                          anneeEnCours!,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.95)),
                        ),
                      ],
                    ),
                  ),
                ],

                // Indicateur de statut de configuration
                if (needsInitialization) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange.withOpacity(0.5), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.settings, size: 14, color: Colors.orange),
                        SizedBox(width: 6),
                        Text(
                          'Configuration requise',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.orange),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Séparateur
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.white.withOpacity(0.3), Colors.transparent],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Menu items
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    title: 'Cours',
                    icon: Icons.book_rounded,
                    route: Routes.cours,
                    navVM: navVM,
                    isEnabled: !needsInitialization,
                    disabledTooltip: "Terminez d'abord la configuration",
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    context,
                    title: 'Emploi du temps',
                    icon: Icons.calendar_month_rounded,
                    route: Routes.programme,
                    navVM: navVM,
                    isEnabled: !needsInitialization && coursVM.cours.isNotEmpty,
                    disabledTooltip: "Créez d'abord des cours",
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    context,
                    title: 'Dashboard',
                    icon: Icons.dashboard_rounded,
                    route: Routes.dashboard,
                    navVM: navVM,
                    isEnabled: true,
                  ),
                ],
              ),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: const Color(0xFF22C55E).withOpacity(0.5), blurRadius: 8, spreadRadius: 2)],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          needsInitialization ? 'Configuration en cours...' : 'System Online',
                          style: TextStyle(
                            color: needsInitialization ? Colors.orange : Colors.white.withOpacity(0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildMenuItem(
                  context,
                  title: 'Déconnexion',
                  icon: Icons.logout_rounded,
                  route: Routes.logout,
                  navVM: navVM,
                  isEnabled: true,
                  isDanger: true,
                  customOnTap: onLogout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, {
        required String title,
        required IconData icon,
        required String route,
        required NavigationViewModel navVM,
        required bool isEnabled,
        String disabledTooltip = "",
        bool isDanger = false,
        VoidCallback? customOnTap,
      }) {
    final isActive = navVM.currentRoute == route && isEnabled;

    return Tooltip(
      message: isEnabled ? "" : disabledTooltip,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withOpacity(0.2)
              : (isEnabled ? Colors.transparent : Colors.white.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isActive ? Colors.white.withOpacity(0.3) : Colors.transparent, width: 1.5),
          boxShadow: isActive
              ? [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
          ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? () {
              if (customOnTap != null) {
                customOnTap();
              } else {
                navVM.setCurrentRoute(route);
              }
            } : null,
            borderRadius: BorderRadius.circular(16),
            splashColor: Colors.white.withOpacity(0.1),
            highlightColor: Colors.white.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white.withOpacity(0.25)
                          : (isDanger ? const Color(0xFFEF4444).withOpacity(0.15) : Colors.white.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 22,
                      color: isEnabled
                          ? (isDanger ? const Color(0xFFFEE2E2) : Colors.white)
                          : Colors.white.withOpacity(0.4),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                        color: isEnabled ? Colors.white : Colors.white.withOpacity(0.4),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  if (isActive)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}