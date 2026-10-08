import 'dart:convert';

import 'package:hive_ce_flutter/hive_flutter.dart';

import '../models/school_assessment.dart';
import '../models/school_entry.dart';
import '../models/school_task.dart';
import 'school_data_storage.dart';

class HiveSchoolDataStorage implements SchoolDataStorage {
  static const String entriesBoxName = 'school_entries';
  static const String tasksBoxName = 'school_tasks';
  static const String assessmentsBoxName = 'school_assessments';

  final Box<String> _entries;
  final Box<String> _tasks;
  final Box<String> _assessments;

  const HiveSchoolDataStorage._(
    this._entries,
    this._tasks,
    this._assessments,
  );

  static Future<HiveSchoolDataStorage> open() async {
    await Hive.initFlutter();
    return _openBoxes();
  }

  static Future<HiveSchoolDataStorage> openAtPath(String path) async {
    Hive.init(path);
    return _openBoxes();
  }

  static Future<HiveSchoolDataStorage> _openBoxes() async {
    final entries = await Hive.openBox<String>(entriesBoxName);
    final tasks = await Hive.openBox<String>(tasksBoxName);
    final assessments = await Hive.openBox<String>(assessmentsBoxName);
    return HiveSchoolDataStorage._(entries, tasks, assessments);
  }

  @override
  bool get isAvailable => true;

  @override
  Future<SchoolEntry?> loadEntry(DateTime date) async {
    final json = _entries.get(SchoolEntry.idForDate(date));
    return json == null ? null : _decode(json, SchoolEntry.fromJson);
  }

  @override
  Future<List<SchoolEntry>> loadEntries() async {
    final entries = _decodeAll(_entries.values, SchoolEntry.fromJson);
    entries.sort((a, b) => a.date.compareTo(b.date));
    return entries;
  }

  @override
  Future<void> saveEntry(SchoolEntry entry) =>
      _entries.put(SchoolEntry.idForDate(entry.date), jsonEncode(entry.toJson()));

  @override
  Future<void> deleteEntry(DateTime date) =>
      _entries.delete(SchoolEntry.idForDate(date));

  @override
  Future<SchoolTask?> loadTask(String id) async {
    final json = _tasks.get(id);
    return json == null ? null : _decode(json, SchoolTask.fromJson);
  }

  @override
  Future<List<SchoolTask>> loadTasks() async {
    final tasks = _decodeAll(_tasks.values, SchoolTask.fromJson);
    tasks.sort((a, b) {
      if (a.dueDate == null) return b.dueDate == null ? a.title.compareTo(b.title) : 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });
    return tasks;
  }

  @override
  Future<void> saveTask(SchoolTask task) =>
      _tasks.put(task.id, jsonEncode(task.toJson()));

  @override
  Future<void> deleteTask(String id) => _tasks.delete(id);

  @override
  Future<SchoolAssessment?> loadAssessment(String id) async {
    final json = _assessments.get(id);
    return json == null ? null : _decode(json, SchoolAssessment.fromJson);
  }

  @override
  Future<List<SchoolAssessment>> loadAssessments() async {
    final assessments =
        _decodeAll(_assessments.values, SchoolAssessment.fromJson);
    assessments.sort((a, b) => a.date.compareTo(b.date));
    return assessments;
  }

  @override
  Future<void> saveAssessment(SchoolAssessment assessment) => _assessments.put(
        assessment.id,
        jsonEncode(assessment.toJson()),
      );

  @override
  Future<void> deleteAssessment(String id) => _assessments.delete(id);

  @override
  Future<void> clearAll() async {
    await _entries.clear();
    await _tasks.clear();
    await _assessments.clear();
    await _entries.compact();
    await _tasks.compact();
    await _assessments.compact();
  }

  static T _decode<T>(String raw, T Function(Map<String, Object?>) parse) {
    final value = jsonDecode(raw);
    if (value is! Map) throw const FormatException('Ungültiger Schul-Datensatz.');
    return parse(Map<String, Object?>.from(value));
  }

  static List<T> _decodeAll<T>(
    Iterable<String> values,
    T Function(Map<String, Object?>) parse,
  ) {
    final result = <T>[];
    for (final raw in values) {
      try {
        result.add(_decode(raw, parse));
      } on FormatException {
        // Ein beschädigter Datensatz darf andere lokale Schuldaten nicht sperren.
      } on TypeError {
        // Alte oder falsch typisierte Felder sperren nicht die ganze Box.
      }
    }
    return result;
  }
}
