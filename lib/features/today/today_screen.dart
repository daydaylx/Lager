import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/data/default_activities.dart';
import '../../core/enums/activity_category.dart';
import '../../core/enums/day_type.dart';
import '../../core/enums/special_flag.dart';
import '../../core/enums/training_area.dart';
import '../../core/models/activity_template.dart';
import '../../core/models/daily_entry.dart';
import '../../core/storage/daily_entry_storage.dart';
import '../../core/storage/activity_template_storage.dart';
import '../../core/week_utils.dart';
import '../../core/report/daily_report_generator.dart';
import '../../shared/widgets/app_ui.dart';

class TodayScreen extends StatefulWidget {
  final DailyEntryStorage storage;
  final ActivityTemplateStorage templateStorage;
  final DateTime? date;
  final DateTime? currentDate;
  final int templateRefreshSignal;
  final bool protectBackNavigation;

  const TodayScreen({
    super.key,
    required this.storage,
    required this.templateStorage,
    this.date,
    this.currentDate,
    this.templateRefreshSignal = 0,
    this.protectBackNavigation = true,
  });

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  final TextEditingController _noteController = TextEditingController();
  final Set<String> _selectedActivityIds = {};
  final Set<SpecialFlag> _selectedSpecialFlags = {};
  List<ActivityTemplate> _customTemplates = [];

  DayType _selectedDayType = DayType.betrieb;
  TrainingArea? _selectedArea;
  DailyEntry? _savedEntry;
  bool _hasUnsavedChanges = false;
  bool _isLoading = true;
  bool _loadFailed = false;
  bool _isSaving = false;
  bool _isApplyingEntry = false;
  bool _templatesLoadFailed = false;
  bool _specialFlagsExpanded = false;
  late DateTime _activeDate;
  DateTime? _pendingDate;

  DateTime get _widgetDate {
    final value = widget.date ?? widget.currentDate ?? DateTime.now();
    return DateTime(value.year, value.month, value.day);
  }

  DateTime get _today => _activeDate;

  bool get _isToday {
    final now = widget.currentDate ?? DateTime.now();
    return _today == DateTime(now.year, now.month, now.day);
  }

  String get _screenTitle => _isToday ? 'Heute' : 'Tageseintrag';

  bool get _canSave {
    return switch (_selectedDayType) {
      DayType.betrieb =>
        _selectedArea != null && _selectedActivityIds.isNotEmpty,
      DayType.berufsschule => _selectedActivityIds.isNotEmpty,
      DayType.frei ||
      DayType.urlaub ||
      DayType.krank ||
      DayType.feiertag ||
      DayType.sonstiges =>
        true,
    };
  }

  bool get _canSubmit {
    return !_isLoading &&
        !_isSaving &&
        _canSave &&
        (_savedEntry == null || _hasUnsavedChanges);
  }

  String get _statusLabel {
    if (_savedEntry == null) {
      return 'Noch nicht gespeichert';
    }
    return _hasUnsavedChanges ? 'Änderungen offen' : 'Gespeichert';
  }

  List<String> get _missingItems {
    if (_isLoading || _loadFailed) return const [];
    final items = <String>[];
    if (_selectedDayType == DayType.betrieb && _selectedArea == null) {
      items.add('Bereich');
    }
    if (_selectedDayType.supportsActivities && _selectedActivityIds.isEmpty) {
      items.add('Tätigkeit');
    }
    return items;
  }

  @override
  void initState() {
    super.initState();
    _activeDate = _widgetDate;
    _noteController.addListener(_markChanged);
    _loadEntry();
    _loadTemplates();
  }

  @override
  void didUpdateWidget(covariant TodayScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.templateRefreshSignal != oldWidget.templateRefreshSignal) {
      _loadTemplates();
    }
    if (_widgetDate != _activeDate) {
      _handleExternalDateChange(_widgetDate);
    }
  }

  @override
  void dispose() {
    _noteController
      ..removeListener(_markChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadFailed) {
      return Scaffold(
        appBar: AppBar(title: Text(_screenTitle)),
        body: AppEmptyState(
          icon: Icons.error_outline,
          title: 'Eintrag nicht verfügbar',
          message: _isToday
              ? 'Dein heutiger Eintrag konnte nicht geladen werden.'
              : 'Der Tageseintrag konnte nicht geladen werden.',
          action: FilledButton.icon(
            key: const ValueKey('retry_daily_entry_load'),
            onPressed: _loadEntry,
            icon: const Icon(Icons.refresh),
            label: const Text('Erneut versuchen'),
          ),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(_screenTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope<void>(
      canPop: !widget.protectBackNavigation || !_hasUnsavedChanges,
      onPopInvokedWithResult: _handlePop,
      child: Scaffold(
        appBar: AppBar(title: Text(_screenTitle)),
        body: IgnorePointer(
          ignoring: _isSaving,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _DayStatusCard(
                date: _today,
                statusLabel: _statusLabel,
                isSaved: _savedEntry != null && !_hasUnsavedChanges,
                hasUnsavedChanges: _hasUnsavedChanges,
                missingItems: _missingItems,
              ),
              if (_pendingDate != null) ...[
                const SizedBox(height: 16),
                AppMessage(
                  key: const ValueKey('new_day_pending'),
                  icon: Icons.today_outlined,
                  title: 'Ein neuer Tag hat begonnen.',
                  message:
                      'Deine offenen Änderungen bleiben beim bisherigen Tag.',
                  tone: AppMessageTone.warning,
                  action: IconButton(
                    key: const ValueKey('switch_to_current_day'),
                    onPressed: _switchToPendingDate,
                    tooltip: 'Zum heutigen Tag wechseln',
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              AppSectionHeader(
                title: 'Tagestyp',
                description: _isToday
                    ? 'Was für ein Tag ist heute?'
                    : 'Was für ein Tag war das?',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: DayType.values.map((dayType) {
                  return ChoiceChip(
                    key: ValueKey('day_type_${dayType.name}'),
                    label: Text(dayType.label),
                    selected: _selectedDayType == dayType,
                    onSelected: (_) => _confirmAndSelectDayType(dayType),
                  );
                }).toList(),
              ),
              if (_selectedDayType == DayType.betrieb) ...[
                const SizedBox(height: 24),
                AppSectionHeader(
                  title: 'Bereich',
                  badge: 'Pflicht',
                  badgeRequired: true,
                  description: _isToday
                      ? 'Wo hast du heute gearbeitet?'
                      : 'Wo hast du an diesem Tag gearbeitet?',
                ),
                const SizedBox(height: 12),
                _AreaGrid(
                  areas: TrainingArea.values,
                  selected: _selectedArea,
                  onSelect: _confirmAndSelectArea,
                ),
              ],
              if (_selectedDayType.supportsActivities) ...[
                const SizedBox(height: 24),
                AppSectionHeader(
                  title: 'Tätigkeiten',
                  badge: 'Pflicht',
                  badgeRequired: true,
                  description: _isToday
                      ? 'Wähle aus, was du heute gemacht hast.'
                      : 'Wähle aus, was du an diesem Tag gemacht hast.',
                  trailing: _SelectionCount(count: _selectedActivityIds.length),
                ),
                const SizedBox(height: 12),
                _buildActivities(context),
              ],
              if (_selectedDayType == DayType.sonstiges) ...[
                const SizedBox(height: 24),
                const AppMessage(
                  icon: Icons.edit_note_outlined,
                  title:
                      'Beschreibe den Tag kurz über Besonderheiten oder Notiz.',
                ),
              ],
              if (_selectedDayType.isAbsence) ...[
                const SizedBox(height: 24),
                AppMessage(
                  icon: Icons.event_available_outlined,
                  title:
                      '${_selectedDayType.label} kann direkt gespeichert werden.',
                  tone: AppMessageTone.success,
                ),
              ],
              if (!_selectedDayType.isAbsence) ...[
                const SizedBox(height: 24),
                const AppSectionHeader(
                  title: 'Besonderheiten',
                  badge: 'Optional',
                  badgeRequired: false,
                  description: 'Was war heute besonders?',
                ),
                const SizedBox(height: 12),
                _buildSpecialFlags(),
                const SizedBox(height: 24),
                const AppSectionHeader(
                  title: 'Notiz',
                  badge: 'Optional',
                  badgeRequired: false,
                  description: 'Kurze Ergänzung, falls etwas Besonderes war.',
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const ValueKey('daily_note_field'),
                  controller: _noteController,
                  minLines: 2,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Kurze Notiz, falls etwas Besonderes war ...',
                  ),
                ),
              ],
              if (_canSave) ...[
                const SizedBox(height: 24),
                _ReportCard(
                  report: _currentReport()!,
                  note: (_selectedDayType == DayType.betrieb ||
                          _selectedDayType == DayType.berufsschule)
                      ? (_noteController.text.trim().isEmpty
                          ? null
                          : _noteController.text.trim())
                      : null,
                  hasUnsavedChanges: _hasUnsavedChanges,
                ),
              ],
            ],
          ),
        ),
        bottomNavigationBar: _SaveBar(
          missingItems: _missingItems,
          canSubmit: _canSubmit,
          isSaving: _isSaving,
          isNewEntry: _savedEntry == null,
          isToday: _isToday,
          onSave: _saveEntry,
        ),
      ),
    );
  }

  Widget _buildActivities(BuildContext context) {
    if (_selectedDayType == DayType.betrieb && _selectedArea == null) {
      return const AppMessage(
        icon: Icons.touch_app_outlined,
        title: 'Bereich wählen, dann erscheinen passende Tätigkeiten.',
      );
    }

    final categories = switch (_selectedDayType) {
      DayType.betrieb => [
          _selectedArea!.activityCategory,
          ActivityCategory.sicherheit,
        ],
      DayType.berufsschule => [ActivityCategory.berufsschule],
      _ => <ActivityCategory>[],
    };

    final knownActivityIds = {
      ...defaultActivities.map((activity) => activity.id),
      ..._customTemplates.map((activity) => activity.id),
    };
    final unavailableSelectedIds = _selectedActivityIds
        .where((id) => !knownActivityIds.contains(id))
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_templatesLoadFailed) ...[
          _TemplateLoadWarning(onRetry: _loadTemplates),
          const SizedBox(height: 16),
        ],
        ...categories.expand((category) {
          final defaults = defaultActivities
              .where((activity) => activity.category == category)
              .toList(growable: false);
          final custom = _customTemplates
              .where(
                (activity) =>
                    activity.category == category &&
                    (activity.isActive ||
                        _selectedActivityIds.contains(activity.id)),
              )
              .toList(growable: false);
          return [
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _ActivityGroup(
                title: category.label,
                activities: defaults,
                selectedActivityIds: _selectedActivityIds,
                onToggle: _toggleActivity,
              ),
            ),
            if (custom.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _ActivityGroup(
                  title: 'Eigene Tätigkeiten',
                  activities: custom,
                  selectedActivityIds: _selectedActivityIds,
                  onToggle: _toggleActivity,
                  markAsCustom: true,
                ),
              ),
          ];
        }),
        if (unavailableSelectedIds.isNotEmpty)
          _UnavailableActivities(
            ids: unavailableSelectedIds,
            onRemove: _toggleActivity,
          ),
      ],
    );
  }

  // #25: Compact collapsible special flags
  Widget _buildSpecialFlags() {
    const maxCollapsedUnselected = 3;
    const allFlags = SpecialFlag.values;
    final selectedFlags =
        allFlags.where(_selectedSpecialFlags.contains).toList();
    final unselectedFlags =
        allFlags.where((f) => !_selectedSpecialFlags.contains(f)).toList();

    final needsExpand = unselectedFlags.length > maxCollapsedUnselected;
    final showAll = _specialFlagsExpanded || !needsExpand;
    final visibleUnselected =
        showAll ? unselectedFlags : unselectedFlags.take(maxCollapsedUnselected).toList();
    final hiddenCount = unselectedFlags.length - maxCollapsedUnselected;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...selectedFlags.map((flag) => FilterChip(
              key: ValueKey('special_${flag.name}'),
              label: Text(flag.label),
              selected: true,
              onSelected: (_) => _toggleSpecialFlag(flag),
            )),
        ...visibleUnselected.map((flag) => FilterChip(
              key: ValueKey('special_${flag.name}'),
              label: Text(flag.label),
              selected: false,
              onSelected: (_) => _toggleSpecialFlag(flag),
            )),
        if (!showAll && hiddenCount > 0)
          ActionChip(
            label: Text('+$hiddenCount weitere'),
            onPressed: () => setState(() => _specialFlagsExpanded = true),
          ),
        if (showAll && needsExpand)
          ActionChip(
            label: const Text('Weniger'),
            onPressed: () => setState(() => _specialFlagsExpanded = false),
          ),
      ],
    );
  }

  Future<void> _confirmAndSelectDayType(DayType dayType) async {
    if (_selectedDayType == dayType) {
      return;
    }

    final discardsDetails = _selectedArea != null ||
        _selectedActivityIds.isNotEmpty ||
        (dayType.isAbsence &&
            (_selectedSpecialFlags.isNotEmpty ||
                _noteController.text.trim().isNotEmpty));
    if (discardsDetails &&
        !await _confirmDiscard(
          'Tagestyp ändern?',
          'Bereits ausgewählte Angaben für diesen Tag werden entfernt.',
        )) {
      return;
    }

    setState(() {
      _selectedDayType = dayType;
      _selectedArea = null;
      _selectedActivityIds.clear();
      if (dayType.isAbsence) {
        _selectedSpecialFlags.clear();
      }
      _setChanged();
    });

    if (dayType.isAbsence) {
      _noteController.clear();
    }
  }

  Future<void> _confirmAndSelectArea(TrainingArea area) async {
    if (_selectedArea == area) {
      return;
    }

    if (_selectedActivityIds.isNotEmpty &&
        !await _confirmDiscard(
          'Bereich ändern?',
          'Bereits ausgewählte Tätigkeiten werden entfernt.',
        )) {
      return;
    }

    setState(() {
      _selectedArea = area;
      _selectedActivityIds.clear();
      _setChanged();
    });
  }

  void _toggleActivity(String activityId) {
    setState(() {
      if (!_selectedActivityIds.add(activityId)) {
        _selectedActivityIds.remove(activityId);
      }
      _setChanged();
    });
  }

  void _toggleSpecialFlag(SpecialFlag flag) {
    setState(() {
      if (!_selectedSpecialFlags.add(flag)) {
        _selectedSpecialFlags.remove(flag);
      }
      _setChanged();
    });
  }

  void _markChanged() {
    if (_isApplyingEntry) {
      return;
    }
    if (!_hasUnsavedChanges && mounted) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  void _setChanged() {
    _hasUnsavedChanges = true;
  }

  Future<bool> _confirmDiscard(String title, String message) async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Weiter bearbeiten'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Änderungen verwerfen'),
          ),
        ],
      ),
    );
    return discard == true;
  }

  Future<void> _handlePop(bool didPop, void result) async {
    if (didPop || !widget.protectBackNavigation || !_hasUnsavedChanges) {
      return;
    }
    final discard = await _confirmDiscard(
      'Änderungen verwerfen?',
      'Deine noch nicht gespeicherten Änderungen gehen verloren.',
    );
    if (!discard || !mounted) {
      return;
    }
    setState(() => _hasUnsavedChanges = false);
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      await SystemNavigator.pop();
    }
  }

  Future<void> _loadTemplates() async {
    try {
      final templates = await widget.templateStorage.loadCustom();
      if (mounted) {
        setState(() {
          _customTemplates = templates;
          _templatesLoadFailed = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _templatesLoadFailed = true);
      }
    }
  }

  Future<void> _loadEntry() async {
    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });

    try {
      final entry = await widget.storage.loadByDate(_today);
      if (!mounted) {
        return;
      }
      _applyEntry(entry);
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadFailed = true;
        });
      }
    }
  }

  void _handleExternalDateChange(DateTime nextDate) {
    if (_hasUnsavedChanges) {
      if (_pendingDate != nextDate && mounted) {
        setState(() => _pendingDate = nextDate);
      }
      return;
    }
    _switchToDate(nextDate);
  }

  Future<void> _switchToPendingDate() async {
    final pendingDate = _pendingDate;
    if (pendingDate == null) return;
    if (_hasUnsavedChanges &&
        !await _confirmDiscard(
          'Zum heutigen Tag wechseln?',
          'Deine noch nicht gespeicherten Änderungen gehen verloren.',
        )) {
      return;
    }
    if (!mounted) return;
    await _switchToDate(pendingDate);
  }

  Future<void> _switchToDate(DateTime date) async {
    if (!mounted || date == _activeDate) return;
    setState(() {
      _activeDate = date;
      _pendingDate = null;
      _hasUnsavedChanges = false;
    });
    await _loadEntry();
  }

  void _applyEntry(DailyEntry? entry) {
    _isApplyingEntry = true;
    _noteController.text = entry?.note ?? '';

    setState(() {
      _savedEntry = entry;
      _selectedDayType = entry?.dayType ?? DayType.betrieb;
      _selectedArea = entry?.area;
      _selectedActivityIds
        ..clear()
        ..addAll(entry?.selectedActivities ?? const []);
      _selectedSpecialFlags
        ..clear()
        ..addAll(entry?.specialFlags ?? const []);
      _hasUnsavedChanges = false;
      _isLoading = false;
      _loadFailed = false;
    });

    _isApplyingEntry = false;
  }

  Future<void> _saveEntry() async {
    final now = DateTime.now();
    final existingEntry = _savedEntry;
    final note = _noteController.text.trim();
    final selectedActivities = _selectedActivityIds.toList(growable: false);
    final selectedSpecialFlags = SpecialFlag.values
        .where(_selectedSpecialFlags.contains)
        .toList(growable: false);

    final entry = DailyEntry(
      id: DailyEntry.idForDate(_today),
      date: _today,
      dayType: _selectedDayType,
      area: _selectedDayType == DayType.betrieb ? _selectedArea : null,
      selectedActivities: selectedActivities,
      specialFlags: selectedSpecialFlags,
      note: note.isEmpty ? null : note,
      createdAt: existingEntry?.createdAt ?? now,
      updatedAt: now,
    );

    setState(() => _isSaving = true);

    try {
      await widget.storage.save(entry);
      if (mounted) {
        setState(() {
          _savedEntry = entry;
          _hasUnsavedChanges = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isToday ? 'Heute gespeichert.' : 'Tageseintrag gespeichert.',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Der Eintrag konnte nicht gespeichert werden. Bitte versuche es erneut.',
            ),
          ),
        );
      }
    }
  }

  Map<String, String> _buildActivityTitlesMap() => {
        for (final a in defaultActivities) a.id: a.title,
        for (final a in _customTemplates) a.id: a.title,
      };

  String? _currentReport() {
    if (!_canSave) return null;
    final note = _noteController.text.trim();
    final entry = DailyEntry(
      id: DailyEntry.idForDate(_today),
      date: _today,
      dayType: _selectedDayType,
      area: _selectedDayType == DayType.betrieb ? _selectedArea : null,
      selectedActivities: _selectedActivityIds.toList(growable: false),
      specialFlags: _selectedSpecialFlags.toList(growable: false),
      note: note.isEmpty ? null : note,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return DailyReportGenerator.generate(entry, _buildActivityTitlesMap());
  }
}

class _ReportCard extends StatelessWidget {
  final String report;
  final String? note;
  final bool hasUnsavedChanges;

  const _ReportCard({
    required this.report,
    required this.note,
    required this.hasUnsavedChanges,
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
              'Vorschlag fürs Berichtsheft',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (hasUnsavedChanges) ...[
              const SizedBox(height: 4),
              Text(
                'Vorschau aus aktueller Auswahl – noch nicht gespeichert',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 12),
            SelectableText(report),
            if (note != null) ...[
              const SizedBox(height: 8),
              Text(
                'Zusatznotiz – bei Bedarf übernehmen: $note',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const Key('copy_daily_report'),
              icon: const Icon(Icons.copy_outlined),
              label: const Text('Kopieren'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: report));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tagesbericht kopiert.')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// #21: Stronger status card with colored badge and missing-items hint
class _DayStatusCard extends StatelessWidget {
  final DateTime date;
  final String statusLabel;
  final bool isSaved;
  final bool hasUnsavedChanges;
  final List<String> missingItems;

  const _DayStatusCard({
    required this.date,
    required this.statusLabel,
    required this.isSaved,
    required this.hasUnsavedChanges,
    required this.missingItems,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final ({Color bg, Color fg}) badge;
    if (isSaved && !hasUnsavedChanges) {
      badge = (bg: cs.primaryContainer, fg: cs.onPrimaryContainer);
    } else if (hasUnsavedChanges) {
      badge = (bg: cs.tertiaryContainer, fg: cs.onTertiaryContainer);
    } else {
      badge = (bg: cs.surfaceContainer, fg: cs.onSurfaceVariant);
    }

    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatDayDate(date),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badge.bg,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    statusLabel,
                    key: const ValueKey('daily_entry_status'),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: badge.fg,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (missingItems.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Noch ${missingItems.join(' und ')} auswählen',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// #26: Lighter save bar with compact missing-items hint
class _SaveBar extends StatelessWidget {
  final List<String> missingItems;
  final bool canSubmit;
  final bool isSaving;
  final bool isNewEntry;
  final bool isToday;
  final VoidCallback onSave;

  const _SaveBar({
    required this.missingItems,
    required this.canSubmit,
    required this.isSaving,
    required this.isNewEntry,
    required this.isToday,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainer,
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (missingItems.isNotEmpty) ...[
              Text(
                'Fehlt: ${missingItems.join(' · ')}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const ValueKey('save_daily_entry'),
                onPressed: canSubmit ? onSave : null,
                icon: isSaving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(isNewEntry ? Icons.save_outlined : Icons.update),
                label: Text(
                  isNewEntry
                      ? isToday
                          ? 'Heute speichern'
                          : 'Tag speichern'
                      : 'Änderungen speichern',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityGroup extends StatelessWidget {
  final String title;
  final List<ActivityTemplate> activities;
  final Set<String> selectedActivityIds;
  final ValueChanged<String> onToggle;
  final bool markAsCustom;

  const _ActivityGroup({
    required this.title,
    required this.activities,
    required this.selectedActivityIds,
    required this.onToggle,
    this.markAsCustom = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(title: title),
        const SizedBox(height: 8),
        Material(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: activities.indexed.map((entry) {
              final index = entry.$1;
              final activity = entry.$2;
              final isSelected = selectedActivityIds.contains(activity.id);
              final enabled = activity.isActive || isSelected;
              return Column(
                children: [
                  InkWell(
                    key: ValueKey('activity_${activity.id}'),
                    onTap: enabled ? () => onToggle(activity.id) : null,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 56),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
                        child: Row(
                          children: [
                            Checkbox(
                              value: isSelected,
                              onChanged:
                                  enabled ? (_) => onToggle(activity.id) : null,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activity.title,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: !activity.isActive && !isSelected
                                          ? theme.colorScheme.onSurface
                                              .withValues(alpha: 0.45)
                                          : null,
                                    ),
                                  ),
                                  if (!activity.isActive) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      markAsCustom
                                          ? 'Eigene Tätigkeit · Deaktiviert'
                                          : 'Deaktiviert',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ] else if (markAsCustom) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      'Eigene Tätigkeit',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (index < activities.length - 1) const Divider(indent: 56),
                ],
              );
            }).toList(growable: false),
          ),
        ),
      ],
    );
  }
}

class _TemplateLoadWarning extends StatelessWidget {
  final VoidCallback onRetry;

  const _TemplateLoadWarning({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return AppMessage(
      icon: Icons.warning_amber_outlined,
      title: 'Eigene Tätigkeiten konnten nicht geladen werden.',
      message: 'Vordefinierte Tätigkeiten bleiben verfügbar.',
      tone: AppMessageTone.error,
      action: IconButton(
        onPressed: onRetry,
        tooltip: 'Erneut versuchen',
        icon: const Icon(Icons.refresh),
      ),
    );
  }
}

class _SelectionCount extends StatelessWidget {
  final int count;

  const _SelectionCount({required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: count == 0
            ? theme.colorScheme.surfaceContainer
            : theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count gewählt',
        style: theme.textTheme.labelMedium?.copyWith(
          color: count == 0
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// #23: 2-column area card grid using ChoiceChips with icons
class _AreaGrid extends StatelessWidget {
  final List<TrainingArea> areas;
  final TrainingArea? selected;
  final ValueChanged<TrainingArea> onSelect;

  const _AreaGrid({
    required this.areas,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < areas.length; i += 2) {
      if (i > 0) rows.add(const SizedBox(height: 8));
      rows.add(Row(
        children: [
          Expanded(child: _areaChip(areas[i])),
          const SizedBox(width: 8),
          if (i + 1 < areas.length)
            Expanded(child: _areaChip(areas[i + 1]))
          else
            const Expanded(child: SizedBox.shrink()),
        ],
      ));
    }
    return Column(children: rows);
  }

  Widget _areaChip(TrainingArea area) {
    return ChoiceChip(
      key: ValueKey('area_${area.name}'),
      label: Text(area.label),
      avatar: Icon(area.icon, size: 16),
      showCheckmark: false,
      selected: selected == area,
      onSelected: (_) => onSelect(area),
    );
  }
}

class _UnavailableActivities extends StatelessWidget {
  final List<String> ids;
  final ValueChanged<String> onRemove;

  const _UnavailableActivities({
    required this.ids,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nicht mehr verfügbare Tätigkeiten',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Diese Auswahl stammt aus einem älteren Eintrag. '
          'Du kannst sie entfernen oder unverändert speichern.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ids.indexed
              .map(
                (e) => InputChip(
                  label: Text('Nicht verfügbar (${e.$1 + 1})'),
                  onDeleted: () => onRemove(e.$2),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}
