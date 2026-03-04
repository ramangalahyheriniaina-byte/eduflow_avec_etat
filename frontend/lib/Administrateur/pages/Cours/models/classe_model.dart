import 'matiere_model.dart';

class Classe {
  final int? idClasse;
  final String nomClasse;
  List<Matiere>? matieres;

  Classe({
    this.idClasse,
    required this.nomClasse,
    this.matieres,
  });

  factory Classe.fromJson(Map<String, dynamic> json) {
    return Classe(
      idClasse: json['id_classe'],
      nomClasse: json['nom_classe'],
      matieres: json['matieres'] != null
          ? (json['matieres'] as List).map((m) => Matiere.fromJson(m)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idClasse != null) 'id_classe': idClasse,
      'nom_classe': nomClasse,
      if (matieres != null) 'matieres': matieres!.map((m) => m.toJson()).toList(),
    };
  }
}