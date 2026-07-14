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

enum ReminderScheduleKind {
  primary,
  followUp,
  weeklyCheck,
}

class ReminderScheduleSlot {
  final int id;
  final int weekday;
  final ReminderTime time;
  final ReminderScheduleKind kind;

  const ReminderScheduleSlot({
    required this.id,
    required this.weekday,
    required this.time,
    required this.kind,
  });
}

List<ReminderScheduleSlot> buildReminderSchedule(ReminderSettings settings) {
  final normalized = settings.normalized();
  if (!normalized.enabled ||
      normalized.times.isEmpty ||
      normalized.weekdays.isEmpty) {
    return const [];
  }

  final time = normalized.times.first;
  return List.unmodifiable([
    for (final weekday in normalized.weekdays)
      ReminderScheduleSlot(
        id: weekday,
        weekday: weekday,
        time: time,
        kind: ReminderScheduleKind.primary,
      ),
  ]);
}

abstract interface class NotificationScheduler {
  Future<String?> initialize(void Function(String?) onTap);
  void clearOnTap();
  Future<NotificationScheduleResult> schedule(ReminderSettings settings);
  Future<void> cancelAll();
  Future<bool> areNotificationsEnabled();
}

/// No-op implementation used in tests. Tracks calls for assertions.
class NoOpNotificationScheduler implements NotificationScheduler {
  int initializeCalls = 0;
  int scheduleCalls = 0;
  int cancelAllCalls = 0;
  ReminderSettings? lastScheduled;
  NotificationScheduleResult scheduleResult;
  Object? initializeError;
  Object? scheduleError;
  String? initialPayload;
  bool notificationsEnabled;
  void Function(String?)? _onTap;

  NoOpNotificationScheduler({
    this.scheduleResult = NotificationScheduleResult.scheduled,
    this.initializeError,
    this.scheduleError,
    this.initialPayload,
    this.notificationsEnabled = true,
  });

  @override
  Future<String?> initialize(void Function(String?) onTap) async {
    initializeCalls++;
    if (initializeError case final error?) {
      throw error;
    }
    _onTap = onTap;
    final payload = initialPayload;
    initialPayload = null;
    return payload;
  }

  void emitTap(String? payload) => _onTap?.call(payload);

  @override
  void clearOnTap() => _onTap = null;

  @override
  Future<NotificationScheduleResult> schedule(ReminderSettings settings) async {
    scheduleCalls++;
    lastScheduled = settings.normalized();
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
  Future<bool> areNotificationsEnabled() async => notificationsEnabled;
}

/// Real implementation backed by flutter_local_notifications.
/// Initialises lazily — the constructor makes no native calls.
class FlutterLocalNotificationScheduler implements NotificationScheduler {
  const FlutterLocalNotificationScheduler();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static bool _launchDetailsRead = false;
  static void Function(String?)? _onNotificationTap;

  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
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

  static Future<void> _updateLocalTimezone() async {
    final currentTimezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimezone.identifier));
  }

  @override
  Future<String?> initialize(void Function(String?) onTap) async {
    _onNotificationTap = onTap;
    await _ensureInitialized();
    if (_launchDetailsRead) return null;
    final details = await _plugin.getNotificationAppLaunchDetails();
    _launchDetailsRead = true;
    return details?.didNotificationLaunchApp == true
        ? details?.notificationResponse?.payload
        : null;
  }

  @override
  void clearOnTap() => _onNotificationTap = null;

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
    final normalized = settings.normalized();
    if (!normalized.enabled ||
        normalized.times.isEmpty ||
        normalized.weekdays.isEmpty) {
      await _plugin.cancelAll();
      return NotificationScheduleResult.disabled;
    }

    final permissionGranted = await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    if (permissionGranted == false) {
      return NotificationScheduleResult.permissionDenied;
    }

    await _updateLocalTimezone();
    await _plugin.cancelAll();

    const androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Tägliche Berichtsheft-Erinnerungen',
      channelDescription: 'Tägliche Erinnerung zum Ausfüllen des Berichtshefts',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );
    const details = NotificationDetails(android: androidDetails);

    const title = 'Heute schon eingetragen?';
    const body = 'Tippe, um schnell deinen Tageseintrag zu machen.';

    for (final slot in buildReminderSchedule(normalized)) {
      await _plugin.zonedSchedule(
        slot.id,
        title,
        body,
        _nextWeekdayInstance(slot.weekday, slot.time),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'today',
      );
    }

    return NotificationScheduleResult.scheduled;
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
      candidate = tz.TZDateTime(
        tz.local,
        candidate.year,
        candidate.month,
        candidate.day + 1,
        time.hour,
        time.minute,
      );
    }
    return candidate;
  }
}
