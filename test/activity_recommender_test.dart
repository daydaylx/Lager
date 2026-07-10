import 'package:berichtsheft_merker/core/enums/day_type.dart';
import 'package:berichtsheft_merker/core/models/daily_entry.dart';
import 'package:berichtsheft_merker/features/today/activity_recommender.dart';
import 'package:flutter_test/flutter_test.dart';

DailyEntry _entry(
  DateTime date, {
  DayType dayType = DayType.betrieb,
  List<String> activities = const [],
}) {
  return DailyEntry(
    id: DailyEntry.idForDate(date),
    date: date,
    dayType: dayType,
    areas: const [],
    selectedActivities: activities,
    specialFlags: const [],
    reportNote: null,
    createdAt: date,
    updatedAt: date,
  );
}

void main() {
  group('computeFrequentActivityIds', () {
    test('sortiert nach Häufigkeit, letzter Nutzung und ID', () {
      final ids = computeFrequentActivityIds([
        _entry(DateTime(2026, 6, 10), activities: const ['a', 'b']),
        _entry(DateTime(2026, 6, 11), activities: const ['a']),
        _entry(DateTime(2026, 6, 12), activities: const ['d', 'c']),
        _entry(
          DateTime(2026, 6, 13),
          dayType: DayType.frei,
          activities: const ['ignored'],
        ),
      ]);

      expect(ids, ['a', 'c', 'd', 'b']);
    });
  });
}
