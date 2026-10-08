import '../models/school_assessment.dart';
import '../models/school_entry.dart';
import '../models/school_task.dart';
import 'school_data_storage.dart';

class InMemorySchoolDataStorage implements SchoolDataStorage {
  final Map<String, SchoolEntry> _entries = {};
  final Map<String, SchoolTask> _tasks = {};
  final Map<String, SchoolAssessment> _assessments = {};

  @override
  bool get isAvailable => true;

  @override
  Future<SchoolEntry?> loadEntry(DateTime date) async =>
      _entries[SchoolEntry.idForDate(date)];

  @override
  Future<List<SchoolEntry>> loadEntries() async {
    final entries = _entries.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return entries;
  }

  @override
  Future<void> saveEntry(SchoolEntry entry) async {
    _entries[SchoolEntry.idForDate(entry.date)] = entry;
  }

  @override
  Future<void> deleteEntry(DateTime date) async {
    _entries.remove(SchoolEntry.idForDate(date));
  }

  @override
  Future<SchoolTask?> loadTask(String id) async => _tasks[id];

  @override
  Future<List<SchoolTask>> loadTasks() async {
    final tasks = _tasks.values.toList()
      ..sort((a, b) {
        if (a.dueDate == null) {
          return b.dueDate == null ? a.title.compareTo(b.title) : 1;
        }
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
    return tasks;
  }

  @override
  Future<void> saveTask(SchoolTask task) async {
    _tasks[task.id] = task;
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.remove(id);
  }

  @override
  Future<SchoolAssessment?> loadAssessment(String id) async =>
      _assessments[id];

  @override
  Future<List<SchoolAssessment>> loadAssessments() async {
    final assessments = _assessments.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return assessments;
  }

  @override
  Future<void> saveAssessment(SchoolAssessment assessment) async {
    _assessments[assessment.id] = assessment;
  }

  @override
  Future<void> deleteAssessment(String id) async {
    _assessments.remove(id);
  }

  @override
  Future<void> clearAll() async {
    _entries.clear();
    _tasks.clear();
    _assessments.clear();
  }
}

class UnavailableSchoolDataStorage implements SchoolDataStorage {
  final String reason;

  const UnavailableSchoolDataStorage(this.reason);

  @override
  bool get isAvailable => false;

  Future<T> _fail<T>() async => throw StateError(reason);

  @override
  Future<SchoolEntry?> loadEntry(DateTime date) => _fail();

  @override
  Future<List<SchoolEntry>> loadEntries() => _fail();

  @override
  Future<void> saveEntry(SchoolEntry entry) => _fail();

  @override
  Future<void> deleteEntry(DateTime date) => _fail();

  @override
  Future<SchoolTask?> loadTask(String id) => _fail();

  @override
  Future<List<SchoolTask>> loadTasks() => _fail();

  @override
  Future<void> saveTask(SchoolTask task) => _fail();

  @override
  Future<void> deleteTask(String id) => _fail();

  @override
  Future<SchoolAssessment?> loadAssessment(String id) => _fail();

  @override
  Future<List<SchoolAssessment>> loadAssessments() => _fail();

  @override
  Future<void> saveAssessment(SchoolAssessment assessment) => _fail();

  @override
  Future<void> deleteAssessment(String id) => _fail();

  @override
  Future<void> clearAll() => _fail();
}
