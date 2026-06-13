import 'package:flutter_test/flutter_test.dart';
import 'package:berichtsheft_merker/core/models/reminder_settings.dart';

void main() {
  group('ReminderSettings.defaults', () {
    test('Standardwerte sind korrekt', () {
      expect(ReminderSettings.defaults.enabled, isFalse);
      expect(
        ReminderSettings.defaults.times,
        [const ReminderTime(hour: 20, minute: 0)],
      );
      expect(ReminderSettings.defaults.weekdays, [1, 2, 3, 4, 5]);
    });
  });

  group('ReminderTime', () {
    test('Gleichheit bei gleichen Werten', () {
      expect(
        const ReminderTime(hour: 20, minute: 0),
        equals(const ReminderTime(hour: 20, minute: 0)),
      );
    });

    test('Ungleichheit bei verschiedenen Werten', () {
      expect(
        const ReminderTime(hour: 8, minute: 0),
        isNot(equals(const ReminderTime(hour: 20, minute: 0))),
      );
    });

    test('fromString parst HH:MM korrekt', () {
      final t = ReminderTime.fromString('08:30');
      expect(t.hour, 8);
      expect(t.minute, 30);
    });

    test('toDisplayString gibt nullaufgefüllte Zeit zurück', () {
      expect(const ReminderTime(hour: 8, minute: 5).toDisplayString(), '08:05');
      expect(
          const ReminderTime(hour: 20, minute: 0).toDisplayString(), '20:00');
    });

    test('fromString wirft bei ungültigem Format', () {
      expect(() => ReminderTime.fromString('invalid'), throwsFormatException);
      expect(() => ReminderTime.fromString('25:00'), throwsFormatException);
      expect(() => ReminderTime.fromString('08:60'), throwsFormatException);
    });
  });

  group('ReminderSettings', () {
    test('Gleichheit funktioniert', () {
      const a = ReminderSettings(
        enabled: true,
        times: [ReminderTime(hour: 8, minute: 0)],
        weekdays: [1, 2, 3],
      );
      const b = ReminderSettings(
        enabled: true,
        times: [ReminderTime(hour: 8, minute: 0)],
        weekdays: [1, 2, 3],
      );
      expect(a, equals(b));
    });

    test('copyWith ändert nur angegebene Felder', () {
      final copy = ReminderSettings.defaults.copyWith(enabled: true);
      expect(copy.enabled, isTrue);
      expect(copy.times, ReminderSettings.defaults.times);
      expect(copy.weekdays, ReminderSettings.defaults.weekdays);
    });

    test('copyWith ohne Argumente erzeugt gleiche Einstellungen', () {
      expect(ReminderSettings.defaults.copyWith(),
          equals(ReminderSettings.defaults));
    });
  });
}
