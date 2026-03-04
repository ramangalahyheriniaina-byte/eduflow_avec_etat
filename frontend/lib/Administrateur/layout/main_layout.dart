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
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  String? _anneeEnCours;
  bool _isLoading = true;
  bool _needsInitialization = false;
  bool _needsUpload = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAnneeActive();
    });
  }

  Future<void> _checkAnneeActive() async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final coursVM = context.read<CoursViewModel>();

      if (!mounted) return;

      if (!coursVM.isInitialized) {
        setState(() {
          _needsInitialization = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _anneeEnCours = coursVM.anneeScolaire?.displayName;
          _isLoading = false;
          _needsInitialization = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _onInitializationComplete() {
    setState(() {
      _needsInitialization = false;
      _needsUpload = true;
    });
  }

  void _onUploadComplete() {
    final coursVM = context.read<CoursViewModel>();
    setState(() {
      _needsUpload = false;
      _anneeEnCours = coursVM.anneeScolaire?.displayName;
    });
  }

  // NOUVELLE MÉTHODE POUR LA DÉCONNEXION
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

  //  NOUVELLE MÉTHODE POUR EXÉCUTER LA DÉCONNEXION
  void _performLogout() {
    // Reset du ViewModel
    final coursVM = context.read<CoursViewModel>();
    coursVM.reset();

    // Navigation vers login
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
                'Chargement...',
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
    final coursVM = context.read<CoursViewModel>();
    final edtVM = context.read<EdtViewModel>();
    final dashboardVM = context.read<DashboardViewModel>();

    dashboardVM.updateSeancesList(edtVM.seances);
    dashboardVM.updateCoursList(coursVM.cours);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (edtVM.seances.isNotEmpty) {
        navVM.markEdtExists(true);
      }
      if (coursVM.cours.isNotEmpty) {
        navVM.markCoursExists(true);
      }
    });

    Widget content;
    if (_needsInitialization) {
      content = CoursInitView(onComplete: _onInitializationComplete);
    } else if (_needsUpload) {
      content = UploadProgrammeView(onComplete: _onUploadComplete);
    } else {
      switch (navVM.currentRoute) {
        case Routes.programme:
          content = EdtView();
          break;
        case Routes.dashboard:
          content = const DashboardView();
          break;
        case Routes.cours:
        default:
          content = const CoursListView();
      }
    }

    return Scaffold(
      body: Row(
        children: [
          SidebarWithYear(
            anneeEnCours: _anneeEnCours,
            onLogout: () => _showLogoutDialog(context),
          ),
          Expanded(child: content),
        ],
      ),
    );
  }
}

// ========== SIDEBAR MODIFIÉE AVEC CALLBACK ==========
class SidebarWithYear extends StatelessWidget {
  final String? anneeEnCours;
  final VoidCallback onLogout; 

  const SidebarWithYear({
    super.key,
    this.anneeEnCours,
    required this.onLogout, 
  });

  @override
  Widget build(BuildContext context) {
    final navVM = context.watch<NavigationViewModel>();

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
          // Header
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
                  'Admin Dashboard',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.8),
                    letterSpacing: 0.3,
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
                    isEnabled: true,
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    context,
                    title: 'Emploi du temps',
                    icon: Icons.calendar_month_rounded,
                    route: Routes.programme,
                    navVM: navVM,
                    isEnabled: true,
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    context,
                    title: 'Dashboard',
                    icon: Icons.dashboard_rounded,
                    route: Routes.dashboard,
                    navVM: navVM,
                    isEnabled: navVM.dashboardEnabled,
                    disabledTooltip: "Créez d'abord un emploi du temps",
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
                      Text(
                        'System Online',
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w500),
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
                  customOnTap: onLogout, // UTILISER LE CALLBACK
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
        VoidCallback? customOnTap, // NOUVEAU PARAMÈTRE
      }) {
    final isActive = navVM.currentRoute == route;

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
                customOnTap(); //  ACTION PERSONNALISÉE (DÉCONNEXION)
              } else {
                navVM.setCurrentRoute(route); //  NAVIGATION NORMALE
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
                      color: isEnabled ? (isDanger ? const Color(0xFFFEE2E2) : Colors.white) : Colors.white.withOpacity(0.4),
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