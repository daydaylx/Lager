import 'package:berichtsheft_merker/core/models/reminder_settings.dart';
import 'package:berichtsheft_merker/core/services/notification_service.dart';
import 'package:berichtsheft_merker/features/profile/profile_reminder_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfileReminderController', () {
    test('speichert Nutzerabsicht vor der Android-Planung', () async {
      final events = <String>[];
      final scheduler = _RecordingScheduler(
        onSchedule: (settings) {
          events.add('schedule:${settings.enabled}');
          return _status(settings);
        },
      );
      final controller = ProfileReminderController(
        scheduler: scheduler,
        saveSettings: (settings) async {
          events.add('save:${settings.enabled}');
        },
      );
      final next = ReminderSettings.defaults.copyWith(enabled: true);

      final result = await controller.saveAndReschedule(
        previous: ReminderSettings.defaults,
        next: next,
        requestPermissions: true,
      );

      expect(events, ['save:true', 'schedule:true']);
      expect(result.settings, next);
      expect(result.status?.state, ReminderRuntimeState.readyExact);
      expect(scheduler.lastRequestPermissions, isTrue);
    });

    test('Speicherfehler verändert Android-Planung nicht', () async {
      final scheduler = _RecordingScheduler();
      final controller = ProfileReminderController(
        scheduler: scheduler,
        saveSettings: (_) async => throw StateError('disk full'),
      );

      final result = await controller.saveAndReschedule(
        previous: ReminderSettings.defaults,
        next: ReminderSettings.defaults.copyWith(enabled: true),
      );

      expect(result.settings, ReminderSettings.defaults);
      expect(result.error, ProfileReminderController.saveError);
      expect(scheduler.scheduleCalls, 0);
    });

    test('Planungsfehler behält gespeicherte Nutzerabsicht aktiv', () async {
      final saved = <ReminderSettings>[];
      final scheduler = _RecordingScheduler(
        onSchedule: (_) => throw StateError('native failure'),
      );
      final controller = ProfileReminderController(
        scheduler: scheduler,
        saveSettings: (settings) async => saved.add(settings),
      );
      final next = ReminderSettings.defaults.copyWith(enabled: true);

      final result = await controller.saveAndReschedule(
        previous: ReminderSettings.defaults,
        next: next,
      );

      expect(saved, [next]);
      expect(result.settings.enabled, isTrue);
      expect(result.status?.state, ReminderRuntimeState.error);
      expect(result.error, ProfileReminderController.scheduleError);
    });

    test('load liefert Einstellungen und tatsächlichen Laufzeitstatus',
        () async {
      final scheduler = _RecordingScheduler(
        exactAlarmsEnabled: false,
      );
      final settings = ReminderSettings.defaults.copyWith(enabled: true);
      final controller = ProfileReminderController(
        scheduler: scheduler,
        loadSettings: () async => settings,
      );

      final result = await controller.load();

      expect(result.settings, settings);
      expect(result.status?.state, ReminderRuntimeState.readyApproximate);
    });

    test('reconcile repariert ohne Berechtigungsdialog', () async {
      final scheduler = _RecordingScheduler();
      final controller = ProfileReminderController(scheduler: scheduler);
      final settings = ReminderSettings.defaults.copyWith(enabled: true);

      await controller.reconcile(settings);

      expect(scheduler.lastRequestPermissions, isFalse);
    });

    test('Testbenachrichtigung wird separat angestoßen', () async {
      final scheduler = _RecordingScheduler();
      final controller = ProfileReminderController(scheduler: scheduler);

      final result = await controller.sendTest(
        ReminderSettings.defaults.copyWith(enabled: true),
      );

      expect(scheduler.testCalls, 1);
      expect(result.error, isNull);
    });

    test('changeTime ersetzt die einzelne Uhrzeit', () {
      final controller = ProfileReminderController(
        scheduler: _RecordingScheduler(),
      );

      final edit = controller.changeTime(
        ReminderSettings.defaults,
        const ReminderTime(hour: 8, minute: 30),
      );

      expect(edit.settings?.time, const ReminderTime(hour: 8, minute: 30));
    });

    test('letzter Wochentag kann nicht abgewählt werden', () {
      final controller = ProfileReminderController(
        scheduler: _RecordingScheduler(),
      );
      const settings = ReminderSettings(
        enabled: true,
        time: ReminderTime(hour: 20, minute: 0),
        weekdays: [1],
      );

      expect(controller.toggleWeekday(settings, 1).settings, isNull);
    });
  });
}

ReminderRuntimeStatus _status(
  ReminderSettings settings, {
  bool exactAlarmsEnabled = true,
}) {
  if (!settings.enabled) return ReminderRuntimeStatus.disabled;
  return ReminderRuntimeStatus(
    state: exactAlarmsEnabled
        ? ReminderRuntimeState.readyExact
        : ReminderRuntimeState.readyApproximate,
    notificationsEnabled: true,
    exactAlarmsEnabled: exactAlarmsEnabled,
    channelEnabled: true,
    expectedCount: settings.weekdays.length,
    pendingCount: settings.weekdays.length,
  );
}

class _RecordingScheduler implements NotificationScheduler {
  final ReminderRuntimeStatus Function(ReminderSettings settings)? onSchedule;
  final bool exactAlarmsEnabled;
  int scheduleCalls = 0;
  int testCalls = 0;
  bool? lastRequestPermissions;

  _RecordingScheduler({
    this.onSchedule,
    this.exactAlarmsEnabled = true,
  });

  @override
  Future<void> cancelAll() async {}

  @override
  void clearOnTap() {}

  @override
  Future<String?> initialize(void Function(String? payload) onTap) async =>
      null;

  @override
  Future<ReminderRuntimeStatus> inspect(ReminderSettings settings) async =>
      _status(
        settings,
        exactAlarmsEnabled: exactAlarmsEnabled,
      );

  @override
  Future<ReminderRuntimeStatus> schedule(
    ReminderSettings settings, {
    bool requestPermissions = false,
  }) async {
    scheduleCalls++;
    lastRequestPermissions = requestPermissions;
    return onSchedule?.call(settings) ??
        _status(
          settings,
          exactAlarmsEnabled: exactAlarmsEnabled,
        );
  }

  @override
  Future<ReminderRuntimeStatus> sendTestNotification(
    ReminderSettings settings,
  ) async {
    testCalls++;
    return inspect(settings);
  }
}
