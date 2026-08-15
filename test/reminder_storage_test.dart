import 'dart:convert';

import 'package:berichtsheft_merker/core/models/reminder_settings.dart';
import 'package:berichtsheft_merker/core/storage/reminder_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ReminderStorage V2', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('frisches Laden liefert Defaults und legt V2 atomar an', () async {
      final settings = await ReminderStorage.load();
      final prefs = await SharedPreferences.getInstance();

      expect(settings, ReminderSettings.defaults);
      final stored = jsonDecode(prefs.getString('reminder_settings_v2')!);
      expect(stored['version'], 2);
      expect(stored['enabled'], isFalse);
      expect(stored['time'], '20:00');
      expect(stored['weekdays'], [1, 2, 3, 4, 5]);
    });

    test('vollständiger V2-Roundtrip bleibt erhalten', () async {
      const original = ReminderSettings(
        enabled: true,
        time: ReminderTime(hour: 7, minute: 15),
        weekdays: [1, 3, 5],
      );

      await ReminderStorage.save(original);

      expect(await ReminderStorage.load(), original);
    });

    test('alte drei Schlüssel werden auf V2 migriert', () async {
      SharedPreferences.setMockInitialValues({
        'reminder_enabled': true,
        'reminder_times': '["20:00", "08:30", "ungültig"]',
        'reminder_weekdays': '[5, 1, 1, 9]',
      });

      final loaded = await ReminderStorage.load();
      final prefs = await SharedPreferences.getInstance();

      expect(loaded.enabled, isTrue);
      expect(loaded.time, const ReminderTime(hour: 8, minute: 30));
      expect(loaded.weekdays, [1, 5]);
      expect(prefs.getString('reminder_settings_v2'), isNotNull);
    });

    test('leere Legacy-Listen werden auf sichere Defaults repariert', () async {
      SharedPreferences.setMockInitialValues({
        'reminder_enabled': true,
        'reminder_times': '[]',
        'reminder_weekdays': '[]',
      });

      final loaded = await ReminderStorage.load();

      expect(loaded.time, ReminderSettings.defaults.time);
      expect(loaded.weekdays, ReminderSettings.defaults.weekdays);
    });

    test('beschädigtes V2 wird sicher deaktiviert und neu geschrieben',
        () async {
      SharedPreferences.setMockInitialValues({
        'reminder_settings_v2': '{kein json',
        'reminder_enabled': true,
      });

      final loaded = await ReminderStorage.load();
      final prefs = await SharedPreferences.getInstance();

      expect(loaded, ReminderSettings.defaults);
      expect(
        jsonDecode(prefs.getString('reminder_settings_v2')!)['enabled'],
        isFalse,
      );
    });

    test('unvollständiges V2 wird nicht teilweise übernommen', () async {
      SharedPreferences.setMockInitialValues({
        'reminder_settings_v2': jsonEncode({
          'version': 2,
          'enabled': true,
          'time': '08:00',
        }),
      });

      expect(await ReminderStorage.load(), ReminderSettings.defaults);
    });
  });
}
