import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:berichtsheft_merker/core/services/notification_service.dart';
import 'package:berichtsheft_merker/features/profile/profile_screen.dart';

Future<NoOpNotificationScheduler> pumpScreen(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final spy = NoOpNotificationScheduler();
  await tester.pumpWidget(
    MaterialApp(
      home: ProfileScreen(
        onDataCleared: () async {},
        notificationScheduler: spy,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return spy;
}

void main() {
  group('Profil-Screen Erinnerungen', () {
    testWidgets('Erinnerungs-Sektion wird angezeigt', (tester) async {
      await pumpScreen(tester);
      expect(find.text('Erinnerungen'), findsOneWidget);
    });

    testWidgets('Toggle startet als deaktiviert', (tester) async {
      await pumpScreen(tester);
      final toggle = tester.widget<SwitchListTile>(
        find.byKey(const ValueKey('reminder_toggle')),
      );
      expect(toggle.value, isFalse);
    });

    testWidgets('Toggle aktivieren speichert reminder_enabled in SharedPreferences',
        (tester) async {
      await pumpScreen(tester);
      await tester.tap(find.byKey(const ValueKey('reminder_toggle')));
      await tester.pumpAndSettle();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('reminder_enabled'), isTrue);
    });

    testWidgets('Toggle aktivieren ruft schedule() auf', (tester) async {
      final spy = await pumpScreen(tester);
      await tester.tap(find.byKey(const ValueKey('reminder_toggle')));
      await tester.pumpAndSettle();
      expect(spy.scheduleCalls, 1);
      expect(spy.lastScheduled?.enabled, isTrue);
    });

    testWidgets('Standard-Zeit 20:00 ist nach Aktivieren sichtbar', (tester) async {
      await pumpScreen(tester, prefs: {'reminder_enabled': true});
      expect(find.text('20:00'), findsOneWidget);
    });

    testWidgets('Zeit löschen entfernt sie aus der Liste', (tester) async {
      await pumpScreen(tester, prefs: {'reminder_enabled': true});
      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('reminder_time_0')),
          matching: find.byIcon(Icons.delete_outline),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('20:00'), findsNothing);
    });

    testWidgets('Zeit-hinzufügen-Button ist vorhanden wenn aktiviert',
        (tester) async {
      await pumpScreen(tester, prefs: {'reminder_enabled': true});
      expect(find.byKey(const ValueKey('reminder_add_time')), findsOneWidget);
    });

    testWidgets('Mo–Fr Chips sind standardmäßig ausgewählt', (tester) async {
      await pumpScreen(tester, prefs: {'reminder_enabled': true});
      for (int i = 1; i <= 5; i++) {
        final chip = tester.widget<FilterChip>(
          find.byKey(ValueKey('reminder_weekday_$i')),
        );
        expect(chip.selected, isTrue, reason: 'Wochentag $i soll ausgewählt sein');
      }
      for (int i = 6; i <= 7; i++) {
        final chip = tester.widget<FilterChip>(
          find.byKey(ValueKey('reminder_weekday_$i')),
        );
        expect(chip.selected, isFalse, reason: 'Wochentag $i soll nicht ausgewählt sein');
      }
    });

    testWidgets('Wochentag-Chip toggeln wählt ihn aus', (tester) async {
      await pumpScreen(tester, prefs: {'reminder_enabled': true});
      await tester.tap(find.byKey(const ValueKey('reminder_weekday_6')));
      await tester.pumpAndSettle();
      final chip = tester.widget<FilterChip>(
        find.byKey(const ValueKey('reminder_weekday_6')),
      );
      expect(chip.selected, isTrue);
    });
  });
}
