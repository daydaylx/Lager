import 'package:flutter_test/flutter_test.dart';
import 'package:berichtsheft_merker/core/enums/day_type.dart';
import 'package:berichtsheft_merker/core/enums/special_flag.dart';
import 'package:berichtsheft_merker/core/enums/training_area.dart';
import 'package:berichtsheft_merker/core/models/daily_entry.dart';
import 'package:berichtsheft_merker/core/report/daily_report_generator.dart';

DailyEntry _entry({
  DayType dayType = DayType.betrieb,
  List<TrainingArea> areas = const [TrainingArea.wareneingang],
  List<String> activities = const [],
  List<SpecialFlag> flags = const [],
  String? note,
}) {
  final date = DateTime(2024, 6, 3);
  return DailyEntry(
    id: DailyEntry.idForDate(date),
    date: date,
    dayType: dayType,
    areas: dayType == DayType.betrieb ? areas : const [],
    selectedActivities: activities,
    specialFlags: flags,
    note: note,
    createdAt: date,
    updatedAt: date,
  );
}

const _titles = {
  'wareneingang_01': 'Ware angenommen',
  'wareneingang_02': 'Lieferschein geprüft',
  'wareneingang_03': 'Artikel eingelagert',
  'berufsschule_01': 'Lagerwirtschaft Grundlagen',
  'berufsschule_02': 'Sicherheitsunterweisung',
};

void main() {
  group('DailyReportGenerator — Betrieb', () {
    test('area + 1 bekannte Tätigkeit', () {
      final result = DailyReportGenerator.generate(
        _entry(activities: ['wareneingang_01']),
        _titles,
      );
      expect(result, contains('Wareneingang'));
      expect(result, contains('Ware angenommen'));
      expect(result, isNot(contains('wareneingang_01')));
    });

    test('area + 3 bekannte Tätigkeiten — natürliche Listenformatierung', () {
      final result = DailyReportGenerator.generate(
        _entry(
          activities: [
            'wareneingang_01',
            'wareneingang_02',
            'wareneingang_03',
          ],
        ),
        _titles,
      );
      expect(result, contains('Ware angenommen'));
      expect(result, contains('Lieferschein geprüft und Artikel eingelagert'));
      expect(result, isNot(matches(RegExp(r'wareneingang_\d+'))));
    });

    test('mehrere Bereiche werden ohne erfundene Inhalte formuliert', () {
      final result = DailyReportGenerator.generate(
        _entry(
          areas: const [TrainingArea.wareneingang, TrainingArea.verpackung],
          activities: ['wareneingang_01', 'wareneingang_02'],
        ),
        _titles,
      );
      expect(result, contains('Bereichen Wareneingang und Verpackung'));
      expect(result, contains('Ware angenommen und Lieferschein geprüft'));
    });

    test('2 Tätigkeiten — "X und Y"', () {
      final result = DailyReportGenerator.generate(
        _entry(activities: ['wareneingang_01', 'wareneingang_02']),
        _titles,
      );
      expect(result, contains('Ware angenommen und Lieferschein geprüft'));
    });

    test('area + nur unbekannte IDs — keine rohe ID, sinnvoller Fallback', () {
      final result = DailyReportGenerator.generate(
        _entry(activities: ['unbekannt_99', 'alt_07']),
        _titles,
      );
      expect(result, isNot(contains('unbekannt_99')));
      expect(result, isNot(contains('alt_07')));
      expect(result, contains('Wareneingang'));
    });

    test('gemischt bekannte + unbekannte IDs — unbekannte werden ignoriert',
        () {
      final result = DailyReportGenerator.generate(
        _entry(activities: ['wareneingang_01', 'unbekannt_99']),
        _titles,
      );
      expect(result, contains('Ware angenommen'));
      expect(result, isNot(contains('unbekannt_99')));
    });

    test('ohne area + bekannte Tätigkeiten — Fallback auf Betrieb', () {
      final result = DailyReportGenerator.generate(
        _entry(areas: const [], activities: ['wareneingang_01']),
        _titles,
      );
      expect(result, contains('Im Betrieb'));
      expect(result, contains('Ware angenommen'));
    });

    test('ohne area + ohne bekannte Tätigkeiten — generischer Betriebstext',
        () {
      final result = DailyReportGenerator.generate(
        _entry(areas: const [], activities: []),
        _titles,
      );
      expect(result, contains('Betriebstag'));
    });

    test('area + keine bekannten Tätigkeiten — Dokumentationstext', () {
      final result = DailyReportGenerator.generate(
        _entry(activities: ['unbekannt_01']),
        _titles,
      );
      expect(result, contains('Wareneingang'));
      expect(result, contains('wurden Tätigkeiten dokumentiert'));
    });
  });

  group('DailyReportGenerator — Berufsschule', () {
    test('mit Themen', () {
      final result = DailyReportGenerator.generate(
        _entry(
          dayType: DayType.berufsschule,
          activities: ['berufsschule_01', 'berufsschule_02'],
        ),
        _titles,
      );
      expect(result, contains('Berufsschule'));
      expect(result, contains('Lagerwirtschaft Grundlagen'));
      expect(result, contains('Sicherheitsunterweisung'));
    });

    test('ein Thema nutzt ein kurzes Berufsschulmuster', () {
      final result = DailyReportGenerator.generate(
        _entry(
          dayType: DayType.berufsschule,
          activities: ['berufsschule_01'],
        ),
        _titles,
      );
      expect(result, contains('In der Berufsschule'));
      expect(result, contains('Lagerwirtschaft Grundlagen'));
    });

    test('ohne Themen', () {
      final result = DailyReportGenerator.generate(
        _entry(dayType: DayType.berufsschule, activities: []),
        _titles,
      );
      expect(result, equals('Heute war Berufsschule.'));
    });
  });

  group('DailyReportGenerator — Abwesenheit', () {
    test('frei', () {
      final result = DailyReportGenerator.generate(
        _entry(dayType: DayType.frei),
        _titles,
      );
      expect(result, equals('Heute war frei.'));
    });

    test('urlaub', () {
      final result = DailyReportGenerator.generate(
        _entry(dayType: DayType.urlaub),
        _titles,
      );
      expect(result, equals('Heute hatte ich Urlaub.'));
    });

    test('krank', () {
      final result = DailyReportGenerator.generate(
        _entry(dayType: DayType.krank),
        _titles,
      );
      expect(result, equals('Heute war ich krank.'));
    });

    test('feiertag', () {
      final result = DailyReportGenerator.generate(
        _entry(dayType: DayType.feiertag),
        _titles,
      );
      expect(result, equals('Heute war Feiertag.'));
    });
  });

  group('DailyReportGenerator — Sonstiges', () {
    test('mit Notiz', () {
      const note = 'Besichtigung des neuen Lagers.';
      final result = DailyReportGenerator.generate(
        _entry(dayType: DayType.sonstiges, note: note),
        _titles,
      );
      expect(result, equals(note));
    });

    test('ohne Notiz', () {
      final result = DailyReportGenerator.generate(
        _entry(dayType: DayType.sonstiges),
        _titles,
      );
      expect(result, equals('Sonstiger Tag.'));
    });
  });

  group('DailyReportGenerator — SpecialFlags', () {
    test('selbststaendig', () {
      final result = DailyReportGenerator.generate(
        _entry(
          activities: ['wareneingang_01'],
          flags: [SpecialFlag.selbststaendig],
        ),
        _titles,
      );
      expect(result, contains('selbstständig gearbeitet'));
    });

    test('unterAnleitung', () {
      final result = DailyReportGenerator.generate(
        _entry(
          activities: ['wareneingang_01'],
          flags: [SpecialFlag.unterAnleitung],
        ),
        _titles,
      );
      expect(result, contains('unter Anleitung'));
    });

    test('neuesGelernt', () {
      final result = DailyReportGenerator.generate(
        _entry(
          activities: ['wareneingang_01'],
          flags: [SpecialFlag.neuesGelernt],
        ),
        _titles,
      );
      expect(result, contains('neue Aufgabe kennengelernt'));
    });

    test('wiederholt', () {
      final result = DailyReportGenerator.generate(
        _entry(
          activities: ['wareneingang_01'],
          flags: [SpecialFlag.wiederholt],
        ),
        _titles,
      );
      expect(result, contains('zur Übung wiederholt'));
    });

    test('problemAufgetreten ohne Notiz — kurzer Problem-Satz', () {
      final result = DailyReportGenerator.generate(
        _entry(
          activities: ['wareneingang_01'],
          flags: [SpecialFlag.problemAufgetreten],
        ),
        _titles,
      );
      expect(result, contains('Problem wurde festgehalten'));
    });

    test('problemAufgetreten mit Notiz — Notiz wird eingebunden', () {
      final result = DailyReportGenerator.generate(
        _entry(
          activities: ['wareneingang_01'],
          flags: [SpecialFlag.problemAufgetreten],
          note: 'Lieferung fehlerhaft',
        ),
        _titles,
      );
      expect(result, contains('Ein Problem wurde notiert'));
      expect(result, contains('Lieferung fehlerhaft'));
    });

    test('fehlerKorrigiert und kontrolle — erscheinen im Bericht', () {
      final result = DailyReportGenerator.generate(
        _entry(
          activities: ['wareneingang_01'],
          flags: [SpecialFlag.fehlerKorrigiert, SpecialFlag.kontrolle],
        ),
        _titles,
      );
      expect(result, contains('Fehler wurde besprochen und korrigiert'));
      expect(result, contains('Kontrolle wurde durchgeführt'));
    });

    test('Notiz ohne Problem-Flag wird kurz ergänzt', () {
      final result = DailyReportGenerator.generate(
        _entry(
          activities: ['wareneingang_01'],
          note: 'Lieferung kam später an',
        ),
        _titles,
      );
      expect(result, contains('Notiz:'));
      expect(result, contains('Lieferung kam später an'));
    });
  });

  group('DailyReportGenerator — SpecialFlags Berufsschule', () {
    test('selbststaendig in Berufsschule — schulspezifische Formulierung', () {
      final result = DailyReportGenerator.generate(
        _entry(
          dayType: DayType.berufsschule,
          activities: ['berufsschule_01'],
          flags: [SpecialFlag.selbststaendig],
        ),
        _titles,
      );
      expect(result, contains('selbstständig erarbeitet'));
      expect(result, isNot(contains('selbstständig gearbeitet')));
    });

    test('unterAnleitung in Berufsschule — schulspezifische Formulierung', () {
      final result = DailyReportGenerator.generate(
        _entry(
          dayType: DayType.berufsschule,
          activities: ['berufsschule_01'],
          flags: [SpecialFlag.unterAnleitung],
        ),
        _titles,
      );
      expect(result, contains('Themen wurden unter Anleitung behandelt'));
      expect(result, isNot(contains('Tätigkeiten erfolgten')));
    });

    test('neuesGelernt in Berufsschule — Thema statt Aufgabe', () {
      final result = DailyReportGenerator.generate(
        _entry(
          dayType: DayType.berufsschule,
          activities: ['berufsschule_01'],
          flags: [SpecialFlag.neuesGelernt],
        ),
        _titles,
      );
      expect(result, contains('neues Thema kennengelernt'));
      expect(result, isNot(contains('neue Aufgabe')));
    });

    test('wiederholt in Berufsschule — Inhalte statt Tätigkeiten', () {
      final result = DailyReportGenerator.generate(
        _entry(
          dayType: DayType.berufsschule,
          activities: ['berufsschule_01'],
          flags: [SpecialFlag.wiederholt],
        ),
        _titles,
      );
      expect(result, contains('Inhalte wurden zur Übung wiederholt'));
      expect(result, isNot(contains('Tätigkeiten wurden')));
    });

    test('kontrolle in Berufsschule — Lernkontrolle', () {
      final result = DailyReportGenerator.generate(
        _entry(
          dayType: DayType.berufsschule,
          activities: ['berufsschule_01'],
          flags: [SpecialFlag.kontrolle],
        ),
        _titles,
      );
      expect(result, contains('Lernkontrolle wurde durchgeführt'));
    });

    test('kombination: selbststaendig + kontrolle in Berufsschule', () {
      final result = DailyReportGenerator.generate(
        _entry(
          dayType: DayType.berufsschule,
          activities: ['berufsschule_01'],
          flags: [SpecialFlag.selbststaendig, SpecialFlag.kontrolle],
        ),
        _titles,
      );
      expect(result, contains('selbstständig erarbeitet'));
      expect(result, contains('Lernkontrolle'));
    });

    test('problemAufgetreten in Berufsschule — universell', () {
      final result = DailyReportGenerator.generate(
        _entry(
          dayType: DayType.berufsschule,
          activities: ['berufsschule_01'],
          flags: [SpecialFlag.problemAufgetreten],
        ),
        _titles,
      );
      expect(result, contains('Problem wurde festgehalten'));
    });
  });

  group('DailyReportGenerator — datumsbasierte Satzmuster', () {
    DailyEntry entryOnDay(int day, {int activityCount = 1}) {
      final date = DateTime(2026, 6, day);
      final activities = List.generate(activityCount, (i) => 'wareneingang_0${i + 1}');
      return DailyEntry(
        id: DailyEntry.idForDate(date),
        date: date,
        dayType: DayType.betrieb,
        areas: const [TrainingArea.wareneingang],
        selectedActivities: activities,
        specialFlags: const [],
        note: null,
        createdAt: date,
        updatedAt: date,
      );
    }

    test('gleiche Auswahl an zwei aufeinanderfolgenden Tagen erzeugt verschiedene Satzmuster', () {
      final result17 = DailyReportGenerator.generate(entryOnDay(17), _titles);
      final result18 = DailyReportGenerator.generate(entryOnDay(18), _titles);
      expect(result17, isNot(equals(result18)));
    });

    test('determinismus: gleicher Tag erzeugt immer denselben Text', () {
      final r1 = DailyReportGenerator.generate(entryOnDay(17), _titles);
      final r2 = DailyReportGenerator.generate(entryOnDay(17), _titles);
      expect(r1, equals(r2));
    });

    test('Berufsschule 3 Themen: Tag 18 erzeugt Variante 0', () {
      final date = DateTime(2026, 6, 18); // 18 % 3 == 0
      final entry = DailyEntry(
        id: DailyEntry.idForDate(date),
        date: date,
        dayType: DayType.berufsschule,
        areas: const [],
        selectedActivities: const [
          'berufsschule_01',
          'berufsschule_02',
          'wareneingang_01',
        ],
        specialFlags: const [],
        note: null,
        createdAt: date,
        updatedAt: date,
      );
      final titles = {
        ..._titles,
        'wareneingang_01': 'Lagerwirtschaft Praxis',
      };
      final result = DailyReportGenerator.generate(entry, titles);
      expect(result, contains('Heute war Berufsschule. Themen waren:'));
    });

    test('Berufsschule 3 Themen: Tag 19 erzeugt Variante 1', () {
      final date = DateTime(2026, 6, 19); // 19 % 3 == 1
      final entry = DailyEntry(
        id: DailyEntry.idForDate(date),
        date: date,
        dayType: DayType.berufsschule,
        areas: const [],
        selectedActivities: const [
          'berufsschule_01',
          'berufsschule_02',
          'wareneingang_01',
        ],
        specialFlags: const [],
        note: null,
        createdAt: date,
        updatedAt: date,
      );
      final titles = {
        ..._titles,
        'wareneingang_01': 'Lagerwirtschaft Praxis',
      };
      final result = DailyReportGenerator.generate(entry, titles);
      expect(result, contains('In der Berufsschule habe ich folgende Themen bearbeitet:'));
    });

    test('Berufsschule 3 Themen: Tag 20 erzeugt Variante 2', () {
      final date = DateTime(2026, 6, 20); // 20 % 3 == 2
      final entry = DailyEntry(
        id: DailyEntry.idForDate(date),
        date: date,
        dayType: DayType.berufsschule,
        areas: const [],
        selectedActivities: const [
          'berufsschule_01',
          'berufsschule_02',
          'wareneingang_01',
        ],
        specialFlags: const [],
        note: null,
        createdAt: date,
        updatedAt: date,
      );
      final titles = {
        ..._titles,
        'wareneingang_01': 'Lagerwirtschaft Praxis',
      };
      final result = DailyReportGenerator.generate(entry, titles);
      expect(result, contains('Die heutigen Themen in der Berufsschule waren:'));
    });
  });
}
