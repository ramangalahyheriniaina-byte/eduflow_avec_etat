// 📁 lib/pages/edt/Model/edtModel.dart

import '../../../core/status_enum.dart';
import '../../Cours/models/cours_model.dart';

/// Model EDT = Une séance d'un cours
/// Correspond à la table "seance" en BDD
class Edt {
  final int? idSeance;
  final int idCours;
  final DateTime dateSeance;
  final String heureDebut;
  final String heureFin;
  StatutSeance statut;

  // Relations (chargées depuis le ViewModel)
  Cours? cours; // Pour afficher matiere, prof, classe

  Edt({
    this.idSeance,
    required this.idCours,
    required this.dateSeance,
    required this.heureDebut,
    required this.heureFin,
    this.statut = StatutSeance.prevu,
    this.cours,
  });

  /// 🆕 Convertir en JSON (pour backend)
  Map<String, dynamic> toJson() => {
    if (idSeance != null) 'id_seance': idSeance,
    'id_cours': idCours,
    'date_seance': dateSeance.toIso8601String().split('T')[0], // YYYY-MM-DD
    'heure_debut': heureDebut,
    'heure_fin': heureFin,
    'statut': statut.value,
  };

  /// 🆕 Créer depuis JSON (pour backend) - MODIFIÉ !
  factory Edt.fromJson(Map<String, dynamic> json) {
    // CORRECTION : Simplifier le parsing du statut
    final statutString = json['statut'] as String? ?? 'prevu';

    // Convertir le string en StatutSeance
    StatutSeance statut;

    // Supprimer accents et espaces
    final cleanedStatut = statutString
        .toLowerCase()
        .trim()
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e');

    if (cleanedStatut.contains('annul')) {
      statut = StatutSeance.annule;
    } else if (cleanedStatut.contains('termine')) {
      statut = StatutSeance.termine;
    } else if (cleanedStatut.contains('en cours') || cleanedStatut.contains('encours')) {
      statut = StatutSeance.enCours;
    } else {
      statut = StatutSeance.prevu; // Valeur par défaut
    }

    // CORRECTION : Parser les heures (gérer le format avec secondes)
    String heureDebut = json['heure_debut'] as String? ?? '';
    String heureFin = json['heure_fin'] as String? ?? '';

    // Extraire seulement HH:MM si format HH:MM:SS
    if (heureDebut.length > 5) {
      heureDebut = heureDebut.substring(0, 5);
    }
    if (heureFin.length > 5) {
      heureFin = heureFin.substring(0, 5);
    }

    // Créer l'instance
    final edt = Edt(
      idSeance: json['id_seance'] as int?,
      idCours: json['id_cours'] as int,
      dateSeance: DateTime.parse(json['date_seance'] as String),
      heureDebut: heureDebut,
      heureFin: heureFin,
      statut: statut,
    );

    // Charger le cours si présent
    if (json['cours'] != null) {
      try {
        final coursJson = json['cours'] as Map<String, dynamic>;
        edt.cours = Cours.fromJson(coursJson);
      } catch (e) {
        print('⚠️ Erreur parsing cours dans Edt: $e');
      }
    }

    return edt;
  }

  /// Alternative: fromJson avec cours optionnel
  factory Edt.fromJsonWithCours(Map<String, dynamic> json, Cours? coursAssocie) {
    final edt = Edt(
      idSeance: json['id_seance'],
      idCours: json['id_cours'],
      dateSeance: DateTime.parse(json['date_seance']),
      heureDebut: json['heure_debut'],
      heureFin: json['heure_fin'],
      statut: StatutSeance.fromString(json['statut'] ?? 'prevu'),
      cours: coursAssocie, // <-- Cours déjà chargé séparément
    );

    return edt;
  }

  /// 🆕 Jour de la semaine (Lundi, Mardi, etc.)
  String get jourSemaine {
    const jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    return jours[dateSeance.weekday - 1];
  }

  /// 🆕 Date formatée (ex: 15/01/2025)
  String get dateFormatee {
    return '${dateSeance.day.toString().padLeft(2, '0')}/${dateSeance.month.toString().padLeft(2, '0')}/${dateSeance.year}';
  }

  /// 🆕 Vérifier si ce cours est aujourd'hui
  bool get estAujourdhui {
    final aujourdhui = DateTime.now();
    return dateSeance.year == aujourdhui.year &&
        dateSeance.month == aujourdhui.month &&
        dateSeance.day == aujourdhui.day;
  }

  /// 🆕 Vérifier si ce cours appartient à la semaine actuelle
  bool get estSemaineActuelle {
    final aujourdhui = DateTime.now();
    final lundiActuel = aujourdhui.subtract(Duration(days: aujourdhui.weekday - 1));
    final lundiSeance = dateSeance.subtract(Duration(days: dateSeance.weekday - 1));

    return lundiSeance.year == lundiActuel.year &&
        lundiSeance.month == lundiActuel.month &&
        lundiSeance.day == lundiActuel.day;
  }

  /// 🆕 Calculer le statut en temps réel
  String get statutActuel {
    if (statut == StatutSeance.annule) return 'Annulé';
    if (!estAujourdhui) return 'À venir';

    final maintenant = DateTime.now();
    final heureDebutParsed = _parseHeure(heureDebut);
    final heureFinParsed = _parseHeure(heureFin);

    if (maintenant.isBefore(heureDebutParsed)) return 'À venir';
    if (maintenant.isAfter(heureFinParsed)) return 'Terminé';

    return 'En cours';
  }

  /// 🆕 Lundi de la semaine de cette séance
  DateTime get lundiDeLaSemaine {
    return dateSeance.subtract(Duration(days: dateSeance.weekday - 1));
  }

  // ========== GETTERS POUR L'AFFICHAGE ==========

  String get nomMatiere {
    // Essayer dans l'ordre :
    // 1. Cours.matiere
    // 2. Fallback
    if (cours?.matiere?.nomMatiere != null) {
      return cours!.matiere!.nomMatiere;
    }
    return 'Matière inconnue';
  }

  String get nomProf {
    if (cours?.prof?.nomProf != null) {
      return cours!.prof!.nomProf;
    }
    return 'Prof inconnu';
  }

  String get nomClasse {
    // Essayer dans l'ordre :
    // 1. Cours.matiere.classe
    // 2. Cours.classe (si votre API le fournit)
    // 3. Fallback
    if (cours?.matiere?.classe?.nomClasse != null) {
      return cours!.matiere!.classe!.nomClasse;
    }
    if (cours?.classe?.nomClasse != null) {
      return cours!.classe!.nomClasse;
    }
    return 'Classe inconnue';
  }

  // ========== HELPERS PRIVÉS ==========

  /// Parser une heure "14:30" en DateTime aujourd'hui
  DateTime _parseHeure(String heure) {
    final parts = heure.split(':');
    if (parts.length != 2) return DateTime.now();

    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;

    return DateTime(
      dateSeance.year,
      dateSeance.month,
      dateSeance.day,
      h,
      m,
    );
  }

  /// 🆕 Copier avec modifications
  Edt copyWith({
    int? idSeance,
    int? idCours,
    DateTime? dateSeance,
    String? heureDebut,
    String? heureFin,
    StatutSeance? statut,
    Cours? cours,
  }) {
    return Edt(
      idSeance: idSeance ?? this.idSeance,
      idCours: idCours ?? this.idCours,
      dateSeance: dateSeance ?? this.dateSeance,
      heureDebut: heureDebut ?? this.heureDebut,
      heureFin: heureFin ?? this.heureFin,
      statut: statut ?? this.statut,
      cours: cours ?? this.cours,
    );
  }
}