import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/data/default_activities.dart';
import '../../core/report/daily_report_generator.dart';
import '../../core/enums/day_type.dart';
import '../../core/enums/special_flag.dart';
import '../../core/enums/training_area.dart';
import '../../core/models/daily_entry.dart';
import '../../core/models/activity_template.dart';
import '../../core/storage/activity_template_storage.dart';
import '../../core/storage/daily_entry_storage.dart';
import '../../core/week_utils.dart';
import '../../shared/widgets/app_ui.dart';
import '../today/today_screen.dart';

class WeekScreen extends StatefulWidget {
  final DailyEntryStorage storage;
  final ActivityTemplateStorage templateStorage;
  final DateTime? initialDate;
  final DateTime? currentDate;
  final int refreshSignal;
  final int templateRefreshSignal;

  const WeekScreen({
    super.key,
    required this.storage,
    required this.templateStorage,
    this.initialDate,
    this.currentDate,
    this.refreshSignal = 0,
    this.templateRefreshSignal = 0,
  });

  @override
  State<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends State<WeekScreen> {
  late DateTime _selectedWeekStart;
  Map<String, DailyEntry> _entries = {};
  Map<String, ActivityTemplate> _customTemplates = {};
  bool _isLoading = true;
  bool _loadFailed = false;
  bool _templatesLoadFailed = false;
  int _loadGeneration = 0;

  DateTime get _today {
    final now = widget.currentDate ?? DateTime.now();
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
    _selectedWeekStart =
        startOfWeek(widget.initialDate ?? widget.currentDate ?? DateTime.now());
    _loadWeek();
    _loadTemplates();
  }

  @override
  void didUpdateWidget(covariant WeekScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    var shouldLoadWeek = widget.refreshSignal != oldWidget.refreshSignal;
    if (widget.currentDate != null &&
        oldWidget.currentDate != null &&
        _normalizedDate(widget.currentDate!) !=
            _normalizedDate(oldWidget.currentDate!)) {
      final oldCurrentWeek = startOfWeek(oldWidget.currentDate!);
      if (_selectedWeekStart == oldCurrentWeek) {
        _selectedWeekStart = startOfWeek(widget.currentDate!);
      }
      shouldLoadWeek = true;
    }
    if (widget.templateRefreshSignal != oldWidget.templateRefreshSignal) {
      _loadTemplates();
    }
    if (shouldLoadWeek) {
      _loadWeek();
    }
  }

  static DateTime _normalizedDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

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
      return AppEmptyState(
        icon: Icons.error_outline,
        title: 'Woche nicht verfügbar',
        message: 'Die Einträge dieser Woche konnten nicht geladen werden.',
        action: FilledButton.icon(
          key: const ValueKey('retry_week_load'),
          onPressed: _loadWeek,
          icon: const Icon(Icons.refresh),
          label: const Text('Erneut versuchen'),
        ),
      );
    }

    final weekDays = _weekDays;
    final dueWeekDays = weekDays.where(_isDueWeekDay).toList();
    final enteredDueDays = dueWeekDays.where(_hasEntry).length;
    final hasEntries = _entries.isNotEmpty;
    final isCurrentWeek = _selectedWeekStart == _currentWeekStart;
    final missingCount = dueWeekDays.length - enteredDueDays;

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
            hasEntries: hasEntries,
            onPrevious: () => _changeWeek(-7),
            onNext: () => _changeWeek(7),
            onSummary: _openSummary,
          ),
          if (isCurrentWeek && missingCount > 0) ...[
            const SizedBox(height: 16),
            _MissingDaysBanner(count: missingCount),
          ],
          if (!hasEntries) ...[
            const SizedBox(height: 16),
            const _EmptyWeekCard(),
          ],
          if (_templatesLoadFailed) ...[
            const SizedBox(height: 16),
            _WeekTemplateWarning(onRetry: _loadTemplates),
          ],
          const SizedBox(height: 16),
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: weekDays.indexed.map((entry) {
                final index = entry.$1;
                final date = entry.$2;
                final dailyEntry = _entryFor(date);
                return _DayCard(
                  date: date,
                  entry: dailyEntry,
                  status: _statusFor(date, dailyEntry),
                  summary: _summaryFor(dailyEntry),
                  onTap: date.isAfter(_today) ? null : () => _openDay(date),
                  showDivider: index < weekDays.length - 1,
                );
              }).toList(growable: false),
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

  Future<void> _loadTemplates() async {
    try {
      final templates = await widget.templateStorage.loadCustom();
      if (mounted) {
        setState(() {
          _customTemplates = {
            for (final template in templates) template.id: template,
          };
          _templatesLoadFailed = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _templatesLoadFailed = true);
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
          templateStorage: widget.templateStorage,
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
          activityTitles: {
            for (final activity in defaultActivities)
              activity.id: activity.title,
            for (final activity in _customTemplates.values)
              activity.id: activity.title,
          },
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
  final bool hasEntries;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSummary;

  const _WeekHeader({
    required this.weekStart,
    required this.enteredDays,
    required this.dueDays,
    required this.canGoForward,
    required this.hasEntries,
    required this.onPrevious,
    required this.onNext,
    required this.onSummary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final end = weekStart.add(const Duration(days: 6));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    'KW ${isoWeekNumber(weekStart)} / ${isoWeekYear(weekStart)}',
                    key: const ValueKey('week_number'),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
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
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Text(
                '$enteredDays von $dueDays fälligen Werktagen eingetragen',
                key: const ValueKey('week_progress'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              dueDays == 0
                  ? '0 %'
                  : '${((enteredDays / dueDays) * 100).round()} %',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: dueDays == 0 ? 0 : enteredDays / dueDays,
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(height: 14),
        FilledButton.tonalIcon(
          key: const ValueKey('show_week_summary'),
          onPressed: hasEntries ? onSummary : null,
          icon: const Icon(Icons.summarize_outlined),
          label: const Text('Wochenzusammenfassung'),
        ),
      ],
    );
  }

  static String _shortDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.';
  }
}

class _MissingDaysBanner extends StatelessWidget {
  final int count;

  const _MissingDaysBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return AppMessage(
      key: const ValueKey('missing_days_banner'),
      icon: Icons.warning_amber_outlined,
      title: '$count ${count == 1 ? 'Tag fehlt' : 'Tage fehlen'} noch diese Woche',
      message: 'Tippe auf einen offenen Tag, um ihn einzutragen.',
      tone: AppMessageTone.warning,
    );
  }
}

class _EmptyWeekCard extends StatelessWidget {
  const _EmptyWeekCard();

  @override
  Widget build(BuildContext context) {
    return const AppMessage(
      icon: Icons.edit_calendar_outlined,
      title: 'Noch keine Einträge',
      message:
          'Tippe auf einen vergangenen Tag, um ihn für diese Woche einzutragen.',
    );
  }
}

class _WeekTemplateWarning extends StatelessWidget {
  final VoidCallback onRetry;

  const _WeekTemplateWarning({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return AppMessage(
      icon: Icons.warning_amber_outlined,
      title: 'Eigene Tätigkeitstitel konnten nicht geladen werden.',
      message: 'Standardtitel bleiben sichtbar.',
      tone: AppMessageTone.warning,
      action: IconButton(
        onPressed: onRetry,
        tooltip: 'Erneut versuchen',
        icon: const Icon(Icons.refresh),
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
  final bool showDivider;

  const _DayCard({
    required this.date,
    required this.entry,
    required this.status,
    required this.summary,
    required this.onTap,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = status.color(theme.colorScheme);
    final containerColor = status.containerColor(theme.colorScheme);

    return Column(
      children: [
        InkWell(
          key: ValueKey('week_day_${DailyEntry.idForDate(date)}'),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 76),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: containerColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(status.icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                formatDayDate(date),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              status.label,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: color,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
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
                      ],
                    ),
                  ),
                  if (onTap != null) const Icon(Icons.chevron_right, size: 20),
                ],
              ),
            ),
          ),
        ),
        if (showDivider) const Divider(indent: 50),
      ],
    );
  }
}

class _WeekSummaryScreen extends StatelessWidget {
  final DateTime weekStart;
  final List<DateTime> days;
  final Map<String, DailyEntry> entries;
  final DateTime today;
  final Map<String, String> activityTitles;

  const _WeekSummaryScreen({
    required this.weekStart,
    required this.days,
    required this.entries,
    required this.today,
    required this.activityTitles,
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
                activityTitles: activityTitles,
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
  final Map<String, String> activityTitles;

  const _SummaryDayCard({
    required this.date,
    required this.entry,
    required this.isMissing,
    required this.activityTitles,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatDayDate(date),
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
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Vorschlag fürs Berichtsheft',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              SelectableText(
                DailyReportGenerator.generate(entry!, activityTitles),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                key: Key('copy_report_${entry!.id}'),
                icon: const Icon(Icons.copy_outlined),
                label: const Text('Kopieren'),
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: DailyReportGenerator.generate(
                        entry!,
                        activityTitles,
                      ),
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tagesbericht kopiert.')),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _activityTitle(String id) {
    return activityTitles[id] ?? 'Nicht mehr verfügbare Tätigkeit';
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

  Color containerColor(ColorScheme colorScheme) {
    return switch (kind) {
      _DayStatusKind.saved => colorScheme.primaryContainer,
      _DayStatusKind.absence => colorScheme.tertiaryContainer,
      _DayStatusKind.missing => colorScheme.errorContainer,
      _DayStatusKind.neutral => colorScheme.surfaceContainer,
    };
  }
}
