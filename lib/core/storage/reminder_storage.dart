import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/reminder_settings.dart';
import 'preferences_write.dart';

class ReminderStorage {
  static const int schemaVersion = 2;

  static Future<ReminderSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final currentJson = prefs.getString(PreferenceKeys.reminderSettingsV2);
    if (currentJson != null) {
      try {
        return _decodeCurrent(currentJson);
      } catch (_) {
        final repaired = ReminderSettings.defaults.normalized();
        await _saveTo(prefs, repaired);
        return repaired;
      }
    }

    final migrated = _readLegacy(prefs);
    await _saveTo(prefs, migrated);
    return migrated;
  }

  static Future<void> save(ReminderSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await _saveTo(prefs, settings.normalized());
  }

  static Future<void> _saveTo(
    SharedPreferences prefs,
    ReminderSettings settings,
  ) async {
    final normalized = settings.normalized();
    await requirePreferenceWrite(
      prefs.setString(
        PreferenceKeys.reminderSettingsV2,
        jsonEncode({
          'version': schemaVersion,
          'enabled': normalized.enabled,
          'time': normalized.time.toDisplayString(),
          'weekdays': normalized.weekdays,
        }),
      ),
      message: 'Erinnerungseinstellungen konnten nicht gespeichert werden.',
    );
  }

  static ReminderSettings _decodeCurrent(String value) {
    final decoded = jsonDecode(value);
    if (decoded is! Map<String, dynamic> ||
        decoded['version'] != schemaVersion ||
        decoded['enabled'] is! bool ||
        decoded['time'] is! String ||
        decoded['weekdays'] is! List<dynamic>) {
      throw const FormatException('Ungültige Reminder-Einstellungen.');
    }

    final weekdays = (decoded['weekdays'] as List<dynamic>)
        .whereType<int>()
        .toList(growable: false);
    return ReminderSettings(
      enabled: decoded['enabled'] as bool,
      time: ReminderTime.fromString(decoded['time'] as String),
      weekdays: weekdays,
    ).normalized();
  }

  static ReminderSettings _readLegacy(SharedPreferences prefs) {
    final enabled = prefs.getBool(PreferenceKeys.reminderEnabled) ?? false;
    final time = _readLegacyTime(prefs.getString(PreferenceKeys.reminderTimes));
    final weekdays =
        _readLegacyWeekdays(prefs.getString(PreferenceKeys.reminderWeekdays));
    return ReminderSettings(
      enabled: enabled,
      time: time,
      weekdays: weekdays,
    ).normalized();
  }

  static ReminderTime _readLegacyTime(String? value) {
    if (value == null) return ReminderSettings.defaults.time;
    try {
      final decoded = jsonDecode(value);
      if (decoded is! List<dynamic>) return ReminderSettings.defaults.time;
      final times = decoded
          .whereType<String>()
          .map((entry) {
            try {
              return ReminderTime.fromString(entry);
            } on FormatException {
              return null;
            }
          })
          .whereType<ReminderTime>()
          .toList()
        ..sort((a, b) => a.hour == b.hour
            ? a.minute.compareTo(b.minute)
            : a.hour.compareTo(b.hour));
      return times.isEmpty ? ReminderSettings.defaults.time : times.first;
    } catch (_) {
      return ReminderSettings.defaults.time;
    }
  }

  static List<int> _readLegacyWeekdays(String? value) {
    if (value == null) return ReminderSettings.defaults.weekdays;
    try {
      final decoded = jsonDecode(value);
      if (decoded is! List<dynamic>) return ReminderSettings.defaults.weekdays;
      final weekdays = decoded.whereType<int>().toList(growable: false);
      return weekdays.isEmpty ? ReminderSettings.defaults.weekdays : weekdays;
    } catch (_) {
      return ReminderSettings.defaults.weekdays;
    }
  }
}
