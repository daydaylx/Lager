import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:berichtsheft_merker/core/school/models/school_assessment.dart';
import 'package:berichtsheft_merker/core/school/models/school_entry.dart';
import 'package:berichtsheft_merker/core/school/models/school_task.dart';
import 'package:berichtsheft_merker/core/school/storage/hive_school_data_storage.dart';

void main() {
  test('Schuldaten überleben Box-Neuöffnung mit mehreren Blöcken', () async {
    final directory = await Directory.systemTemp.createTemp(
      'school_hive_reopen_test_',
    );
    final date = DateTime(2026, 9, 22);
    final createdAt = DateTime(2026, 9, 22, 8);
    final earlierDate = DateTime(2026, 9, 21);
    final earlierEntry = SchoolEntry(
      id: SchoolEntry.idForDate(earlierDate),
      date: earlierDate,
      blocks: const [],
      createdAt: earlierDate,
      updatedAt: earlierDate,
    );
    final entry = SchoolEntry(
      id: SchoolEntry.idForDate(date),
      date: date,
      blocks: const [
        SchoolBlock(
          curriculumUnitId: 'de_sn_fachkraft_lf08',
          topics: ['Ladungssicherung', 'Stauplan'],
        ),
        SchoolBlock(
          curriculumUnitId: 'custom_wirtschaftskunde',
          customUnitTitle: 'Wirtschaftskunde',
          topics: ['Tarifvertrag'],
        ),
      ],
      privateNote: 'Nur für mich',
      taskId: 'task_1',
      assessmentId: 'assessment_1',
      createdAt: createdAt,
      updatedAt: createdAt,
    );
    final updatedEntry = SchoolEntry(
      id: entry.id,
      date: entry.date,
      blocks: const [
        SchoolBlock(
          curriculumUnitId: 'de_sn_fachkraft_lf08',
          topics: ['Ladungssicherung', 'Stauplan'],
        ),
        SchoolBlock(
          curriculumUnitId: 'custom_wirtschaftskunde',
          customUnitTitle: 'Wirtschaftskunde',
          topics: ['Tarifvertrag'],
        ),
      ],
      privateNote: 'Aktualisierte private Notiz',
      taskId: entry.taskId,
      assessmentId: entry.assessmentId,
      createdAt: entry.createdAt,
      updatedAt: DateTime(2026, 9, 22, 9),
    );
    final task = SchoolTask(
      id: 'task_1',
      title: 'Arbeitsblatt',
      curriculumUnitId: 'de_sn_fachkraft_lf08',
      createdAt: createdAt,
      dueDate: DateTime(2026, 9, 25),
    );
    final laterTask = SchoolTask(
      id: 'task_2',
      title: 'Ohne Fälligkeit',
      createdAt: createdAt,
    );
    final assessment = SchoolAssessment(
      id: 'assessment_1',
      title: 'Lernkontrolle',
      curriculumUnitId: 'de_sn_fachkraft_lf08',
      date: DateTime(2026, 10, 2),
      kind: SchoolAssessmentKind.test,
    );
    final laterAssessment = SchoolAssessment(
      id: 'assessment_2',
      title: 'Mündliche Prüfung',
      date: DateTime(2026, 10, 9),
    );

    try {
      final storage = await HiveSchoolDataStorage.openAtPath(directory.path);
      await storage.saveEntry(entry);
      await storage.saveEntry(earlierEntry);
      await storage.saveTask(task);
      await storage.saveTask(laterTask);
      await storage.saveAssessment(assessment);
      await storage.saveAssessment(laterAssessment);
      await storage.saveEntry(updatedEntry);
      await Hive.close();

      final reopened = await HiveSchoolDataStorage.openAtPath(directory.path);
      expect((await reopened.loadEntry(date))?.toJson(), updatedEntry.toJson());
      expect((await reopened.loadTask(task.id))?.toJson(), task.toJson());
      expect(
        (await reopened.loadAssessment(assessment.id))?.toJson(),
        assessment.toJson(),
      );
      final entries = await reopened.loadEntries();
      expect(entries.map((item) => item.id), [earlierEntry.id, entry.id]);
      expect(entries.last.toJson(), updatedEntry.toJson());
      expect(
        (await reopened.loadTasks()).map((item) => item.id),
        [task.id, laterTask.id],
      );
      expect(
        (await reopened.loadAssessments()).map((item) => item.id),
        [assessment.id, laterAssessment.id],
      );
    } finally {
      await Hive.close();
      await directory.delete(recursive: true);
    }
  });

  test('alte Felder werden ignoriert und beschädigte Einträge übersprungen',
      () async {
    final directory = await Directory.systemTemp.createTemp(
      'school_hive_legacy_test_',
    );
    final date = DateTime(2026, 1, 8);
    final id = SchoolEntry.idForDate(date);

    try {
      final storage = await HiveSchoolDataStorage.openAtPath(directory.path);
      final box = Hive.box<String>(HiveSchoolDataStorage.entriesBoxName);
      await box.put(
        id,
        jsonEncode({
          'date': date.toIso8601String(),
          'blocks': [
            {
              'curriculumUnitId': 'custom_history',
              'topics': ['Lerninhalt'],
              'futureField': 'wird ignoriert',
            },
          ],
          'futureField': 'wird ignoriert',
        }),
      );
      await box.put('corrupt', '{');

      final loaded = await storage.loadEntry(date);
      expect(loaded, isNotNull);
      expect(loaded!.id, id);
      expect(loaded.blocks, hasLength(1));
      expect(loaded.blocks.single.curriculumUnitId, 'custom_history');
      expect(loaded.blocks.single.topics, ['Lerninhalt']);
      expect((await storage.loadEntries()).map((entry) => entry.id), [id]);
    } finally {
      await Hive.close();
      await directory.delete(recursive: true);
    }
  });

  test('Einträge, Aufgaben und Nachweise lassen sich löschen und leeren',
      () async {
    final directory = await Directory.systemTemp.createTemp(
      'school_hive_delete_test_',
    );
    final date = DateTime(2026, 3, 5);
    final now = DateTime(2026, 3, 5, 8);

    try {
      final storage = await HiveSchoolDataStorage.openAtPath(directory.path);
      final entry = SchoolEntry(
        id: SchoolEntry.idForDate(date),
        date: date,
        blocks: const [],
        createdAt: now,
        updatedAt: now,
      );
      await storage.saveEntry(entry);
      await storage.saveTask(
        SchoolTask(id: 'task', title: 'Aufgabe', createdAt: now),
      );
      await storage.saveAssessment(
        SchoolAssessment(id: 'assessment', title: 'Test', date: date),
      );
      await storage.deleteEntry(date);
      await storage.deleteTask('task');
      await storage.deleteAssessment('assessment');
      expect(await storage.loadEntries(), isEmpty);
      expect(await storage.loadTasks(), isEmpty);
      expect(await storage.loadAssessments(), isEmpty);

      await storage.saveEntry(entry);
      await storage.clearAll();
      expect(await storage.loadEntries(), isEmpty);
    } finally {
      await Hive.close();
      await directory.delete(recursive: true);
    }
  });
}
