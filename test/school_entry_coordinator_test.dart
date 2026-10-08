import 'package:flutter_test/flutter_test.dart';

import 'package:berichtsheft_merker/core/activity_utils.dart';
import 'package:berichtsheft_merker/core/enums/day_type.dart';
import 'package:berichtsheft_merker/core/models/daily_entry.dart';
import 'package:berichtsheft_merker/core/report/daily_report_generator.dart';
import 'package:berichtsheft_merker/core/school/models/school_assessment.dart';
import 'package:berichtsheft_merker/core/school/models/school_entry.dart';
import 'package:berichtsheft_merker/core/school/models/school_task.dart';
import 'package:berichtsheft_merker/core/school/services/school_entry_coordinator.dart';
import 'package:berichtsheft_merker/core/school/storage/in_memory_school_data_storage.dart';
import 'package:berichtsheft_merker/core/storage/in_memory_daily_entry_storage.dart';

void main() {
  test('mehrere Schulblöcke synchronisieren den Berichtsheft-Snapshot', () async {
    final date = DateTime(2026, 9, 22);
    final now = DateTime(2026, 9, 22, 8);
    final schoolStorage = InMemorySchoolDataStorage();
    final dailyStorage = InMemoryDailyEntryStorage(
      initialEntries: [_dailyEntry(date, dayType: DayType.berufsschule)],
    );
    final coordinator = SchoolEntryCoordinator(
      schoolStorage: schoolStorage,
      dailyEntryStorage: dailyStorage,
    );
    final schoolEntry = _schoolEntry(date, now);
    final task = SchoolTask(
      id: 'task_1',
      title: 'Arbeitsblatt',
      curriculumUnitId: 'de_sn_fachkraft_lagerlogistik_lf08',
      createdAt: now,
      dueDate: DateTime(2026, 9, 25),
    );
    final assessment = SchoolAssessment(
      id: 'assessment_1',
      title: 'Lernkontrolle',
      curriculumUnitId: 'de_sn_fachkraft_lagerlogistik_lf08',
      date: DateTime(2026, 10, 2),
    );

    final snapshot = await coordinator.save(
      entry: schoolEntry,
      task: task,
      assessment: assessment,
    );
    final loadedSchoolEntry = await schoolStorage.loadEntry(date);

    expect(loadedSchoolEntry?.blocks, hasLength(2));
    expect(loadedSchoolEntry?.taskId, task.id);
    expect(loadedSchoolEntry?.assessmentId, assessment.id);
    expect(await schoolStorage.loadTask(task.id), isNotNull);
    expect(await schoolStorage.loadAssessment(assessment.id), isNotNull);
    expect(snapshot.dayType, DayType.berufsschule);
    expect(snapshot.selectedActivities, hasLength(2));
    expect(snapshot.reportNote, 'Zusätzliche Berichtnotiz');
    expect(snapshot.privateNote, 'Nur für mich');

    final report = DailyReportGenerator.generate(
      snapshot,
      activityTitlesForEntry(snapshot, const []),
    );
    expect(report, contains('LF 8'));
    expect(report, contains('Ladungssicherung'));
    expect(report, contains('Wirtschaftskunde'));
    expect(report, isNot(contains('Nur für mich')));
  });

  test('Bearbeiten ersetzt Blöcke und entfernt gelöschte Verknüpfungen', () async {
    final date = DateTime(2026, 9, 22);
    final now = DateTime(2026, 9, 22, 8);
    final schoolStorage = InMemorySchoolDataStorage();
    final dailyStorage = InMemoryDailyEntryStorage();
    final coordinator = SchoolEntryCoordinator(
      schoolStorage: schoolStorage,
      dailyEntryStorage: dailyStorage,
    );
    final first = _schoolEntry(date, now);
    await coordinator.save(
      entry: first,
      task: SchoolTask(id: 'task_1', title: 'Aufgabe', createdAt: now),
      assessment: SchoolAssessment(
        id: 'assessment_1',
        title: 'Test',
        date: DateTime(2026, 10, 2),
      ),
    );

    final updated = SchoolEntry(
      id: first.id,
      date: first.date,
      blocks: const [
        SchoolBlock(
          curriculumUnitId: 'de_sn_fachkraft_lagerlogistik_lf08',
          topics: ['Neue Ladungssicherung'],
        ),
      ],
      privateNote: 'Aktualisiert',
      createdAt: first.createdAt,
      updatedAt: now.add(const Duration(hours: 1)),
    );
    await coordinator.save(entry: updated);

    final savedDaily = await dailyStorage.loadByDate(date);
    expect((await schoolStorage.loadEntry(date))?.blocks, hasLength(1));
    expect(savedDaily?.selectedActivities, hasLength(1));
    expect(savedDaily?.adhocActivities.single.title, contains('Neue Ladungssicherung'));
    expect(await schoolStorage.loadTask('task_1'), isNull);
    expect(await schoolStorage.loadAssessment('assessment_1'), isNull);
  });

  test('bestehender anderer Tagestyp wird ohne Bestätigung nicht überschrieben',
      () async {
    final date = DateTime(2026, 4, 8);
    final now = DateTime(2026, 4, 8, 8);
    final oldDailyEntry = _dailyEntry(date, dayType: DayType.betrieb);
    final dailyStorage = InMemoryDailyEntryStorage(
      initialEntries: [oldDailyEntry],
    );
    final schoolStorage = InMemorySchoolDataStorage();
    final coordinator = SchoolEntryCoordinator(
      schoolStorage: schoolStorage,
      dailyEntryStorage: dailyStorage,
    );

    await expectLater(
      coordinator.save(entry: _schoolEntry(date, now)),
      throwsStateError,
    );
    expect(await dailyStorage.loadByDate(date), oldDailyEntry);
    expect(await schoolStorage.loadEntry(date), isNull);

    final snapshot = await coordinator.save(
      entry: _schoolEntry(date, now),
      allowReplacingExistingDayType: true,
    );
    expect(snapshot.dayType, DayType.berufsschule);
    expect(snapshot.reportNote, isNull);
    expect(await schoolStorage.loadEntry(date), isNotNull);
  });

  test('Speicherfehler stellt bisherigen Schul- und Berichtsheftstand wieder her',
      () async {
    final date = DateTime(2026, 5, 12);
    final now = DateTime(2026, 5, 12, 8);
    final oldSchoolEntry = _schoolEntry(date, now);
    final oldDailyEntry = _dailyEntry(date, dayType: DayType.berufsschule);
    final schoolStorage = InMemorySchoolDataStorage();
    await schoolStorage.saveEntry(oldSchoolEntry);
    await schoolStorage.saveTask(
      SchoolTask(id: 'old_task', title: 'Alte Aufgabe', createdAt: now),
    );
    final dailyStorage = _FailFirstDailyEntryStorage(oldDailyEntry);
    final coordinator = SchoolEntryCoordinator(
      schoolStorage: schoolStorage,
      dailyEntryStorage: dailyStorage,
    );

    await expectLater(
      coordinator.save(
        entry: SchoolEntry(
          id: oldSchoolEntry.id,
          date: date,
          blocks: const [
            SchoolBlock(
              curriculumUnitId: 'de_sn_fachkraft_lagerlogistik_lf08',
              topics: ['Neue Inhalte'],
            ),
          ],
          createdAt: now,
          updatedAt: now.add(const Duration(hours: 1)),
        ),
        task: SchoolTask(id: 'new_task', title: 'Neue Aufgabe', createdAt: now),
      ),
      throwsStateError,
    );

    expect(await schoolStorage.loadEntry(date), oldSchoolEntry);
    expect(await dailyStorage.loadByDate(date), oldDailyEntry);
    expect(await schoolStorage.loadTask('old_task'), isNotNull);
    expect(await schoolStorage.loadTask('new_task'), isNull);
  });

  test('Übergang zu anderem Tagestyp entfernt SchoolEntry konsistent', () async {
    final date = DateTime(2026, 6, 4);
    final now = DateTime(2026, 6, 4, 8);
    final schoolStorage = InMemorySchoolDataStorage();
    final dailyStorage = InMemoryDailyEntryStorage();
    final coordinator = SchoolEntryCoordinator(
      schoolStorage: schoolStorage,
      dailyEntryStorage: dailyStorage,
    );
    await coordinator.save(entry: _schoolEntry(date, now));

    final replacement = _dailyEntry(date, dayType: DayType.betrieb);
    await coordinator.replaceWithDailyEntry(replacement);

    expect(await dailyStorage.loadByDate(date), replacement);
    expect(await schoolStorage.loadEntry(date), isNull);
  });
}

SchoolEntry _schoolEntry(DateTime date, DateTime now) => SchoolEntry(
      id: SchoolEntry.idForDate(date),
      date: date,
      blocks: const [
        SchoolBlock(
          curriculumUnitId: 'de_sn_fachkraft_lagerlogistik_lf08',
          topics: ['Ladungssicherung', 'Stauplan'],
        ),
        SchoolBlock(
          curriculumUnitId: 'custom_wirtschaftskunde',
          customUnitTitle: 'Wirtschaftskunde',
          topics: ['Tarifvertrag'],
        ),
      ],
      privateNote: 'Nur für mich',
      createdAt: now,
      updatedAt: now,
    );

DailyEntry _dailyEntry(DateTime date, {required DayType dayType}) => DailyEntry(
      id: DailyEntry.idForDate(date),
      date: date,
      dayType: dayType,
      areas: const [],
      selectedActivities: const [],
      specialFlags: const [],
      reportNote: 'Zusätzliche Berichtnotiz',
      privateNote: 'Alte private Notiz',
      createdAt: date,
      updatedAt: date,
    );

class _FailFirstDailyEntryStorage extends InMemoryDailyEntryStorage {
  bool _shouldFail = true;

  _FailFirstDailyEntryStorage(DailyEntry initialEntry)
      : super(initialEntries: [initialEntry]);

  @override
  Future<void> save(DailyEntry entry) async {
    if (_shouldFail) {
      _shouldFail = false;
      throw StateError('Simulierter Schreibfehler');
    }
    await super.save(entry);
  }
}
