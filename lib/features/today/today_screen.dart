import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/activity_utils.dart';
import '../../core/enums/day_type.dart';
import '../../core/enums/special_flag.dart';
import '../../core/enums/training_area.dart';
import '../../core/models/activity_template.dart';
import '../../core/models/daily_entry.dart';
import '../../core/storage/daily_entry_storage.dart';
import '../../core/storage/activity_template_storage.dart';
import '../../core/report/daily_report_generator.dart';
import '../../shared/widgets/app_ui.dart';
import 'activity_picker_model.dart';
import 'activity_recommender.dart';
import 'today_entry_draft.dart';
import 'widgets/activity_section.dart';
import 'widgets/activity_picker_section.dart';
import 'widgets/area_grid.dart';
import 'widgets/day_status_card.dart';
import 'widgets/day_type_selector.dart';
import 'widgets/report_card.dart';
import 'widgets/save_bar.dart';
import 'widgets/special_flags_note_section.dart';

class TodayScreen extends StatefulWidget {
  final DailyEntryStorage storage;
  final ActivityTemplateStorage templateStorage;
  final DateTime? date;
  final DateTime? currentDate;
  final int? trainingYear;
  final int templateRefreshSignal;
  final bool protectBackNavigation;

  const TodayScreen({
    super.key,
    required this.storage,
    required this.templateStorage,
    this.date,
    this.currentDate,
    this.trainingYear,
    this.templateRefreshSignal = 0,
    this.protectBackNavigation = true,
  });

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _activitySearchController =
      TextEditingController();
  final Set<String> _selectedActivityIds = {};
  final Set<SpecialFlag> _selectedSpecialFlags = {};
  List<ActivityTemplate> _customTemplates = [];
  List<String> _frequentActivityIds = [];
  String _activitySearchQuery = '';

  DayType _selectedDayType = DayType.betrieb;
  final Set<TrainingArea> _selectedAreas = {};
  DailyEntry? _savedEntry;
  bool _hasUnsavedChanges = false;
  bool _isLoading = true;
  bool _loadFailed = false;
  bool _isSaving = false;
  bool _isApplyingEntry = false;
  bool _templatesLoadFailed = false;
  bool _optionalSectionExpanded = false;
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

  TodayEntryDraft get _draft => TodayEntryDraft(
        date: _today,
        dayType: _selectedDayType,
        selectedAreas: _selectedAreas,
        selectedActivityIds: _selectedActivityIds,
        selectedSpecialFlags: _selectedSpecialFlags,
        note: _noteController.text,
      );

  bool get _canSave => _draft.canSave;

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
    return _draft.missingItems;
  }

  @override
  void initState() {
    super.initState();
    _activeDate = _widgetDate;
    _noteController.addListener(_markChanged);
    _loadEntry();
    _loadTemplates();
    _loadFrequentActivities();
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
    _activitySearchController.dispose();
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

    final report = _canSave &&
            (_selectedDayType == DayType.betrieb ||
                _selectedDayType == DayType.berufsschule)
        ? _currentReport()
        : null;

    return PopScope<void>(
      canPop: !widget.protectBackNavigation || !_hasUnsavedChanges,
      onPopInvokedWithResult: _handlePop,
      child: Scaffold(
        appBar: AppBar(title: Text(_screenTitle)),
        body: IgnorePointer(
          ignoring: _isSaving,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: DayStatusCard(
                  date: _today,
                  statusLabel: _statusLabel,
                  isSaved: _savedEntry != null && !_hasUnsavedChanges,
                  hasUnsavedChanges: _hasUnsavedChanges,
                  missingItems: _missingItems,
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
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
                    DayTypeSelector(
                      selectedDayType: _selectedDayType,
                      onSelect: _confirmAndSelectDayType,
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
                      AreaGrid(
                        areas: TrainingArea.values,
                        selected: _selectedAreas,
                        onToggle: _toggleArea,
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
                        trailing:
                            SelectionCount(count: _selectedActivityIds.length),
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
                      const SizedBox(height: 16),
                      SpecialFlagsAndNoteSection(
                        selectedDayType: _selectedDayType,
                        savedEntryId: _savedEntry?.id,
                        isExpanded: _optionalSectionExpanded,
                        onExpansionChanged: (expanded) =>
                            setState(() => _optionalSectionExpanded = expanded),
                        selectedSpecialFlags: _selectedSpecialFlags,
                        onToggleSpecialFlag: _toggleSpecialFlag,
                        noteController: _noteController,
                      ),
                    ],
                    if (report != null) ...[
                      const SizedBox(height: 16),
                      ReportCard(
                        key: const ValueKey('report_card'),
                        report: report,
                        isSaved: _savedEntry != null && !_hasUnsavedChanges,
                        onCopy: _copyReport,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SaveBar(
          missingItems: _missingItems,
          canSubmit: _canSubmit,
          isSaving: _isSaving,
          isNewEntry: _savedEntry == null,
          isToday: _isToday,
          onSave: _saveEntry,
          selectedActivityCount: _selectedActivityIds.length,
          supportsActivities: _selectedDayType.supportsActivities,
        ),
      ),
    );
  }

  Widget _buildActivities(BuildContext context) {
    if (_selectedDayType == DayType.betrieb && _selectedAreas.isEmpty) {
      return const AppMessage(
        icon: Icons.touch_app_outlined,
        title: 'Bereich wählen, dann erscheinen passende Tätigkeiten.',
      );
    }

    final model = ActivityPickerModel.build(
      dayType: _selectedDayType,
      selectedAreas: _selectedAreas,
      selectedActivityIds: _selectedActivityIds,
      customTemplates: _customTemplates,
      frequentActivityIds: _frequentActivityIds,
      searchQuery: _activitySearchQuery,
      trainingYear: widget.trainingYear,
    );

    return ActivityPickerSection(
      model: model,
      templatesLoadFailed: _templatesLoadFailed,
      onRetryTemplates: _loadTemplates,
      searchController: _activitySearchController,
      searchQuery: _activitySearchQuery,
      onSearchChanged: (value) => setState(() => _activitySearchQuery = value),
      onClearSearch: _clearActivitySearch,
      onToggleActivity: _toggleActivity,
      trainingYear: widget.trainingYear,
    );
  }

  void _clearActivitySearch() {
    _activitySearchController.clear();
    setState(() => _activitySearchQuery = '');
  }

  Future<void> _confirmAndSelectDayType(DayType dayType) async {
    if (_selectedDayType == dayType) {
      return;
    }

    final discardsDetails = _selectedAreas.isNotEmpty ||
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
      _selectedAreas.clear();
      _selectedActivityIds.clear();
      _activitySearchQuery = '';
      if (dayType.isAbsence) {
        _selectedSpecialFlags.clear();
      }
      _optionalSectionExpanded = dayType == DayType.sonstiges;
      _setChanged();
    });
    _activitySearchController.clear();

    if (dayType.isAbsence) {
      _noteController.clear();
    }
  }

  bool _hasSelectedActivitiesIn(TrainingArea area) {
    final ids = activityIdsForCategory(area.activityCategory, _customTemplates);
    return _selectedActivityIds.any(ids.contains);
  }

  void _removeSelectedActivitiesIn(TrainingArea area) {
    final ids = activityIdsForCategory(area.activityCategory, _customTemplates);
    _selectedActivityIds.removeAll(ids);
  }

  Future<void> _toggleArea(TrainingArea area) async {
    if (_selectedAreas.contains(area)) {
      if (_hasSelectedActivitiesIn(area) &&
          !await _confirmDiscard(
            'Bereich entfernen?',
            'Ausgewählte Tätigkeiten in diesem Bereich werden entfernt.',
          )) {
        return;
      }
      setState(() {
        _selectedAreas.remove(area);
        _removeSelectedActivitiesIn(area);
        _setChanged();
      });
    } else {
      setState(() {
        _selectedAreas.add(area);
        _setChanged();
      });
    }
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

  Future<void> _loadFrequentActivities() async {
    try {
      final entries = await widget.storage.loadAll();
      final ids = computeFrequentActivityIds(entries);
      if (mounted) {
        setState(() => _frequentActivityIds = ids);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _frequentActivityIds = const []);
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
      _selectedAreas
        ..clear()
        ..addAll(entry?.areas ?? const []);
      _selectedActivityIds
        ..clear()
        ..addAll(entry?.selectedActivities ?? const []);
      _selectedSpecialFlags
        ..clear()
        ..addAll(entry?.specialFlags ?? const []);
      _hasUnsavedChanges = false;
      _isLoading = false;
      _loadFailed = false;
      _optionalSectionExpanded =
          _selectedSpecialFlags.isNotEmpty || _noteController.text.isNotEmpty;
    });

    _isApplyingEntry = false;
  }

  Future<void> _saveEntry() async {
    final now = DateTime.now();
    final entry = _draft.toEntry(timestamp: now, existingEntry: _savedEntry);

    setState(() => _isSaving = true);

    try {
      await widget.storage.save(entry);
      if (mounted) {
        setState(() {
          _savedEntry = entry;
          _hasUnsavedChanges = false;
          _isSaving = false;
        });
        _loadFrequentActivities();
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

  String? _currentReport() {
    if (!_canSave) return null;
    final now = DateTime.now();
    final entry = _draft.toEntry(timestamp: now, existingEntry: _savedEntry);
    return DailyReportGenerator.generate(
      entry,
      buildActivityTitlesMap(_customTemplates),
    );
  }

  void _copyReport() {
    final report = _currentReport();
    if (report == null) return;
    Clipboard.setData(ClipboardData(text: report));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tagesbericht kopiert.')),
    );
  }
}
