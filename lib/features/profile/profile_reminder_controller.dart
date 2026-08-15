import '../../core/models/reminder_settings.dart';
import '../../core/services/notification_service.dart';
import '../../core/storage/reminder_storage.dart';

typedef ReminderSettingsLoader = Future<ReminderSettings> Function();
typedef ReminderSettingsSaver = Future<void> Function(
  ReminderSettings settings,
);

class ProfileReminderController {
  static const loadError =
      'Erinnerungseinstellungen konnten nicht geladen werden.';
  static const saveError =
      'Die Einstellung konnte nicht gespeichert werden. Bitte versuche es erneut.';
  static const scheduleError =
      'Die Einstellung ist gespeichert, aber Android konnte die Erinnerung noch nicht vollständig planen.';
  static const testError =
      'Die Testbenachrichtigung konnte nicht gesendet werden.';

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

  Future<ReminderLoadResult> load() async {
    try {
      final settings = await _loadSettings();
      try {
        final status = await _scheduler.inspect(settings);
        return ReminderLoadResult(settings: settings, status: status);
      } catch (_) {
        return ReminderLoadResult(
          settings: settings,
          status: _errorStatus(settings),
          error: scheduleError,
        );
      }
    } catch (_) {
      return const ReminderLoadResult(error: loadError);
    }
  }

  Future<ReminderSaveResult> saveAndReschedule({
    required ReminderSettings previous,
    required ReminderSettings next,
    bool requestPermissions = false,
  }) async {
    final normalized = next.normalized();
    try {
      await _saveSettings(normalized);
    } catch (_) {
      return ReminderSaveResult(settings: previous, error: saveError);
    }

    try {
      final status = await _scheduler.schedule(
        normalized,
        requestPermissions: requestPermissions,
      );
      return ReminderSaveResult(settings: normalized, status: status);
    } catch (_) {
      return ReminderSaveResult(
        settings: normalized,
        status: _errorStatus(normalized),
        error: scheduleError,
      );
    }
  }

  Future<ReminderSaveResult> reconcile(ReminderSettings settings) async {
    final normalized = settings.normalized();
    try {
      final status = await _scheduler.schedule(normalized);
      return ReminderSaveResult(settings: normalized, status: status);
    } catch (_) {
      return ReminderSaveResult(
        settings: normalized,
        status: _errorStatus(normalized),
        error: scheduleError,
      );
    }
  }

  Future<ReminderSaveResult> requestPermissions(
    ReminderSettings settings,
  ) async {
    final normalized = settings.normalized();
    try {
      final status = await _scheduler.schedule(
        normalized,
        requestPermissions: true,
      );
      return ReminderSaveResult(settings: normalized, status: status);
    } catch (_) {
      return ReminderSaveResult(
        settings: normalized,
        status: _errorStatus(normalized),
        error: scheduleError,
      );
    }
  }

  Future<ReminderTestResult> sendTest(ReminderSettings settings) async {
    try {
      final status = await _scheduler.sendTestNotification(settings);
      return ReminderTestResult(status: status);
    } catch (_) {
      return ReminderTestResult(
        status: _errorStatus(settings),
        error: testError,
      );
    }
  }

  ReminderSettingsEdit toggleEnabled(
    ReminderSettings settings,
    bool enabled,
  ) =>
      ReminderSettingsEdit(settings: settings.copyWith(enabled: enabled));

  ReminderSettingsEdit changeTime(
      ReminderSettings settings, ReminderTime time) {
    return ReminderSettingsEdit(settings: settings.copyWith(time: time));
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
      settings: settings.copyWith(weekdays: weekdays),
    );
  }

  ReminderRuntimeStatus _errorStatus(ReminderSettings settings) {
    return ReminderRuntimeStatus(
      state: ReminderRuntimeState.error,
      notificationsEnabled: true,
      exactAlarmsEnabled: false,
      channelEnabled: true,
      expectedCount: settings.enabled ? settings.weekdays.length : 0,
      pendingCount: 0,
      error: scheduleError,
    );
  }
}

class ReminderLoadResult {
  final ReminderSettings? settings;
  final ReminderRuntimeStatus? status;
  final String? error;

  const ReminderLoadResult({this.settings, this.status, this.error});
}

class ReminderSaveResult {
  final ReminderSettings settings;
  final ReminderRuntimeStatus? status;
  final String? error;

  const ReminderSaveResult({
    required this.settings,
    this.status,
    this.error,
  });
}

class ReminderTestResult {
  final ReminderRuntimeStatus status;
  final String? error;

  const ReminderTestResult({required this.status, this.error});
}

class ReminderSettingsEdit {
  final ReminderSettings? settings;
  final String? error;

  const ReminderSettingsEdit({this.settings, this.error});
}
