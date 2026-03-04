import 'package:flutter/material.dart';
import '../../../core/status_enum.dart';
import '../../edt/Model/edtModel.dart';

/// Model pour le Dashboard - Représente une séance en cours
class DashboardModel {
  final Edt seance;

  DashboardModel({required this.seance});

  factory DashboardModel.fromSeance(Edt seance) {
    return DashboardModel(seance: seance);
  }

  /// ✅ Statut EN TEMPS RÉEL basé sur l'heure actuelle
  StatutSeance get statutReel {
    final maintenant = DateTime.now();
    final dateSeance = seance.dateSeance;

    // Vérifier si c'est aujourd'hui
    final estAujourdhui = maintenant.year == dateSeance.year &&
        maintenant.month == dateSeance.month &&
        maintenant.day == dateSeance.day;

    // Si annulé en base, on garde annulé
    if (seance.statut == StatutSeance.annule) {
      return StatutSeance.annule;
    }

    // Si pas aujourd'hui, on garde le statut en base
    if (!estAujourdhui) {
      return seance.statut;
    }

    // Analyser les heures
    try {
      final debut = _parseHeure(seance.heureDebut);
      final fin = _parseHeure(seance.heureFin);

      if (maintenant.isBefore(debut)) {
        return StatutSeance.prevu;
      } else if (maintenant.isAfter(fin)) {
        return StatutSeance.termine;
      } else {
        return StatutSeance.enCours;
      }
    } catch (e) {
      // En cas d'erreur de parsing, retourner le statut en base
      return seance.statut;
    }
  }

  /// ✅ Couleurs selon le STATUT RÉEL
  Map<String, Color> get couleurs {
    switch (statutReel) {
      case StatutSeance.annule:
        return {
          'background': Colors.red.shade50,
          'badge': Colors.red,
          'text': Colors.red.shade800,
        };
      case StatutSeance.enCours:
        return {
          'background': Colors.orange.shade50,
          'badge': Colors.orange,
          'text': Colors.orange.shade800,
        };
      case StatutSeance.termine:
        return {
          'background': Colors.green.shade50,
          'badge': Colors.green,
          'text': Colors.green.shade800,
        };
      case StatutSeance.prevu:
      default:
        return {
          'background': const Color(0xFF10B981).withOpacity(0.1),
          'badge': const Color(0xFF10B981),
          'text': const Color(0xFF065F46),
        };
    }
  }

  /// ✅ Texte du badge selon le STATUT RÉEL
  String get badgeText {
    switch (statutReel) {
      case StatutSeance.annule:
        return "Annulé";
      case StatutSeance.enCours:
        return "En cours";
      case StatutSeance.termine:
        return "Terminé";
      case StatutSeance.prevu:
      default:
        return "Prévu";
    }
  }

  /// Conditions pour les boutons - BASÉ SUR STATUT RÉEL
  bool get peutEtreAnnule => statutReel != StatutSeance.annule &&
      statutReel != StatutSeance.termine;

  bool get peutEtreMarqueEnCours => statutReel == StatutSeance.prevu;

  bool get peutEtreTermine => statutReel == StatutSeance.enCours;

  bool get peutEtreLance => statutReel == StatutSeance.prevu;

  bool get peutEtreEnRetard {
    final maintenant = DateTime.now();
    final debut = _parseHeure(seance.heureDebut);
    return statutReel == StatutSeance.prevu &&
        maintenant.isAfter(debut);
  }

  /// Getters pour affichage
  String get nomMatiere => seance.cours?.matiere?.nomMatiere ?? 'Matière';

  String get nomProf => seance.cours?.prof?.nomProf ?? 'Professeur';

  String get nomClasse => seance.cours?.classe?.nomClasse ??
      seance.cours?.matiere?.classe?.nomClasse ?? 'Classe';

  String get heureDebut {
    final parts = seance.heureDebut.split(':');
    return parts.length >= 2 ? '${parts[0]}:${parts[1]}' : seance.heureDebut;
  }

  String get heureFin {
    final parts = seance.heureFin.split(':');
    return parts.length >= 2 ? '${parts[0]}:${parts[1]}' : seance.heureFin;
  }

  /// Helper privé pour parser les heures
  DateTime _parseHeure(String heure) {
    try {
      // Enlever les secondes si présentes (format HH:MM:SS)
      String heureFormatee = heure;
      if (heure.contains(':')) {
        final parts = heure.split(':');
        if (parts.length >= 2) {
          heureFormatee = '${parts[0]}:${parts[1]}';
        }
      }

      final parts = heureFormatee.split(':');
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
      final d = seance.dateSeance;
      return DateTime(d.year, d.month, d.day, h, m);
    } catch (_) {
      final d = seance.dateSeance;
      return DateTime(d.year, d.month, d.day, 0, 0);
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DashboardModel &&
        other.seance.idSeance == seance.idSeance &&
        other.statutReel == statutReel;
  }

  @override
  int get hashCode => seance.idSeance.hashCode ^ statutReel.hashCode;
}

/// Helper class pour représenter une heure (pour compatibilité)
class TimeOfDay {
  final int hour;
  final int minute;

  TimeOfDay({required this.hour, required this.minute});

  @override
  String toString() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}