import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:berichtsheft_merker/core/enums/day_type.dart';
import 'package:berichtsheft_merker/core/enums/activity_category.dart';
import 'package:berichtsheft_merker/core/enums/special_flag.dart';
import 'package:berichtsheft_merker/core/enums/training_area.dart';
import 'package:berichtsheft_merker/core/models/daily_entry.dart';
import 'package:berichtsheft_merker/core/models/activity_template.dart';
import 'package:berichtsheft_merker/core/storage/daily_entry_storage.dart';
import 'package:berichtsheft_merker/core/storage/in_memory_daily_entry_storage.dart';
import 'package:berichtsheft_merker/core/storage/in_memory_activity_template_storage.dart';
import 'package:berichtsheft_merker/core/week_utils.dart';
import 'package:berichtsheft_merker/features/week/week_screen.dart';

DateTime normalizedToday() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

DailyEntry entryFor(
  DateTime date, {
  DayType dayType = DayType.betrieb,
  List<TrainingArea> areas = const [TrainingArea.wareneingang],
  List<String> activities = const ['wareneingang_01'],
  List<SpecialFlag> specialFlags = const [],
  String? note,
}) {
  return DailyEntry(
    id: DailyEntry.idForDate(date),
    date: date,
    dayType: dayType,
    areas: dayType == DayType.betrieb ? areas : const [],
    selectedActivities: dayType.supportsActivities ? activities : const [],
    specialFlags: specialFlags,
    reportNote: note,
    createdAt: date,
    updatedAt: date,
  );
}

Future<void> pumpWeek(
  WidgetTester tester, {
  DailyEntryStorage? storage,
  InMemoryActivityTemplateStorage? templateStorage,
  DateTime? initialDate,
  DateTime? currentDate,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: WeekScreen(
        storage: storage ?? InMemoryDailyEntryStorage(),
        templateStorage: templateStorage ?? InMemoryActivityTemplateStorage(),
        initialDate: initialDate,
        currentDate: currentDate,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class ControlledWeekStorage implements DailyEntryStorage {
  final Map<String, DailyEntry> entries = {};
  Object? loadError;
  int loadCalls = 0;

  @override
  Future<DailyEntry?> loadByDate(DateTime date) async {
    loadCalls++;
    if (loadError case final error?) {
      throw error;
    }
    return entries[DailyEntry.idForDate(date)];
  }

  @override
  Future<List<DailyEntry>> loadAll() async {
    if (loadError case final error?) {
      throw error;
    }
    return entries.values.toList(growable: false);
  }

  @override
  Future<void> save(DailyEntry entry) async {
    entries[DailyEntry.idForDate(entry.date)] = entry;
  }

  @override
  Future<void> clearAll() async {
    entries.clear();
  }
}

void main() {
  testWidgets('zeigt sieben Tageskarten mit Status und Fortschritt', (
    WidgetTester tester,
  ) async {
    final today = normalizedToday();
    final monday = startOfWeek(today);
    final dueDays = today.weekday > DateTime.friday ? 5 : today.weekday;
    final entries = [
      entryFor(monday),
      if (dueDays >= 3)
        entryFor(
          monday.add(const Duration(days: 2)),
          dayType: DayType.urlaub,
        ),
    ];
    final storage = InMemoryDailyEntryStorage(initialEntries: entries);

    await pumpWeek(tester, storage: storage, initialDate: today);

    expect(
      find.text(
          '${entries.length} von $dueDays fälligen Werktagen eingetragen'),
      findsOneWidget,
    );

    for (var index = 0; index < 7; index++) {
      final date = monday.add(Duration(days: index));
      final dayCard = find.byKey(
        ValueKey('week_day_${DailyEntry.idForDate(date)}'),
      );
      await tester.scrollUntilVisible(
        dayCard,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(dayCard, findsOneWidget);
      final expectedStatus = entries.any((entry) => entry.date == date)
          ? entries.firstWhere((entry) => entry.date == date).dayType.isAbsence
              ? 'Urlaub'
              : 'Gespeichert'
          : date.weekday <= DateTime.friday && !date.isAfter(today)
              ? 'Offen'
              : 'Kein Eintrag';
      expect(
        find.descendant(of: dayCard, matching: find.text(expectedStatus)),
        findsOneWidget,
      );
    }
  });

  testWidgets('navigiert zurück und vorwärts, aber nicht in die Zukunft', (
    WidgetTester tester,
  ) async {
    final today = normalizedToday();
    final currentMonday = startOfWeek(today);
    final previousMonday = currentMonday.subtract(const Duration(days: 7));

    await pumpWeek(tester, initialDate: today);

    final nextButton = tester.widget<IconButton>(
      find.byKey(const ValueKey('next_week')),
    );
    expect(nextButton.onPressed, isNull);

    await tester.tap(find.byKey(const ValueKey('previous_week')));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'KW ${isoWeekNumber(previousMonday)} / ${isoWeekYear(previousMonday)}',
      ),
      findsOneWidget,
    );
    expect(
      tester
          .widget<IconButton>(find.byKey(const ValueKey('next_week')))
          .onPressed,
      isNotNull,
    );

    await tester.tap(find.byKey(const ValueKey('next_week')));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'KW ${isoWeekNumber(currentMonday)} / ${isoWeekYear(currentMonday)}',
      ),
      findsOneWidget,
    );
  });

  testWidgets('aktuelle Woche folgt einem externen Wochenwechsel', (
    WidgetTester tester,
  ) async {
    final storage = InMemoryDailyEntryStorage();
    final templateStorage = InMemoryActivityTemplateStorage();
    final firstWeek = DateTime(2026, 6, 12);
    final nextWeek = DateTime(2026, 6, 15);

    Widget subject(DateTime currentDate) => MaterialApp(
          home: WeekScreen(
            storage: storage,
            templateStorage: templateStorage,
            currentDate: currentDate,
          ),
        );

    await tester.pumpWidget(subject(firstWeek));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('week_number'))).data,
      'KW ${isoWeekNumber(firstWeek)} / ${isoWeekYear(firstWeek)}',
    );

    await tester.pumpWidget(subject(nextWeek));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('week_number'))).data,
      'KW ${isoWeekNumber(nextWeek)} / ${isoWeekYear(nextWeek)}',
    );
  });

  testWidgets('historisch ausgewählte Woche bleibt beim Wochenwechsel', (
    WidgetTester tester,
  ) async {
    final storage = InMemoryDailyEntryStorage();
    final templateStorage = InMemoryActivityTemplateStorage();

    Widget subject(DateTime currentDate) => MaterialApp(
          home: WeekScreen(
            storage: storage,
            templateStorage: templateStorage,
            currentDate: currentDate,
          ),
        );

    await tester.pumpWidget(subject(DateTime(2026, 6, 12)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('previous_week')));
    await tester.pumpAndSettle();
    final selectedWeek =
        startOfWeek(DateTime(2026, 6, 12)).subtract(const Duration(days: 7));
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('week_number'))).data,
      'KW ${isoWeekNumber(selectedWeek)} / ${isoWeekYear(selectedWeek)}',
    );

    await tester.pumpWidget(subject(DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('week_number'))).data,
      'KW ${isoWeekNumber(selectedWeek)} / ${isoWeekYear(selectedWeek)}',
    );
  });

  testWidgets('öffnet Zusammenfassung mit Tätigkeiten, Notiz und Fehltag', (
    WidgetTester tester,
  ) async {
    final today = normalizedToday();
    final monday = startOfWeek(today);
    final storage = InMemoryDailyEntryStorage(
      initialEntries: [
        entryFor(
          monday,
          specialFlags: const [SpecialFlag.selbststaendig],
          note: 'Neue Warenannahme',
        ),
      ],
    );

    await pumpWeek(tester, storage: storage, initialDate: today);
    await tester.tap(find.byKey(const ValueKey('show_week_summary')));
    await tester.pumpAndSettle();

    expect(find.text('Wochenzusammenfassung'), findsOneWidget);
    expect(find.text('Lieferung angenommen und geprüft'), findsOneWidget);
    expect(find.text('Besonderheiten: Selbstständig'), findsOneWidget);
    expect(find.text('Notiz: Neue Warenannahme'), findsOneWidget);
    if (today.weekday >= DateTime.tuesday) {
      expect(find.text('Kein Eintrag – offen'), findsWidgets);
    }
  });

  testWidgets('leere Woche deaktiviert die Zusammenfassung', (
    WidgetTester tester,
  ) async {
    await pumpWeek(tester);

    final button = tester.widget<IconButton>(
      find.byKey(const ValueKey('show_week_summary')),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('Zusammenfassung zeigt Titel einer eigenen Tätigkeit', (
    WidgetTester tester,
  ) async {
    final today = normalizedToday();
    final monday = startOfWeek(today);
    final storage = InMemoryDailyEntryStorage(
      initialEntries: [
        entryFor(monday, activities: const ['custom_1']),
      ],
    );
    final templateStorage = InMemoryActivityTemplateStorage(
      initialTemplates: const [
        ActivityTemplate(
          id: 'custom_1',
          title: 'Eigene Warenprüfung',
          category: ActivityCategory.wareneingang,
          isCustom: true,
          isActive: false,
        ),
      ],
    );

    await pumpWeek(
      tester,
      storage: storage,
      templateStorage: templateStorage,
      initialDate: today,
    );
    await tester.tap(find.byKey(const ValueKey('show_week_summary')));
    await tester.pumpAndSettle();

    expect(find.text('Eigene Warenprüfung'), findsOneWidget);
  });

  testWidgets('Tag kann aus Woche geöffnet, gespeichert und neu geladen werden',
      (
    WidgetTester tester,
  ) async {
    final today = normalizedToday();
    final monday = startOfWeek(today);
    final storage = InMemoryDailyEntryStorage();

    await pumpWeek(tester, storage: storage, initialDate: today);
    await tester.tap(
      find.byKey(ValueKey('week_day_${DailyEntry.idForDate(monday)}')),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(monday == today ? 'Heute' : 'Tageseintrag'),
      findsWidgets,
    );
    await tester.tap(find.byKey(const ValueKey('day_type_frei')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save_daily_entry')));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Frei'), findsWidgets);
    expect(
      find.text('1 von ${today.weekday > 5 ? 5 : today.weekday} '
          'fälligen Werktagen eingetragen'),
      findsOneWidget,
    );
  });

  testWidgets('Zurück-Navigation schützt ungespeicherte Änderungen', (
    WidgetTester tester,
  ) async {
    final today = normalizedToday();
    final monday = startOfWeek(today);
    await pumpWeek(tester, initialDate: today);

    await tester.tap(
      find.byKey(ValueKey('week_day_${DailyEntry.idForDate(monday)}')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('day_type_frei')));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Änderungen verwerfen?'), findsOneWidget);
    await tester.tap(find.text('Weiter bearbeiten'));
    await tester.pumpAndSettle();
    expect(find.text(monday == today ? 'Heute' : 'Tageseintrag'), findsWidgets);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Änderungen verwerfen'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('week_number')), findsOneWidget);
  });

  testWidgets('Ladefehler kann erneut versucht werden', (
    WidgetTester tester,
  ) async {
    final storage = ControlledWeekStorage()
      ..loadError = StateError('Lesefehler');

    await pumpWeek(tester, storage: storage);

    expect(
      find.text('Die Einträge dieser Woche konnten nicht geladen werden.'),
      findsOneWidget,
    );
    expect(storage.loadCalls, greaterThanOrEqualTo(1));

    storage.loadError = null;
    await tester.tap(find.byKey(const ValueKey('retry_week_load')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('week_list')), findsOneWidget);
    expect(storage.loadCalls, greaterThanOrEqualTo(8));
  });

  testWidgets('neues Refresh-Signal lädt die sichtbare Woche erneut', (
    WidgetTester tester,
  ) async {
    final storage = ControlledWeekStorage();
    await tester.pumpWidget(
      MaterialApp(
        home: WeekScreen(
          storage: storage,
          templateStorage: InMemoryActivityTemplateStorage(),
          refreshSignal: 0,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(storage.loadCalls, 7);

    await tester.pumpWidget(
      MaterialApp(
        home: WeekScreen(
          storage: storage,
          templateStorage: InMemoryActivityTemplateStorage(),
          refreshSignal: 1,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(storage.loadCalls, 14);
  });

  group('Berichtsvorschlag in Wochenzusammenfassung', () {
    testWidgets('zeigt Berichtstext für gespeicherten Tag', (
      WidgetTester tester,
    ) async {
      final today = normalizedToday();
      final monday = startOfWeek(today);
      final storage = InMemoryDailyEntryStorage(
        initialEntries: [entryFor(monday)],
      );

      await pumpWeek(tester, storage: storage, initialDate: today);
      await tester.tap(find.byKey(const ValueKey('show_week_summary')));
      await tester.pumpAndSettle();

      expect(find.text('Lieferung angenommen und geprüft'), findsOneWidget);
      expect(find.text('Vorschlag fürs Berichtsheft'), findsOneWidget);
    });

    testWidgets('Kopieren-Button pro Tag vorhanden und zeigt Snackbar', (
      WidgetTester tester,
    ) async {
      final today = normalizedToday();
      final monday = startOfWeek(today);
      final mondayId = DailyEntry.idForDate(monday);
      final storage = InMemoryDailyEntryStorage(
        initialEntries: [entryFor(monday)],
      );

      await pumpWeek(tester, storage: storage, initialDate: today);
      await tester.tap(find.byKey(const ValueKey('show_week_summary')));
      await tester.pumpAndSettle();

      final copyKey = Key('copy_report_$mondayId');
      await tester.scrollUntilVisible(
        find.byKey(copyKey),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byKey(copyKey), findsOneWidget);

      await tester.tap(find.byKey(copyKey));
      await tester.pump();
      expect(find.text('Tagesbericht kopiert.'), findsOneWidget);
    });
  });
}
