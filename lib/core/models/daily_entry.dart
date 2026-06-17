import '../enums/day_type.dart';
import '../enums/special_flag.dart';
import '../enums/training_area.dart';

class DailyEntry {
  final String id;
  final DateTime date;
  final DayType dayType;
  final List<TrainingArea> areas;
  final List<String> selectedActivities;
  final List<SpecialFlag> specialFlags;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DailyEntry({
    required this.id,
    required this.date,
    required this.dayType,
    required this.areas,
    required this.selectedActivities,
    required this.specialFlags,
    required this.note,
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
