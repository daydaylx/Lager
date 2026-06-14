import 'package:flutter_test/flutter_test.dart';
import 'package:berichtsheft_merker/core/enums/day_type.dart';
import 'package:berichtsheft_merker/core/enums/special_flag.dart';
import 'package:berichtsheft_merker/core/enums/training_area.dart';
import 'package:berichtsheft_merker/core/models/daily_entry.dart';
import 'package:berichtsheft_merker/core/report/daily_report_generator.dart';

DailyEntry _entry({
  DayType dayType = DayType.betrieb,
  TrainingArea? area = TrainingArea.wareneingang,
  List<String> activities = const [],
  List<SpecialFlag> flags = const [],
  String? note,
}) {
  final date = DateTime(2024, 6, 3);
  return DailyEntry(
    id: DailyEntry.idForDate(date),
    date: date,
    dayType: dayType,
    area: dayType == DayType.betrieb ? area : null,
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
        _entry(area: null, activities: ['wareneingang_01']),
        _titles,
      );
      expect(result, contains('Im Betrieb'));
      expect(result, contains('Ware angenommen'));
    });

    test('ohne area + ohne bekannte Tätigkeiten — generischer Betriebstext',
        () {
      final result = DailyReportGenerator.generate(
        _entry(area: null, activities: []),
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

    test('problemAufgetreten ohne Notiz — kein Problem-Satz', () {
      final result = DailyReportGenerator.generate(
        _entry(
          activities: ['wareneingang_01'],
          flags: [SpecialFlag.problemAufgetreten],
        ),
        _titles,
      );
      expect(result, isNot(contains('Problem')));
    });

    test('problemAufgetreten mit Notiz — Hinweis erscheint', () {
      final result = DailyReportGenerator.generate(
        _entry(
          activities: ['wareneingang_01'],
          flags: [SpecialFlag.problemAufgetreten],
          note: 'Lieferung fehlerhaft',
        ),
        _titles,
      );
      expect(result, contains('Zusatznotiz'));
    });

    test('fehlerKorrigiert und kontrolle — nicht im Bericht', () {
      final result = DailyReportGenerator.generate(
        _entry(
          activities: ['wareneingang_01'],
          flags: [SpecialFlag.fehlerKorrigiert, SpecialFlag.kontrolle],
        ),
        _titles,
      );
      expect(result, isNot(contains('Fehler')));
      expect(result, isNot(contains('Kontrolle')));
    });
  });
}
