import '../../domain/curriculum_registry.dart';
import '../../enums/day_type.dart';
import '../../models/adhoc_activity.dart';
import '../../models/daily_entry.dart';
import '../../storage/daily_entry_storage.dart';
import '../models/school_assessment.dart';
import '../models/school_entry.dart';
import '../models/school_task.dart';
import '../storage/school_data_storage.dart';

/// Speichert den strukturierten Schultag und hält den kompatiblen
/// Berichtsheft-Snapshot für denselben Kalendertag synchron.
class SchoolEntryCoordinator {
  final SchoolDataStorage schoolStorage;
  final DailyEntryStorage dailyEntryStorage;

  const SchoolEntryCoordinator({
    required this.schoolStorage,
    required this.dailyEntryStorage,
  });

  Future<DailyEntry> save({
    required SchoolEntry entry,
    SchoolTask? task,
    SchoolAssessment? assessment,
    bool allowReplacingExistingDayType = false,
  }) async {
    final oldSchoolEntry = await schoolStorage.loadEntry(entry.date);
    final oldDailyEntry = await dailyEntryStorage.loadByDate(entry.date);
    if (oldDailyEntry != null &&
        oldDailyEntry.dayType != DayType.berufsschule &&
        !allowReplacingExistingDayType) {
      throw StateError(
        'Für diesen Tag existiert bereits ein anderer Tageseintrag.',
      );
    }
    final oldTask = oldSchoolEntry?.taskId == null
        ? null
        : await schoolStorage.loadTask(oldSchoolEntry!.taskId!);
    final oldAssessment = oldSchoolEntry?.assessmentId == null
        ? null
        : await schoolStorage.loadAssessment(oldSchoolEntry!.assessmentId!);

    final savedEntry = SchoolEntry(
      id: SchoolEntry.idForDate(entry.date),
      date: entry.date,
      blocks: entry.blocks,
      privateNote: entry.privateNote,
      taskId: task?.id,
      assessmentId: assessment?.id,
      createdAt: oldSchoolEntry?.createdAt ?? entry.createdAt,
      updatedAt: entry.updatedAt,
    );
    final dailySnapshot = _dailySnapshot(savedEntry, oldDailyEntry);

    try {
      if (task != null) await schoolStorage.saveTask(task);
      if (assessment != null) await schoolStorage.saveAssessment(assessment);
      await schoolStorage.saveEntry(savedEntry);
      await dailyEntryStorage.save(dailySnapshot);
      if (oldSchoolEntry?.taskId case final oldId?) {
        if (oldId != task?.id) await schoolStorage.deleteTask(oldId);
      }
      if (oldSchoolEntry?.assessmentId case final oldId?) {
        if (oldId != assessment?.id) await schoolStorage.deleteAssessment(oldId);
      }
    } catch (_) {
      await _restoreEntry(oldSchoolEntry, entry.date);
      await _restoreDailyEntry(oldDailyEntry, entry.date);
      await _restoreTask(oldTask, oldSchoolEntry?.taskId, task?.id);
      await _restoreAssessment(
        oldAssessment,
        oldSchoolEntry?.assessmentId,
        assessment?.id,
      );
      rethrow;
    }
    return dailySnapshot;
  }

  Future<void> delete(DateTime date) async {
    final entry = await schoolStorage.loadEntry(date);
    final dailyEntry = await dailyEntryStorage.loadByDate(date);
    final oldTask = entry?.taskId == null
        ? null
        : await schoolStorage.loadTask(entry!.taskId!);
    final oldAssessment = entry?.assessmentId == null
        ? null
        : await schoolStorage.loadAssessment(entry!.assessmentId!);
    try {
      await schoolStorage.deleteEntry(date);
      if (entry?.taskId case final taskId?) {
        await schoolStorage.deleteTask(taskId);
      }
      if (entry?.assessmentId case final assessmentId?) {
        await schoolStorage.deleteAssessment(assessmentId);
      }
      if (dailyEntry?.dayType == DayType.berufsschule) {
        await dailyEntryStorage.delete(dailyEntry!.id);
      }
    } catch (_) {
      await _restoreEntry(entry, date);
      await _restoreDailyEntry(dailyEntry, date);
      await _restoreTask(oldTask, entry?.taskId, null);
      await _restoreAssessment(oldAssessment, entry?.assessmentId, null);
      rethrow;
    }
  }

  Future<void> replaceWithDailyEntry(DailyEntry entry) async {
    final oldSchoolEntry = await schoolStorage.loadEntry(entry.date);
    final oldDailyEntry = await dailyEntryStorage.loadByDate(entry.date);
    final oldTask = oldSchoolEntry?.taskId == null
        ? null
        : await schoolStorage.loadTask(oldSchoolEntry!.taskId!);
    final oldAssessment = oldSchoolEntry?.assessmentId == null
        ? null
        : await schoolStorage.loadAssessment(oldSchoolEntry!.assessmentId!);
    try {
      await dailyEntryStorage.save(entry);
      await schoolStorage.deleteEntry(entry.date);
      if (oldSchoolEntry?.taskId case final taskId?) {
        await schoolStorage.deleteTask(taskId);
      }
      if (oldSchoolEntry?.assessmentId case final assessmentId?) {
        await schoolStorage.deleteAssessment(assessmentId);
      }
    } catch (_) {
      await _restoreDailyEntry(oldDailyEntry, entry.date);
      await _restoreEntry(oldSchoolEntry, entry.date);
      await _restoreTask(oldTask, oldSchoolEntry?.taskId, null);
      await _restoreAssessment(oldAssessment, oldSchoolEntry?.assessmentId, null);
      rethrow;
    }
  }

  DailyEntry _dailySnapshot(SchoolEntry entry, DailyEntry? previous) {
    final activities = <String>[];
    final adhocActivities = <String, String>{};
    for (final (index, block) in entry.blocks.indexed) {
      final unit = CurriculumRegistry.unitById(block.curriculumUnitId);
      final unitTitle = block.customUnitTitle?.trim().isNotEmpty == true
          ? block.customUnitTitle!.trim()
          : unit?.displayTitle ?? 'Eigenes Fach';
      final topics = block.topics
          .map((topic) => topic.trim())
          .where((topic) => topic.isNotEmpty)
          .toList(growable: false);
      final title = topics.isEmpty
          ? unitTitle
          : '$unitTitle: ${topics.join(', ')}';
      final activityId = _activityId(entry, block, index);
      activities.add(activityId);
      adhocActivities[activityId] = title;
    }

    final previousSchoolDay =
        previous?.dayType == DayType.berufsschule ? previous : null;
    return DailyEntry(
      id: DailyEntry.idForDate(entry.date),
      date: entry.date,
      dayType: DayType.berufsschule,
      areas: const [],
      selectedActivities: activities,
      specialFlags: previousSchoolDay?.specialFlags ?? const [],
      reportNote: previousSchoolDay?.reportNote,
      privateNote: entry.privateNote,
      adhocActivities: adhocActivities.entries
          .map((item) => AdhocActivity(id: item.key, title: item.value))
          .toList(growable: false),
      createdAt: previous?.createdAt ?? entry.createdAt,
      updatedAt: entry.updatedAt,
    );
  }

  String _activityId(SchoolEntry entry, SchoolBlock block, int index) {
    final unitId = block.curriculumUnitId
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]+'), '_');
    return 'school_${SchoolEntry.idForDate(entry.date)}_${index}_$unitId';
  }

  Future<void> _restoreEntry(SchoolEntry? oldEntry, DateTime date) async {
    if (oldEntry == null) {
      await schoolStorage.deleteEntry(date);
    } else {
      await schoolStorage.saveEntry(oldEntry);
    }
  }

  Future<void> _restoreDailyEntry(DailyEntry? oldEntry, DateTime date) async {
    if (oldEntry == null) {
      await dailyEntryStorage.delete(DailyEntry.idForDate(date));
    } else {
      await dailyEntryStorage.save(oldEntry);
    }
  }

  Future<void> _restoreTask(
    SchoolTask? oldTask,
    String? oldId,
    String? newId,
  ) async {
    if (newId != null && newId != oldId) {
      await schoolStorage.deleteTask(newId);
    }
    if (oldId != null) {
      if (oldTask == null) {
        await schoolStorage.deleteTask(oldId);
      } else {
        await schoolStorage.saveTask(oldTask);
      }
    }
  }

  Future<void> _restoreAssessment(
    SchoolAssessment? oldAssessment,
    String? oldId,
    String? newId,
  ) async {
    if (newId != null && newId != oldId) {
      await schoolStorage.deleteAssessment(newId);
    }
    if (oldId != null) {
      if (oldAssessment == null) {
        await schoolStorage.deleteAssessment(oldId);
      } else {
        await schoolStorage.saveAssessment(oldAssessment);
      }
    }
  }
}
