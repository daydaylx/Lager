import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:berichtsheft_merker/core/enums/day_type.dart';
import 'package:berichtsheft_merker/core/enums/special_flag.dart';
import 'package:berichtsheft_merker/core/enums/training_area.dart';
import 'package:berichtsheft_merker/core/models/daily_entry.dart';
import 'package:berichtsheft_merker/core/storage/daily_entry_storage.dart';
import 'package:berichtsheft_merker/core/storage/in_memory_daily_entry_storage.dart';
import 'package:berichtsheft_merker/core/week_utils.dart';
import 'package:berichtsheft_merker/features/week/week_screen.dart';

DateTime normalizedToday() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

DailyEntry entryFor(
  DateTime date, {
  DayType dayType = DayType.betrieb,
  TrainingArea? area = TrainingArea.wareneingang,
  List<String> activities = const ['wareneingang_01'],
  List<SpecialFlag> specialFlags = const [],
  String? note,
}) {
  return DailyEntry(
    id: DailyEntry.idForDate(date),
    date: date,
    dayType: dayType,
    area: dayType == DayType.betrieb ? area : null,
    selectedActivities: dayType.supportsActivities ? activities : const [],
    specialFlags: specialFlags,
    note: note,
    createdAt: date,
    updatedAt: date,
  );
}

Future<void> pumpWeek(
  WidgetTester tester, {
  DailyEntryStorage? storage,
  DateTime? initialDate,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: WeekScreen(
        storage: storage ?? InMemoryDailyEntryStorage(),
        initialDate: initialDate,
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
              ? 'Fehlt'
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
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('show_week_summary')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('show_week_summary')));
    await tester.pumpAndSettle();

    expect(find.text('Wochenzusammenfassung'), findsOneWidget);
    expect(find.text('Ware angenommen'), findsOneWidget);
    expect(find.text('Besonderheiten: Selbstständig'), findsOneWidget);
    expect(find.text('Notiz: Neue Warenannahme'), findsOneWidget);
    if (today.weekday >= DateTime.tuesday) {
      expect(find.text('Kein Eintrag – fehlt'), findsWidgets);
    }
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
          refreshSignal: 1,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(storage.loadCalls, 14);
  });
}
