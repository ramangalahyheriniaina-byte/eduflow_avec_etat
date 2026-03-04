import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apk_web_eduflow/core/services/api_service.dart';
import '../../edt/view_model/edt_view_model.dart';
import '../../Cours/view_models/cours_view_model.dart';
import '../Model/dashboard_model.dart';
import '../view_model/dashboard_view_model.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dashboardViewModel = context.read<DashboardViewModel>();
      final edtViewModel = context.read<EdtViewModel>();

      print('📱 Dashboard: Initialisation...');

      if (edtViewModel.seances.isEmpty) {
        print('📱 Dashboard: Chargement initial des données EDT...');
        edtViewModel.loadInitialData().then((_) {
          Future.delayed(const Duration(milliseconds: 500), () {
            print('📱 Dashboard: Chargement des données dashboard...');
            dashboardViewModel.loadInitialData();
          });
        });
      } else {
        print('📱 Dashboard: Données EDT déjà présentes, chargement dashboard...');
        dashboardViewModel.loadInitialData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashVM = context.watch<DashboardViewModel>();
    final edtVM = context.watch<EdtViewModel>();
    final coursVM = context.watch<CoursViewModel>();

    // DEBUG: Afficher le nombre de séances
    print('📱 Dashboard Build: ${dashVM.seances.length} séances, ${edtVM.seances.length} séances EDT');

    return Container(
      color: const Color(0xFFF8FAFC),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === En-tête ===
            _buildHeader(dashVM),
            const SizedBox(height: 32),

            // === Section "Cours en cours" ===
            _buildCoursEnCoursSection(dashVM, edtVM),
            const SizedBox(height: 32),

            // === Section "Avancement des cours" + Calendrier ===
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildAvancementSection(dashVM, coursVM),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: _buildCalendarSection(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ========== EN-TÊTE ==========
  Widget _buildHeader(DashboardViewModel dashVM) {
    final aujourdhui = DateTime.now();
    final jourActuel = dashVM.jourActuel;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: const [
            Text(
              'Bonjour, Admin !',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            SizedBox(width: 8),
            Text('👋', style: TextStyle(fontSize: 28)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF86EFAC)),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today,
                  size: 16, color: Color(0xFF166534)),
              const SizedBox(width: 8),
              Text(
                '$jourActuel ${aujourdhui.day}/${aujourdhui.month}/${aujourdhui.year}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF166534),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ========== SECTION COURS EN COURS ==========
  Widget _buildCoursEnCoursSection(DashboardViewModel dashVM, EdtViewModel edtVM) {
    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        final coursFiltres = viewModel.getCoursAujourdhuiFiltered();
        final totalAujourdhui = viewModel.getAllCoursAujourdhui();

        print('📱 Dashboard: ${coursFiltres.length} cours filtrés (total aujourd\'hui: ${totalAujourdhui.length})');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bandeau titre
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF629EB9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    viewModel.showAllCours
                        ? 'Tous les cours aujourd\'hui (${totalAujourdhui.length})'
                        : 'Cours en cours (${coursFiltres.length}/${totalAujourdhui.length})',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      // Bouton Refresh
                      IconButton(
                        onPressed: () async {
                          print('🔄 Dashboard: Rafraîchissement manuel...');
                          await edtVM.loadInitialData();
                          await Future.delayed(const Duration(milliseconds: 300));
                          await viewModel.loadInitialData();
                          // Réinitialiser à "cours en cours" après rafraîchissement
                          viewModel.resetToCoursEnCours();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Données rafraîchies'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        tooltip: 'Rafraîchir',
                      ),
                      const SizedBox(width: 8),
                      // BOUTON "Voir Tous" / "Cours en cours"
                      ElevatedButton(
                        onPressed: () {
                          if (viewModel.showAllCours) {
                            // Retour au mode "cours en cours seulement"
                            viewModel.resetToCoursEnCours();
                          } else {
                            // Passer en mode "voir tous"
                            viewModel.toggleShowAllCours();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFDE047),
                          foregroundColor: const Color(0xFF713F12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          viewModel.showAllCours
                              ? 'Cours en cours'
                              : 'Voir Tous',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Grille des cours
            if (coursFiltres.isEmpty)
              _buildEmptyCoursAujourdhui(viewModel.showAllCours)
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.8,
                ),
                itemCount: coursFiltres.length,
                itemBuilder: (context, index) {
                  final dm = coursFiltres[index];
                  return KeyedSubtree(
                    key: ValueKey('seance-${dm.seance.idSeance}-${dm.statutReel}-${DateTime.now().millisecondsSinceEpoch}'),
                    child: _buildSeanceCard(dm, viewModel),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyCoursAujourdhui(bool showAllMode) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              showAllMode ? Icons.event_busy_rounded : Icons.schedule,
              size: 64,
              color: const Color(0xFFCBD5E1),
            ),
            const SizedBox(height: 16),
            Text(
              showAllMode
                  ? 'Aucun cours aujourd\'hui'
                  : 'Aucun cours en cours',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              showAllMode
                  ? 'Aucun cours n\'est programmé pour aujourd\'hui'
                  : 'Il n\'y a pas de cours en cours en ce moment',
              style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ========== CARTE SÉANCE ==========
  Widget _buildSeanceCard(DashboardModel dm, DashboardViewModel dashVM) {
    // DEBUG: Afficher le statut
    print('📱 Carte séance ${dm.seance.idSeance}: statutBase=${dm.seance.statut}, statutReel=${dm.statutReel}');

    final couleurs = dm.couleurs;
    final bgColor = couleurs['background']!;
    final badgeColor = couleurs['badge']!;
    final textColor = couleurs['text']!;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Badge statut + Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  dm.badgeText,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              // MENU D'ACTIONS
              if (dm.peutEtreAnnule || dm.peutEtreMarqueEnCours || dm.peutEtreTermine)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, size: 18, color: textColor),
                  itemBuilder: (context) {
                    final List<PopupMenuEntry<String>> items = [];

                    if (dm.peutEtreMarqueEnCours) {
                      items.add(
                        PopupMenuItem(
                          value: 'marquer_en_cours',
                          child: Row(
                            children: const [
                              Icon(Icons.play_arrow, size: 16, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Marquer en cours'),
                            ],
                          ),
                        ),
                      );
                    }

                    if (dm.peutEtreTermine) {
                      items.add(
                        PopupMenuItem(
                          value: 'terminer',
                          child: Row(
                            children: const [
                              Icon(Icons.check, size: 16, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Terminer'),
                            ],
                          ),
                        ),
                      );
                    }

                    if (dm.peutEtreAnnule) {
                      items.add(
                        PopupMenuItem(
                          value: 'annuler',
                          child: Row(
                            children: const [
                              Icon(Icons.close, size: 16, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Annuler'),
                            ],
                          ),
                        ),
                      );
                    }

                    return items;
                  },
                  onSelected: (value) async {
                    print('📱 Action sélectionnée: $value pour séance ${dm.seance.idSeance}');

                    try {
                      switch (value) {
                        case 'marquer_en_cours':
                          await dashVM.marquerEnCours(dm);
                          break;
                        case 'terminer':
                          await dashVM.terminerSeance(dm);
                          break;
                        case 'annuler':
                          await dashVM.annulerSeance(dm);
                          break;
                      }

                      // Forcer un rebuild du widget parent
                      setState(() {});

                      // Message de confirmation
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Statut mis à jour avec succès'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );

                    } catch (e) {
                      print('❌ Erreur action: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur: $e'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Infos cours
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dm.nomClasse,
                style: TextStyle(
                  fontSize: 12,
                  color: textColor.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dm.nomMatiere,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                dm.nomProf,
                style: TextStyle(
                  fontSize: 13,
                  color: textColor.withOpacity(0.8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Horaires
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time, size: 14, color: textColor),
                const SizedBox(width: 6),
                Text(
                  '${dm.heureDebut} - ${dm.heureFin}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== SECTION AVANCEMENT ==========
  Widget _buildAvancementSection(DashboardViewModel dashVM, CoursViewModel coursVM) {
    final avancementCours = dashVM.avancementParCours();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Avancement des cours',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 24),

          // Tableau
          if (avancementCours.isEmpty)
            _buildEmptyAvancement()
          else
            Column(
              children: [
                const Row(
                  children: [
                    Expanded(flex: 2, child: Text('Classe', style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600))),
                    Expanded(flex: 3, child: Text('Cours', style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600))),
                    Expanded(flex: 4, child: Text('Progression', style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600))),
                    Expanded(flex: 1, child: Text('%', style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                ...avancementCours.take(4).map((avancement) => _buildAvancementRow(avancement)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAvancementRow(AvancementCours avancement) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              avancement.nomClasse,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              avancement.nomMatiere,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
            ),
          ),
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: avancement.progression / 100,
                minHeight: 8,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation(avancement.couleur),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${avancement.progression.toInt()}%',
              style: TextStyle(
                fontSize: 14,
                color: avancement.couleur,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAvancement() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.insights, size: 48, color: Color(0xFFCBD5E1)),
            SizedBox(height: 16),
            Text(
              'Aucun cours disponible',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== SECTION CALENDRIER ==========
  Widget _buildCalendarSection() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startWeekday = firstDayOfMonth.weekday;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getMonthName(now.month),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 24),

          // Jours de la semaine
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['L', 'M', 'M', 'J', 'V', 'S', 'D']
                .map((day) => SizedBox(
              width: 32,
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ))
                .toList(),
          ),
          const SizedBox(height: 12),

          // Grille calendrier
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: daysInMonth + startWeekday - 1,
            itemBuilder: (context, index) {
              if (index < startWeekday - 1) return const SizedBox.shrink();
              final day = index - startWeekday + 2;
              final isToday = day == now.day;

              return Container(
                decoration: BoxDecoration(
                  color: isToday ? const Color(0xFF3B82F6) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return months[month - 1];
  }
}