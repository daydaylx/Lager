import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:berichtsheft_merker/core/enums/activity_category.dart';
import 'package:berichtsheft_merker/core/models/activity_template.dart';
import 'package:berichtsheft_merker/core/storage/in_memory_activity_template_storage.dart';
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
    expect(find.text('Vordefiniert (87)'), findsOneWidget);
  });

  testWidgets('Kategorie-Filter zeigt nur passende Tätigkeiten', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.tap(find.text('Wareneingang').first);
    await tester.pump();

    expect(find.text('Vordefiniert (10)'), findsOneWidget);
    expect(find.text('Ware angenommen'), findsOneWidget);
  });

  testWidgets('Kategorie erneut antippen hebt Auswahl auf', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.tap(find.text('Wareneingang').first);
    await tester.pump();
    expect(find.text('Vordefiniert (10)'), findsOneWidget);

    await tester.tap(find.text('Wareneingang').first);
    await tester.pump();
    expect(find.text('Vordefiniert (87)'), findsOneWidget);
  });

  testWidgets('eigene Tätigkeit hinzufügen erscheint in Eigene-Liste', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Meine Testroutine');
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

    // Wareneingang-Filter: 10 Einträge + Eigene-Sektion passen in Viewport
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
}
