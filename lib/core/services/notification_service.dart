import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../models/reminder_settings.dart';

abstract interface class NotificationScheduler {
  Future<void> schedule(ReminderSettings settings);
  Future<void> cancelAll();
}

/// No-op implementation used in tests. Tracks calls for assertions.
class NoOpNotificationScheduler implements NotificationScheduler {
  int scheduleCalls = 0;
  int cancelAllCalls = 0;
  ReminderSettings? lastScheduled;

  @override
  Future<void> schedule(ReminderSettings settings) async {
    scheduleCalls++;
    lastScheduled = settings;
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCalls++;
  }
}

/// Real implementation backed by flutter_local_notifications.
/// Initialises lazily — the constructor makes no native calls.
class FlutterLocalNotificationScheduler implements NotificationScheduler {
  const FlutterLocalNotificationScheduler();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings),
    );
    _initialized = true;
  }

  @override
  Future<void> schedule(ReminderSettings settings) async {
    await _ensureInitialized();
    await _plugin.cancelAll();
    if (!settings.enabled ||
        settings.times.isEmpty ||
        settings.weekdays.isEmpty) {
      return;
    }

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    const androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Tageserinnerung',
      channelDescription: 'Erinnerung zum Ausfüllen des Berichtshefts',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const details = NotificationDetails(android: androidDetails);

    int id = 0;
    for (final weekday in settings.weekdays) {
      for (final time in settings.times) {
        await _plugin.zonedSchedule(
          id++,
          'Berichtsheft-Merker',
          'Vergiss nicht, deinen Tageseintrag zu machen!',
          _nextWeekdayInstance(weekday, time),
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }
  }

  @override
  Future<void> cancelAll() async {
    await _ensureInitialized();
    await _plugin.cancelAll();
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
