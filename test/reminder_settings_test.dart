import 'package:berichtsheft_merker/core/models/reminder_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReminderTime', () {
    test('parst und formatiert HH:MM', () {
      expect(
        ReminderTime.fromString('08:30'),
        const ReminderTime(hour: 8, minute: 30),
      );
      expect(
        const ReminderTime(hour: 8, minute: 5).toDisplayString(),
        '08:05',
      );
    });

    test('weist ungültige persistierte Zeiten zurück', () {
      expect(() => ReminderTime.fromString('invalid'), throwsFormatException);
      expect(() => ReminderTime.fromString('25:00'), throwsFormatException);
      expect(() => ReminderTime.fromString('08:60'), throwsFormatException);
    });
  });

  group('ReminderSettings', () {
    test('Defaults sind aus, 20:00 und Montag bis Freitag', () {
      expect(ReminderSettings.defaults.enabled, isFalse);
      expect(
        ReminderSettings.defaults.time,
        const ReminderTime(hour: 20, minute: 0),
      );
      expect(ReminderSettings.defaults.weekdays, [1, 2, 3, 4, 5]);
    });

    test('copyWith ändert einzelne Werte und schützt die Tagesliste', () {
      final copy = ReminderSettings.defaults.copyWith(
        enabled: true,
        time: const ReminderTime(hour: 8, minute: 30),
        weekdays: [6, 7],
      );

      expect(copy.enabled, isTrue);
      expect(copy.time, const ReminderTime(hour: 8, minute: 30));
      expect(copy.weekdays, [6, 7]);
      expect(() => copy.weekdays.add(1), throwsUnsupportedError);
    });

    test('normalized filtert, dedupliziert und sortiert Wochentage', () {
      const settings = ReminderSettings(
        enabled: true,
        time: ReminderTime(hour: 7, minute: 15),
        weekdays: [5, 1, 5, 9, 0],
      );

      expect(settings.normalized().weekdays, [1, 5]);
    });

    test('normalized repariert eine leere Tagesliste', () {
      const settings = ReminderSettings(
        enabled: true,
        time: ReminderTime(hour: 7, minute: 15),
        weekdays: [],
      );

      expect(
          settings.normalized().weekdays, ReminderSettings.defaults.weekdays);
    });

    test('Gleichheit berücksichtigt Uhrzeit und Tage', () {
      const first = ReminderSettings(
        enabled: true,
        time: ReminderTime(hour: 8, minute: 0),
        weekdays: [1, 3, 5],
      );
      const second = ReminderSettings(
        enabled: true,
        time: ReminderTime(hour: 8, minute: 0),
        weekdays: [1, 3, 5],
      );

      expect(first, second);
    });
  });
}
