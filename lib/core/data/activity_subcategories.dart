import '../enums/activity_category.dart';
import '../models/activity_template.dart';

String? activitySubcategory(ActivityTemplate activity) {
  final explicit = activity.subcategory?.trim();
  if (explicit != null && explicit.isNotEmpty) return explicit;
  if (activity.isCustom) return null;

  final number = _idNumber(activity.id);
  if (number == null) return null;

  return switch (activity.category) {
    ActivityCategory.wareneingang => switch (number) {
        <= 2 => 'Annahme',
        <= 6 => 'Prüfung',
        <= 10 => 'Vorbereitung',
        _ => 'Scanner & Dokumentation',
      },
    ActivityCategory.einlagerung => switch (number) {
        <= 5 => 'Einlagerung',
        <= 10 => 'Ordnung & Lagerung',
        _ => 'System & Bestand',
      },
    ActivityCategory.transport => switch (number) {
        <= 4 => 'Transport',
        <= 7 => 'Sicherheit',
        _ => 'Ladehilfsmittel & Scanner',
      },
    ActivityCategory.kommissionierung => switch (number) {
        <= 5 => 'Auftrag & Entnahme',
        <= 8 => 'Kontrolle',
        _ => 'System & Bereitstellung',
      },
    ActivityCategory.verpackung => switch (number) {
        <= 4 => 'Verpacken',
        <= 8 => 'Material & Label',
        _ => 'Prüfung & Versandvorbereitung',
      },
    ActivityCategory.versand => switch (number) {
        <= 5 => 'Vorbereitung',
        <= 10 => 'Verladung',
        _ => 'System & Touren',
      },
    ActivityCategory.inventur => switch (number) {
        <= 4 => 'Zählen',
        <= 7 => 'Abgleich',
        _ => 'Scanner & Kontrolle',
      },
    ActivityCategory.retouren => switch (number) {
        <= 3 => 'Annahme',
        <= 6 => 'Prüfung',
        _ => 'System & Sortierung',
      },
    ActivityCategory.berufsschule => switch (number) {
        <= 5 => 'Unterricht',
        <= 11 => 'Übung & Wiederholung',
        _ => 'Fachthemen & Ausbildung',
      },
    ActivityCategory.sicherheit => switch (number) {
        <= 5 => 'Sicherheit',
        <= 10 => 'Ordnung & 5S',
        _ => 'Qualität & Unterweisung',
      },
  };
}

int? _idNumber(String id) {
  final match = RegExp(r'_(\d+)$').firstMatch(id);
  return match == null ? null : int.tryParse(match.group(1)!);
}
