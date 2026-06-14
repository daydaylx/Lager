import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/reminder_settings.dart';

class ReminderStorage {
  static Future<ReminderSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(PreferenceKeys.reminderEnabled) ?? false;

    final timesJson = prefs.getString(PreferenceKeys.reminderTimes);
    final List<ReminderTime> times;
    if (timesJson == null) {
      times = ReminderSettings.defaults.times;
    } else {
      List<ReminderTime> parsed;
      try {
        final decoded = jsonDecode(timesJson) as List<dynamic>;
        if (decoded.isEmpty) {
          parsed = [];
        } else {
          final entries = decoded
              .map((s) {
                try {
                  return ReminderTime.fromString(s as String);
                } on FormatException {
                  return null;
                }
              })
              .whereType<ReminderTime>()
              .toList();
          // Fall back to defaults only when every entry was corrupt.
          parsed = entries.isEmpty ? List.of(ReminderSettings.defaults.times) : entries;
        }
      } catch (_) {
        parsed = List.of(ReminderSettings.defaults.times);
      }
      times = parsed;
    }

    final weekdaysJson = prefs.getString(PreferenceKeys.reminderWeekdays);
    final List<int> weekdays;
    if (weekdaysJson == null) {
      weekdays = ReminderSettings.defaults.weekdays;
    } else {
      List<int> parsed;
      try {
        final decoded = jsonDecode(weekdaysJson) as List<dynamic>;
        parsed = decoded
            .whereType<int>()
            .where((d) => d >= 1 && d <= 7)
            .toSet()
            .toList()
          ..sort();
      } catch (_) {
        parsed = List.of(ReminderSettings.defaults.weekdays);
      }
      weekdays = parsed;
    }

    return ReminderSettings(enabled: enabled, times: times, weekdays: weekdays);
  }

  static Future<void> save(ReminderSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PreferenceKeys.reminderEnabled, settings.enabled);
    await prefs.setString(
      PreferenceKeys.reminderTimes,
      jsonEncode(settings.times.map((t) => t.toDisplayString()).toList()),
    );
    await prefs.setString(
      PreferenceKeys.reminderWeekdays,
      jsonEncode(settings.weekdays),
    );
  }
}
