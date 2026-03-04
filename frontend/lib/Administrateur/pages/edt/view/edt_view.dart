import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/status_enum.dart';
import '../../../core/navigation_view_model.dart';
import '../../../app/routes.dart';
import '../../Cours/models/cours_model.dart';
import '../../Cours/models/classe_model.dart';
import '../../Cours/view_models/cours_view_model.dart';
import '../view_model/edt_view_model.dart';

class EdtView extends StatefulWidget {
  const EdtView({super.key});

  @override
  State<EdtView> createState() => _EdtViewState();
}

class _EdtViewState extends State<EdtView> {
  final TextEditingController debutCtrl = TextEditingController();
  final TextEditingController finCtrl = TextEditingController();
  String jourSelectionne = "Lundi";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 🔄 Charger les données après la première frame
      final edtViewModel = context.read<EdtViewModel>();
      final coursViewModel = context.read<CoursViewModel>();

      // Charger les données EDT
      edtViewModel.loadInitialData();

      // Si les cours ne sont pas encore chargés, les charger aussi
      if (coursViewModel.classes.isEmpty) {
        coursViewModel.loadInitialData();
      }
    });
  }

  @override
  void dispose() {
    debutCtrl.dispose();
    finCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final edtVM = context.watch<EdtViewModel>();
    final coursVM = context.watch<CoursViewModel>();
    final navVM = context.watch<NavigationViewModel>();

    // Récupération des cours disponibles
    final List<Cours> coursDisponibles = _getCoursDisponibles(coursVM, edtVM);

    // Vérification du cours sélectionné
    if (edtVM.coursSelectionne != null &&
        !coursDisponibles.any((c) => c.idCours == edtVM.coursSelectionne!.idCours)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        edtVM.selectionnerCours(null);
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // EN-TÊTE
              _buildHeader(edtVM),
              const SizedBox(height: 24),

              // SÉLECTION CLASSE
              if (coursVM.classes.isNotEmpty) ...[
                _buildClasseSelector(coursVM, edtVM),
                const SizedBox(height: 24),
              ],

              // FORMULAIRE AJOUT
              _buildFormulaire(coursDisponibles, edtVM, coursVM, navVM, context),
              const SizedBox(height: 32),

              // PLANNING HEBDOMADAIRE
              _buildPlanningHebdomadaire(edtVM),
            ],
          ),
        ),
      ),
    );
  }

  // ========== HEADER ==========
  Widget _buildHeader(EdtViewModel edtVM) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Emploi du Temps',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Organisez vos cours de manière optimale',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, size: 18, color: Color(0xFF629EB9)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Séances planifiées',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                  Text(
                    '${edtVM.seancesDeLaSemaine().length}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ========== SÉLECTION CLASSE ==========
  Widget _buildClasseSelector(CoursViewModel coursVM, EdtViewModel edtVM) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Classe:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 45,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: coursVM.classes.map((classe) {
              final isSelected = edtVM.selectedClasse?.idClasse == classe.idClasse;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => edtVM.changerClasse(classe),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFEC4899) : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      classe.nomClasse,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ========== FORMULAIRE ==========
  Widget _buildFormulaire(List<Cours> coursDisponibles, EdtViewModel edtVM,
      CoursViewModel coursVM, NavigationViewModel navVM, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.add_circle_outline, color: Color(0xFFEC4899), size: 24),
              SizedBox(width: 12),
              Text(
                'Ajouter une Séance',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // LIGNE 1: JOUR + HEURES + MATIÈRE
          Row(
            children: [
              Expanded(child: _buildJourField()),
              const SizedBox(width: 12),
              Expanded(child: _buildTimeField('Début', debutCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _buildTimeField('Fin', finCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _buildCoursField(coursDisponibles, edtVM)),
            ],
          ),
          const SizedBox(height: 24),

          // BOUTON AJOUTER
          // BOUTON AJOUTER
          // BOUTON AJOUTER - Version simplifiée
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: edtVM.coursSelectionne == null ||
                  debutCtrl.text.isEmpty ||
                  finCtrl.text.isEmpty
                  ? null
                  : () async {
                // VALIDATION : Vérifier que fin > début
                if (!_isHeureFinApresDebut(debutCtrl.text, finCtrl.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('L\'heure de fin doit être après l\'heure de début'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                // Calculer la date
                final dateSeance = _getDateFromJour(
                  edtVM.lundiSemaineSelectionnee,
                  jourSelectionne,
                );

                await edtVM.ajouterSeance(
                  cours: edtVM.coursSelectionne!,
                  dateSeance: dateSeance,
                  heureDebut: debutCtrl.text,
                  heureFin: finCtrl.text,
                );

                // Gérer le succès/erreur
                if (edtVM.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(edtVM.error!),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                } else {
                  debutCtrl.clear();
                  finCtrl.clear();

                  // Activer le dashboard SANS navigation auto
                  navVM.markEdtExists(true);

                  // Message de succès simple pendant 2 secondes
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Séance ajoutée avec succès !',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      backgroundColor: Color(0xFF10B981),
                      duration: Duration(seconds: 2), // Juste 2 secondes
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                'Ajouter au planning',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEC4899),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== PLANNING HEBDOMADAIRE ==========
  Widget _buildPlanningHebdomadaire(EdtViewModel edtVM) {
    final seances = edtVM.seancesDeLaSemaine();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_month, color: Color(0xFFEC4899), size: 24),
                const SizedBox(width: 12),
                Text(
                  'Planning Hebdomadaire${edtVM.selectedClasse != null ? ' - ${edtVM.selectedClasse!.nomClasse}' : ''}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            // Navigation semaine
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    final nouvelleSemaine = edtVM.lundiSemaineSelectionnee
                        .subtract(const Duration(days: 7));
                    edtVM.changerSemaine(nouvelleSemaine);
                  },
                  icon: const Icon(Icons.chevron_left),
                  color: const Color(0xFF629EB9),
                ),
                Text(
                  'Semaine du ${edtVM.lundiSemaineSelectionnee.day}/${edtVM.lundiSemaineSelectionnee.month}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                IconButton(
                  onPressed: () {
                    final nouvelleSemaine = edtVM.lundiSemaineSelectionnee
                        .add(const Duration(days: 7));
                    edtVM.changerSemaine(nouvelleSemaine);
                  },
                  icon: const Icon(Icons.chevron_right),
                  color: const Color(0xFF629EB9),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // GRILLE HEBDOMADAIRE
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildJourColumn('Lundi', edtVM, seances),
              _buildJourColumn('Mardi', edtVM, seances),
              _buildJourColumn('Mercredi', edtVM, seances),
              _buildJourColumn('Jeudi', edtVM, seances),
              _buildJourColumn('Vendredi', edtVM, seances),
              _buildJourColumn('Samedi', edtVM, seances),
            ],
          ),
        ),
      ],
    );
  }

  // ========== COLONNE JOUR ==========
  Widget _buildJourColumn(String jour, EdtViewModel edtVM, List<dynamic> seances) {
    final dateJour = _getDateFromJour(edtVM.lundiSemaineSelectionnee, jour);
    final seancesJour = seances.where((s) {
      return s.dateSeance.year == dateJour.year &&
          s.dateSeance.month == dateJour.month &&
          s.dateSeance.day == dateJour.day;
    }).toList();

    // Trier par heure de début
    seancesJour.sort((a, b) => a.heureDebut.compareTo(b.heureDebut));

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            // En-tête du jour
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  Text(
                    jour,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${seancesJour.length} séance(s)',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Liste des séances
            if (seancesJour.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: const [
                    Icon(Icons.event_busy, size: 32, color: Color(0xFFCBD5E1)),
                    SizedBox(height: 8),
                    Text(
                      'Aucune\nséance',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              )
            else
              ...seancesJour.map((seance) => _buildSeanceCard(seance, edtVM)),
          ],
        ),
      ),
    );
  }

  // ========== CARTE SÉANCE ==========
  Widget _buildSeanceCard(dynamic seance, EdtViewModel edtVM) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          left: BorderSide(color: Color(0xFF10B981), width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            seance.cours?.matiere?.nomMatiere ?? 'Matière',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${seance.heureDebut} - ${seance.heureFin}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            seance.cours?.prof?.nomProf ?? 'Prof',
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ========== CHAMP JOUR ==========
  Widget _buildJourField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.calendar_today, size: 16, color: Color(0xFF64748B)),
            SizedBox(width: 6),
            Text(
              'Jour',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: jourSelectionne,
              items: const [
                DropdownMenuItem(value: 'Lundi', child: Text('Lundi')),
                DropdownMenuItem(value: 'Mardi', child: Text('Mardi')),
                DropdownMenuItem(value: 'Mercredi', child: Text('Mercredi')),
                DropdownMenuItem(value: 'Jeudi', child: Text('Jeudi')),
                DropdownMenuItem(value: 'Vendredi', child: Text('Vendredi')),
                DropdownMenuItem(value: 'Samedi', child: Text('Samedi')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    jourSelectionne = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  // ========== CHAMP HEURE ==========
  Widget _buildTimeField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.access_time, size: 16, color: Color(0xFF64748B)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              controller.text =
              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
              setState(() {});
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              controller.text.isEmpty ? '--:--' : controller.text,
              style: TextStyle(
                fontSize: 14,
                color: controller.text.isEmpty
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF1E293B),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ========== CHAMP COURS ==========
  Widget _buildCoursField(List<Cours> coursDisponibles, EdtViewModel edtVM) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.book, size: 16, color: Color(0xFF64748B)),
            const SizedBox(width: 6),
            Text(
              'Matière',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Cours>(
              isExpanded: true,
              hint: Text(
                coursDisponibles.isEmpty
                    ? 'Aucun cours'
                    : 'Sélectionner...',
                style: const TextStyle(fontSize: 13),
              ),
              value: edtVM.coursSelectionne,
              items: coursDisponibles.map((cours) {
                return DropdownMenuItem<Cours>(
                  value: cours,
                  child: Text(
                    cours.matiere?.nomMatiere ?? 'Matière',
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: edtVM.selectionnerCours,
            ),
          ),
        ),
      ],
    );
  }

  // ========== HELPERS ==========
  List<Cours> _getCoursDisponibles(CoursViewModel coursVM, EdtViewModel edtVM) {
    if (edtVM.selectedClasse != null) {
      final coursFiltre = coursVM.coursList
          .where((cours) => cours.classe?.idClasse == edtVM.selectedClasse!.idClasse)
          .toList();

      final Map<int, Cours> coursUniques = {};
      for (var cours in coursFiltre) {
        if (cours.idCours != null) {
          coursUniques[cours.idCours!] = cours;
        }
      }

      return coursUniques.values.toList();
    }

    final Map<int, Cours> coursUniques = {};
    for (var cours in coursVM.coursList) {
      if (cours.idCours != null) {
        coursUniques[cours.idCours!] = cours;
      }
    }

    return coursUniques.values.toList();
  }

  DateTime _getDateFromJour(DateTime lundi, String jour) {
    const jours = {
      'Lundi': 0,
      'Mardi': 1,
      'Mercredi': 2,
      'Jeudi': 3,
      'Vendredi': 4,
      'Samedi': 5,
    };

    final offset = jours[jour] ?? 0;
    return lundi.add(Duration(days: offset));
  }

  //  AJOUTEZ cette méthode helper :
  bool _isHeureFinApresDebut(String debut, String fin) {
    final debutParts = debut.split(':');
    final finParts = fin.split(':');

    if (debutParts.length != 2 || finParts.length != 2) return false;

    final debutHour = int.tryParse(debutParts[0]) ?? 0;
    final debutMin = int.tryParse(debutParts[1]) ?? 0;
    final finHour = int.tryParse(finParts[0]) ?? 0;
    final finMin = int.tryParse(finParts[1]) ?? 0;

    // Comparer d'abord les heures, puis les minutes
    if (finHour > debutHour) return true;
    if (finHour == debutHour && finMin > debutMin) return true;
    return false;
  }
}