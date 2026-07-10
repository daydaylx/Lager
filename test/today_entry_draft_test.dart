import 'package:berichtsheft_merker/core/enums/day_type.dart';
import 'package:berichtsheft_merker/core/enums/special_flag.dart';
import 'package:berichtsheft_merker/core/enums/training_area.dart';
import 'package:berichtsheft_merker/core/models/adhoc_activity.dart';
import 'package:berichtsheft_merker/core/models/daily_entry.dart';
import 'package:berichtsheft_merker/features/today/today_entry_draft.dart';
import 'package:flutter_test/flutter_test.dart';

TodayEntryDraft _draft({
  DateTime? date,
  DayType dayType = DayType.betrieb,
  Set<TrainingArea> areas = const {},
  Set<String> activities = const {},
  Set<SpecialFlag> flags = const {},
  String reportNote = '',
  String privateNote = '',
  Map<String, String> adhocActivities = const {},
}) {
  return TodayEntryDraft(
    date: date ?? DateTime(2026, 6, 12),
    dayType: dayType,
    selectedAreas: areas,
    selectedActivityIds: activities,
    selectedSpecialFlags: flags,
    reportNote: reportNote,
    privateNote: privateNote,
    adhocActivities: adhocActivities,
  );
}

void main() {
  group('TodayEntryDraft', () {
    test('Betrieb braucht Bereich und Tätigkeit', () {
      final empty = _draft();
      expect(empty.canSave, isFalse);
      expect(empty.missingItems, ['Bereich', 'Tätigkeit']);

      final withArea = _draft(areas: {TrainingArea.wareneingang});
      expect(withArea.canSave, isFalse);
      expect(withArea.missingItems, ['Tätigkeit']);

      final complete = _draft(
        areas: {TrainingArea.wareneingang},
        activities: {'wareneingang_01'},
      );
      expect(complete.canSave, isTrue);
      expect(complete.missingItems, isEmpty);
    });

    test('Berufsschule braucht nur Tätigkeit', () {
      final empty = _draft(dayType: DayType.berufsschule);
      expect(empty.canSave, isFalse);
      expect(empty.missingItems, ['Tätigkeit']);

      final complete = _draft(
        dayType: DayType.berufsschule,
        activities: {'berufsschule_01'},
      );
      expect(complete.canSave, isTrue);
      expect(complete.missingItems, isEmpty);
    });

    test('Abwesenheiten und Sonstiges sind direkt speicherbar', () {
      for (final dayType in [
        DayType.frei,
        DayType.urlaub,
        DayType.krank,
        DayType.feiertag,
        DayType.sonstiges,
      ]) {
        final draft = _draft(dayType: dayType);
        expect(draft.canSave, isTrue, reason: dayType.name);
        expect(draft.missingItems, isEmpty, reason: dayType.name);
      }
    });

    test('toEntry trimmt Berichtsnotiz und erhält Erstellungszeit', () {
      final date = DateTime(2026, 6, 12);
      final createdAt = DateTime(2026, 6, 12, 8);
      final updatedAt = DateTime(2026, 6, 12, 17);
      final existing = DailyEntry(
        id: DailyEntry.idForDate(date),
        date: date,
        dayType: DayType.sonstiges,
        areas: const [],
        selectedActivities: const [],
        specialFlags: const [],
        reportNote: 'Alt',
        createdAt: createdAt,
        updatedAt: DateTime(2026, 6, 12, 9),
      );

      final entry = _draft(
        date: date,
        dayType: DayType.betrieb,
        areas: {TrainingArea.wareneingang},
        activities: {'wareneingang_01'},
        flags: {SpecialFlag.kontrolle, SpecialFlag.selbststaendig},
        reportNote: '  Neue Notiz  ',
      ).toEntry(timestamp: updatedAt, existingEntry: existing);

      expect(entry.id, DailyEntry.idForDate(date));
      expect(entry.createdAt, createdAt);
      expect(entry.updatedAt, updatedAt);
      expect(entry.reportNote, 'Neue Notiz');
      expect(entry.privateNote, isNull);
      expect(entry.areas, [TrainingArea.wareneingang]);
      expect(entry.selectedActivities, ['wareneingang_01']);
      expect(
        entry.specialFlags,
        [SpecialFlag.selbststaendig, SpecialFlag.kontrolle],
      );
    });

    test('toEntry speichert private Notiz getrennt von Berichtsnotiz', () {
      final timestamp = DateTime(2026, 6, 12, 17);
      final entry = _draft(
        dayType: DayType.betrieb,
        areas: {TrainingArea.wareneingang},
        activities: {'wareneingang_01'},
        reportNote: 'Fürs Berichtsheft',
        privateNote: '  Nur für mich  ',
      ).toEntry(timestamp: timestamp);

      expect(entry.reportNote, 'Fürs Berichtsheft');
      expect(entry.privateNote, 'Nur für mich');
    });

    test('toEntry übernimmt einmalige Tätigkeiten', () {
      final timestamp = DateTime(2026, 6, 12, 17);
      final entry = _draft(
        dayType: DayType.betrieb,
        areas: {TrainingArea.wareneingang},
        activities: {'wareneingang_01', 'adhoc_1'},
        adhocActivities: const {'adhoc_1': 'Sonderaufgabe'},
      ).toEntry(timestamp: timestamp);

      expect(
        entry.adhocActivities,
        [const AdhocActivity(id: 'adhoc_1', title: 'Sonderaufgabe')],
      );
      expect(entry.selectedActivities, contains('adhoc_1'));
    });

    test('toEntry entfernt Bereiche bei Nicht-Betrieb und leere Notiz', () {
      final timestamp = DateTime(2026, 6, 12, 17);
      final entry = _draft(
        dayType: DayType.berufsschule,
        areas: {TrainingArea.wareneingang},
        activities: {'berufsschule_01'},
        reportNote: '   ',
      ).toEntry(timestamp: timestamp);

      expect(entry.areas, isEmpty);
      expect(entry.reportNote, isNull);
      expect(entry.privateNote, isNull);
      expect(entry.createdAt, timestamp);
      expect(entry.updatedAt, timestamp);
    });
  });
}
