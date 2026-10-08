import '../models/school_assessment.dart';
import '../models/school_entry.dart';
import '../models/school_task.dart';

abstract interface class SchoolDataStorage {
  bool get isAvailable;

  Future<SchoolEntry?> loadEntry(DateTime date);
  Future<List<SchoolEntry>> loadEntries();
  Future<void> saveEntry(SchoolEntry entry);
  Future<void> deleteEntry(DateTime date);

  Future<SchoolTask?> loadTask(String id);
  Future<List<SchoolTask>> loadTasks();
  Future<void> saveTask(SchoolTask task);
  Future<void> deleteTask(String id);

  Future<SchoolAssessment?> loadAssessment(String id);
  Future<List<SchoolAssessment>> loadAssessments();
  Future<void> saveAssessment(SchoolAssessment assessment);
  Future<void> deleteAssessment(String id);

  Future<void> clearAll();
}
