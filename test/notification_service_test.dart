import 'package:berichtsheft_merker/core/models/reminder_settings.dart';
import 'package:berichtsheft_merker/core/services/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Reminder-Plan erzeugt stabile eindeutige IDs je Wochentag', () {
    const settings = ReminderSettings(
      enabled: true,
      time: ReminderTime(hour: 20, minute: 0),
      weekdays: [1, 3, 5],
    );

    final schedule = buildReminderSchedule(settings);

    expect(schedule.map((slot) => slot.id), [1101, 1103, 1105]);
    expect(schedule.map((slot) => slot.weekday), [1, 3, 5]);
    expect(
      schedule.every(
        (slot) => slot.time == const ReminderTime(hour: 20, minute: 0),
      ),
      isTrue,
    );
  });

  test('deaktivierte Erinnerung erzeugt keine Slots', () {
    expect(buildReminderSchedule(ReminderSettings.defaults), isEmpty);
  });

  test('NoOp-Scheduler meldet exakten und ungefähren Zustand', () async {
    final exact = NoOpNotificationScheduler();
    final approximate = NoOpNotificationScheduler(exactAlarmsEnabled: false);
    final settings = ReminderSettings.defaults.copyWith(enabled: true);

    expect(
      (await exact.schedule(settings)).state,
      ReminderRuntimeState.readyExact,
    );
    expect(
      (await approximate.schedule(settings)).state,
      ReminderRuntimeState.readyApproximate,
    );
  });

  test('NoOp-Scheduler meldet blockierte Notifications', () async {
    final scheduler = NoOpNotificationScheduler(notificationsEnabled: false);

    final status = await scheduler.schedule(
      ReminderSettings.defaults.copyWith(enabled: true),
    );

    expect(status.state, ReminderRuntimeState.blocked);
    expect(status.isPermissionBlocked, isTrue);
  });

  test('NoOp-Scheduler liefert Kaltstart-Payload nur einmal', () async {
    final scheduler = NoOpNotificationScheduler(initialPayload: 'today');
    String? tapped;

    expect(await scheduler.initialize((payload) => tapped = payload), 'today');
    expect(await scheduler.initialize((payload) => tapped = payload), isNull);

    scheduler.emitTap('today');
    expect(tapped, 'today');
  });
}
