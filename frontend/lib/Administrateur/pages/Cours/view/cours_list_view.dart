// lib/Administrateur/pages/Cours/view/cours_list_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/cours_view_model.dart';
import '../models/classe_model.dart';
import '../models/matiere_model.dart';
import '../models/prof_model.dart';

class CoursListView extends StatefulWidget {
  const CoursListView({Key? key}) : super(key: key);

  @override
  State<CoursListView> createState() => _CoursListViewState();
}

class _CoursListViewState extends State<CoursListView> {
  // 🎯 CLÉS POUR GARDER L'ÉTAT DES EXPANSION TILES
  final Map<int, bool> _expandedClasses = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 🔄 Charger les données après la première frame
      final coursViewModel = context.read<CoursViewModel>();
      coursViewModel.loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CoursViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFFF9FAFB),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF629EB9)),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: Row(
            children: [
              // PANNEAU GAUCHE - Liste des profs
              Container(
                width: 350,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(2, 0),
                    ),
                  ],
                ),
                child: _buildPanneauProfs(context, viewModel),
              ),

              // PANNEAU DROIT - Classes et matières
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // APP BAR
                    SliverAppBar(
                      expandedHeight: 200,
                      pinned: true,
                      backgroundColor: const Color(0xFF629EB9),
                      flexibleSpace: FlexibleSpaceBar(
                        title: const Text(
                          'Répartition des Matières',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        background: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF629EB9), Color(0xFF4A7C96)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 60),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    viewModel.anneeScolaire?.displayName ?? '',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${viewModel.totalClasses} classes • ${viewModel.totalMatieres} matières',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // STATISTIQUES
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.check_circle,
                                label: 'Avec prof',
                                value: '${viewModel.matieresAvecProf}',
                                color: const Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.pending,
                                label: 'Sans prof',
                                value: '${viewModel.matieresSansProf}',
                                color: const Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // LISTE DES CLASSES
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final classe = viewModel.classes[index];
                            return _buildClasseCard(context, classe, viewModel);
                          },
                          childCount: viewModel.classes.length,
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ========== PANNEAU GAUCHE - GESTION PROFS ==========
  Widget _buildPanneauProfs(BuildContext context, CoursViewModel viewModel) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF629EB9), Color(0xFF4A7C96)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: const [
                  Icon(Icons.people, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Professeurs',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${viewModel.profs.length}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Profs',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Bouton ajouter
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAjouterProfDialog(context, viewModel),
              icon: const Icon(Icons.person_add),
              label: const Text('Ajouter un prof'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF629EB9),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),

        // Liste des profs avec animation
        Expanded(
          child: viewModel.profs.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.person_off, size: 64, color: Color(0xFF9CA3AF)),
                SizedBox(height: 16),
                Text(
                  'Aucun professeur',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Ajoutez des profs pour commencer les affectations',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ],
            ),
          )
              : AnimatedList(
            key: ValueKey(viewModel.profs.length),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            initialItemCount: viewModel.profs.length,
            itemBuilder: (context, index, animation) {
              if (index >= viewModel.profs.length) {
                return const SizedBox.shrink();
              }

              final prof = viewModel.profs[index];
              final nbCours = viewModel.cours
                  .where((c) => c.idProf == prof.idProf)
                  .length;

              // 🎨 ANIMATION DE SLIDE + FADE
              return SlideTransition(
                position: animation.drive(
                  Tween<Offset>(
                    begin: const Offset(-1, 0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeOutCubic)),
                ),
                child: FadeTransition(
                  opacity: animation,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ProfCard(
                      prof: prof,
                      nbCours: nbCours,
                      onDelete: () => _showSupprimerProfDialog(
                        context,
                        prof,
                        viewModel,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClasseCard(BuildContext context, Classe classe, CoursViewModel viewModel) {
    final totalHeures = viewModel.getTotalHeuresClasse(classe);

    // 🎯 Récupérer ou initialiser l'état d'expansion
    _expandedClasses.putIfAbsent(classe.idClasse!, () => false);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
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
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            // 🎯 CLÉ UNIQUE POUR PRÉSERVER L'ÉTAT
            key: ValueKey('classe_${classe.idClasse}'),
            initiallyExpanded: _expandedClasses[classe.idClasse!]!,
            onExpansionChanged: (expanded) {
              setState(() {
                _expandedClasses[classe.idClasse!] = expanded;
              });
            },
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF629EB9), Color(0xFF4A7C96)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.class_, color: Colors.white, size: 24),
            ),
            title: Text(
              classe.nomClasse,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${classe.matieres?.length ?? 0} matières • $totalHeures heures totales',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
            children: [
              const Divider(),
              if (classe.matieres == null || classe.matieres!.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Aucune matière',
                    style: TextStyle(color: Color(0xFF9CA3AF)),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: classe.matieres!.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final matiere = classe.matieres![index];
                    return _MatiereCard(
                      key: ValueKey('matiere_${matiere.idMatiere}'),
                      matiere: matiere,
                      viewModel: viewModel,
                      onAffecterProf: () => _showAffecterProfDialog(
                        context,
                        matiere,
                        viewModel,
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== DIALOGUES ==========
  void _showAjouterProfDialog(BuildContext context, CoursViewModel viewModel) {
    final controller = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.person_add, color: Color(0xFF629EB9)),
              SizedBox(width: 12),
              Text('Ajouter un professeur'),
            ],
          ),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Nom du professeur',
              hintText: 'Ex: M. Dupont, Mme Martin...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            autofocus: true,
            enabled: !isLoading,
            onSubmitted: (_) async {
              if (controller.text.trim().isNotEmpty && !isLoading) {
                setDialogState(() => isLoading = true);
                await viewModel.ajouterProf(controller.text.trim());
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                if (controller.text.trim().isNotEmpty) {
                  setDialogState(() => isLoading = true);
                  await viewModel.ajouterProf(controller.text.trim());
                  if (context.mounted) Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF629EB9),
              ),
              child: isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSupprimerProfDialog(
      BuildContext context,
      Prof prof,
      CoursViewModel viewModel,
      ) {
    final nbCours = viewModel.cours.where((c) => c.idProf == prof.idProf).length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer ce professeur ?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Êtes-vous sûr de vouloir supprimer ${prof.nomProf} ?'),
            if (nbCours > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFF59E0B)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Color(0xFFF59E0B), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$nbCours affectation${nbCours > 1 ? "s" : ""} sera${nbCours > 1 ? "ont" : ""} supprimée${nbCours > 1 ? "s" : ""}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              await viewModel.supprimerProf(prof.idProf!);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showAffecterProfDialog(
      BuildContext context,
      Matiere matiere,
      CoursViewModel viewModel,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Affecter un prof'),
            const SizedBox(height: 4),
            Text(
              matiere.nomMatiere,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Color(0xFF629EB9),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 350,
          child: viewModel.profs.isEmpty
              ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_off, size: 48, color: Color(0xFF9CA3AF)),
              const SizedBox(height: 16),
              const Text(
                'Aucun professeur disponible',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Veuillez d\'abord ajouter des professeurs dans le panneau de gauche.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showAjouterProfDialog(context, viewModel);
                },
                icon: const Icon(Icons.person_add),
                label: const Text('Ajouter un prof'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF629EB9),
                ),
              ),
            ],
          )
              : ListView.builder(
            shrinkWrap: true,
            itemCount: viewModel.profs.length,
            itemBuilder: (context, index) {
              final prof = viewModel.profs[index];
              final nbCours = viewModel.cours
                  .where((c) => c.idProf == prof.idProf)
                  .length;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF629EB9).withOpacity(0.1),
                  child: Text(
                    prof.nomProf[0].toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF629EB9),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(prof.nomProf),
                subtitle: Text('$nbCours cours déjà affecté${nbCours > 1 ? "s" : ""}'),
                onTap: () async {
                  await viewModel.affecterProfAMatiere(
                    idMatiere: matiere.idMatiere!,
                    idProf: prof.idProf!,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${prof.nomProf} affecté à ${matiere.nomMatiere}',
                        ),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }
}

// ========== WIDGETS STATEFUL ==========

/// Widget pour une carte de prof
class _ProfCard extends StatelessWidget {
  final Prof prof;
  final int nbCours;
  final VoidCallback onDelete;

  const _ProfCard({
    required this.prof,
    required this.nbCours,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Hero(
          tag: 'prof_${prof.idProf}',
          child: CircleAvatar(
            backgroundColor: const Color(0xFF629EB9).withOpacity(0.1),
            child: Text(
              prof.nomProf[0].toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF629EB9),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          prof.nomProf,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '$nbCours cours affecté${nbCours > 1 ? "s" : ""}',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

/// Widget pour une carte de matière (SANS ICÔNE)
class _MatiereCard extends StatelessWidget {
  final Matiere matiere;
  final CoursViewModel viewModel;
  final VoidCallback onAffecterProf;

  const _MatiereCard({
    Key? key,
    required this.matiere,
    required this.viewModel,
    required this.onAffecterProf,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cours = viewModel.getCoursForMatiere(matiere.idMatiere!);
    final hasProf = cours != null;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasProf
              ? const Color(0xFF10B981).withOpacity(0.3)
              : const Color(0xFFE5E7EB),
          width: 1.5,
        ),
      ),
      child: ListTile(
        // ✅ SUPPRESSION DE L'ICÔNE
        // leading: Icon(...)  ← Supprimé

        title: Text(
          matiere.nomMatiere,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            hasProf
                ? '${viewModel.getProfById(cours.idProf)?.nomProf ?? "Prof inconnu"} • ${matiere.heureTotale}h'
                : '${matiere.heureTotale}h • Pas de prof assigné',
            style: TextStyle(
              fontSize: 13,
              color: hasProf ? const Color(0xFF10B981) : const Color(0xFF6B7280),
              fontWeight: hasProf ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
        trailing: hasProf
            ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF629EB9), size: 20),
              onPressed: onAffecterProf,
            ),
          ],
        )
            : IconButton(
          icon: const Icon(Icons.person_add, color: Color(0xFF629EB9)),
          onPressed: onAffecterProf,
        ),
      ),
    );
  }
}