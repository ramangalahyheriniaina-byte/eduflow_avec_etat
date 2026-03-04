// ========== MATIERE MODEL ==========
import 'classe_model.dart';

class Matiere {
  final int? idMatiere;
  final String nomMatiere;
  final int heureTotale;
  final int idClasse;
  Classe? classe;

  Matiere({
    this.idMatiere,
    required this.nomMatiere,
    required this.heureTotale,
    required this.idClasse,
    this.classe,
  });

  factory Matiere.fromJson(Map<String, dynamic> json) {
    return Matiere(
      idMatiere: json['id_matiere'],
      nomMatiere: json['nom_matiere'],
      heureTotale: json['heure_totale'],
      idClasse: json['id_classe'],
      classe: json['classe'] != null ? Classe.fromJson(json['classe']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idMatiere != null) 'id_matiere': idMatiere,
      'nom_matiere': nomMatiere,
      'heure_totale': heureTotale,
      'id_classe': idClasse,
      if (classe != null) 'classe': classe!.toJson(),
    };
  }
}