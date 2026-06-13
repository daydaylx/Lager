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
    expect(find.text('Wareneingang'), findsOneWidget);
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
  });

  testWidgets('eigene Tätigkeit löschen entfernt sie aus der Liste', (
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

    await tester.ensureVisible(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();

    expect(find.text('Zu löschende Tätigkeit'), findsNothing);
    expect(find.text('Eigene (1)'), findsNothing);
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
