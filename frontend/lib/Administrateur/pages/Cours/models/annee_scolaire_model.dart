class AnneeScolaire {
  final int? idAnneeScolaire;
  final int startYear;
  final int endYear;
  final bool isActive;

  AnneeScolaire({
    this.idAnneeScolaire,
    required this.startYear,
    required this.endYear,
    this.isActive = true,
  });

  factory AnneeScolaire.fromJson(Map<String, dynamic> json) {
    return AnneeScolaire(
      idAnneeScolaire: json['id_annee_scolaire'],
      startYear: json['start_year'],
      endYear: json['end_year'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idAnneeScolaire != null) 'id_annee_scolaire': idAnneeScolaire,
      'start_year': startYear,
      'end_year': endYear,
      'is_active': isActive,
    };
  }

  String get displayName => '$startYear-$endYear';
}