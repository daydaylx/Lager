import 'package:flutter_test/flutter_test.dart';
import 'package:berichtsheft_merker/core/models/reminder_settings.dart';
import 'package:berichtsheft_merker/core/services/notification_service.dart';
import 'package:berichtsheft_merker/features/profile/profile_reminder_controller.dart';

void main() {
  group('ProfileReminderController', () {
    test('successful save stores normalized settings and schedules', () async {
      final scheduler = _RecordingScheduler();
      final saved = <ReminderSettings>[];
      final controller = ProfileReminderController(
        scheduler: scheduler,
        saveSettings: (settings) async {
          saved.add(settings);
        },
      );
      const previous = ReminderSettings.defaults;
      const next = ReminderSettings(
        enabled: true,
        times: [
          ReminderTime(hour: 20, minute: 0),
          ReminderTime(hour: 8, minute: 0),
        ],
        weekdays: [5, 1, 1],
      );

      final result = await controller.saveAndReschedule(
        previous: previous,
        next: next,
      );

      final expected = next.normalized();
      expect(result.settings, expected);
      expect(result.error, isNull);
      expect(result.notificationsBlockedBySystem, isFalse);
      expect(scheduler.scheduled, [expected]);
      expect(saved, [expected]);
    });

    test('permission denied restores previous schedule without saving',
        () async {
      final scheduler = _RecordingScheduler(
        onSchedule: (settings) => settings.enabled
            ? NotificationScheduleResult.permissionDenied
            : NotificationScheduleResult.disabled,
      );
      final saved = <ReminderSettings>[];
      final controller = ProfileReminderController(
        scheduler: scheduler,
        saveSettings: (settings) async {
          saved.add(settings);
        },
      );
      const previous = ReminderSettings.defaults;

      final result = await controller.saveAndReschedule(
        previous: previous,
        next: previous.copyWith(enabled: true),
      );

      expect(result.settings, previous);
      expect(result.error, ProfileReminderController.permissionError);
      expect(result.notificationsBlockedBySystem, isTrue);
      expect(scheduler.scheduled, [
        previous.copyWith(enabled: true),
        previous,
      ]);
      expect(saved, isEmpty);
    });

    test('scheduling error restores previous settings and reports save error',
        () async {
      final scheduler = _RecordingScheduler(
        onSchedule: (settings) {
          if (settings.enabled) throw StateError('native scheduling failed');
          return NotificationScheduleResult.disabled;
        },
      );
      final saved = <ReminderSettings>[];
      final controller = ProfileReminderController(
        scheduler: scheduler,
        saveSettings: (settings) async {
          saved.add(settings);
        },
      );
      const previous = ReminderSettings.defaults;

      final result = await controller.saveAndReschedule(
        previous: previous,
        next: previous.copyWith(enabled: true),
      );

      expect(result.settings, previous);
      expect(result.error, ProfileReminderController.saveError);
      expect(result.notificationsBlockedBySystem, isNull);
      expect(scheduler.scheduled, [
        previous.copyWith(enabled: true),
        previous,
      ]);
      expect(saved, [previous]);
    });

    test('permission check sets and clears permission error', () async {
      final scheduler = _RecordingScheduler(notificationsEnabled: false);
      final controller = ProfileReminderController(scheduler: scheduler);

      final blocked = await controller.checkPermission(
        settings: ReminderSettings.defaults.copyWith(enabled: true),
        currentError: null,
      );

      expect(blocked?.notificationsBlockedBySystem, isTrue);
      expect(blocked?.error, ProfileReminderController.permissionError);

      scheduler.notificationsEnabled = true;
      final allowed = await controller.checkPermission(
        settings: ReminderSettings.defaults.copyWith(enabled: true),
        currentError: ProfileReminderController.permissionError,
      );

      expect(allowed?.notificationsBlockedBySystem, isFalse);
      expect(allowed?.error, isNull);
    });

    test('changeTime updates the single time', () {
      final controller = ProfileReminderController(
        scheduler: _RecordingScheduler(),
      );

      final edit = controller.changeTime(
        ReminderSettings.defaults,
        const ReminderTime(hour: 8, minute: 30),
      );

      expect(edit.settings?.times, const [ReminderTime(hour: 8, minute: 30)]);
      expect(edit.error, isNull);
    });

    test('last weekday cannot be deselected', () {
      final controller = ProfileReminderController(
        scheduler: _RecordingScheduler(),
      );
      const settings = ReminderSettings(
        enabled: true,
        times: [ReminderTime(hour: 20, minute: 0)],
        weekdays: [1],
      );

      final weekdayEdit = controller.toggleWeekday(settings, 1);

      expect(weekdayEdit.settings, isNull);
      expect(weekdayEdit.error, isNull);
    });
  });
}

class _RecordingScheduler implements NotificationScheduler {
  final NotificationScheduleResult Function(ReminderSettings settings)?
      onSchedule;
  final List<ReminderSettings> scheduled = [];
  bool notificationsEnabled;

  _RecordingScheduler({
    this.onSchedule,
    this.notificationsEnabled = true,
  });

  @override
  Future<bool> areNotificationsEnabled() async => notificationsEnabled;

  @override
  Future<void> cancelAll() async {}

  @override
  void clearOnTap() {}

  @override
  Future<String?> initialize(void Function(String? p1) onTap) async => null;

  @override
  Future<NotificationScheduleResult> schedule(ReminderSettings settings) async {
    final normalized = settings.normalized();
    scheduled.add(normalized);
    final handler = onSchedule;
    if (handler != null) return handler(normalized);
    return normalized.enabled
        ? NotificationScheduleResult.scheduled
        : NotificationScheduleResult.disabled;
  }
}
