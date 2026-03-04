// 📁 lib/core/status_enum.dart
enum StatutCours {
  nonCommence('non_commence'),
  enCours('en_cours'),
  termine('termine');

  final String value;
  const StatutCours(this.value);

  factory StatutCours.fromString(String value) {
    switch (value.toUpperCase()) {
      case 'NON_COMMENCE':
      case 'NON_COMMENCÉ':
        return StatutCours.nonCommence;
      case 'EN_COURS':
      case 'EN COURS':
        return StatutCours.enCours;
      case 'TERMINE':
      case 'TERMINÉ':
        return StatutCours.termine;
      default:
        return StatutCours.nonCommence;
    }
  }

  String get label {
    switch (this) {
      case StatutCours.nonCommence:
        return 'Non commencé';
      case StatutCours.enCours:
        return 'En cours';
      case StatutCours.termine:
        return 'Terminé';
    }
  }
}

enum StatutSeance {
  annule('annule'),
  prevu('prevu'),
  enCours('en_cours'),
  termine('termine');

  final String value;
  const StatutSeance(this.value);

  factory StatutSeance.fromString(String value) {
    switch (value.toUpperCase()) {
      case 'ANNULE':
      case 'ANNULÉ':
        return StatutSeance.annule;
      case 'PREVU':
      case 'PRÉVU':
        return StatutSeance.prevu;
      case 'EN_COURS':
      case 'EN COURS':
        return StatutSeance.enCours;
      case 'TERMINE':
      case 'TERMINÉ':
        return StatutSeance.termine;
      default:
        return StatutSeance.prevu;
    }
  }

  String get label {
    switch (this) {
      case StatutSeance.annule:
        return 'Annulé';
      case StatutSeance.prevu:
        return 'Prévu';
      case StatutSeance.enCours:
        return 'En cours';
      case StatutSeance.termine:
        return 'Terminé';
    }
  }
}

extension StatutSeanceExtension on StatutSeance {
  String get name => value;
}

extension StatutCoursExtension on StatutCours {
  String get name => value;
}