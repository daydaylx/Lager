import 'package:flutter/material.dart';
import '../../core/data/default_activities.dart';
import '../../core/enums/day_type.dart';
import '../../core/enums/special_flag.dart';
import '../../core/enums/training_area.dart';
import '../../core/models/daily_entry.dart';
import '../../core/storage/daily_entry_storage.dart';
import '../../core/week_utils.dart';
import '../today/today_screen.dart';

class WeekScreen extends StatefulWidget {
  final DailyEntryStorage storage;
  final DateTime? initialDate;
  final int refreshSignal;

  const WeekScreen({
    super.key,
    required this.storage,
    this.initialDate,
    this.refreshSignal = 0,
  });

  @override
  State<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends State<WeekScreen> {
  late DateTime _selectedWeekStart;
  Map<String, DailyEntry> _entries = {};
  bool _isLoading = true;
  bool _loadFailed = false;
  int _loadGeneration = 0;

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime get _currentWeekStart => startOfWeek(_today);

  List<DateTime> get _weekDays {
    return List.generate(
      7,
      (index) => _selectedWeekStart.add(Duration(days: index)),
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedWeekStart = startOfWeek(widget.initialDate ?? DateTime.now());
    _loadWeek();
  }

  @override
  void didUpdateWidget(covariant WeekScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshSignal != oldWidget.refreshSignal) {
      _loadWeek();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Woche')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadFailed) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Die Einträge dieser Woche konnten nicht geladen werden.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                key: const ValueKey('retry_week_load'),
                onPressed: _loadWeek,
                icon: const Icon(Icons.refresh),
                label: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
      );
    }

    final weekDays = _weekDays;
    final dueWeekDays = weekDays.where(_isDueWeekDay).toList();
    final enteredDueDays = dueWeekDays.where(_hasEntry).length;
    final hasEntries = _entries.isNotEmpty;

    return RefreshIndicator(
      onRefresh: _loadWeek,
      child: ListView(
        key: const ValueKey('week_list'),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _WeekHeader(
            weekStart: _selectedWeekStart,
            enteredDays: enteredDueDays,
            dueDays: dueWeekDays.length,
            canGoForward: _selectedWeekStart.isBefore(_currentWeekStart),
            onPrevious: () => _changeWeek(-7),
            onNext: () => _changeWeek(7),
          ),
          if (!hasEntries) ...[
            const SizedBox(height: 16),
            const _EmptyWeekCard(),
          ],
          const SizedBox(height: 16),
          ...weekDays.map((date) {
            final entry = _entryFor(date);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _DayCard(
                date: date,
                entry: entry,
                status: _statusFor(date, entry),
                summary: _summaryFor(entry),
                onTap: date.isAfter(_today) ? null : () => _openDay(date),
              ),
            );
          }),
          const SizedBox(height: 6),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              key: const ValueKey('show_week_summary'),
              onPressed: _openSummary,
              icon: const Icon(Icons.summarize_outlined),
              label: const Text('Wochenzusammenfassung anzeigen'),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasEntry(DateTime date) => _entryFor(date) != null;

  DailyEntry? _entryFor(DateTime date) {
    return _entries[DailyEntry.idForDate(date)];
  }

  bool _isDueWeekDay(DateTime date) {
    return date.weekday <= DateTime.friday && !date.isAfter(_today);
  }

  _DayStatus _statusFor(DateTime date, DailyEntry? entry) {
    if (entry != null) {
      if (entry.dayType.isAbsence) {
        return _DayStatus(
          label: entry.dayType.label,
          icon: Icons.event_available_outlined,
          kind: _DayStatusKind.absence,
        );
      }
      return const _DayStatus(
        label: 'Gespeichert',
        icon: Icons.check_circle_outline,
        kind: _DayStatusKind.saved,
      );
    }

    if (_isDueWeekDay(date)) {
      return const _DayStatus(
        label: 'Fehlt',
        icon: Icons.error_outline,
        kind: _DayStatusKind.missing,
      );
    }

    return const _DayStatus(
      label: 'Kein Eintrag',
      icon: Icons.circle_outlined,
      kind: _DayStatusKind.neutral,
    );
  }

  String _summaryFor(DailyEntry? entry) {
    if (entry == null) {
      return 'Noch kein Tageseintrag';
    }

    return switch (entry.dayType) {
      DayType.betrieb =>
        '${entry.area?.label ?? 'Betrieb'} · ${_activityCountLabel(entry)}',
      DayType.berufsschule => _topicCountLabel(entry.selectedActivities.length),
      DayType.frei ||
      DayType.urlaub ||
      DayType.krank ||
      DayType.feiertag =>
        'Als ${entry.dayType.label} eingetragen',
      DayType.sonstiges => entry.note ?? 'Sonstiger Tag',
    };
  }

  String _activityCountLabel(DailyEntry entry) {
    final count = entry.selectedActivities.length;
    return '$count ${count == 1 ? 'Tätigkeit' : 'Tätigkeiten'}';
  }

  String _topicCountLabel(int count) {
    return '$count ${count == 1 ? 'Thema' : 'Themen'}';
  }

  Future<void> _loadWeek() async {
    final generation = ++_loadGeneration;
    final requestedWeekStart = _selectedWeekStart;
    final requestedDays = List.generate(
      7,
      (index) => requestedWeekStart.add(Duration(days: index)),
    );

    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadFailed = false;
      });
    }

    try {
      final loaded = await Future.wait(
        requestedDays.map(widget.storage.loadByDate),
      );
      if (!mounted ||
          generation != _loadGeneration ||
          requestedWeekStart != _selectedWeekStart) {
        return;
      }
      setState(() {
        _entries = {
          for (final entry in loaded)
            if (entry != null) DailyEntry.idForDate(entry.date): entry,
        };
        _isLoading = false;
        _loadFailed = false;
      });
    } catch (_) {
      if (mounted &&
          generation == _loadGeneration &&
          requestedWeekStart == _selectedWeekStart) {
        setState(() {
          _isLoading = false;
          _loadFailed = true;
        });
      }
    }
  }

  void _changeWeek(int days) {
    final newStart = _selectedWeekStart.add(Duration(days: days));
    if (newStart.isAfter(_currentWeekStart)) {
      return;
    }
    setState(() => _selectedWeekStart = newStart);
    _loadWeek();
  }

  Future<void> _openDay(DateTime date) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => TodayScreen(
          storage: widget.storage,
          date: date,
        ),
      ),
    );
    await _loadWeek();
  }

  void _openSummary() {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => _WeekSummaryScreen(
          weekStart: _selectedWeekStart,
          days: _weekDays,
          entries: _entries,
          today: _today,
        ),
      ),
    );
  }
}

class _WeekHeader extends StatelessWidget {
  final DateTime weekStart;
  final int enteredDays;
  final int dueDays;
  final bool canGoForward;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _WeekHeader({
    required this.weekStart,
    required this.enteredDays,
    required this.dueDays,
    required this.canGoForward,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final end = weekStart.add(const Duration(days: 6));
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  key: const ValueKey('previous_week'),
                  onPressed: onPrevious,
                  tooltip: 'Vorherige Woche',
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'KW ${isoWeekNumber(weekStart)} / '
                        '${isoWeekYear(weekStart)}',
                        key: const ValueKey('week_number'),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${_shortDate(weekStart)} – ${_shortDate(end)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  key: const ValueKey('next_week'),
                  onPressed: canGoForward ? onNext : null,
                  tooltip: 'Nächste Woche',
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '$enteredDays von $dueDays fälligen Werktagen eingetragen',
              key: const ValueKey('week_progress'),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: dueDays == 0 ? 0 : enteredDays / dueDays,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
      ),
    );
  }

  static String _shortDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.';
  }
}

class _EmptyWeekCard extends StatelessWidget {
  const _EmptyWeekCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.edit_calendar_outlined),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Für diese Woche gibt es noch keine Einträge. '
              'Starte mit einem Tag, der bereits stattgefunden hat.',
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final DateTime date;
  final DailyEntry? entry;
  final _DayStatus status;
  final String summary;
  final VoidCallback? onTap;

  const _DayCard({
    required this.date,
    required this.entry,
    required this.status,
    required this.summary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = status.color(theme.colorScheme);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        key: ValueKey('week_day_${DailyEntry.idForDate(date)}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(status.icon, color: color, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_weekday(date)}, ${date.day}. ${_month(date)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      entry == null
                          ? summary
                          : '${entry!.dayType.label} · $summary',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      status.label,
                      style: theme.textTheme.labelLarge?.copyWith(color: color),
                    ),
                  ],
                ),
              ),
              if (onTap != null) const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekSummaryScreen extends StatelessWidget {
  final DateTime weekStart;
  final List<DateTime> days;
  final Map<String, DailyEntry> entries;
  final DateTime today;

  const _WeekSummaryScreen({
    required this.weekStart,
    required this.days,
    required this.entries,
    required this.today,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wochenzusammenfassung')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            'KW ${isoWeekNumber(weekStart)} / ${isoWeekYear(weekStart)}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          ...days.map((date) {
            final entry = entries[DailyEntry.idForDate(date)];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SummaryDayCard(
                date: date,
                entry: entry,
                isMissing: date.weekday <= DateTime.friday &&
                    !date.isAfter(today) &&
                    entry == null,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SummaryDayCard extends StatelessWidget {
  final DateTime date;
  final DailyEntry? entry;
  final bool isMissing;

  const _SummaryDayCard({
    required this.date,
    required this.entry,
    required this.isMissing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_weekday(date)}, ${date.day}. ${_month(date)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (entry == null)
              Text(isMissing ? 'Kein Eintrag – fehlt' : 'Kein Eintrag')
            else ...[
              Text(
                entry!.dayType == DayType.betrieb && entry!.area != null
                    ? '${entry!.dayType.label} · ${entry!.area!.label}'
                    : entry!.dayType.label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              if (entry!.selectedActivities.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...entry!.selectedActivities.map(
                  (id) => _BulletText(text: _activityTitle(id)),
                ),
              ],
              if (entry!.specialFlags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Besonderheiten: '
                  '${entry!.specialFlags.map((flag) => flag.label).join(', ')}',
                ),
              ],
              if (entry!.note case final note?) ...[
                const SizedBox(height: 8),
                Text('Notiz: $note'),
              ],
            ],
          ],
        ),
      ),
    );
  }

  String _activityTitle(String id) {
    for (final activity in defaultActivities) {
      if (activity.id == id) {
        return activity.title;
      }
    }
    return id;
  }
}

class _BulletText extends StatelessWidget {
  final String text;

  const _BulletText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

enum _DayStatusKind {
  saved,
  absence,
  missing,
  neutral,
}

class _DayStatus {
  final String label;
  final IconData icon;
  final _DayStatusKind kind;

  const _DayStatus({
    required this.label,
    required this.icon,
    required this.kind,
  });

  Color color(ColorScheme colorScheme) {
    return switch (kind) {
      _DayStatusKind.saved => colorScheme.primary,
      _DayStatusKind.absence => colorScheme.tertiary,
      _DayStatusKind.missing => colorScheme.error,
      _DayStatusKind.neutral => colorScheme.onSurfaceVariant,
    };
  }
}

String _weekday(DateTime date) {
  const weekdays = [
    'Montag',
    'Dienstag',
    'Mittwoch',
    'Donnerstag',
    'Freitag',
    'Samstag',
    'Sonntag',
  ];
  return weekdays[date.weekday - 1];
}

String _month(DateTime date) {
  const months = [
    'Januar',
    'Februar',
    'März',
    'April',
    'Mai',
    'Juni',
    'Juli',
    'August',
    'September',
    'Oktober',
    'November',
    'Dezember',
  ];
  return months[date.month - 1];
}
