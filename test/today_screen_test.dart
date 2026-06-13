import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:berichtsheft_merker/app/app.dart';
import 'package:berichtsheft_merker/core/constants.dart';
import 'package:berichtsheft_merker/core/enums/day_type.dart';
import 'package:berichtsheft_merker/core/enums/special_flag.dart';
import 'package:berichtsheft_merker/core/enums/training_area.dart';
import 'package:berichtsheft_merker/core/models/daily_entry.dart';
import 'package:berichtsheft_merker/core/storage/daily_entry_storage.dart';
import 'package:berichtsheft_merker/core/storage/in_memory_activity_template_storage.dart';
import 'package:berichtsheft_merker/core/storage/in_memory_daily_entry_storage.dart';
import 'package:berichtsheft_merker/features/today/today_screen.dart';

Future<void> tapVisible(
  WidgetTester tester,
  Finder finder, {
  double scrollDelta = 300,
}) async {
  await tester.scrollUntilVisible(
    finder,
    scrollDelta,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> tapSave(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('save_daily_entry')));
  await tester.pump();
}

Future<void> expectStatus(WidgetTester tester, String status) async {
  final finder = find.byKey(const ValueKey('daily_entry_status'));
  await tester.scrollUntilVisible(
    finder,
    -300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  expect(find.text(status), findsOneWidget);
}

FilledButton saveButton(WidgetTester tester) {
  return tester.widget<FilledButton>(
    find.byKey(const ValueKey('save_daily_entry')),
  );
}

class ControlledDailyEntryStorage implements DailyEntryStorage {
  DailyEntry? entry;
  Object? loadError;
  Object? saveError;
  DailyEntry? lastSavedEntry;
  int loadCalls = 0;

  ControlledDailyEntryStorage({
    this.entry,
    this.loadError,
    this.saveError,
  });

  @override
  Future<DailyEntry?> loadByDate(DateTime date) async {
    loadCalls++;
    if (loadError case final error?) {
      throw error;
    }
    return entry;
  }

  @override
  Future<void> save(DailyEntry entry) async {
    if (saveError case final error?) {
      throw error;
    }
    lastSavedEntry = entry;
    this.entry = entry;
  }
}

Future<void> pumpToday(
  WidgetTester tester, {
  DailyEntryStorage? storage,
  DateTime? date,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: TodayScreen(
        storage: storage ?? InMemoryDailyEntryStorage(),
        date: date,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Neuer Betriebseintrag benötigt Bereich und Tätigkeit', (
    WidgetTester tester,
  ) async {
    await pumpToday(tester);

    await expectStatus(tester, 'Noch nicht gespeichert');
    expect(find.text('Wähle einen Bereich aus, um den Tag zu speichern.'),
        findsOneWidget);
    expect(saveButton(tester).onPressed, isNull);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('area_wareneingang')),
    );

    expect(find.text('Ware angenommen'), findsOneWidget);
    expect(find.text('Ware verpackt'), findsNothing);
    expect(find.text('Wähle mindestens eine Tätigkeit aus.'), findsOneWidget);
    expect(saveButton(tester).onPressed, isNull);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('activity_wareneingang_01')),
    );

    expect(saveButton(tester).onPressed, isNotNull);
    await tapSave(tester);

    expect(find.text('Heute gespeichert.'), findsOneWidget);
    expect(saveButton(tester).onPressed, isNull);
    await expectStatus(tester, 'Gespeichert');
  });

  testWidgets('Gespeicherter Eintrag kann bearbeitet werden', (
    WidgetTester tester,
  ) async {
    await pumpToday(tester);

    await tapVisible(tester, find.byKey(const ValueKey('area_lager')));
    await tapVisible(
      tester,
      find.byKey(const ValueKey('activity_einlagerung_01')),
    );
    await tapSave(tester);
    await tapVisible(
      tester,
      find.byKey(const ValueKey('special_selbststaendig')),
    );

    expect(find.text('Änderungen speichern'), findsOneWidget);
    expect(saveButton(tester).onPressed, isNotNull);
    await expectStatus(tester, 'Änderungen offen');

    await tapSave(tester);

    await expectStatus(tester, 'Gespeichert');
  });

  testWidgets('Bereichswechsel entfernt unpassende Tätigkeitsauswahl', (
    WidgetTester tester,
  ) async {
    await pumpToday(tester);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('area_wareneingang')),
    );
    await tapVisible(
      tester,
      find.byKey(const ValueKey('activity_wareneingang_01')),
    );
    expect(saveButton(tester).onPressed, isNotNull);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('area_verpackung')),
      scrollDelta: -300,
    );

    expect(find.text('Ware angenommen'), findsNothing);
    expect(find.text('Ware verpackt'), findsOneWidget);
    expect(saveButton(tester).onPressed, isNull);
  });

  testWidgets('Berufsschule zeigt passende Vorlagen und kann speichern', (
    WidgetTester tester,
  ) async {
    await pumpToday(tester);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('day_type_berufsschule')),
    );

    expect(find.text('Fachunterricht besucht'), findsOneWidget);
    expect(find.text('Ware angenommen'), findsNothing);
    expect(saveButton(tester).onPressed, isNull);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('activity_berufsschule_01')),
    );
    await tapSave(tester);

    await expectStatus(tester, 'Gespeichert');
  });

  testWidgets('Abwesenheit verwirft Details und kann direkt speichern', (
    WidgetTester tester,
  ) async {
    await pumpToday(tester);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('special_selbststaendig')),
    );
    await tester.enterText(
      find.byKey(const ValueKey('daily_note_field')),
      'Wird verworfen',
    );
    await tapVisible(
      tester,
      find.byKey(const ValueKey('day_type_urlaub')),
      scrollDelta: -300,
    );

    expect(find.byKey(const ValueKey('daily_note_field')), findsNothing);
    expect(find.text('Urlaub kann direkt gespeichert werden.'), findsOneWidget);
    expect(saveButton(tester).onPressed, isNotNull);

    await tapSave(tester);
    await expectStatus(tester, 'Gespeichert');

    await tapVisible(
      tester,
      find.byKey(const ValueKey('day_type_sonstiges')),
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('special_selbststaendig')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('daily_note_field')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    final noteField = tester.widget<TextField>(
      find.byKey(const ValueKey('daily_note_field')),
    );
    final specialChip = tester.widget<FilterChip>(
      find.byKey(const ValueKey('special_selbststaendig')),
    );
    expect(noteField.controller?.text, isEmpty);
    expect(specialChip.selected, isFalse);
  });

  testWidgets('Sonstiges speichert optionale Notiz und Besonderheit', (
    WidgetTester tester,
  ) async {
    await pumpToday(tester);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('day_type_sonstiges')),
    );
    await tapVisible(
      tester,
      find.byKey(const ValueKey('special_neuesGelernt')),
    );
    await tester.enterText(
      find.byKey(const ValueKey('daily_note_field')),
      'Brandschutz-Unterweisung',
    );
    await tester.pumpAndSettle();

    expect(saveButton(tester).onPressed, isNotNull);
    await tapSave(tester);

    await expectStatus(tester, 'Gespeichert');
  });

  testWidgets('Heute-Eintrag bleibt beim Tabwechsel im Arbeitsspeicher', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      BerichtsheftApp(
        dailyEntryStorage: InMemoryDailyEntryStorage(),
        templateStorage: InMemoryActivityTemplateStorage(),
        initialOnboardingCompleted: true,
      ),
    );
    await tester.pumpAndSettle();

    await tapVisible(tester, find.byKey(const ValueKey('day_type_frei')));
    await tapSave(tester);
    await expectStatus(tester, 'Gespeichert');

    await tester.tap(find.text(AppStrings.tabWeek));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('week_number')), findsOneWidget);

    await tester.tap(find.text(AppStrings.tabToday));
    await tester.pumpAndSettle();
    expect(find.text('Gespeichert'), findsOneWidget);
  });

  testWidgets('Vorhandener Eintrag wird vollständig in das Formular geladen', (
    WidgetTester tester,
  ) async {
    final date = DateTime(2026, 6, 12);
    final storage = ControlledDailyEntryStorage(
      entry: DailyEntry(
        id: DailyEntry.idForDate(date),
        date: date,
        dayType: DayType.betrieb,
        area: TrainingArea.wareneingang,
        selectedActivities: const ['wareneingang_01'],
        specialFlags: const [SpecialFlag.selbststaendig],
        note: 'Gespeicherte Notiz',
        createdAt: DateTime(2026, 6, 12, 8),
        updatedAt: DateTime(2026, 6, 12, 17),
      ),
    );

    await pumpToday(tester, storage: storage, date: date);

    expect(find.text('Gespeichert'), findsOneWidget);
    expect(saveButton(tester).onPressed, isNull);

    final areaChip = tester.widget<ChoiceChip>(
      find.byKey(const ValueKey('area_wareneingang')),
    );
    expect(areaChip.selected, isTrue);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('activity_wareneingang_01')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    final activityChip = tester.widget<FilterChip>(
      find.byKey(const ValueKey('activity_wareneingang_01')),
    );
    expect(activityChip.selected, isTrue);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('daily_note_field')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    final noteField = tester.widget<TextField>(
      find.byKey(const ValueKey('daily_note_field')),
    );
    expect(noteField.controller?.text, 'Gespeicherte Notiz');
  });

  testWidgets('Neuer Eintrag wird an den Speicher übergeben', (
    WidgetTester tester,
  ) async {
    final storage = ControlledDailyEntryStorage();
    await pumpToday(tester, storage: storage);

    await tapVisible(tester, find.byKey(const ValueKey('day_type_frei')));
    await tapSave(tester);
    await tester.pumpAndSettle();

    expect(storage.lastSavedEntry, isNotNull);
    expect(storage.lastSavedEntry!.dayType, DayType.frei);
    expect(storage.lastSavedEntry!.id, DailyEntry.idForDate(DateTime.now()));
  });

  testWidgets('Bearbeitung erhält Erstellungszeit und aktualisiert Eintrag', (
    WidgetTester tester,
  ) async {
    final date = DateTime(2026, 6, 12);
    final createdAt = DateTime(2026, 6, 12, 8);
    final storage = ControlledDailyEntryStorage(
      entry: DailyEntry(
        id: DailyEntry.idForDate(date),
        date: date,
        dayType: DayType.sonstiges,
        area: null,
        selectedActivities: const [],
        specialFlags: const [],
        note: 'Vorher',
        createdAt: createdAt,
        updatedAt: DateTime(2026, 6, 12, 9),
      ),
    );
    await pumpToday(tester, storage: storage, date: date);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('daily_note_field')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(
      find.byKey(const ValueKey('daily_note_field')),
      'Nachher',
    );
    await tester.pumpAndSettle();
    await tapSave(tester);
    await tester.pumpAndSettle();

    expect(storage.lastSavedEntry, isNotNull);
    expect(storage.lastSavedEntry!.createdAt, createdAt);
    expect(storage.lastSavedEntry!.updatedAt.isAfter(createdAt), isTrue);
    expect(storage.lastSavedEntry!.note, 'Nachher');
  });

  testWidgets('Lesefehler blockiert Formular und Wiederholen lädt erneut', (
    WidgetTester tester,
  ) async {
    final storage = ControlledDailyEntryStorage(
      loadError: StateError('Lesefehler'),
    );
    await pumpToday(tester, storage: storage);

    expect(
      find.text('Dein heutiger Eintrag konnte nicht geladen werden.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('save_daily_entry')), findsNothing);

    storage.loadError = null;
    await tester.tap(find.byKey(const ValueKey('retry_daily_entry_load')));
    await tester.pumpAndSettle();

    expect(storage.loadCalls, 2);
    expect(find.text('Noch nicht gespeichert'), findsOneWidget);
  });

  testWidgets('Schreibfehler erhält Eingaben und zeigt verständlichen Fehler', (
    WidgetTester tester,
  ) async {
    final storage = ControlledDailyEntryStorage(
      saveError: StateError('Schreibfehler'),
    );
    await pumpToday(tester, storage: storage);

    await tapVisible(tester, find.byKey(const ValueKey('day_type_sonstiges')));
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('daily_note_field')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('daily_note_field')),
      'Diese Notiz bleibt erhalten',
    );
    await tester.pumpAndSettle();
    await tapSave(tester);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Der Eintrag konnte nicht gespeichert werden. Bitte versuche es erneut.',
      ),
      findsOneWidget,
    );
    await expectStatus(tester, 'Noch nicht gespeichert');
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('daily_note_field')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    final noteField = tester.widget<TextField>(
      find.byKey(const ValueKey('daily_note_field')),
    );
    expect(noteField.controller?.text, 'Diese Notiz bleibt erhalten');
    expect(saveButton(tester).onPressed, isNotNull);
  });
}
