import 'package:apk_web_eduflow/Administrateur/pages/Cours/models/prof_model.dart';
import 'package:apk_web_eduflow/Administrateur/pages/Cours/models/seance_model.dart';

import '../../../core/status_enum.dart';
import 'classe_model.dart';
import 'matiere_model.dart';

class Cours {
  final int? idCours;
  final StatutCours statut;
  final int idMatiere;
  final int idProf;
  final int cumul;

  // Relations (chargées depuis le ViewModel)
  Matiere? matiere;
  Prof? prof;
  Classe? classe;
  List<Seance>? seances;

  Cours({
    this.idCours,
    this.statut = StatutCours.nonCommence,
    required this.idMatiere,
    required this.idProf,
    this.cumul = 0,
    this.matiere,
    this.prof,
    this.classe,
    this.seances,
  });

  factory Cours.fromJson(Map<String, dynamic> json) {
    // CORRECTION : Vérifier la structure exacte de la réponse API
    // La réponse API devrait avoir 'matiere' au même niveau que 'prof' et 'classe'
    Matiere? parsedMatiere;
    if (json['matiere'] != null) {
      parsedMatiere = Matiere.fromJson(json['matiere']);
    } else if (json['cours'] != null && json['cours']['matiere'] != null) {
      // Fallback : si matiere est dans cours
      parsedMatiere = Matiere.fromJson(json['cours']['matiere']);
    }

    Prof? parsedProf;
    if (json['prof'] != null) {
      parsedProf = Prof.fromJson(json['prof']);
    } else if (json['cours'] != null && json['cours']['prof'] != null) {
      parsedProf = Prof.fromJson(json['cours']['prof']);
    }

    Classe? parsedClasse;
    if (json['classe'] != null) {
      parsedClasse = Classe.fromJson(json['classe']);
    } else if (json['cours'] != null && json['cours']['classe'] != null) {
      parsedClasse = Classe.fromJson(json['cours']['classe']);
    } else if (parsedMatiere != null && parsedMatiere.classe != null) {
      // Classe peut aussi être dans matiere
      parsedClasse = parsedMatiere.classe;
    }

    return Cours(
      idCours: json['id_cours'] ?? json['id'],
      statut: StatutCours.fromString(json['statut'] ?? 'non_commence'),
      idMatiere: json['id_matiere'],
      idProf: json['id_prof'],
      cumul: json['cumul'] ?? 0,
      matiere: parsedMatiere,
      prof: parsedProf,
      classe: parsedClasse,
      seances: json['seances'] != null
          ? (json['seances'] as List).map((s) => Seance.fromJson(s)).toList()
          : null,
    );
  }

  // AJOUTEZ CES DEUX MÉTHODES MANQUANTES :

  Map<String, dynamic> toJson() {
    return {
      if (idCours != null) 'id_cours': idCours,
      'statut': statut.value,
      'id_matiere': idMatiere,
      'id_prof': idProf,
      'cumul': cumul,
      if (matiere != null) 'matiere': matiere!.toJson(),
      if (prof != null) 'prof': prof!.toJson(),
      if (classe != null) 'classe': classe!.toJson(),
      if (seances != null) 'seances': seances!.map((s) => s.toJson()).toList(),
    };
  }

  Cours copyWith({
    int? idCours,
    StatutCours? statut,
    int? idMatiere,
    int? idProf,
    int? cumul,
    Matiere? matiere,
    Prof? prof,
    Classe? classe,
    List<Seance>? seances,
  }) {
    return Cours(
      idCours: idCours ?? this.idCours,
      statut: statut ?? this.statut,
      idMatiere: idMatiere ?? this.idMatiere,
      idProf: idProf ?? this.idProf,
      cumul: cumul ?? this.cumul,
      matiere: matiere ?? this.matiere,
      prof: prof ?? this.prof,
      classe: classe ?? this.classe,
      seances: seances ?? this.seances,
    );
  }

  double get progression {
    if (matiere == null || matiere!.heureTotale == 0) return 0;
    return (cumul / matiere!.heureTotale * 100).clamp(0, 100);
  }

  @override
  String toString() {
    return 'Cours(id: $idCours, matiere: ${matiere?.nomMatiere}, prof: ${prof?.nomProf}, classe: ${classe?.nomClasse})';
  }

  // SURCHARGE == ET HASHCODE pour éviter les doublons dans le dropdown
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Cours && other.idCours == idCours;
  }

  @override
  int get hashCode => idCours.hashCode;
}