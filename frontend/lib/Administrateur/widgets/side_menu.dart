// 📁 lib/widgets/sidebar.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/navigation_view_model.dart';
import '../pages/dashboard/view_model/dashboard_view_model.dart';  // ✅ CHANGÉ
import '../app/routes.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final navVM = context.watch<NavigationViewModel>();
    final dashVM = context.watch<DashboardViewModel>();  // ✅ CHANGÉ

    return Container(
      width: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF629EB9),
            Color(0xFF4A7C96),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Transform.scale(
                    scale: 1.25,
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 200,
                      height: 190,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.school_rounded,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
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
                ],
              )
          ),

          // Séparateur élégant
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 📱 Menu items
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
                    isEnabled: true,  // ✅ CORRIGÉ

                  ),
                ],
              ),
            ),
          ),

          // 🔻 Footer avec déconnexion + statut
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Statut système
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF22C55E).withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'System Online',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Bouton déconnexion
                _buildMenuItem(
                  context,
                  title: 'Déconnexion',
                  icon: Icons.logout_rounded,
                  route: Routes.logout,
                  navVM: navVM,
                  isEnabled: true,
                  isDanger: true,
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
      }) {
    final isActive = navVM.currentRoute == route;

    return Tooltip(
      message: isEnabled ? "" : disabledTooltip,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withOpacity(0.2)
              : (isEnabled ? Colors.transparent : Colors.white.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? Colors.white.withOpacity(0.3)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: isActive
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? () => navVM.setCurrentRoute(route) : null,
            borderRadius: BorderRadius.circular(16),
            splashColor: Colors.white.withOpacity(0.1),
            highlightColor: Colors.white.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Icône avec background
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white.withOpacity(0.25)
                          : (isDanger
                          ? Color(0xFFEF4444).withOpacity(0.15)
                          : Colors.white.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 22,
                      color: isEnabled
                          ? (isDanger ? Color(0xFFFEE2E2) : Colors.white)
                          : Colors.white.withOpacity(0.4),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Titre
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                        color: isEnabled
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  // Indicateur actif
                  if (isActive)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  // Lock icon si désactivé
                  if (!isEnabled && !isDanger)
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 18,
                      color: Colors.white.withOpacity(0.4),
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