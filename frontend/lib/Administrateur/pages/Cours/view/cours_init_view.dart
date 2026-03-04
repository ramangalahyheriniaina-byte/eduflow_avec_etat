import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import view model
import '../view_models/cours_view_model.dart';
// Import pour la navigation
import 'cours_list_view.dart';

class CoursInitView extends StatefulWidget {
  final VoidCallback? onComplete;

  const CoursInitView({
    Key? key,
    this.onComplete,
  }) : super(key: key);

  @override
  State<CoursInitView> createState() => _CoursInitViewState();
}

class _CoursInitViewState extends State<CoursInitView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _startYearController = TextEditingController();
  final TextEditingController _endYearController = TextEditingController();
  final TextEditingController _classeController = TextEditingController();

  List<String> _classesACreer = [];
  int _currentStep = 0;

  @override
  void dispose() {
    _startYearController.dispose();
    _endYearController.dispose();
    _classeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          ClipPath(
            clipper: DiagonalClipper(),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFF5D9BB3),
            ),
          ),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 60),
                  color: Colors.transparent,
                  child: _buildStepperContent(),
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Image.asset(
                      "assets/images/home_start.png",
                      fit: BoxFit.contain,
                      width: 310,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepperContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Dites-nous un peu plus sur\nvotre école ...",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            color: Colors.blueGrey,
          ),
        ),
        const SizedBox(height: 40),
        Expanded(
          child: SingleChildScrollView(
            child: _buildCurrentStepContent(),
          ),
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFE6F4F5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 18,
                    ),
                  ),
                  onPressed: () {
                    setState(() => _currentStep--);
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back, color: Colors.black),
                      SizedBox(width: 15),
                      Text(
                        "Retour",
                        style:
                            TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 15),
            SizedBox(
              width: 180,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF1B6B75),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 18,
                  ),
                ),
                onPressed: _handleNext,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentStep == 2
                          ? "Valider"
                          : "Suivant",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Icon(
                      _currentStep == 2
                          ? Icons.check
                          : Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildAnneeForm();
      case 1:
        return _buildClassesForm();
      case 2:
        return _buildRecapitulatif();
      default:
        return Container();
    }
  }

  Widget _buildAnneeForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildInput(
            label: "Année de début :",
            controller: _startYearController,
            hintText: "2024",
            onChanged: (value) {
              if (value.length == 4) {
                final year = int.tryParse(value);
                if (year != null) {
                  _endYearController.text =
                      (year + 1).toString();
                }
              }
            },
          ),
          const SizedBox(height: 30),
          _buildInput(
            label: "Année de fin :",
            controller: _endYearController,
            hintText: "2025",
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 340,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    const Color(0xFFE6F4F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline,
                      color:
                          Color(0xFF1B6B75)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'L\'année de fin sera automatiquement l\'année de début + 1',
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            Color(0xFF144D53),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassesForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _classeController,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  hintText:
                      'Ex: 6ème A, 5ème B...',
                ),
                onSubmitted: (_) => _ajouterClasse(),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF1B6B75),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
              ),
              onPressed: _ajouterClasse,
              child: const Icon(Icons.add,
                  color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (_classesACreer.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color:
                  const Color(0xFFEAF6F7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.inbox,
                      size: 48,
                      color:
                          Color(0xFF1B6B75)),
                  SizedBox(height: 12),
                  Text(
                    'Aucune classe ajoutée',
                    style: TextStyle(
                      color:
                          Color(0xFF144D53),
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _classesACreer.map((classe) {
              return Chip(
                label: Text(
                  classe,
                  style: const TextStyle(
                    color:
                        Color(0xFF144D53),
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
                deleteIcon: const Icon(
                  Icons.close,
                  size: 18,
                  color:
                      Color(0xFF1B6B75),
                ),
                onDeleted: () {
                  setState(() =>
                      _classesACreer.remove(classe));
                },
                backgroundColor:
                    const Color(0xFFE6F4F5),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildRecapitulatif() {
    final startYear = _startYearController.text;
    final endYear = _endYearController.text;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius:
                BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      color: Colors.blueGrey),
                  const SizedBox(width: 12),
                  Text(
                    'Année scolaire: $startYear - $endYear',
                    style:
                        const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.class_,
                      color: Colors.blueGrey),
                  const SizedBox(width: 12),
                  Text(
                    'Classes: ${_classesACreer.length} classes',
                    style:
                        const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleNext() {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        setState(() => _currentStep++);
      }
    } else if (_currentStep == 1) {
      if (_classesACreer.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
                'Veuillez ajouter au moins une classe'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      setState(() => _currentStep++);
    } else if (_currentStep == 2) {
      _validerEtGenerer();
    }
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    String? hintText,
    Function(String)? onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(label,
              style:
                  const TextStyle(fontSize: 16)),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 230,
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hintText,
              contentPadding:
                  const EdgeInsets.symmetric(
                      horizontal: 10),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _ajouterClasse() {
    final classe =
        _classeController.text.trim();
    if (classe.isEmpty) return;

    if (_classesACreer.contains(classe)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('Cette classe existe déjà'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _classesACreer.add(classe);
      _classeController.clear();
    });
  }

  void _validerEtGenerer() async {
    final viewModel =
        context.read<CoursViewModel>();

    final startYear =
        int.parse(_startYearController.text);
    final endYear =
        int.parse(_endYearController.text);

    await viewModel.initialiserAnneeScolaire(
      startYear: startYear,
      endYear: endYear,
      nomsClasses: _classesACreer,
    );

    if (mounted) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const CoursListView(),
          ),
        );
      }
    }
  }
}

class DiagonalClipper
    extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(
        size.width * 0.45, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(
          CustomClipper<Path> oldClipper) =>
      false;
}
