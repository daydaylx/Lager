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

class TodayScreen extends StatefulWidget {
  final DailyEntryStorage storage;
  final ActivityTemplateStorage templateStorage;
  final DateTime? date;
  final int templateRefreshSignal;
  final bool protectBackNavigation;

  const TodayScreen({
    super.key,
    required this.storage,
    required this.templateStorage,
    this.date,
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

  DateTime get _today {
    final value = widget.date ?? DateTime.now();
    return DateTime(value.year, value.month, value.day);
  }

  bool get _isToday {
    final now = DateTime.now();
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

  @override
  void initState() {
    super.initState();
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
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 16),
                Text(
                  _isToday
                      ? 'Dein heutiger Eintrag konnte nicht geladen werden.'
                      : 'Der Tageseintrag konnte nicht geladen werden.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  key: const ValueKey('retry_daily_entry_load'),
                  onPressed: _loadEntry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Erneut versuchen'),
                ),
              ],
            ),
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
              _buildDayHeader(context),
              const SizedBox(height: 24),
              _SectionTitle(
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
                const SizedBox(height: 28),
                _SectionTitle(
                  title: 'Bereich',
                  description: _isToday
                      ? 'Wo hast du heute gearbeitet?'
                      : 'Wo hast du an diesem Tag gearbeitet?',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: TrainingArea.values.map((area) {
                    return ChoiceChip(
                      key: ValueKey('area_${area.name}'),
                      label: Text(area.label),
                      selected: _selectedArea == area,
                      onSelected: (_) => _confirmAndSelectArea(area),
                    );
                  }).toList(),
                ),
              ],
              if (_selectedDayType.supportsActivities) ...[
                const SizedBox(height: 28),
                _SectionTitle(
                  title: 'Tätigkeiten',
                  description: _isToday
                      ? 'Wähle aus, was du heute gemacht hast.'
                      : 'Wähle aus, was du an diesem Tag gemacht hast.',
                ),
                const SizedBox(height: 12),
                _buildActivities(context),
              ],
              if (_selectedDayType == DayType.sonstiges) ...[
                const SizedBox(height: 24),
                const _InfoCard(
                  icon: Icons.edit_note_outlined,
                  text:
                      'Beschreibe den Tag kurz über Besonderheiten oder Notiz.',
                ),
              ],
              if (_selectedDayType.isAbsence) ...[
                const SizedBox(height: 24),
                _InfoCard(
                  icon: Icons.event_available_outlined,
                  text:
                      '${_selectedDayType.label} kann direkt gespeichert werden.',
                ),
              ],
              if (!_selectedDayType.isAbsence) ...[
                const SizedBox(height: 28),
                const _SectionTitle(
                  title: 'Besonderheiten',
                  description: 'Optional: Was war heute besonders?',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: SpecialFlag.values.map((flag) {
                    return FilterChip(
                      key: ValueKey('special_${flag.name}'),
                      label: Text(flag.label),
                      selected: _selectedSpecialFlags.contains(flag),
                      onSelected: (_) => _toggleSpecialFlag(flag),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),
                const _SectionTitle(
                  title: 'Notiz',
                  description: 'Optional und bewusst kurz.',
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
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_validationHint case final hint?) ...[
                Text(
                  hint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
              ],
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  key: const ValueKey('save_daily_entry'),
                  onPressed: _canSubmit ? _saveEntry : null,
                  icon: _isSaving
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          _savedEntry == null
                              ? Icons.save_outlined
                              : Icons.update,
                        ),
                  label: Text(
                    _savedEntry == null
                        ? _isToday
                            ? 'Heute speichern'
                            : 'Tag speichern'
                        : 'Änderungen speichern',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isSaved = _savedEntry != null && !_hasUnsavedChanges;
    final color = isSaved
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(
              isSaved ? Icons.check_circle : Icons.today_outlined,
              color: color,
              size: 32,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(_today),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _statusLabel,
                    key: const ValueKey('daily_entry_status'),
                    style: theme.textTheme.bodyMedium?.copyWith(color: color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivities(BuildContext context) {
    if (_selectedDayType == DayType.betrieb && _selectedArea == null) {
      return const _InfoCard(
        icon: Icons.touch_app_outlined,
        text: 'Wähle zuerst einen Bereich aus.',
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

  String? get _validationHint {
    if (_selectedDayType == DayType.betrieb && _selectedArea == null) {
      return 'Wähle einen Bereich aus, um den Tag zu speichern.';
    }
    if (_selectedDayType.supportsActivities && _selectedActivityIds.isEmpty) {
      return 'Wähle mindestens eine Tätigkeit aus.';
    }
    return null;
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

  String _formatDate(DateTime date) {
    const weekdays = [
      'Montag',
      'Dienstag',
      'Mittwoch',
      'Donnerstag',
      'Freitag',
      'Samstag',
      'Sonntag',
    ];
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

    return '${weekdays[date.weekday - 1]}, ${date.day}. ${months[date.month - 1]}';
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String description;

  const _SectionTitle({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoCard({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _ActivityGroup extends StatelessWidget {
  final String title;
  final List<ActivityTemplate> activities;
  final Set<String> selectedActivityIds;
  final ValueChanged<String> onToggle;

  const _ActivityGroup({
    required this.title,
    required this.activities,
    required this.selectedActivityIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: activities.map((activity) {
            final isSelected = selectedActivityIds.contains(activity.id);
            return FilterChip(
              key: ValueKey('activity_${activity.id}'),
              label: Text(
                activity.isActive
                    ? activity.title
                    : '${activity.title} (deaktiviert)',
              ),
              selected: isSelected,
              onSelected: activity.isActive || isSelected
                  ? (_) => onToggle(activity.id)
                  : null,
            );
          }).toList(),
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_outlined, color: theme.colorScheme.error),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Eigene Tätigkeiten konnten nicht geladen werden. '
              'Vordefinierte Tätigkeiten bleiben verfügbar.',
            ),
          ),
          IconButton(
            onPressed: onRetry,
            tooltip: 'Erneut versuchen',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
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
          children: ids
              .map(
                (id) => InputChip(
                  label: const Text('Nicht verfügbare Tätigkeit'),
                  onDeleted: () => onRemove(id),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}
