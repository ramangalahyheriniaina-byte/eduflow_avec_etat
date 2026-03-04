// ========== SEANCE MODEL ==========
import '../../../core/status_enum.dart';
import 'cours_model.dart';  // AJOUT IMPORTANT

class Seance {
  final int? idSeance;
  final int idCours;
  final DateTime dateSeance;
  final String heureDebut;
  final String heureFin;
  final StatutSeance statut;

  // AJOUT CRITIQUE : Relation avec Cours
  Cours? cours;

  Seance({
    this.idSeance,
    required this.idCours,
    required this.dateSeance,
    required this.heureDebut,
    required this.heureFin,
    this.statut = StatutSeance.prevu,
    this.cours, // AJOUT
  });

  factory Seance.fromJson(Map<String, dynamic> json) {
    print('🔍 Seance.fromJson - JSON reçu: ${json.keys.toList()}'); // DEBUG

    Cours? parsedCours;

    // Vérifier si 'cours' est présent dans la réponse
    if (json['cours'] != null) {
      print(' Cours trouvé dans la réponse API');
      parsedCours = Cours.fromJson(json['cours']);
    } else {
      print(' Cours NON trouvé dans la réponse API');
    }

    return Seance(
      idSeance: json['id_seance'],
      idCours: json['id_cours'],
      dateSeance: DateTime.parse(json['date_seance']),
      heureDebut: json['heure_debut'],
      heureFin: json['heure_fin'],
      statut: StatutSeance.fromString(json['statut'] ?? 'prevu'),
      cours: parsedCours, // AJOUT
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idSeance != null) 'id_seance': idSeance,
      'id_cours': idCours,
      'date_seance': dateSeance.toIso8601String().split('T')[0],
      'heure_debut': heureDebut,
      'heure_fin': heureFin,
      'statut': statut.value,
      //if (cours != null) 'cours': cours!.toJson(),
    };
  }

  // Getters pour faciliter l'accès aux données
  String get nomMatiere {
    return cours?.matiere?.nomMatiere ?? 'Matière inconnue';
  }

  String get nomProf {
    return cours?.prof?.nomProf ?? 'Prof inconnu';
  }

  String get nomClasse {
    return cours?.classe?.nomClasse ?? cours?.matiere?.classe?.nomClasse ?? 'Classe inconnue';
  }

  String get formattedDate {
    return '${dateSeance.day.toString().padLeft(2, '0')}/${dateSeance.month.toString().padLeft(2, '0')}/${dateSeance.year}';
  }

  String get formattedHeure {
    return '$heureDebut - $heureFin';
  }

  @override
  String toString() {
    return 'Seance(id: $idSeance, date: $formattedDate, heure: $formattedHeure, cours: ${cours?.idCours})';
  }
}