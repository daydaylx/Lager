import 'package:berichtsheft_merker/core/models/reminder_settings.dart';
import 'package:berichtsheft_merker/core/services/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Reminder-Plan erzeugt einen Slot pro gewähltem Wochentag', () {
    const settings = ReminderSettings(
      enabled: true,
      times: [ReminderTime(hour: 20, minute: 0)],
      weekdays: [1, 3, 5],
    );

    final schedule = buildReminderSchedule(settings);
    final ids = schedule.map((slot) => slot.id).toList();

    expect(schedule.length, 3);
    expect(ids.toSet().length, ids.length);
    expect(ids, [1, 3, 5]);
    expect(
      schedule.every(
        (slot) => slot.time == const ReminderTime(hour: 20, minute: 0),
      ),
      isTrue,
    );
  });

  test('deaktivierte Erinnerung erzeugt keine Slots', () {
    const settings = ReminderSettings(
      enabled: false,
      times: [ReminderTime(hour: 20, minute: 0)],
      weekdays: [1, 2, 3, 4, 5],
    );

    final schedule = buildReminderSchedule(settings);

    expect(schedule, isEmpty);
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
