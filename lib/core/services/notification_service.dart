import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../models/reminder_settings.dart';

enum NotificationScheduleResult {
  scheduled,
  disabled,
  permissionDenied,
}

abstract interface class NotificationScheduler {
  Future<NotificationScheduleResult> schedule(ReminderSettings settings);
  Future<void> cancelAll();
  Future<bool> areNotificationsEnabled();
}

/// No-op implementation used in tests. Tracks calls for assertions.
class NoOpNotificationScheduler implements NotificationScheduler {
  int scheduleCalls = 0;
  int cancelAllCalls = 0;
  ReminderSettings? lastScheduled;
  NotificationScheduleResult scheduleResult;
  Object? scheduleError;

  NoOpNotificationScheduler({
    this.scheduleResult = NotificationScheduleResult.scheduled,
    this.scheduleError,
  });

  @override
  Future<NotificationScheduleResult> schedule(ReminderSettings settings) async {
    scheduleCalls++;
    lastScheduled = settings;
    if (scheduleError case final error?) {
      throw error;
    }
    return settings.enabled
        ? scheduleResult
        : NotificationScheduleResult.disabled;
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCalls++;
  }

  @override
  Future<bool> areNotificationsEnabled() async => true;
}

/// Real implementation backed by flutter_local_notifications.
/// Initialises lazily — the constructor makes no native calls.
class FlutterLocalNotificationScheduler implements NotificationScheduler {
  const FlutterLocalNotificationScheduler();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  // Callback invoked when user taps a notification. Set by MainShell.
  static void Function(String?)? _onNotificationTap;

  static void setOnTap(void Function(String?)? callback) {
    _onNotificationTap = callback;
  }

  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    final currentTimezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimezone.identifier));
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings),
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        _onNotificationTap?.call(details.payload);
      },
    );
    _initialized = true;
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    await _ensureInitialized();
    return await _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled() ??
        true;
  }

  @override
  Future<NotificationScheduleResult> schedule(ReminderSettings settings) async {
    await _ensureInitialized();
    await _plugin.cancelAll();
    if (!settings.enabled ||
        settings.times.isEmpty ||
        settings.weekdays.isEmpty) {
      return NotificationScheduleResult.disabled;
    }

    final permissionGranted = await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    if (permissionGranted == false) {
      return NotificationScheduleResult.permissionDenied;
    }

    const androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Tägliche Berichtsheft-Erinnerungen',
      channelDescription:
          'Tägliche Erinnerung zum Ausfüllen des Berichtshefts',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );
    const details = NotificationDetails(android: androidDetails);

    // Primary reminders (IDs 0–49)
    int id = 0;
    for (final weekday in settings.weekdays) {
      for (final time in settings.times) {
        await _plugin.zonedSchedule(
          id++,
          'Berichtsheft nicht vergessen',
          'Heute kurz Tätigkeiten eintragen – dauert nur 1 Minute.',
          _nextWeekdayInstance(weekday, time),
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'today',
        );
      }
    }

    // Second reminders 30 min later (IDs 50–99)
    int secondId = 50;
    for (final weekday in settings.weekdays) {
      for (final time in settings.times) {
        final (shiftedWeekday, shiftedTime) = _shiftTime(weekday, time, 30);
        await _plugin.zonedSchedule(
          secondId++,
          'Berichtsheft nicht vergessen',
          'Immer noch kein Eintrag? Das dauert wirklich nur kurz.',
          _nextWeekdayInstance(shiftedWeekday, shiftedTime),
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'today',
        );
      }
    }

    // Weekly check every Friday at 19:00 (ID 100)
    await _plugin.zonedSchedule(
      100,
      'Berichtsheft nicht vergessen',
      'Schau mal, ob diese Woche alle Tage eingetragen sind.',
      _nextWeekdayInstance(
          DateTime.friday, const ReminderTime(hour: 19, minute: 0)),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'today',
    );

    return NotificationScheduleResult.scheduled;
  }

  @override
  Future<void> cancelAll() async {
    await _ensureInitialized();
    await _plugin.cancelAll();
  }

  // Shifts a weekday+time by extraMinutes, wrapping across midnight correctly.
  static (int weekday, ReminderTime time) _shiftTime(
      int weekday, ReminderTime base, int extraMinutes) {
    final total = base.hour * 60 + base.minute + extraMinutes;
    final newWeekday = ((weekday - 1 + total ~/ 1440) % 7) + 1;
    return (
      newWeekday,
      ReminderTime(hour: (total ~/ 60) % 24, minute: total % 60),
    );
  }

  static tz.TZDateTime _nextWeekdayInstance(int weekday, ReminderTime time) {
    final now = tz.TZDateTime.now(tz.local);
    var candidate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    while (candidate.weekday != weekday || !candidate.isAfter(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }
}
