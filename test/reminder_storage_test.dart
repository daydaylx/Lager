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

    test('Mehrere Zeiten werden korrekt gespeichert', () async {
      const times = [
        ReminderTime(hour: 8, minute: 0),
        ReminderTime(hour: 12, minute: 30),
        ReminderTime(hour: 20, minute: 0),
      ];
      await ReminderStorage.save(
        ReminderSettings.defaults.copyWith(times: times),
      );
      final loaded = await ReminderStorage.load();
      expect(loaded.times, equals(times));
    });

    test('Wochentagauswahl wird korrekt gespeichert', () async {
      await ReminderStorage.save(
        ReminderSettings.defaults.copyWith(weekdays: [6, 7]),
      );
      final loaded = await ReminderStorage.load();
      expect(loaded.weekdays, [6, 7]);
    });

    test('Aktiviert-Umschalten false→true→false bleibt korrekt', () async {
      await ReminderStorage.save(ReminderSettings.defaults.copyWith(enabled: false));
      expect((await ReminderStorage.load()).enabled, isFalse);

      await ReminderStorage.save(ReminderSettings.defaults.copyWith(enabled: true));
      expect((await ReminderStorage.load()).enabled, isTrue);

      await ReminderStorage.save(ReminderSettings.defaults.copyWith(enabled: false));
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
        times: [
          ReminderTime(hour: 7, minute: 15),
          ReminderTime(hour: 21, minute: 45),
        ],
        weekdays: [1, 3, 5],
      );
      await ReminderStorage.save(original);
      final loaded = await ReminderStorage.load();
      expect(loaded, equals(original));
    });
  });
}
