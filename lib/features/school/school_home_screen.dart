import 'package:flutter/material.dart';

import '../../core/domain/curriculum_registry.dart';
import '../../core/domain/curriculum_unit.dart';
import '../../core/domain/occupation.dart';
import '../../core/enums/day_type.dart';
import '../../core/models/daily_entry.dart';
import '../../core/school/models/school_assessment.dart';
import '../../core/school/models/school_entry.dart';
import '../../core/school/models/school_task.dart';
import '../../core/school/services/school_entry_coordinator.dart';
import '../../core/school/storage/school_data_storage.dart';
import '../../core/storage/activity_template_storage.dart';
import '../../core/storage/daily_entry_storage.dart';
import '../../shared/widgets/app_ui.dart';
import 'school_check_in_screen.dart';

class SchoolHomeScreen extends StatefulWidget {
  final SchoolDataStorage storage;
  final DailyEntryStorage dailyEntryStorage;
  final ActivityTemplateStorage templateStorage;
  final String? occupation;
  final int? trainingYear;
  final DateTime currentDate;
  final int refreshSignal;
  final VoidCallback? onOpenProfile;
  final VoidCallback? onNavigateToToday;
  final VoidCallback? onEntrySaved;
  final Future<void> Function()? onRetryStorage;

  const SchoolHomeScreen({
    super.key,
    required this.storage,
    required this.dailyEntryStorage,
    required this.templateStorage,
    required this.occupation,
    required this.trainingYear,
    required this.currentDate,
    this.refreshSignal = 0,
    this.onOpenProfile,
    this.onNavigateToToday,
    this.onEntrySaved,
    this.onRetryStorage,
  });

  @override
  State<SchoolHomeScreen> createState() => _SchoolHomeScreenState();
}

class _SchoolHomeScreenState extends State<SchoolHomeScreen> {
  SchoolEntry? _todayEntry;
  DailyEntry? _todayDailyEntry;
  List<SchoolEntry> _recentEntries = const [];
  List<SchoolTask> _tasks = const [];
  List<SchoolAssessment> _assessments = const [];
  bool _isLoading = true;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant SchoolHomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshSignal != oldWidget.refreshSignal ||
        _day(widget.currentDate) != _day(oldWidget.currentDate) ||
        widget.occupation != oldWidget.occupation ||
        widget.trainingYear != oldWidget.trainingYear ||
        widget.storage != oldWidget.storage) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });
    try {
      final entry = await widget.storage.loadEntry(widget.currentDate);
      final dailyEntry =
          await widget.dailyEntryStorage.loadByDate(widget.currentDate);
      final recentEntries = (await widget.storage.loadEntries()).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      final tasks = (await widget.storage.loadTasks()).toList();
      final assessments = (await widget.storage.loadAssessments()).toList();
      tasks.sort(_compareTasks);
      assessments.sort((a, b) => a.date.compareTo(b.date));
      if (!mounted) return;
      setState(() {
        _todayEntry = entry;
        _todayDailyEntry = dailyEntry;
        _recentEntries = recentEntries
            .where((item) => _day(item.date) != _day(widget.currentDate))
            .take(5)
            .toList(growable: false);
        _tasks = tasks;
        _assessments = assessments;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadFailed = true;
        });
      }
    }
  }

  Future<void> _retry() async {
    try {
      await widget.onRetryStorage?.call();
    } finally {
      await _load();
    }
  }

  Future<void> _openEntryForm({DateTime? date}) async {
    final targetDate = date ?? widget.currentDate;
    if (date == null &&
        _todayEntry == null &&
        _todayDailyEntry != null &&
        _todayDailyEntry!.dayType != DayType.berufsschule) {
      widget.onNavigateToToday?.call();
      return;
    }
    final occupation = TrainingOccupationDetails.fromStorageKey(
      widget.occupation ?? '',
    );
    if (occupation == null || widget.trainingYear == null) {
      widget.onOpenProfile?.call();
      return;
    }
    final coordinator = SchoolEntryCoordinator(
      schoolStorage: widget.storage,
      dailyEntryStorage: widget.dailyEntryStorage,
    );
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => SchoolCheckInScreen(
          date: targetDate,
          occupation: occupation,
          trainingYear: widget.trainingYear!,
          storage: widget.storage,
          dailyEntryStorage: widget.dailyEntryStorage,
          templateStorage: widget.templateStorage,
          coordinator: coordinator,
        ),
      ),
    );
    if (saved == true && mounted) {
      await _load();
      widget.onEntrySaved?.call();
    }
  }

  Future<void> _toggleTask(SchoolTask task, bool isDone) async {
    try {
      await widget.storage.saveTask(
        task.copyWith(
          status: isDone ? SchoolTaskStatus.done : SchoolTaskStatus.open,
        ),
      );
      await _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Die Aufgabe konnte nicht geändert werden.')),
        );
      }
    }
  }

  Future<void> _showAllTasks() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.75,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Alle Aufgaben', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              for (final task in _tasks)
                CheckboxListTile(
                  value: task.status == SchoolTaskStatus.done,
                  title: Text(task.title),
                  subtitle: Text(_taskSubtitle(task)),
                  onChanged: (value) {
                    Navigator.of(context).pop();
                    _toggleTask(task, value ?? false);
                  },
                ),
              if (_tasks.isEmpty)
                const AppEmptyState(
                  icon: Icons.task_alt_outlined,
                  title: 'Noch keine Aufgaben',
                  message: 'Aufgaben aus einem Schultag erscheinen hier.',
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_loadFailed || !widget.storage.isAvailable) {
      return Scaffold(
        appBar: AppBar(title: const Text('Schule')),
        body: AppEmptyState(
          icon: Icons.error_outline,
          title: 'Schulbereich nicht verfügbar',
          message:
              'Die lokalen Schuldaten konnten nicht geöffnet werden. Deine bisherigen Einträge bleiben erhalten.',
          action: widget.onRetryStorage == null
              ? null
              : FilledButton.icon(
                  onPressed: _retry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Erneut versuchen'),
                ),
        ),
      );
    }

    final profile = TrainingOccupationDetails.fromStorageKey(
      widget.occupation ?? '',
    );
    final units = profile == null || widget.trainingYear == null
        ? const <CurriculumUnit>[]
        : CurriculumRegistry.packFor(
            region: CurriculumRegistry.saxonyRegion,
            occupation: profile,
            trainingYear: widget.trainingYear!,
          ).units;
    final allOpenTasks = _tasks
        .where((task) => task.status == SchoolTaskStatus.open)
        .toList(growable: false);
    final openTasks = allOpenTasks.take(3).toList(growable: false);
    final plannedAssessments = _assessments
        .where(
          (assessment) => assessment.status == SchoolAssessmentStatus.planned,
        )
        .toList(growable: false);
    final nextAssessment =
        plannedAssessments.isEmpty ? null : plannedAssessments.first;

    return Scaffold(
      appBar: AppBar(title: const Text('Schule')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            if (profile != null && widget.trainingYear != null)
              Text(
                '${profile.label} · ${widget.trainingYear}. Ausbildungsjahr',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              )
            else
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Ausbildungsprofil ergänzen'),
                subtitle: const Text('Damit passende Lernfelder erscheinen.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: widget.onOpenProfile,
              ),
            const SizedBox(height: 12),
            _todayCard(context),
            if (_recentEntries.isNotEmpty) ...[
              const SizedBox(height: 16),
              _sectionHeading(context, 'Zuletzt erfasste Schultage'),
              for (final entry in _recentEntries)
                _recentEntryCard(context, entry),
            ],
            const SizedBox(height: 16),
            _sectionHeading(context, 'Offen'),
            if (openTasks.isEmpty)
              const AppMessage(
                icon: Icons.task_alt_outlined,
                title: 'Keine offenen Aufgaben',
              )
            else ...[
              for (final task in openTasks)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: false,
                  title: Text(task.title),
                  subtitle: Text(_taskSubtitle(task)),
                  onChanged: (value) => _toggleTask(task, value ?? false),
                ),
            ],
            if (allOpenTasks.length > 3)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _showAllTasks,
                  child: const Text('Alle Aufgaben'),
                ),
              ),
            const SizedBox(height: 12),
            _sectionHeading(context, 'Nächste Klassenarbeit'),
            if (nextAssessment == null)
              const AppMessage(
                icon: Icons.event_note_outlined,
                title: 'Noch keine Klassenarbeit geplant',
              )
            else
              _assessmentCard(context, nextAssessment),
            const SizedBox(height: 12),
            _sectionHeading(context, 'Aktuelle Lernfelder und Fächer'),
            if (units.isEmpty)
              const AppMessage(
                icon: Icons.menu_book_outlined,
                title: 'Wähle dein Ausbildungsprofil aus.',
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: units.take(5).map((unit) {
                  return Chip(
                    label: Text(unit.displayTitle),
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(growable: false),
              ),
          ],
        ),
      ),
    );
  }

  Widget _todayCard(BuildContext context) {
    final entry = _todayEntry;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Heute', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (entry == null &&
                _todayDailyEntry != null &&
                _todayDailyEntry!.dayType != DayType.berufsschule)
              Text(
                'Heute ist bereits „${_todayDailyEntry!.dayType.label}“ eingetragen. Ändere die Tagesart im Heute-Bereich.',
              )
            else if (entry == null)
              const Text('Noch kein Schultag eingetragen.')
            else ...[
              for (final block in entry.blocks)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '${CurriculumRegistry.unitById(block.curriculumUnitId)?.displayTitle ?? block.customUnitTitle ?? 'Eigenes Fach'}${block.topics.isEmpty ? '' : ': ${block.topics.join(', ')}'}',
                  ),
                ),
            ],
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const ValueKey('school_check_in'),
              onPressed: _openEntryForm,
              icon: Icon(entry == null ? Icons.add : Icons.edit_outlined),
              label: Text(
                _todayDailyEntry != null &&
                        _todayDailyEntry!.dayType != DayType.berufsschule
                    ? 'In Heute ändern'
                    : entry == null
                        ? 'Schultag eintragen'
                        : 'Schultag bearbeiten',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recentEntryCard(BuildContext context, SchoolEntry entry) => Card(
        child: ListTile(
          leading: const Icon(Icons.menu_book_outlined),
          title: Text(_formatDate(entry.date)),
          subtitle: Text('${entry.blocks.length} Lernfelder oder Fächer'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _openEntryForm(date: entry.date),
        ),
      );

  Widget _assessmentCard(BuildContext context, SchoolAssessment assessment) =>
      Card(
        child: ListTile(
          leading: const Icon(Icons.event_note_outlined),
          title: Text(assessment.title),
          subtitle: Text('${assessment.kind.label} · ${_formatDate(assessment.date)}'),
        ),
      );

  Widget _sectionHeading(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      );

  String _taskSubtitle(SchoolTask task) => task.dueDate == null
      ? task.type.label
      : '${task.type.label} · fällig ${_formatDate(task.dueDate!)}';

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

  DateTime _day(DateTime date) => DateTime(date.year, date.month, date.day);

  int _compareTasks(SchoolTask a, SchoolTask b) {
    if (a.dueDate == null) return b.dueDate == null ? a.title.compareTo(b.title) : 1;
    if (b.dueDate == null) return -1;
    return a.dueDate!.compareTo(b.dueDate!);
  }
}
