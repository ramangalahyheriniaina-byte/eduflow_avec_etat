// lib/Administrateur/services/pdf_services.dart
import 'dart:typed_data';
import 'ia_service.dart';

class PdfAnalyseService {
  final IAService _iaService = IAService();

  /// Analyse le PDF via l'IA et retourne les données filtrées
  Future<List<Map<String, dynamic>>> analyser(Uint8List pdfBytes) async {
    try {
      // Vérifier d'abord que le serveur est accessible
      final isHealthy = await _iaService.checkHealth();
      if (!isHealthy) {
        throw Exception('Serveur IA inaccessible. Vérifiez que le backend tourne sur http://192.168.88.238:5000');
      }

      // Envoyer à l'IA et récupérer les matières filtrées
      final matieres = await _iaService.analyserPdf(pdfBytes);

      if (matieres.isEmpty) {
        throw Exception('Aucune matière détectée dans le PDF');
      }

      return matieres;

    } catch (e) {
      print(' Erreur analyse PDF: $e');
      rethrow;
    }
  }

  /// Version debug
  Future<void> analyserDebug(Uint8List pdfBytes) async {
    try {
      final debugInfo = await _iaService.analyserPdfDebug(pdfBytes);
      print(' Debug info: $debugInfo');
    } catch (e) {
      print(' Erreur debug: $e');
    }
  }
}