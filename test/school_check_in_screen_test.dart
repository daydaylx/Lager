import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:berichtsheft_merker/core/activity_utils.dart';
import 'package:berichtsheft_merker/core/domain/occupation.dart';
import 'package:berichtsheft_merker/core/enums/day_type.dart';
import 'package:berichtsheft_merker/core/report/daily_report_generator.dart';
import 'package:berichtsheft_merker/core/school/services/school_entry_coordinator.dart';
import 'package:berichtsheft_merker/core/school/storage/in_memory_school_data_storage.dart';
import 'package:berichtsheft_merker/core/storage/in_memory_activity_template_storage.dart';
import 'package:berichtsheft_merker/core/storage/in_memory_daily_entry_storage.dart';
import 'package:berichtsheft_merker/features/school/school_check_in_screen.dart';
import 'package:berichtsheft_merker/features/school/school_home_screen.dart';

void main() {
  testWidgets('vier Schritte speichern Schuleintrag, Aufgabe und Assessment', (
    tester,
  ) async {
    final date = DateTime(2026, 9, 22);
    final schoolStorage = InMemorySchoolDataStorage();
    final dailyStorage = InMemoryDailyEntryStorage();
    final templateStorage = InMemoryActivityTemplateStorage();
    await tester.pumpWidget(
      MaterialApp(
        home: _SchoolFlowHost(
          date: date,
          schoolStorage: schoolStorage,
          dailyStorage: dailyStorage,
          templateStorage: templateStorage,
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('open_check_in')));
    await tester.pumpAndSettle();
    expect(find.text('Schritt 1 von 4'), findsOneWidget);

    await _tapVisible(
      tester,
      find.byKey(
        const ValueKey(
          'school_unit_de_sn_fachkraft_lagerlogistik_lf07',
        ),
      ),
    );
    await _tapVisible(
      tester,
      find.byKey(const ValueKey('add_school_general_subject')),
    );
    await tester.tap(find.byKey(const ValueKey('school_check_in_continue')));
    await tester.pumpAndSettle();
    expect(find.text('Schritt 2 von 4'), findsOneWidget);

    final lf8Topics = find.byKey(
      const ValueKey('school_topics_de_sn_fachkraft_lagerlogistik_lf07'),
    );
    await tester.ensureVisible(lf8Topics);
    await tester.enterText(lf8Topics, 'Ladungssicherung\nStauplan');
    final economicsTitle = find.byKey(
      const ValueKey('school_title_school_general_2026-09-22_1'),
    );
    await tester.ensureVisible(economicsTitle);
    await tester.enterText(economicsTitle, 'Wirtschaftskunde');
    final economicsTopics = find.byKey(
      const ValueKey('school_topics_school_general_2026-09-22_1'),
    );
    await tester.ensureVisible(economicsTopics);
    await tester.enterText(economicsTopics, 'Tarifvertrag');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('school_check_in_continue')));
    await tester.pumpAndSettle();
    expect(find.text('Schritt 3 von 4'), findsOneWidget);

    final task = find.byKey(const ValueKey('school_task_title'));
    await tester.ensureVisible(task);
    await tester.enterText(task, 'Arbeitsblatt bis Freitag');
    final assessment = find.byKey(const ValueKey('school_assessment_title'));
    await tester.ensureVisible(assessment);
    await tester.enterText(assessment, 'Test nächste Woche');
    final privateNote = find.byKey(const ValueKey('school_private_note'));
    await tester.ensureVisible(privateNote);
    await tester.enterText(privateNote, 'Nur für mich');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('school_check_in_continue')));
    await tester.pumpAndSettle();
    expect(find.text('Schritt 4 von 4'), findsOneWidget);
    expect(find.text('Private Notiz bleibt außerhalb des Berichts.'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('school_check_in_continue')));
    await tester.pumpAndSettle();
    expect(find.text('E2E gespeichert'), findsOneWidget);

    final entry = await schoolStorage.loadEntry(date);
    final snapshot = await dailyStorage.loadByDate(date);
    expect(entry, isNotNull);
    expect(entry!.blocks, hasLength(2));
    expect(entry.blocks.first.topics, ['Ladungssicherung', 'Stauplan']);
    expect(entry.blocks.last.customUnitTitle, 'Wirtschaftskunde');
    expect(entry.privateNote, 'Nur für mich');
    expect(snapshot?.dayType, DayType.berufsschule);
    expect(snapshot?.selectedActivities, hasLength(2));
    expect(snapshot?.privateNote, 'Nur für mich');
    expect(await schoolStorage.loadTasks(), hasLength(1));
    expect(await schoolStorage.loadAssessments(), hasLength(1));

    final report = DailyReportGenerator.generate(
      snapshot!,
      activityTitlesForEntry(snapshot, const []),
    );
    expect(report, contains('Ladungssicherung'));
    expect(report, contains('Tarifvertrag'));
    expect(report, isNot(contains('Nur für mich')));

    await tester.tap(find.byKey(const ValueKey('open_school_home')));
    await tester.pumpAndSettle();
    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('Arbeitsblatt bis Freitag'),
      120,
      scrollable: scrollable,
    );
    expect(find.text('Arbeitsblatt bis Freitag'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Test nächste Woche'),
      120,
      scrollable: scrollable,
    );
    expect(find.text('Test nächste Woche'), findsOneWidget);
  });
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

class _SchoolFlowHost extends StatefulWidget {
  final DateTime date;
  final InMemorySchoolDataStorage schoolStorage;
  final InMemoryDailyEntryStorage dailyStorage;
  final InMemoryActivityTemplateStorage templateStorage;

  const _SchoolFlowHost({
    required this.date,
    required this.schoolStorage,
    required this.dailyStorage,
    required this.templateStorage,
  });

  @override
  State<_SchoolFlowHost> createState() => _SchoolFlowHostState();
}

class _SchoolFlowHostState extends State<_SchoolFlowHost> {
  bool _saved = false;

  Future<void> _openCheckIn() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => SchoolCheckInScreen(
          date: widget.date,
          occupation: TrainingOccupation.fachkraftLagerlogistik,
          trainingYear: 2,
          storage: widget.schoolStorage,
          dailyEntryStorage: widget.dailyStorage,
          templateStorage: widget.templateStorage,
          coordinator: SchoolEntryCoordinator(
            schoolStorage: widget.schoolStorage,
            dailyEntryStorage: widget.dailyStorage,
          ),
        ),
      ),
    );
    if (mounted && result == true) setState(() => _saved = true);
  }

  void _openSchoolHome() {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => SchoolHomeScreen(
          storage: widget.schoolStorage,
          dailyEntryStorage: widget.dailyStorage,
          templateStorage: widget.templateStorage,
          occupation: TrainingOccupation.fachkraftLagerlogistik.storageKey,
          trainingYear: 2,
          currentDate: widget.date,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: _saved
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('E2E gespeichert'),
                    TextButton(
                      key: const ValueKey('open_school_home'),
                      onPressed: _openSchoolHome,
                      child: const Text('Schule öffnen'),
                    ),
                  ],
                )
              : TextButton(
                  key: const ValueKey('open_check_in'),
                  onPressed: _openCheckIn,
                  child: const Text('Check-in öffnen'),
                ),
        ),
      );
}
