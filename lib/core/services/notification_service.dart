import 'dart:async';
import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/reminder_settings.dart';

enum ReminderRuntimeState {
  disabled,
  readyExact,
  readyApproximate,
  blocked,
  error,
}

class ReminderRuntimeStatus {
  final ReminderRuntimeState state;
  final bool notificationsEnabled;
  final bool exactAlarmsEnabled;
  final bool channelEnabled;
  final int expectedCount;
  final int pendingCount;
  final String? error;

  const ReminderRuntimeStatus({
    required this.state,
    required this.notificationsEnabled,
    required this.exactAlarmsEnabled,
    required this.channelEnabled,
    required this.expectedCount,
    required this.pendingCount,
    this.error,
  });

  static const disabled = ReminderRuntimeStatus(
    state: ReminderRuntimeState.disabled,
    notificationsEnabled: true,
    exactAlarmsEnabled: true,
    channelEnabled: true,
    expectedCount: 0,
    pendingCount: 0,
  );

  bool get isPermissionBlocked => !notificationsEnabled || !channelEnabled;
}

class ReminderScheduleSlot {
  final int id;
  final int weekday;
  final ReminderTime time;

  const ReminderScheduleSlot({
    required this.id,
    required this.weekday,
    required this.time,
  });
}

const int _reminderIdBase = 1100;
const int _testNotificationId = 1199;

List<ReminderScheduleSlot> buildReminderSchedule(ReminderSettings settings) {
  final normalized = settings.normalized();
  if (!normalized.enabled) return const [];
  return List.unmodifiable([
    for (final weekday in normalized.weekdays)
      ReminderScheduleSlot(
        id: _reminderIdBase + weekday,
        weekday: weekday,
        time: normalized.time,
      ),
  ]);
}

abstract interface class NotificationScheduler {
  Future<String?> initialize(void Function(String?) onTap);
  void clearOnTap();
  Future<ReminderRuntimeStatus> schedule(
    ReminderSettings settings, {
    bool requestPermissions = false,
  });
  Future<ReminderRuntimeStatus> inspect(ReminderSettings settings);
  Future<ReminderRuntimeStatus> sendTestNotification(
    ReminderSettings settings,
  );
  Future<void> cancelAll();
}

class NoOpNotificationScheduler implements NotificationScheduler {
  int initializeCalls = 0;
  int scheduleCalls = 0;
  int cancelAllCalls = 0;
  int testCalls = 0;
  ReminderSettings? lastScheduled;
  Object? initializeError;
  Object? scheduleError;
  String? initialPayload;
  bool notificationsEnabled;
  bool exactAlarmsEnabled;
  bool channelEnabled;
  void Function(String?)? _onTap;

  NoOpNotificationScheduler({
    this.initializeError,
    this.scheduleError,
    this.initialPayload,
    this.notificationsEnabled = true,
    this.exactAlarmsEnabled = true,
    this.channelEnabled = true,
  });

  @override
  Future<String?> initialize(void Function(String?) onTap) async {
    initializeCalls++;
    if (initializeError case final error?) throw error;
    _onTap = onTap;
    final payload = initialPayload;
    initialPayload = null;
    return payload;
  }

  void emitTap(String? payload) => _onTap?.call(payload);

  @override
  void clearOnTap() => _onTap = null;

  @override
  Future<ReminderRuntimeStatus> schedule(
    ReminderSettings settings, {
    bool requestPermissions = false,
  }) async {
    scheduleCalls++;
    lastScheduled = settings.normalized();
    if (scheduleError case final error?) throw error;
    return _statusFor(settings.normalized());
  }

  @override
  Future<ReminderRuntimeStatus> inspect(ReminderSettings settings) async =>
      _statusFor(settings.normalized());

  @override
  Future<ReminderRuntimeStatus> sendTestNotification(
    ReminderSettings settings,
  ) async {
    testCalls++;
    return _statusFor(settings.normalized());
  }

  ReminderRuntimeStatus _statusFor(ReminderSettings settings) {
    if (!settings.enabled) return ReminderRuntimeStatus.disabled;
    final count = settings.weekdays.length;
    final blocked = !notificationsEnabled || !channelEnabled;
    return ReminderRuntimeStatus(
      state: blocked
          ? ReminderRuntimeState.blocked
          : exactAlarmsEnabled
              ? ReminderRuntimeState.readyExact
              : ReminderRuntimeState.readyApproximate,
      notificationsEnabled: notificationsEnabled,
      exactAlarmsEnabled: exactAlarmsEnabled,
      channelEnabled: channelEnabled,
      expectedCount: count,
      pendingCount: count,
    );
  }

  @override
  Future<void> cancelAll() async => cancelAllCalls++;
}

class FlutterLocalNotificationScheduler implements NotificationScheduler {
  FlutterLocalNotificationScheduler();

  static const _channelId = 'daily_reminder';
  static const _channel = AndroidNotificationChannel(
    _channelId,
    'Tägliche Berichtsheft-Erinnerungen',
    description: 'Tägliche Erinnerung zum Ausfüllen des Berichtshefts',
    importance: Importance.high,
    enableVibration: true,
    playSound: true,
  );
  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      'Tägliche Berichtsheft-Erinnerungen',
      channelDescription: 'Tägliche Erinnerung zum Ausfüllen des Berichtshefts',
      icon: 'ic_stat_notification',
      color: Color(0xFF008F7A),
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
      ticker: 'Berichtsheft-Erinnerung',
      enableVibration: true,
      playSound: true,
    ),
  );
  static const _title = 'Heute schon eingetragen?';
  static const _body = 'Tippe, um schnell deinen Tageseintrag zu machen.';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  Future<void>? _initializing;
  bool _launchDetailsRead = false;
  void Function(String?)? _onNotificationTap;
  Future<void> _operation = Future.value();

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    if (_initializing case final initializing?) {
      await initializing;
      return;
    }
    final initialization = _initializeNative();
    _initializing = initialization;
    try {
      await initialization;
      _initialized = true;
    } finally {
      _initializing = null;
    }
  }

  Future<void> _initializeNative() async {
    tzdata.initializeTimeZones();
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_notification'),
      ),
      onDidReceiveNotificationResponse: (details) {
        _onNotificationTap?.call(details.payload);
      },
    );
    await _android?.createNotificationChannel(_channel);
    await _updateLocalTimezone();
  }

  Future<void> _updateLocalTimezone() async {
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

  Future<T> _serialized<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    _operation = _operation.catchError((_) {}).then((_) async {
      try {
        completer.complete(await action());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }

  @override
  Future<ReminderRuntimeStatus> schedule(
    ReminderSettings settings, {
    bool requestPermissions = false,
  }) =>
      _serialized(() => _apply(settings.normalized(), requestPermissions));

  Future<ReminderRuntimeStatus> _apply(
    ReminderSettings settings,
    bool requestPermissions,
  ) async {
    await _ensureInitialized();
    await _updateLocalTimezone();

    if (requestPermissions && settings.enabled) {
      await _android?.requestNotificationsPermission();
      if (await _canScheduleExact() == false) {
        await _android?.requestExactAlarmsPermission();
      }
    }

    await _cancelOwnedNotifications();
    if (!settings.enabled) return ReminderRuntimeStatus.disabled;

    final notificationsEnabled = await _areNotificationsEnabled();
    final exactAlarmsEnabled = await _canScheduleExact();
    final scheduleMode = exactAlarmsEnabled
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
    final slots = buildReminderSchedule(settings);

    try {
      for (final slot in slots) {
        await _plugin.zonedSchedule(
          slot.id,
          _title,
          _body,
          _nextWeekdayInstance(slot.weekday, slot.time),
          _details,
          androidScheduleMode: scheduleMode,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'today',
        );
      }
      final status = await _inspectInitialized(
        settings,
        notificationsEnabled: notificationsEnabled,
        exactAlarmsEnabled: exactAlarmsEnabled,
      );
      if (status.pendingCount != status.expectedCount) {
        throw StateError('Nicht alle Erinnerungen wurden geplant.');
      }
      return status;
    } catch (_) {
      try {
        await _cancelOwnedNotifications();
      } catch (_) {
        // The original scheduling failure is more useful to the caller.
      }
      rethrow;
    }
  }

  @override
  Future<ReminderRuntimeStatus> inspect(ReminderSettings settings) async {
    await _ensureInitialized();
    return _inspectInitialized(settings.normalized());
  }

  Future<ReminderRuntimeStatus> _inspectInitialized(
    ReminderSettings settings, {
    bool? notificationsEnabled,
    bool? exactAlarmsEnabled,
  }) async {
    if (!settings.enabled) return ReminderRuntimeStatus.disabled;
    final notifications =
        notificationsEnabled ?? await _areNotificationsEnabled();
    final exact = exactAlarmsEnabled ?? await _canScheduleExact();
    final channelEnabled = await _isChannelEnabled();
    final expectedIds = buildReminderSchedule(settings).map((slot) => slot.id);
    final expectedSet = expectedIds.toSet();
    final pending = await _plugin.pendingNotificationRequests();
    final pendingCount =
        pending.where((item) => expectedSet.contains(item.id)).length;
    final expectedCount = expectedSet.length;
    final isBlocked = !notifications || !channelEnabled;
    final isComplete = pendingCount == expectedCount;

    return ReminderRuntimeStatus(
      state: !isComplete
          ? ReminderRuntimeState.error
          : isBlocked
              ? ReminderRuntimeState.blocked
              : exact
                  ? ReminderRuntimeState.readyExact
                  : ReminderRuntimeState.readyApproximate,
      notificationsEnabled: notifications,
      exactAlarmsEnabled: exact,
      channelEnabled: channelEnabled,
      expectedCount: expectedCount,
      pendingCount: pendingCount,
      error: isComplete ? null : 'Die Android-Planung ist unvollständig.',
    );
  }

  @override
  Future<ReminderRuntimeStatus> sendTestNotification(
    ReminderSettings settings,
  ) =>
      _serialized(() async {
        await _ensureInitialized();
        final notifications = await _areNotificationsEnabled();
        final channelEnabled = await _isChannelEnabled();
        if (!notifications || !channelEnabled) {
          return _inspectInitialized(settings.normalized());
        }

        // A user-facing test must be immediate and alert again when repeated.
        // Scheduling it for later makes a successful result look like failure,
        // while reusing an already-active ID can be treated as a silent update.
        await _plugin.cancel(_testNotificationId);
        await _plugin.show(
          _testNotificationId,
          'Test erfolgreich',
          'Deine Berichtsheft-Erinnerungen können angezeigt werden.',
          _details,
          payload: 'today',
        );
        return _inspectInitialized(settings.normalized());
      });

  Future<bool> _areNotificationsEnabled() async =>
      await _android?.areNotificationsEnabled() ?? true;

  Future<bool> _canScheduleExact() async =>
      await _android?.canScheduleExactNotifications() ?? true;

  Future<bool> _isChannelEnabled() async {
    final channels = await _android?.getNotificationChannels();
    final channel =
        channels?.where((item) => item.id == _channelId).firstOrNull;
    return channel == null || channel.importance != Importance.none;
  }

  Future<void> _cancelOwnedNotifications() async {
    for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
      await _plugin.cancel(_reminderIdBase + weekday);
      await _plugin.cancel(weekday); // legacy IDs
    }
    await _plugin.cancel(_testNotificationId);
  }

  @override
  Future<void> cancelAll() => _serialized(() async {
        await _ensureInitialized();
        await _plugin.cancelAll();
      });

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

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
