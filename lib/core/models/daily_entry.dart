import '../enums/day_type.dart';
import '../enums/special_flag.dart';
import '../enums/training_area.dart';
import 'adhoc_activity.dart';

class DailyEntry {
  final String id;
  final DateTime date;
  final DayType dayType;
  final List<TrainingArea> areas;
  final List<String> selectedActivities;
  final List<SpecialFlag> specialFlags;

  /// Ergänzung für das Berichtsheft. Darf vom Berichtsgenerator verwendet
  /// und in kopierten Berichten angezeigt werden.
  final String? reportNote;

  /// Private Notiz — nur für den Nutzer innerhalb der App. Darf niemals in
  /// einen generierten oder kopierten Berichtstext gelangen.
  final String? privateNote;

  /// Einmalige Freitext-Tätigkeiten, die nur für diesen Tag gelten.
  final List<AdhocActivity> adhocActivities;

  final DateTime createdAt;
  final DateTime updatedAt;

  const DailyEntry({
    required this.id,
    required this.date,
    required this.dayType,
    required this.areas,
    required this.selectedActivities,
    required this.specialFlags,
    required this.reportNote,
    this.privateNote,
    this.adhocActivities = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  static String idForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final month = normalizedDate.month.toString().padLeft(2, '0');
    final day = normalizedDate.day.toString().padLeft(2, '0');
    return '${normalizedDate.year}-$month-$day';
  }
}
