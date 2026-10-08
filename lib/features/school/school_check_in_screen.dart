import 'package:flutter/material.dart';

import '../../core/activity_utils.dart';
import '../../core/domain/curriculum_registry.dart';
import '../../core/domain/curriculum_unit.dart';
import '../../core/domain/occupation.dart';
import '../../core/enums/day_type.dart';
import '../../core/models/daily_entry.dart';
import '../../core/models/activity_template.dart';
import '../../core/school/models/school_assessment.dart';
import '../../core/school/models/school_entry.dart';
import '../../core/school/models/school_task.dart';
import '../../core/school/services/school_entry_coordinator.dart';
import '../../core/school/storage/school_data_storage.dart';
import '../../core/storage/activity_template_storage.dart';
import '../../core/storage/daily_entry_storage.dart';
import '../../shared/widgets/app_ui.dart';

class SchoolCheckInScreen extends StatefulWidget {
  final DateTime date;
  final TrainingOccupation occupation;
  final int trainingYear;
  final SchoolDataStorage storage;
  final DailyEntryStorage dailyEntryStorage;
  final ActivityTemplateStorage templateStorage;
  final SchoolEntryCoordinator coordinator;
  final bool allowReplacingExistingDayType;

  const SchoolCheckInScreen({
    super.key,
    required this.date,
    required this.occupation,
    required this.trainingYear,
    required this.storage,
    required this.dailyEntryStorage,
    required this.templateStorage,
    required this.coordinator,
    this.allowReplacingExistingDayType = false,
  });

  @override
  State<SchoolCheckInScreen> createState() => _SchoolCheckInScreenState();
}

class _SchoolCheckInScreenState extends State<SchoolCheckInScreen> {
  final Map<String, TextEditingController> _topicControllers = {};
  final Map<String, TextEditingController> _customTitleControllers = {};
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _privateNoteController = TextEditingController();
  final TextEditingController _assessmentTitleController =
      TextEditingController();
  final Set<String> _selectedUnitIds = {};
  List<CurriculumUnit> _units = const [];
  SchoolEntry? _existingEntry;
  DailyEntry? _existingDailyEntry;
  SchoolTask? _existingTask;
  SchoolAssessment? _existingAssessment;
  DateTime? _taskDueDate;
  late DateTime _assessmentDate;
  int _step = 0;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _loadFailed = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    _assessmentDate = _day(widget.date).add(const Duration(days: 7));
    _load();
  }

  @override
  void dispose() {
    for (final controller in _topicControllers.values) {
      controller.dispose();
    }
    for (final controller in _customTitleControllers.values) {
      controller.dispose();
    }
    _taskTitleController.dispose();
    _privateNoteController.dispose();
    _assessmentTitleController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });
    try {
      final entry = await widget.storage.loadEntry(widget.date);
      final dailyEntry = await widget.dailyEntryStorage.loadByDate(widget.date);
      final templates = await widget.templateStorage.loadCustom();
      final pack = CurriculumRegistry.packFor(
        region: CurriculumRegistry.saxonyRegion,
        occupation: widget.occupation,
        trainingYear: widget.trainingYear,
      );
      final units = [...pack.units];
      final blocks = entry?.blocks ?? _legacyBlocks(dailyEntry, templates);
      for (final block in blocks) {
        if (units.any((unit) => unit.id == block.curriculumUnitId)) continue;
        final known = CurriculumRegistry.unitById(block.curriculumUnitId);
        units.add(
          known ??
              CurriculumUnit(
                id: block.curriculumUnitId,
                occupation: widget.occupation,
                region: CurriculumRegistry.saxonyRegion,
                trainingYear: widget.trainingYear,
                unitType: CurriculumUnitType.custom,
                displayCode: 'Eigenes Fach',
                title: block.customUnitTitle ?? 'Bisherige Inhalte',
              ),
        );
      }
      final task = entry?.taskId == null
          ? null
          : await widget.storage.loadTask(entry!.taskId!);
      final assessment = entry?.assessmentId == null
          ? null
          : await widget.storage.loadAssessment(entry!.assessmentId!);
      if (!mounted) return;
      setState(() {
        _existingEntry = entry;
        _existingDailyEntry = dailyEntry;
        _existingTask = task;
        _existingAssessment = assessment;
        _units = units;
        _selectedUnitIds
          ..clear()
          ..addAll(blocks.map((block) => block.curriculumUnitId));
        for (final block in blocks) {
          _topicControllers[block.curriculumUnitId] = TextEditingController(
            text: block.topics.join('\n'),
          );
          if (block.customUnitTitle != null) {
            _customTitleControllers[block.curriculumUnitId] =
                TextEditingController(text: block.customUnitTitle);
          }
        }
        _privateNoteController.text =
            entry?.privateNote ?? dailyEntry?.privateNote ?? '';
        _taskTitleController.text = task?.title ?? '';
        _taskDueDate = task?.dueDate;
        _assessmentTitleController.text = assessment?.title ?? '';
        _assessmentDate = assessment?.date ?? _assessmentDate;
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

  List<SchoolBlock> _legacyBlocks(
    DailyEntry? dailyEntry,
    Iterable<ActivityTemplate> templates,
  ) {
    final existingEntry = dailyEntry;
    if (existingEntry == null ||
        existingEntry.dayType != DayType.berufsschule ||
        existingEntry.selectedActivities.isEmpty) {
      return const [];
    }
    final id = 'legacy_school_${DailyEntry.idForDate(widget.date)}';
    final titles = activityTitlesForEntry(existingEntry, templates);
    final topics = existingEntry.selectedActivities
        .map((activityId) => titles[activityId] ?? activityId)
        .toList(growable: false);
    return [
      SchoolBlock(
        curriculumUnitId: id,
        customUnitTitle: 'Bisherige Inhalte',
        topics: topics,
      ),
    ];
  }

  void _toggleUnit(CurriculumUnit unit, bool selected) {
    setState(() {
      if (selected) {
        _selectedUnitIds.add(unit.id);
        _topicControllers.putIfAbsent(unit.id, TextEditingController.new);
        if (unit.unitType == CurriculumUnitType.custom ||
            unit.unitType == CurriculumUnitType.generalSubject) {
          _customTitleControllers.putIfAbsent(
            unit.id,
            () => TextEditingController(text: unit.title),
          );
        }
      } else {
        _selectedUnitIds.remove(unit.id);
        _topicControllers.remove(unit.id)?.dispose();
        _customTitleControllers.remove(unit.id)?.dispose();
      }
    });
  }

  void _addGeneralSubject() {
    final dateId = SchoolEntry.idForDate(widget.date);
    var suffix = 1;
    var id = 'school_general_${dateId}_$suffix';
    while (_units.any((unit) => unit.id == id)) {
      suffix++;
      id = 'school_general_${dateId}_$suffix';
    }
    final unit = CurriculumUnit(
      id: id,
      occupation: widget.occupation,
      region: CurriculumRegistry.saxonyRegion,
      trainingYear: widget.trainingYear,
      unitType: CurriculumUnitType.generalSubject,
      displayCode: '',
      title: 'Eigenes Fach',
    );
    setState(() {
      _units = [..._units, unit];
      _selectedUnitIds.add(unit.id);
      _topicControllers[unit.id] = TextEditingController();
      _customTitleControllers[unit.id] = TextEditingController();
    });
  }

  Future<void> _save() async {
    if (_selectedUnitIds.isEmpty || _isSaving) return;
    final selectedUnits = _units
        .where((unit) => _selectedUnitIds.contains(unit.id))
        .toList(growable: false);
    final hasUnnamedGeneralSubject = selectedUnits.any(
      (unit) =>
          unit.unitType == CurriculumUnitType.generalSubject &&
          (_customTitleControllers[unit.id]?.text.trim().isEmpty ?? true),
    );
    if (hasUnnamedGeneralSubject) {
      setState(() => _saveError = 'Gib den Namen des Fachs ein.');
      return;
    }
    setState(() {
      _isSaving = true;
      _saveError = null;
    });
    final now = DateTime.now();
    final blocks = selectedUnits.map((unit) {
      final title = _customTitleControllers[unit.id]?.text.trim();
      return SchoolBlock(
        curriculumUnitId: unit.id,
        customUnitTitle: unit.unitType == CurriculumUnitType.custom ||
                unit.unitType == CurriculumUnitType.generalSubject
            ? (title == null || title.isEmpty ? unit.title : title)
            : null,
        topics: _topicsFor(unit.id),
      );
    }).toList(growable: false);
    final oldEntry = _existingEntry;
    final taskTitle = _taskTitleController.text.trim();
    final task = taskTitle.isEmpty
        ? null
        : SchoolTask(
            id: _existingTask?.id ?? _newId('school_task', now),
            title: taskTitle,
            curriculumUnitId: selectedUnits.first.id,
            createdAt: _existingTask?.createdAt ?? now,
            dueDate: _taskDueDate,
            status: _existingTask?.status ?? SchoolTaskStatus.open,
            type: _existingTask?.type ?? SchoolTaskType.homework,
            note: _existingTask?.note,
          );
    final assessmentTitle = _assessmentTitleController.text.trim();
    final assessment = assessmentTitle.isEmpty
        ? null
        : SchoolAssessment(
            id: _existingAssessment?.id ?? _newId('school_assessment', now),
            title: assessmentTitle,
            curriculumUnitId: selectedUnits.first.id,
            date: _assessmentDate,
            status: _existingAssessment?.status ??
                SchoolAssessmentStatus.planned,
            kind: _existingAssessment?.kind ?? SchoolAssessmentKind.classTest,
            result: _existingAssessment?.result,
            note: _existingAssessment?.note,
          );
    final entry = SchoolEntry(
      id: SchoolEntry.idForDate(widget.date),
      date: widget.date,
      blocks: blocks,
      privateNote: _optionalText(_privateNoteController.text),
      taskId: task?.id,
      assessmentId: assessment?.id,
      createdAt: oldEntry?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      await widget.coordinator.save(
        entry: entry,
        task: task,
        assessment: assessment,
        allowReplacingExistingDayType:
            widget.allowReplacingExistingDayType,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _saveError =
              'Der Schultag konnte nicht vollständig gespeichert werden. Deine bisherigen Einträge wurden beibehalten.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_loadFailed || !widget.storage.isAvailable) {
      return Scaffold(
        appBar: AppBar(title: const Text('Schultag eintragen')),
        body: AppEmptyState(
          icon: Icons.error_outline,
          title: 'Schulbereich nicht verfügbar',
          message:
              'Die lokalen Schuldaten konnten nicht gelesen werden. Versuche es später erneut.',
          action: FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(false),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Zurück'),
          ),
        ),
      );
    }

    final stepTitle = switch (_step) {
      0 => 'Lernfelder und Fächer',
      1 => 'Themen',
      2 => 'Aufgabe und Klassenarbeit',
      _ => 'Prüfen und speichern',
    };
    return Scaffold(
      appBar: AppBar(
        title: const Text('Berufsschultag'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('Schritt ${_step + 1} von 4')),
          ),
        ],
      ),
      body: ListView(
        key: ValueKey('school_check_in_step_$_step'),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            '${_formatDate(widget.date)} · $stepTitle',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          if (_step == 0) _buildUnitSelection(),
          if (_step == 1) _buildTopicInputs(),
          if (_step == 2) _buildOptionalDetails(),
          if (_step == 3) _buildReview(),
          if (_saveError != null) ...[
            const SizedBox(height: 12),
            AppMessage(
              icon: Icons.error_outline,
              title: _saveError!,
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            if (_step > 0)
              OutlinedButton.icon(
                onPressed: _isSaving ? null : () => setState(() => _step--),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Zurück'),
              )
            else
              OutlinedButton(
                onPressed: _isSaving
                    ? null
                    : () => Navigator.of(context).pop(false),
                child: const Text('Abbrechen'),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                key: const ValueKey('school_check_in_continue'),
                onPressed: _isSaving || (_step == 0 && _selectedUnitIds.isEmpty)
                    ? null
                    : _step == 3
                        ? _save
                        : () => setState(() => _step++),
                icon: _isSaving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(_step == 3 ? Icons.save_outlined : Icons.arrow_forward),
                label: Text(_step == 3 ? 'Schultag speichern' : 'Weiter'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_units.isEmpty)
          const AppMessage(
            icon: Icons.menu_book_outlined,
            title: 'Keine passenden Lernfelder verfügbar.',
          ),
        for (final unit in _units)
          CheckboxListTile(
            key: ValueKey('school_unit_${unit.id}'),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(unit.displayTitle),
            subtitle: Text(unit.unitType.label),
            value: _selectedUnitIds.contains(unit.id),
            onChanged: (selected) => _toggleUnit(unit, selected ?? false),
          ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            key: const ValueKey('add_school_general_subject'),
            onPressed: _addGeneralSubject,
            icon: const Icon(Icons.add),
            label: const Text('Eigenes Fach hinzufügen'),
          ),
        ),
      ],
    );
  }

  Widget _buildTopicInputs() {
    final selected = _units
        .where((unit) => _selectedUnitIds.contains(unit.id))
        .toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final unit in selected) ...[
          Text(
            _unitTitleForDisplay(unit),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          if (unit.unitType == CurriculumUnitType.custom ||
              unit.unitType == CurriculumUnitType.generalSubject) ...[
            TextField(
              key: ValueKey('school_title_${unit.id}'),
              controller: _customTitleControllers.putIfAbsent(
                unit.id,
                () => TextEditingController(text: unit.title),
              ),
              decoration: InputDecoration(
                labelText: unit.unitType == CurriculumUnitType.generalSubject
                    ? 'Fachname'
                    : 'Fach oder Lernfeld',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
          ],
          TextField(
            key: ValueKey('school_topics_${unit.id}'),
            controller: _topicControllers.putIfAbsent(
              unit.id,
              TextEditingController.new,
            ),
            minLines: 1,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Themen (optional)',
              hintText: 'Zum Beispiel: Wareneingang, Lieferscheinprüfung',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildOptionalDetails() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: const ValueKey('school_task_title'),
            controller: _taskTitleController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Aufgabe (optional)',
              hintText: 'Zum Beispiel: Arbeitsblatt bis Freitag',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickTaskDueDate,
            icon: const Icon(Icons.event_outlined),
            label: Text(
              _taskDueDate == null
                  ? 'Fälligkeit hinzufügen'
                  : 'Fällig am ${_formatDate(_taskDueDate!)}',
            ),
          ),
          if (_taskDueDate != null)
            TextButton(
              onPressed: () => setState(() => _taskDueDate = null),
              child: const Text('Fälligkeit entfernen'),
            ),
          const SizedBox(height: 16),
          TextField(
            key: const ValueKey('school_assessment_title'),
            controller: _assessmentTitleController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Klassenarbeit oder Test (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickAssessmentDate,
            icon: const Icon(Icons.event_note_outlined),
            label: Text('Termin: ${_formatDate(_assessmentDate)}'),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const ValueKey('school_private_note'),
            controller: _privateNoteController,
            minLines: 2,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Private Notiz (optional)',
              helperText: 'Wird nicht in den Berichtshefttext übernommen.',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      );

  String _unitTitleForDisplay(CurriculumUnit unit) {
    if (unit.unitType != CurriculumUnitType.custom &&
        unit.unitType != CurriculumUnitType.generalSubject) {
      return unit.displayTitle;
    }
    final enteredTitle = _customTitleControllers[unit.id]?.text.trim();
    return enteredTitle == null || enteredTitle.isEmpty
        ? unit.title
        : enteredTitle;
  }

  Widget _buildReview() {
    final selected = _units
        .where((unit) => _selectedUnitIds.contains(unit.id))
        .toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_existingDailyEntry != null &&
            _existingDailyEntry!.dayType != DayType.berufsschule)
          const AppMessage(
            icon: Icons.info_outline,
            title:
                'Der bisherige Tagesbericht wird nach deiner Bestätigung durch diesen Schultag ersetzt.',
          ),
        for (final unit in selected)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(_unitTitleForDisplay(unit)),
            subtitle: Text(
              _topicsFor(unit.id).isEmpty
                  ? 'Keine Themen ergänzt'
                  : _topicsFor(unit.id).join(' · '),
            ),
          ),
        if (_taskTitleController.text.trim().isNotEmpty)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.task_alt_outlined),
            title: Text(_taskTitleController.text.trim()),
            subtitle: Text(
              _taskDueDate == null
                  ? 'Aufgabe'
                  : 'Fällig ${_formatDate(_taskDueDate!)}',
            ),
          ),
        if (_assessmentTitleController.text.trim().isNotEmpty)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_note_outlined),
            title: Text(_assessmentTitleController.text.trim()),
            subtitle: Text('Termin ${_formatDate(_assessmentDate)}'),
          ),
        if (_privateNoteController.text.trim().isNotEmpty)
          const AppMessage(
            icon: Icons.lock_outline,
            title: 'Private Notiz bleibt außerhalb des Berichts.',
          ),
      ],
    );
  }

  Future<void> _pickTaskDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _taskDueDate ?? _day(widget.date),
      firstDate: DateTime(widget.date.year - 2),
      lastDate: DateTime(widget.date.year + 5),
    );
    if (picked != null && mounted) setState(() => _taskDueDate = picked);
  }

  Future<void> _pickAssessmentDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _assessmentDate,
      firstDate: DateTime(widget.date.year - 2),
      lastDate: DateTime(widget.date.year + 5),
    );
    if (picked != null && mounted) setState(() => _assessmentDate = picked);
  }

  List<String> _topicsFor(String id) =>
      (_topicControllers[id]?.text ?? '')
          .split(RegExp(r'[\n,;]+'))
          .map((topic) => topic.trim())
          .where((topic) => topic.isNotEmpty)
          .toList(growable: false);

  String? _optionalText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _newId(String prefix, DateTime now) =>
      '${prefix}_${now.microsecondsSinceEpoch}';

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

  DateTime _day(DateTime date) => DateTime(date.year, date.month, date.day);
}
