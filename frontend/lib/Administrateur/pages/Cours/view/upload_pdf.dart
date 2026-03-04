import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/cours_view_model.dart';
import 'cours_list_view.dart';

class UploadProgrammeView extends StatefulWidget {
  final VoidCallback? onComplete;

  const UploadProgrammeView({Key? key, this.onComplete}) : super(key: key);

  @override
  State<UploadProgrammeView> createState() => _UploadProgrammeViewState();
}

class _UploadProgrammeViewState extends State<UploadProgrammeView> {
  Uint8List? _pdfBytes;
  String? _pdfNom;
  String? _classeSelectionnee;
  bool _isGenerating = false;
  String? _errorMessage;

  Future<void> _choisirPdf() async {
    setState(() => _errorMessage = null);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;

        if (bytes.isEmpty) {
          setState(() => _errorMessage = 'Le fichier PDF est vide');
          return;
        }

        setState(() {
          _pdfBytes = bytes;
          _pdfNom = result.files.single.name;
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Erreur sélection fichier: $e');
    }
  }

  Future<void> _generer() async {
    if (_pdfBytes == null) return;

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      final vm = context.read<CoursViewModel>();
      await vm.genererDepuisPdf(_pdfBytes!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Programme généré avec succès'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );

      widget.onComplete != null
          ? widget.onComplete!()
          : Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const CoursListView()),
            );
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CoursViewModel>();
    final classes = vm.classes.map((e) => e.nomClasse).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFB8D4DC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Bienvenue sur L'analyse IA",
            style: TextStyle(color: Colors.black87)),
        centerTitle: true,
      ),

      // BODY AVEC ROBOT A DROITE
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            /// FORMULAIRE
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6E8EE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5B8FA8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Une touche magique avec notre IA",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Optimiser votre programme scolaire pour suivre la tendance.\n"
                        "Faites générer les programmes avec l'IA",
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _isGenerating ? null : _choisirPdf,
                              child: Container(
                                height: 150,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _pdfBytes != null
                                        ? const Color(0xFF5B8FA8)
                                        : Colors.grey,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.insert_drive_file_outlined,
                                        size: 70,
                                        color: const Color(0xFF5B8FA8)
                                            .withOpacity(
                                                _pdfBytes != null ? 1 : 0.5)),
                                    const SizedBox(height: 8),
                                    Text(
                                      _pdfBytes != null
                                          ? "Changer le PDF"
                                          : "Choisir un PDF",
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                hint: const Text("Classe"),
                                value: _classeSelectionnee,
                                items: classes
                                    .map((c) => DropdownMenuItem(
                                        value: c, child: Text(c)))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _classeSelectionnee = v),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      if (_pdfNom != null)
                        Text("Fichier sélectionné : $_pdfNom"),

                      if (_errorMessage != null)
                        Text(_errorMessage!,
                            style: const TextStyle(color: Colors.red)),

                      const SizedBox(height: 20),

                      Center(
                        child: ElevatedButton(
                          onPressed: (_pdfBytes != null && !_isGenerating)
                              ? _generer
                              : null,
                          child: _isGenerating
                              ? const CircularProgressIndicator()
                              : const Text("Générer le pdf"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 40),

            /// ROBOT ICON
            if (MediaQuery.of(context).size.width > 700)
              Expanded(
                child: Image.asset(
                  "assets/images/robo.png",
                  height: 260,
                  fit: BoxFit.contain,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
