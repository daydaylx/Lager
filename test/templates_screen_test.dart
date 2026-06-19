import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:berichtsheft_merker/core/enums/activity_category.dart';
import 'package:berichtsheft_merker/core/enums/day_type.dart';
import 'package:berichtsheft_merker/core/enums/training_area.dart';
import 'package:berichtsheft_merker/core/models/activity_template.dart';
import 'package:berichtsheft_merker/core/models/daily_entry.dart';
import 'package:berichtsheft_merker/core/storage/in_memory_activity_template_storage.dart';
import 'package:berichtsheft_merker/core/storage/in_memory_daily_entry_storage.dart';
import 'package:berichtsheft_merker/features/templates/templates_screen.dart';

void main() {
  late InMemoryActivityTemplateStorage storage;

  setUp(() {
    storage = InMemoryActivityTemplateStorage();
  });

  Widget buildSubject() {
    return MaterialApp(home: TemplatesScreen(storage: storage));
  }

  testWidgets('zeigt Kategoriefilter und vordefinierte Tätigkeiten', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('Alle'), findsOneWidget);
    expect(find.text('Wareneingang'), findsWidgets);
    expect(find.text('Vordefiniert (132)'), findsOneWidget);
  });

  testWidgets('Kategorie-Filter zeigt nur passende Tätigkeiten', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.tap(find.text('Wareneingang').first);
    await tester.pump();

    expect(find.text('Vordefiniert (15)'), findsOneWidget);
    expect(find.text('Ware angenommen'), findsOneWidget);
    expect(find.text('Wareneingang · Annahme'), findsWidgets);
  });

  testWidgets('Kategorie erneut antippen hebt Auswahl auf', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.tap(find.text('Wareneingang').first);
    await tester.pump();
    expect(find.text('Vordefiniert (15)'), findsOneWidget);

    await tester.tap(find.text('Wareneingang').first);
    await tester.pump();
    expect(find.text('Vordefiniert (132)'), findsOneWidget);
  });

  testWidgets('Suche filtert Tätigkeiten lokal', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.enterText(
      find.byKey(const ValueKey('template_search')),
      'Ware angenommen',
    );
    await tester.pump();

    expect(find.text('Vordefiniert (1)'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ListTile),
        matching: find.text('Ware angenommen'),
      ),
      findsOneWidget,
    );
    expect(find.text('Ware verpackt'), findsNothing);
  });

  testWidgets('eigene Tätigkeit hinzufügen erscheint in Eigene-Liste', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('template_title_field')),
      'Meine Testroutine',
    );
    await tester.tap(find.text('Hinzufügen'));
    await tester.pumpAndSettle();

    expect(find.text('Eigene (1)'), findsOneWidget);
    expect(find.text('Meine Testroutine'), findsOneWidget);
  });

  testWidgets('leeres Titel-Feld schließt Dialog nicht', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Hinzufügen'));
    await tester.pumpAndSettle();

    expect(find.text('Hinzufügen'), findsOneWidget);
    expect(find.text('Gib eine Bezeichnung ein.'), findsOneWidget);
  });

  testWidgets('Duplikat zu Standardtätigkeit wird normalisiert verhindert', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('template_title_field')),
      '  WARE   ANGENOMMEN ',
    );
    await tester.tap(find.text('Hinzufügen'));
    await tester.pumpAndSettle();

    expect(
      find.text('Diese Tätigkeit existiert bereits: „Ware angenommen".'),
      findsOneWidget,
    );
    expect(find.text('Hinzufügen'), findsOneWidget);
    expect(await storage.loadCustom(), isEmpty);
  });

  testWidgets('Duplikat zu inaktiver eigener Tätigkeit wird verhindert', (
    tester,
  ) async {
    await storage.save(
      const ActivityTemplate(
        id: 'custom_1',
        title: 'Ware verräumt',
        category: ActivityCategory.einlagerung,
        isCustom: true,
        isActive: false,
      ),
    );
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('template_title_field')),
      ' ware   verräumt ',
    );
    await tester.tap(find.text('Hinzufügen'));
    await tester.pumpAndSettle();

    expect(
      find.text('Diese Tätigkeit existiert bereits: „Ware verräumt".'),
      findsOneWidget,
    );
    expect(await storage.loadCustom(), hasLength(1));
  });

  testWidgets('eigene Tätigkeit kann deaktiviert und reaktiviert werden', (
    tester,
  ) async {
    await storage.save(
      const ActivityTemplate(
        id: 'custom_1',
        title: 'Zu löschende Tätigkeit',
        category: ActivityCategory.wareneingang,
        isCustom: true,
      ),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();
    await tester.pump();

    // Wareneingang-Filter: vordefinierte Einträge + Eigene-Sektion.
    await tester.tap(find.text('Wareneingang').first);
    await tester.pump();

    expect(find.text('Zu löschende Tätigkeit'), findsOneWidget);
    expect(find.text('Eigene (1)'), findsOneWidget);

    await tester.ensureVisible(find.byTooltip('Deaktivieren'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Deaktivieren'));
    await tester.pumpAndSettle();

    expect(find.text('Zu löschende Tätigkeit'), findsOneWidget);
    expect(find.text('Wareneingang · Deaktiviert'), findsOneWidget);
    expect((await storage.loadCustom()).single.isActive, isFalse);

    await tester.tap(find.byTooltip('Aktivieren'));
    await tester.pumpAndSettle();
    expect(find.text('Wareneingang · Deaktiviert'), findsNothing);
    expect((await storage.loadCustom()).single.isActive, isTrue);
  });

  testWidgets('Kategorie-Filter zeigt nur eigene Tätigkeit der Kategorie', (
    tester,
  ) async {
    await storage.save(
      const ActivityTemplate(
        id: 'custom_1',
        title: 'Eigene Wareneingang-Aufgabe',
        category: ActivityCategory.wareneingang,
        isCustom: true,
      ),
    );
    await storage.save(
      const ActivityTemplate(
        id: 'custom_2',
        title: 'Eigene Versand-Aufgabe',
        category: ActivityCategory.versand,
        isCustom: true,
      ),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Wareneingang').first);
    await tester.pump();

    expect(find.text('Eigene Wareneingang-Aufgabe'), findsOneWidget);
    expect(find.text('Eigene Versand-Aufgabe'), findsNothing);
  });

  testWidgets('zeigt häufig genutzte Tätigkeiten aus gespeicherten Einträgen', (
    tester,
  ) async {
    final dailyStorage = InMemoryDailyEntryStorage(
      initialEntries: [
        DailyEntry(
          id: DailyEntry.idForDate(DateTime(2026, 6, 8)),
          date: DateTime(2026, 6, 8),
          dayType: DayType.betrieb,
          areas: const [TrainingArea.wareneingang],
          selectedActivities: const ['wareneingang_01'],
          specialFlags: const [],
          note: null,
          createdAt: DateTime(2026, 6, 8),
          updatedAt: DateTime(2026, 6, 8),
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: TemplatesScreen(storage: storage, dailyEntryStorage: dailyStorage),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Häufig genutzt'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('frequent_wareneingang_01')),
      findsOneWidget,
    );
  });
}
