// Diese Tests sichern die Persistenzstabilität: Enum-Namen und Activity-IDs
// werden als Strings in Hive gespeichert. Umbenennungen würden bestehende
// Nutzereinträge unlesbar machen. Änderungen hier sind bewusste Entscheidungen,
// keine kosmetischen Aufräumarbeiten.
import 'package:flutter_test/flutter_test.dart';
import 'package:berichtsheft_merker/core/data/default_activities.dart';
import 'package:berichtsheft_merker/core/enums/activity_category.dart';
import 'package:berichtsheft_merker/core/enums/day_type.dart';
import 'package:berichtsheft_merker/core/enums/special_flag.dart';
import 'package:berichtsheft_merker/core/enums/training_area.dart';

void main() {
  group('DayType-Namen sind stabil (Hive speichert den .name-String)', () {
    test('alle erwarteten Namen vorhanden', () {
      const expected = [
        'betrieb',
        'berufsschule',
        'frei',
        'urlaub',
        'krank',
        'feiertag',
        'sonstiges',
      ];
      expect(DayType.values.map((e) => e.name).toList(), expected);
    });

    test('byName funktioniert für alle Werte', () {
      for (final name in DayType.values.map((e) => e.name)) {
        expect(() => DayType.values.byName(name), returnsNormally);
      }
    });
  });

  group('TrainingArea-Namen sind stabil', () {
    test('alle erwarteten Namen vorhanden', () {
      const expected = [
        'wareneingang',
        'lager',
        'transport',
        'kommissionierung',
        'verpackung',
        'versand',
        'inventur',
        'retouren',
      ];
      expect(TrainingArea.values.map((e) => e.name).toList(), expected);
    });
  });

  group('SpecialFlag-Namen sind stabil', () {
    test('alle erwarteten Namen vorhanden', () {
      const expected = [
        'selbststaendig',
        'unterAnleitung',
        'neuesGelernt',
        'problemAufgetreten',
        'kontrolle',
        'fehlerKorrigiert',
        'wiederholt',
      ];
      expect(SpecialFlag.values.map((e) => e.name).toList(), expected);
    });
  });

  group('ActivityCategory-Namen sind stabil', () {
    test('alle erwarteten Namen vorhanden', () {
      const expected = [
        'wareneingang',
        'einlagerung',
        'transport',
        'kommissionierung',
        'verpackung',
        'versand',
        'inventur',
        'retouren',
        'berufsschule',
        'sicherheit',
      ];
      expect(ActivityCategory.values.map((e) => e.name).toList(), expected);
    });
  });

  group('Activity-IDs sind stabil (werden in DailyEntry.selectedActivities gespeichert)', () {
    test('mindestens 87 Standardtätigkeiten vorhanden', () {
      expect(defaultActivities.length, greaterThanOrEqualTo(87));
    });

    test('alle IDs sind einzigartig', () {
      final ids = defaultActivities.map((a) => a.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('bekannte IDs pro Kategorie existieren weiterhin', () {
      final ids = defaultActivities.map((a) => a.id).toSet();

      const knownIds = [
        'wareneingang_01',
        'wareneingang_02',
        'wareneingang_03',
        'einlagerung_01',
        'transport_01',
        'kommissionierung_01',
        'verpackung_01',
        'versand_01',
        'inventur_01',
        'retouren_01',
        'berufsschule_01',
        'sicherheit_01',
        'sicherheit_02',
      ];

      for (final id in knownIds) {
        expect(ids, contains(id), reason: 'Activity-ID "$id" fehlt');
      }
    });

    test('IDs folgen dem erwarteten Muster <kategorie>_<nn>', () {
      final idPattern = RegExp(r'^[a-z]+_\d{2}$');
      for (final activity in defaultActivities) {
        expect(
          idPattern.hasMatch(activity.id),
          isTrue,
          reason: 'ID "${activity.id}" entspricht nicht dem Muster',
        );
      }
    });
  });
}
