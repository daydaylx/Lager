import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:berichtsheft_merker/app/app.dart';
import 'package:berichtsheft_merker/core/constants.dart';
import 'package:berichtsheft_merker/core/enums/activity_category.dart';
import 'package:berichtsheft_merker/core/enums/day_type.dart';
import 'package:berichtsheft_merker/core/enums/special_flag.dart';
import 'package:berichtsheft_merker/core/enums/training_area.dart';
import 'package:berichtsheft_merker/core/models/daily_entry.dart';
import 'package:berichtsheft_merker/core/models/activity_template.dart';
import 'package:berichtsheft_merker/core/storage/daily_entry_storage.dart';
import 'package:berichtsheft_merker/core/storage/activity_template_storage.dart';
import 'package:berichtsheft_merker/core/storage/in_memory_activity_template_storage.dart';
import 'package:berichtsheft_merker/core/storage/in_memory_daily_entry_storage.dart';
import 'package:berichtsheft_merker/core/week_utils.dart';
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

// #52: Bereichs-Chips sind mit Unterzeile höher — nach Bereichswahl zu den
// Tätigkeiten scrollen, damit diese im ListView gebaut und prüfbar sind.
Future<void> scrollToActivities(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.byKey(const ValueKey('activity_search')),
    300,
    scrollable: find.byType(Scrollable).first,
  );
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
  Future<List<DailyEntry>> loadAll() async {
    if (loadError case final error?) {
      throw error;
    }
    return entry == null ? const [] : [entry!];
  }

  @override
  Future<void> save(DailyEntry entry) async {
    if (saveError case final error?) {
      throw error;
    }
    lastSavedEntry = entry;
    this.entry = entry;
  }

  @override
  Future<void> clearAll() async {
    entry = null;
  }
}

class ControlledActivityTemplateStorage implements ActivityTemplateStorage {
  Object? loadError;
  final List<ActivityTemplate> templates;

  ControlledActivityTemplateStorage({
    this.loadError,
    Iterable<ActivityTemplate> templates = const [],
  }) : templates = templates.toList();

  @override
  Future<void> clearAll() async {
    templates.clear();
  }

  @override
  Future<List<ActivityTemplate>> loadCustom() async {
    if (loadError case final error?) {
      throw error;
    }
    return templates;
  }

  @override
  Future<void> save(ActivityTemplate template) async {
    templates
      ..removeWhere((item) => item.id == template.id)
      ..add(template);
  }
}

Future<void> pumpToday(
  WidgetTester tester, {
  DailyEntryStorage? storage,
  ActivityTemplateStorage? templateStorage,
  DateTime? date,
  int? trainingYear,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: TodayScreen(
        storage: storage ?? InMemoryDailyEntryStorage(),
        templateStorage: templateStorage ?? InMemoryActivityTemplateStorage(),
        date: date,
        trainingYear: trainingYear,
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

    await expectStatus(tester, 'Noch offen');
    expect(find.text('Noch offen: Bereich · Tätigkeit'), findsOneWidget);
    expect(saveButton(tester).onPressed, isNull);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('area_wareneingang')),
    );
    await scrollToActivities(tester);

    expect(find.text('Ware angenommen'), findsOneWidget);
    expect(find.text('Ware verpackt'), findsNothing);
    expect(find.text('Noch offen: Tätigkeit'), findsOneWidget);
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

  testWidgets('Tätigkeitssuche filtert die sichtbare Auswahlliste', (
    WidgetTester tester,
  ) async {
    await pumpToday(tester);

    await tapVisible(tester, find.byKey(const ValueKey('area_wareneingang')));
    await scrollToActivities(tester);
    await tester.enterText(
      find.byKey(const ValueKey('activity_search')),
      'Scanner',
    );
    await tester.pumpAndSettle();

    expect(find.text('Wareneingang mit Scanner erfasst'), findsOneWidget);
    expect(find.text('Ware angenommen'), findsNothing);
  });

  testWidgets('Tätigkeiten werden in Untergruppen angezeigt', (
    WidgetTester tester,
  ) async {
    await pumpToday(tester);

    await tapVisible(tester, find.byKey(const ValueKey('area_wareneingang')));
    await scrollToActivities(tester);

    expect(find.text('Annahme'), findsOneWidget);
    expect(find.text('Prüfung'), findsOneWidget);
  });

  testWidgets('Ausbildungsjahr zeigt passende Empfehlungen ohne Filter', (
    WidgetTester tester,
  ) async {
    await pumpToday(tester, trainingYear: 2);

    await tapVisible(tester, find.byKey(const ValueKey('area_wareneingang')));
    await scrollToActivities(tester);

    expect(find.text('Passend zum 2. Ausbildungsjahr'), findsOneWidget);
    expect(find.text('Wareneingang mit Scanner erfasst'), findsWidgets);
    expect(find.text('Ware angenommen'), findsOneWidget);
  });

  testWidgets('ausgewählte Tätigkeit bleibt bei Suche als Chip sichtbar', (
    WidgetTester tester,
  ) async {
    await pumpToday(tester);

    await tapVisible(tester, find.byKey(const ValueKey('area_wareneingang')));
    await tapVisible(
      tester,
      find.byKey(const ValueKey('activity_wareneingang_11')),
    );

    expect(
      find.byKey(const ValueKey('selected_activity_wareneingang_11')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey('activity_search')),
      'nicht vorhanden',
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('selected_activity_wareneingang_11')),
      findsOneWidget,
    );
    expect(find.text('Keine passenden Tätigkeiten gefunden'), findsOneWidget);
  });

  testWidgets(
      'häufig genutzte Tätigkeiten werden aus gespeicherten Tagen gezeigt',
      (WidgetTester tester) async {
    final dayOne = DateTime(2026, 6, 8);
    final dayTwo = DateTime(2026, 6, 9);
    final storage = InMemoryDailyEntryStorage(
      initialEntries: [
        DailyEntry(
          id: DailyEntry.idForDate(dayOne),
          date: dayOne,
          dayType: DayType.betrieb,
          areas: const [TrainingArea.wareneingang],
          selectedActivities: const ['wareneingang_11'],
          specialFlags: const [],
          note: null,
          createdAt: dayOne,
          updatedAt: dayOne,
        ),
        DailyEntry(
          id: DailyEntry.idForDate(dayTwo),
          date: dayTwo,
          dayType: DayType.betrieb,
          areas: const [TrainingArea.wareneingang],
          selectedActivities: const ['wareneingang_11', 'wareneingang_01'],
          specialFlags: const [],
          note: null,
          createdAt: dayTwo,
          updatedAt: dayTwo,
        ),
      ],
    );

    await pumpToday(tester, storage: storage);
    await tapVisible(tester, find.byKey(const ValueKey('area_wareneingang')));
    await scrollToActivities(tester);

    expect(find.text('Häufig genutzt'), findsOneWidget);
    expect(find.text('Wareneingang mit Scanner erfasst'), findsWidgets);
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
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Besonderheiten & Notiz'));
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

  testWidgets('Bereich abwählen entfernt Tätigkeitsauswahl nach Bestätigung', (
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

    // Bereich abwählen — löst Confirm-Dialog aus
    await tapVisible(
      tester,
      find.byKey(const ValueKey('area_wareneingang')),
      scrollDelta: -300,
    );
    expect(find.text('Bereich entfernen?'), findsOneWidget);
    await tester.tap(find.text('Änderungen verwerfen'));
    await tester.pumpAndSettle();

    expect(find.text('Ware angenommen'), findsNothing);
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

    await tapVisible(tester, find.text('Besonderheiten & Notiz'));
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
    expect(find.text('Tagestyp ändern?'), findsOneWidget);
    await tester.tap(find.text('Änderungen verwerfen'));
    await tester.pumpAndSettle();

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

  testWidgets('Bereich abwählen kann ohne Datenverlust abgebrochen werden', (
    WidgetTester tester,
  ) async {
    await pumpToday(tester);

    await tapVisible(tester, find.byKey(const ValueKey('area_wareneingang')));
    await tapVisible(
      tester,
      find.byKey(const ValueKey('activity_wareneingang_01')),
    );
    // Bereich wieder abwählen — löst Confirm-Dialog aus, da Tätigkeiten gewählt sind
    await tapVisible(
      tester,
      find.byKey(const ValueKey('area_wareneingang')),
      scrollDelta: -300,
    );

    await tester.tap(find.text('Weiter bearbeiten'));
    await tester.pumpAndSettle();

    final selectedArea = tester.widget<FilterChip>(
      find.byKey(const ValueKey('area_wareneingang')),
    );
    expect(selectedArea.selected, isTrue);
    expect(find.text('Ware angenommen'), findsWidgets);
  });

  testWidgets('eigene Tätigkeit kann ausgewählt und gespeichert werden', (
    WidgetTester tester,
  ) async {
    final storage = ControlledDailyEntryStorage();
    final templateStorage = InMemoryActivityTemplateStorage(
      initialTemplates: const [
        ActivityTemplate(
          id: 'custom_1',
          title: 'Eigene Warenprüfung',
          category: ActivityCategory.wareneingang,
          isCustom: true,
        ),
      ],
    );
    await pumpToday(
      tester,
      storage: storage,
      templateStorage: templateStorage,
    );

    await tapVisible(tester, find.byKey(const ValueKey('area_wareneingang')));
    await tapVisible(
      tester,
      find.byKey(const ValueKey('activity_custom_1')),
    );
    await tapSave(tester);
    await tester.pumpAndSettle();

    expect(storage.lastSavedEntry?.selectedActivities, ['custom_1']);
  });

  testWidgets('deaktivierte historische Tätigkeit bleibt abwählbar sichtbar', (
    WidgetTester tester,
  ) async {
    final date = DateTime(2026, 6, 12);
    final storage = ControlledDailyEntryStorage(
      entry: DailyEntry(
        id: DailyEntry.idForDate(date),
        date: date,
        dayType: DayType.betrieb,
        areas: const [TrainingArea.wareneingang],
        selectedActivities: const ['custom_1'],
        specialFlags: const [],
        note: null,
        createdAt: date,
        updatedAt: date,
      ),
    );
    final templateStorage = InMemoryActivityTemplateStorage(
      initialTemplates: const [
        ActivityTemplate(
          id: 'custom_1',
          title: 'Alte eigene Tätigkeit',
          category: ActivityCategory.wareneingang,
          isCustom: true,
          isActive: false,
        ),
      ],
    );

    await pumpToday(
      tester,
      storage: storage,
      templateStorage: templateStorage,
      date: date,
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('activity_custom_1')),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Alte eigene Tätigkeit'), findsWidgets);
    expect(find.text('Eigene Tätigkeit · Deaktiviert'), findsOneWidget);
    final checkbox = tester.widget<Checkbox>(
      find.descendant(
        of: find.byKey(const ValueKey('activity_custom_1')),
        matching: find.byType(Checkbox),
      ),
    );
    expect(checkbox.value, isTrue);
    expect(checkbox.onChanged, isNotNull);
  });

  testWidgets('Vorlagen-Ladefehler lässt Standardtätigkeiten nutzbar', (
    WidgetTester tester,
  ) async {
    final templateStorage = ControlledActivityTemplateStorage(
      loadError: StateError('Lesefehler'),
    );
    await pumpToday(tester, templateStorage: templateStorage);
    await tapVisible(tester, find.byKey(const ValueKey('area_wareneingang')));
    await scrollToActivities(tester);

    expect(
      find.textContaining('Eigene Tätigkeiten konnten nicht geladen werden.'),
      findsOneWidget,
    );
    expect(find.text('Ware angenommen'), findsOneWidget);
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

  testWidgets('sauberer Tageswechsel lädt den neuen Tag', (tester) async {
    final storage = InMemoryDailyEntryStorage();
    final dayOne = DateTime(2026, 6, 12);
    final dayTwo = DateTime(2026, 6, 13);

    Widget subject(DateTime currentDate) => MaterialApp(
          home: TodayScreen(
            storage: storage,
            templateStorage: InMemoryActivityTemplateStorage(),
            currentDate: currentDate,
          ),
        );

    await tester.pumpWidget(subject(dayOne));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const ValueKey('day_type_frei')));
    await tapSave(tester);
    await tester.pumpAndSettle();

    await tester.pumpWidget(subject(dayTwo));
    await tester.pumpAndSettle();
    expect(find.text(formatDayDate(dayTwo)), findsOneWidget);
    expect(find.text('Noch offen'), findsOneWidget);

    await tapVisible(tester, find.byKey(const ValueKey('day_type_frei')));
    await tapSave(tester);
    expect(await storage.loadByDate(dayOne), isNotNull);
    expect(await storage.loadByDate(dayTwo), isNotNull);
  });

  testWidgets('offene Änderungen bleiben beim bisherigen Tag', (tester) async {
    final dayOne = DateTime(2026, 6, 12);
    final dayTwo = DateTime(2026, 6, 13);
    final storage = InMemoryDailyEntryStorage();

    Widget subject(DateTime currentDate) => MaterialApp(
          home: TodayScreen(
            storage: storage,
            templateStorage: InMemoryActivityTemplateStorage(),
            currentDate: currentDate,
          ),
        );

    await tester.pumpWidget(subject(dayOne));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const ValueKey('day_type_sonstiges')));
    await tester.enterText(
      find.byKey(const ValueKey('daily_note_field')),
      'Offene Notiz',
    );

    await tester.pumpWidget(subject(dayTwo));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(Scrollable).first,
      const Offset(0, 2000),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('new_day_pending')), findsOneWidget);
    expect(find.text(formatDayDate(dayOne)), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('switch_to_current_day')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Änderungen verwerfen'));
    await tester.pumpAndSettle();

    expect(find.text(formatDayDate(dayTwo)), findsOneWidget);
    expect(find.text('Noch offen'), findsOneWidget);
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
        areas: const [TrainingArea.wareneingang],
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

    final areaChip = tester.widget<FilterChip>(
      find.byKey(const ValueKey('area_wareneingang')),
    );
    expect(areaChip.selected, isTrue);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('activity_wareneingang_01')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    final activityCheckbox = tester.widget<Checkbox>(
      find.descendant(
        of: find.byKey(const ValueKey('activity_wareneingang_01')),
        matching: find.byType(Checkbox),
      ),
    );
    expect(activityCheckbox.value, isTrue);

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
        areas: const [],
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
    expect(find.text('Noch offen'), findsOneWidget);
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
    await expectStatus(tester, 'Noch offen');
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

  group('Berichtskarte', () {
    testWidgets('erscheint nach Auswahl von Bereich und Tätigkeit', (
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

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('report_card')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byKey(const ValueKey('report_card')), findsOneWidget);
    });

    testWidgets('zeigt Nicht-gespeichert-Status vor dem Speichern', (
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

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('report_card')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Entwurf'), findsOneWidget);
    });

    testWidgets('Kopieren-Button zeigt SnackBar', (
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

      await tapVisible(
        tester,
        find.byKey(const ValueKey('copy_report_card')),
      );

      expect(find.text('Tagesbericht kopiert.'), findsOneWidget);
    });

    testWidgets('Vorschau-Button ist nicht mehr vorhanden', (
      WidgetTester tester,
    ) async {
      await pumpToday(tester);
      expect(
        find.byKey(const ValueKey('preview_daily_report')),
        findsNothing,
      );
    });
  });
}
