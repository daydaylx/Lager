import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:berichtsheft_merker/core/models/reminder_settings.dart';
import 'package:berichtsheft_merker/core/storage/reminder_storage.dart';

void main() {
  group('ReminderStorage', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Frisches Laden gibt Standardwerte zurück', () async {
      final settings = await ReminderStorage.load();
      expect(settings, equals(ReminderSettings.defaults));
    });

    test('Aktiviert speichern und laden gibt aktiviert zurück', () async {
      await ReminderStorage.save(
        ReminderSettings.defaults.copyWith(enabled: true),
      );
      final loaded = await ReminderStorage.load();
      expect(loaded.enabled, isTrue);
    });

    test('Deaktiviert speichern und laden gibt deaktiviert zurück', () async {
      await ReminderStorage.save(
        ReminderSettings.defaults.copyWith(enabled: false),
      );
      final loaded = await ReminderStorage.load();
      expect(loaded.enabled, isFalse);
    });

    test('Eine Zeit wird korrekt gespeichert', () async {
      const times = [ReminderTime(hour: 8, minute: 30)];
      await ReminderStorage.save(
        ReminderSettings.defaults.copyWith(times: times),
      );
      final loaded = await ReminderStorage.load();
      expect(loaded.times, equals(times));
    });

    test('Mehrere gespeicherte Zeiten werden auf die früheste reduziert',
        () async {
      const times = [
        ReminderTime(hour: 8, minute: 0),
        ReminderTime(hour: 12, minute: 30),
        ReminderTime(hour: 20, minute: 0),
      ];
      await ReminderStorage.save(
        ReminderSettings.defaults.copyWith(times: times),
      );
      final loaded = await ReminderStorage.load();
      expect(loaded.times, const [ReminderTime(hour: 8, minute: 0)]);
    });

    test('Wochentagauswahl wird korrekt gespeichert', () async {
      await ReminderStorage.save(
        ReminderSettings.defaults.copyWith(weekdays: [6, 7]),
      );
      final loaded = await ReminderStorage.load();
      expect(loaded.weekdays, [6, 7]);
    });

    test('Aktiviert-Umschalten false→true→false bleibt korrekt', () async {
      await ReminderStorage.save(
          ReminderSettings.defaults.copyWith(enabled: false));
      expect((await ReminderStorage.load()).enabled, isFalse);

      await ReminderStorage.save(
          ReminderSettings.defaults.copyWith(enabled: true));
      expect((await ReminderStorage.load()).enabled, isTrue);

      await ReminderStorage.save(
          ReminderSettings.defaults.copyWith(enabled: false));
      expect((await ReminderStorage.load()).enabled, isFalse);
    });

    test('Leere Zeitenliste wird korrekt gespeichert', () async {
      await ReminderStorage.save(
        ReminderSettings.defaults.copyWith(times: []),
      );
      final loaded = await ReminderStorage.load();
      expect(loaded.times, isEmpty);
    });

    test('Leere Wochentagliste wird korrekt gespeichert', () async {
      await ReminderStorage.save(
        ReminderSettings.defaults.copyWith(weekdays: []),
      );
      final loaded = await ReminderStorage.load();
      expect(loaded.weekdays, isEmpty);
    });

    test('Vollständiger Roundtrip bleibt erhalten', () async {
      const original = ReminderSettings(
        enabled: true,
        times: [ReminderTime(hour: 7, minute: 15)],
        weekdays: [1, 3, 5],
      );
      await ReminderStorage.save(original);
      final loaded = await ReminderStorage.load();
      expect(loaded, equals(original));
    });

    test('Korruptes times-JSON fällt auf Standardzeiten zurück', () async {
      SharedPreferences.setMockInitialValues({
        'reminder_times': 'KEIN_JSON',
      });
      final loaded = await ReminderStorage.load();
      expect(loaded.times, equals(ReminderSettings.defaults.times));
    });

    test('Korruptes weekdays-JSON fällt auf Standard-Wochentage zurück',
        () async {
      SharedPreferences.setMockInitialValues({
        'reminder_weekdays': '{KEIN_JSON}',
      });
      final loaded = await ReminderStorage.load();
      expect(loaded.weekdays, equals(ReminderSettings.defaults.weekdays));
    });

    test('Wochentage außerhalb 1..7 werden gefiltert', () async {
      SharedPreferences.setMockInitialValues({
        'reminder_weekdays': '[0, 1, 5, 8, 9]',
      });
      final loaded = await ReminderStorage.load();
      expect(loaded.weekdays, [1, 5]);
    });

    test('Doppelte Wochentage werden dedupliziert und sortiert', () async {
      SharedPreferences.setMockInitialValues({
        'reminder_weekdays': '[5, 1, 3, 1, 5]',
      });
      final loaded = await ReminderStorage.load();
      expect(loaded.weekdays, [1, 3, 5]);
    });

    test('Leere Wochentagsliste bleibt leer', () async {
      SharedPreferences.setMockInitialValues({
        'reminder_weekdays': '[]',
      });
      final loaded = await ReminderStorage.load();
      expect(loaded.weekdays, isEmpty);
    });

    test('Nicht-int-Einträge in weekdays-JSON werden ignoriert', () async {
      SharedPreferences.setMockInitialValues({
        'reminder_weekdays': '[1, "abc", 3, null, 5]',
      });
      final loaded = await ReminderStorage.load();
      expect(loaded.weekdays, [1, 3, 5]);
    });

    test('Ungültige Zeiteinträge verwerfen gültige Zeiten nicht', () async {
      SharedPreferences.setMockInitialValues({
        'reminder_times': '["08:00", 42, "ungültig", "20:00"]',
      });
      final loaded = await ReminderStorage.load();
      expect(
        loaded.times,
        const [ReminderTime(hour: 8, minute: 0)],
      );
    });

    test('copyWith erzeugt unmodifiable Liste', () {
      final settings = ReminderSettings.defaults.copyWith(weekdays: [1, 2, 3]);
      expect(() => settings.weekdays.add(4), throwsUnsupportedError);
      expect(() => settings.times.add(const ReminderTime(hour: 8, minute: 0)),
          throwsUnsupportedError);
    });
  });
}
