import '../../core/enums/day_type.dart';
import '../../core/enums/special_flag.dart';
import '../../core/enums/training_area.dart';
import '../../core/models/adhoc_activity.dart';
import '../../core/models/daily_entry.dart';

class TodayEntryDraft {
  final DateTime date;
  final DayType dayType;
  final Set<TrainingArea> selectedAreas;
  final Set<String> selectedActivityIds;
  final Set<SpecialFlag> selectedSpecialFlags;
  final String reportNote;
  final String privateNote;
  final Map<String, String> adhocActivities;

  const TodayEntryDraft({
    required this.date,
    required this.dayType,
    required this.selectedAreas,
    required this.selectedActivityIds,
    required this.selectedSpecialFlags,
    required this.reportNote,
    required this.privateNote,
    required this.adhocActivities,
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
    final trimmedReportNote = reportNote.trim();
    final trimmedPrivateNote = privateNote.trim();
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
      reportNote: trimmedReportNote.isEmpty ? null : trimmedReportNote,
      privateNote: trimmedPrivateNote.isEmpty ? null : trimmedPrivateNote,
      adhocActivities: adhocActivities.entries
          .map((e) => AdhocActivity(id: e.key, title: e.value))
          .toList(growable: false),
      createdAt: existingEntry?.createdAt ?? timestamp,
      updatedAt: timestamp,
    );
  }
}
