import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:berichtsheft_merker/core/domain/occupation.dart';
import 'package:berichtsheft_merker/core/enums/day_type.dart';
import 'package:berichtsheft_merker/core/models/daily_entry.dart';
import 'package:berichtsheft_merker/core/school/models/school_assessment.dart';
import 'package:berichtsheft_merker/core/school/models/school_entry.dart';
import 'package:berichtsheft_merker/core/school/models/school_task.dart';
import 'package:berichtsheft_merker/core/school/storage/in_memory_school_data_storage.dart';
import 'package:berichtsheft_merker/core/storage/in_memory_activity_template_storage.dart';
import 'package:berichtsheft_merker/core/storage/in_memory_daily_entry_storage.dart';
import 'package:berichtsheft_merker/features/school/school_home_screen.dart';

void main() {
  const occupation = TrainingOccupation.fachkraftLagerlogistik;
  final today = DateTime(2026, 9, 22);
  final now = DateTime(2026, 9, 22, 8);

  SchoolHomeScreen screen({
    required InMemorySchoolDataStorage storage,
    required InMemoryDailyEntryStorage dailyStorage,
    DateTime? currentDate,
  }) =>
      SchoolHomeScreen(
        storage: storage,
        dailyEntryStorage: dailyStorage,
        templateStorage: InMemoryActivityTemplateStorage(),
        occupation: occupation.storageKey,
        trainingYear: 2,
        currentDate: currentDate ?? today,
      );

  testWidgets('leerer Schulstart bietet den Check-in an', (tester) async {
    final storage = InMemorySchoolDataStorage();
    await tester.pumpWidget(
      MaterialApp(
        home: screen(
          storage: storage,
          dailyStorage: InMemoryDailyEntryStorage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Schule'), findsOneWidget);
    expect(find.text('Noch kein Schultag eingetragen.'), findsOneWidget);
    expect(find.byKey(const ValueKey('school_check_in')), findsOneWidget);
    expect(find.text('Keine offenen Aufgaben'), findsOneWidget);
    expect(find.text('Noch keine Klassenarbeit geplant'), findsOneWidget);
  });

  testWidgets('zeigt maximal drei offene Aufgaben und nächste Arbeit', (
    tester,
  ) async {
    final storage = InMemorySchoolDataStorage();
    final entry = SchoolEntry(
      id: SchoolEntry.idForDate(today),
      date: today,
      blocks: const [
        SchoolBlock(
          curriculumUnitId: 'de_sn_fachkraft_lagerlogistik_lf08',
          topics: ['Ladungssicherung'],
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );
    await storage.saveEntry(entry);
    for (var index = 1; index <= 4; index++) {
      await storage.saveTask(
        SchoolTask(
          id: 'task_$index',
          title: 'Aufgabe $index',
          createdAt: now,
          dueDate: today.add(Duration(days: index)),
        ),
      );
    }
    await storage.saveAssessment(
      SchoolAssessment(
        id: 'assessment',
        title: 'Lernkontrolle',
        date: today.add(const Duration(days: 5)),
        kind: SchoolAssessmentKind.test,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: screen(
          storage: storage,
          dailyStorage: InMemoryDailyEntryStorage(
            initialEntries: [
              DailyEntry(
                id: DailyEntry.idForDate(today),
                date: today,
                dayType: DayType.berufsschule,
                areas: const [],
                selectedActivities: const [],
                specialFlags: const [],
                reportNote: null,
                createdAt: now,
                updatedAt: now,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Ladungssicherung'), findsOneWidget);
    final scrollable = find.byType(Scrollable).first;
    for (var index = 1; index <= 3; index++) {
      await tester.scrollUntilVisible(
        find.text('Aufgabe $index'),
        120,
        scrollable: scrollable,
      );
      expect(find.text('Aufgabe $index'), findsOneWidget);
    }
    expect(find.text('Aufgabe 4'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Alle Aufgaben'),
      120,
      scrollable: scrollable,
    );
    expect(find.text('Alle Aufgaben'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Lernkontrolle'),
      120,
      scrollable: scrollable,
    );
    expect(find.text('Lernkontrolle'), findsOneWidget);
  });

  testWidgets('bleibt bei 360×640 und Textskalierung 1.5 ohne Overflow', (
    tester,
  ) async {
    final storage = InMemorySchoolDataStorage();
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(360, 640),
          textScaler: TextScaler.linear(1.5),
        ),
        child: MaterialApp(
          home: screen(
            storage: storage,
            dailyStorage: InMemoryDailyEntryStorage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('school_check_in')), findsOneWidget);
  });
}
