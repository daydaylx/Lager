import '../../core/enums/day_type.dart';
import '../../core/enums/special_flag.dart';
import '../../core/enums/training_area.dart';
import '../../core/models/daily_entry.dart';

class TodayEntryDraft {
  final DateTime date;
  final DayType dayType;
  final Set<TrainingArea> selectedAreas;
  final Set<String> selectedActivityIds;
  final Set<SpecialFlag> selectedSpecialFlags;
  final String note;

  const TodayEntryDraft({
    required this.date,
    required this.dayType,
    required this.selectedAreas,
    required this.selectedActivityIds,
    required this.selectedSpecialFlags,
    required this.note,
  });

  bool get canSave {
    return switch (dayType) {
      DayType.betrieb =>
        selectedAreas.isNotEmpty && selectedActivityIds.isNotEmpty,
      DayType.berufsschule => selectedActivityIds.isNotEmpty,
      DayType.frei ||
      DayType.urlaub ||
      DayType.krank ||
      DayType.feiertag ||
      DayType.sonstiges =>
        true,
    };
  }

  List<String> get missingItems {
    final items = <String>[];
    if (dayType == DayType.betrieb && selectedAreas.isEmpty) {
      items.add('Bereich');
    }
    if (dayType.supportsActivities && selectedActivityIds.isEmpty) {
      items.add('Tätigkeit');
    }
    return items;
  }

  DailyEntry toEntry({
    required DateTime timestamp,
    DailyEntry? existingEntry,
  }) {
    final trimmedNote = note.trim();
    return DailyEntry(
      id: DailyEntry.idForDate(date),
      date: date,
      dayType: dayType,
      areas: dayType == DayType.betrieb
          ? selectedAreas.toList(growable: false)
          : const [],
      selectedActivities: selectedActivityIds.toList(growable: false),
      specialFlags: SpecialFlag.values
          .where(selectedSpecialFlags.contains)
          .toList(growable: false),
      note: trimmedNote.isEmpty ? null : trimmedNote,
      createdAt: existingEntry?.createdAt ?? timestamp,
      updatedAt: timestamp,
    );
  }
}
