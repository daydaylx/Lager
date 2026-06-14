class ReminderTime {
  final int hour;
  final int minute;

  const ReminderTime({required this.hour, required this.minute});

  static ReminderTime fromString(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) throw FormatException('Ungültiges Format: $hhmm');
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null || h < 0 || h > 23 || m < 0 || m > 59) {
      throw FormatException('Ungültige Zeit: $hhmm');
    }
    return ReminderTime(hour: h, minute: m);
  }

  String toDisplayString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      other is ReminderTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() => 'ReminderTime(${toDisplayString()})';
}

class ReminderSettings {
  final bool enabled;
  final List<ReminderTime> times;
  final List<int> weekdays;

  const ReminderSettings({
    required this.enabled,
    required this.times,
    required this.weekdays,
  });

  static const ReminderSettings defaults = ReminderSettings(
    enabled: false,
    times: [ReminderTime(hour: 20, minute: 0)],
    weekdays: [1, 2, 3, 4, 5],
  );

  ReminderSettings copyWith({
    bool? enabled,
    List<ReminderTime>? times,
    List<int>? weekdays,
  }) {
    return ReminderSettings(
      enabled: enabled ?? this.enabled,
      times: List.unmodifiable(times ?? this.times),
      weekdays: List.unmodifiable(weekdays ?? this.weekdays),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ReminderSettings &&
      other.enabled == enabled &&
      _listEquals(other.times, times) &&
      _listEquals(other.weekdays, weekdays);

  @override
  int get hashCode =>
      Object.hash(enabled, Object.hashAll(times), Object.hashAll(weekdays));
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
