import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:berichtsheft_merker/core/enums/day_type.dart';
import 'package:berichtsheft_merker/core/enums/training_area.dart';
import 'package:berichtsheft_merker/core/models/daily_entry.dart';
import 'package:berichtsheft_merker/core/storage/activity_template_storage.dart';
import 'package:berichtsheft_merker/core/storage/daily_entry_storage.dart';
import 'package:berichtsheft_merker/core/storage/in_memory_activity_template_storage.dart';
import 'package:berichtsheft_merker/core/storage/in_memory_daily_entry_storage.dart';
import 'package:berichtsheft_merker/features/today/today_screen.dart';

import 'test_helpers.dart';

Future<void> pumpToday(
  WidgetTester tester, {
  DailyEntryStorage? storage,
  ActivityTemplateStorage? templateStorage,
  DateTime? date,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: TodayScreen(
        storage: storage ?? InMemoryDailyEntryStorage(),
        templateStorage: templateStorage ?? InMemoryActivityTemplateStorage(),
        date: date,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> startBetrieb(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('day_type_betrieb')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('area_wareneingang')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('today_flow_continue')));
  await tester.pumpAndSettle();
}

Future<void> chooseOneActivity(WidgetTester tester) async {
  final activity = find.byKey(const ValueKey('activity_wareneingang_01'));
  await tester.scrollUntilVisible(
    activity,
    250,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(activity);
  await tester.pumpAndSettle();
}

Future<void> confirmActivities(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('today_flow_continue')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
      'neuer Betriebstag folgt dem geführten Check-in bis zur Übersicht',
      (tester) async {
    final storage = InMemoryDailyEntryStorage();
    await pumpToday(tester, storage: storage);

    expect(find.text('Wähle kurz: Tagtyp'), findsOneWidget);
    await startBetrieb(tester);
    expect(find.text('Tätigkeiten'), findsOneWidget);

    await chooseOneActivity(tester);
    await confirmActivities(tester);
    expect(find.text('Dein Tag auf einen Blick'), findsOneWidget);
    expect(find.byKey(const ValueKey('report_card')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('save_daily_entry')));
    await tester.pumpAndSettle();
    await dismissJokeSheetIfPresent(tester);
    expect(find.text('Erfasst'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('daily_entry_status')),
      findsOneWidget,
    );
    expect(await storage.loadByDate(DateTime.now()), isNotNull);
  });

  testWidgets('Abbruch der Tätigkeitsauswahl verwirft nur die Arbeitsauswahl',
      (tester) async {
    await pumpToday(tester);
    await startBetrieb(tester);
    await chooseOneActivity(tester);
    await tester.tap(find.byKey(const ValueKey('close_activity_picker')));
    await tester.pumpAndSettle();

    expect(find.text('Wo hast du gearbeitet?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('today_flow_continue')));
    await tester.pumpAndSettle();
    expect(find.text('0 gewählt'), findsOneWidget);
  });

  testWidgets('Berufsschule überspringt die Bereichsauswahl', (tester) async {
    await pumpToday(tester);
    await tester.tap(find.byKey(const ValueKey('day_type_berufsschule')));
    await tester.pumpAndSettle();

    expect(find.text('Tätigkeiten'), findsOneWidget);
    final activity = find.byKey(const ValueKey('activity_berufsschule_01'));
    await tester.scrollUntilVisible(
      activity,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(activity);
    await tester.tap(find.byKey(const ValueKey('today_flow_continue')));
    await tester.pumpAndSettle();
    expect(find.text('Berufsschule'), findsWidgets);
  });

  testWidgets(
      'Abwesenheit kann ohne Tätigkeiten geprüft und gespeichert werden',
      (tester) async {
    await pumpToday(tester);
    await selectAbsenceType(tester, DayType.urlaub);
    expect(find.text('Dein Tag auf einen Blick'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('save_daily_entry')));
    await tester.pumpAndSettle();
    await dismissJokeSheetIfPresent(tester);
    expect(find.text('Abwesenheit'), findsOneWidget);
    expect(find.text('Urlaub'), findsWidgets);
  });

  testWidgets('gespeicherte Übersicht öffnet gezielt den Ergänzungs-Schritt',
      (tester) async {
    final date = DateTime(2026, 6, 12);
    final storage = InMemoryDailyEntryStorage(
      initialEntries: [
        DailyEntry(
          id: DailyEntry.idForDate(date),
          date: date,
          dayType: DayType.betrieb,
          areas: const [TrainingArea.wareneingang],
          selectedActivities: const ['wareneingang_01'],
          specialFlags: const [],
          reportNote: null,
          createdAt: date,
          updatedAt: date,
        ),
      ],
    );
    await pumpToday(tester, storage: storage, date: date);

    expect(find.text('Erfasst'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('edit_entry_details')));
    await tester.pumpAndSettle();
    expect(find.text('Dein Tag auf einen Blick'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Besonderheiten & Notizen'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Besonderheiten & Notizen'), findsOneWidget);
  });

  testWidgets('Wie gestern starten übernimmt Typ, Bereich und Tätigkeiten',
      (tester) async {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final storage = InMemoryDailyEntryStorage(
      initialEntries: [
        DailyEntry(
          id: DailyEntry.idForDate(yesterday),
          date: yesterday,
          dayType: DayType.betrieb,
          areas: const [TrainingArea.wareneingang],
          selectedActivities: const ['wareneingang_01'],
          specialFlags: const [],
          reportNote: null,
          createdAt: yesterday,
          updatedAt: yesterday,
        ),
      ],
    );
    await pumpToday(tester, storage: storage);
    await tester.tap(find.byKey(const ValueKey('duplicate_yesterday')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Übernehmen'));
    await tester.pumpAndSettle();

    expect(find.text('Tätigkeiten übernommen.'), findsOneWidget);
    expect(find.byKey(const ValueKey('day_type_betrieb')), findsOneWidget);
  });

  testWidgets('Ladefehler bietet Wiederholen ohne Formular an', (tester) async {
    await pumpToday(
      tester,
      storage: _FailingStorage(),
    );
    expect(find.text('Dein heutiger Eintrag konnte nicht geladen werden.'),
        findsOneWidget);
    expect(find.byKey(const ValueKey('save_daily_entry')), findsNothing);
  });
}

class _FailingStorage implements DailyEntryStorage {
  @override
  Future<void> clearAll() async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<List<DailyEntry>> loadAll() async => throw StateError('failed');

  @override
  Future<DailyEntry?> loadByDate(DateTime date) async =>
      throw StateError('failed');

  @override
  Future<void> save(DailyEntry entry) async {}
}
