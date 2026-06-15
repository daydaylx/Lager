import 'package:berichtsheft_merker/core/models/reminder_settings.dart';
import 'package:berichtsheft_merker/core/services/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Reminder-Plan verwendet eindeutige deterministische IDs', () {
    final settings = ReminderSettings(
      enabled: true,
      times: [
        for (var hour = 0; hour < 8; hour++)
          ReminderTime(hour: hour, minute: 0),
      ],
      weekdays: const [7, 1, 2, 3, 4, 5, 6],
    );

    final schedule = buildReminderSchedule(settings);
    final ids = schedule.map((slot) => slot.id).toList();

    expect(schedule.length, 99);
    expect(ids.toSet().length, ids.length);
    expect(ids, containsAll([0, 48, 50, 98, 100]));
  });

  test('Folgeerinnerung wechselt korrekt über Mitternacht', () {
    final shifted = shiftReminderTime(
      DateTime.sunday,
      const ReminderTime(hour: 23, minute: 45),
      30,
    );

    expect(shifted.weekday, DateTime.monday);
    expect(shifted.time, const ReminderTime(hour: 0, minute: 15));
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
