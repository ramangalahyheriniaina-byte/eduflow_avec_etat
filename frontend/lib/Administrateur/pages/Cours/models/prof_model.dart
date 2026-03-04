// ========== PROF MODEL ==========
class Prof {
  final int? idProf;
  final String nomProf;
  final int nbAbs;

  Prof({
    this.idProf,
    required this.nomProf,
    this.nbAbs = 0,
  });

  factory Prof.fromJson(Map<String, dynamic> json) {
    return Prof(
      idProf: json['id_prof'],
      nomProf: json['nom_prof'],
      nbAbs: json['nb_abs'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idProf != null) 'id_prof': idProf,
      'nom_prof': nomProf,
      'nb_abs': nbAbs,
    };
  }
}