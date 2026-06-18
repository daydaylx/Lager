import '../../core/models/reminder_settings.dart';
import '../../core/services/notification_service.dart';
import '../../core/storage/reminder_storage.dart';

typedef ReminderSettingsLoader = Future<ReminderSettings> Function();
typedef ReminderSettingsSaver = Future<void> Function(
  ReminderSettings settings,
);

class ProfileReminderController {
  static const permissionError =
      'Benachrichtigungen sind nicht erlaubt. Bitte in den Einstellungen aktivieren.';
  static const loadError =
      'Erinnerungseinstellungen konnten nicht geladen werden.';
  static const saveError =
      'Die Erinnerung konnte nicht gespeichert werden. Bitte versuche es erneut.';
  static const duplicateTimeError = 'Diese Uhrzeit ist bereits eingetragen.';

  final NotificationScheduler _scheduler;
  final ReminderSettingsLoader _loadSettings;
  final ReminderSettingsSaver _saveSettings;

  ProfileReminderController({
    required NotificationScheduler scheduler,
    ReminderSettingsLoader? loadSettings,
    ReminderSettingsSaver? saveSettings,
  })  : _scheduler = scheduler,
        _loadSettings = loadSettings ?? ReminderStorage.load,
        _saveSettings = saveSettings ?? ReminderStorage.save;

  Future<ReminderLoadResult> load({
    required bool notificationsBlockedBySystem,
  }) async {
    try {
      final settings = await _loadSettings();
      return ReminderLoadResult(
        settings: settings,
        error: settings.enabled && notificationsBlockedBySystem
            ? permissionError
            : null,
      );
    } catch (_) {
      return const ReminderLoadResult(error: loadError);
    }
  }

  Future<ReminderPermissionResult?> checkPermission({
    required ReminderSettings settings,
    required String? currentError,
  }) async {
    try {
      final enabled = await _scheduler.areNotificationsEnabled();
      return ReminderPermissionResult(
        notificationsBlockedBySystem: !enabled,
        error: _permissionErrorForStatus(
          enabled: enabled,
          settings: settings,
          currentError: currentError,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<ReminderSaveResult> saveAndReschedule({
    required ReminderSettings previous,
    required ReminderSettings next,
  }) async {
    final normalized = next.normalized();
    try {
      final result = await _scheduler.schedule(normalized);
      if (result == NotificationScheduleResult.permissionDenied) {
        await _restoreSchedule(previous);
        return ReminderSaveResult(
          settings: previous,
          error: permissionError,
          notificationsBlockedBySystem: true,
        );
      }
      await _saveSettings(normalized);
      return ReminderSaveResult(
        settings: normalized,
        notificationsBlockedBySystem: false,
      );
    } catch (_) {
      await _restoreReminderState(previous);
      return ReminderSaveResult(settings: previous, error: saveError);
    }
  }

  ReminderSettingsEdit toggleEnabled(
    ReminderSettings settings,
    bool enabled,
  ) {
    return ReminderSettingsEdit(settings: settings.copyWith(enabled: enabled));
  }

  ReminderSettingsEdit deleteTime(ReminderSettings settings, int index) {
    if (settings.times.length <= 1 ||
        index < 0 ||
        index >= settings.times.length) {
      return const ReminderSettingsEdit();
    }
    final times = [...settings.times]..removeAt(index);
    return ReminderSettingsEdit(settings: settings.copyWith(times: times));
  }

  ReminderSettingsEdit addTime(ReminderSettings settings, ReminderTime time) {
    if (settings.times.contains(time)) {
      return const ReminderSettingsEdit(error: duplicateTimeError);
    }
    if (settings.times.length >= ReminderSettings.maxTimes) {
      return const ReminderSettingsEdit(
        error:
            'Es können höchstens ${ReminderSettings.maxTimes} Uhrzeiten gespeichert werden.',
      );
    }
    final times = [...settings.times, time]..sort((a, b) => a.hour == b.hour
        ? a.minute.compareTo(b.minute)
        : a.hour.compareTo(b.hour));
    return ReminderSettingsEdit(settings: settings.copyWith(times: times));
  }

  ReminderSettingsEdit toggleWeekday(ReminderSettings settings, int weekday) {
    final weekdays = List<int>.from(settings.weekdays);
    if (weekdays.contains(weekday)) {
      if (weekdays.length <= 1) return const ReminderSettingsEdit();
      weekdays.remove(weekday);
    } else {
      weekdays.add(weekday);
      weekdays.sort();
    }
    return ReminderSettingsEdit(
        settings: settings.copyWith(weekdays: weekdays));
  }

  String? _permissionErrorForStatus({
    required bool enabled,
    required ReminderSettings settings,
    required String? currentError,
  }) {
    if (enabled && currentError == permissionError) return null;
    if (!enabled && settings.enabled) return permissionError;
    return currentError;
  }

  Future<void> _restoreSchedule(ReminderSettings previous) async {
    try {
      await _scheduler.schedule(previous);
    } catch (_) {
      // The visible save error covers both the initial and rollback failures.
    }
  }

  Future<void> _restoreReminderState(ReminderSettings previous) async {
    await _restoreSchedule(previous);
    try {
      await _saveSettings(previous);
    } catch (_) {
      // The visible save error covers native and persisted rollback failures.
    }
  }
}

class ReminderLoadResult {
  final ReminderSettings? settings;
  final String? error;

  const ReminderLoadResult({this.settings, this.error});
}

class ReminderPermissionResult {
  final bool notificationsBlockedBySystem;
  final String? error;

  const ReminderPermissionResult({
    required this.notificationsBlockedBySystem,
    required this.error,
  });
}

class ReminderSaveResult {
  final ReminderSettings settings;
  final String? error;
  final bool? notificationsBlockedBySystem;

  const ReminderSaveResult({
    required this.settings,
    this.error,
    this.notificationsBlockedBySystem,
  });
}

class ReminderSettingsEdit {
  final ReminderSettings? settings;
  final String? error;

  const ReminderSettingsEdit({this.settings, this.error});
}
