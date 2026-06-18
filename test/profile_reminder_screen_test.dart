import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:berichtsheft_merker/core/services/notification_service.dart';
import 'package:berichtsheft_merker/core/storage/in_memory_activity_template_storage.dart';
import 'package:berichtsheft_merker/core/storage/in_memory_daily_entry_storage.dart';
import 'package:berichtsheft_merker/features/profile/profile_screen.dart';

/// Scrolls the ProfileScreen's body ListView until [key] is built into the
/// element tree. Uses the only vertical Scrollable in the tree.
Future<void> scrollTo(WidgetTester tester, String key) async {
  final vertical = find.byWidgetPredicate(
    (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
  );
  await tester.scrollUntilVisible(
    find.byKey(ValueKey(key)),
    200.0,
    scrollable: vertical,
  );
  await tester.pumpAndSettle();
}

Future<NoOpNotificationScheduler> pumpScreen(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
  NoOpNotificationScheduler? scheduler,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final spy = scheduler ?? NoOpNotificationScheduler();
  await tester.pumpWidget(
    MaterialApp(
      home: ProfileScreen(
        dailyEntryStorage: InMemoryDailyEntryStorage(),
        templateStorage: InMemoryActivityTemplateStorage(),
        onDataCleared: () async {},
        notificationScheduler: spy,
      ),
    ),
  );
  await tester.pumpAndSettle();
  // The reminder section is below the profile form in a lazy SliverList.
  await scrollTo(tester, 'reminder_toggle');
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

    testWidgets(
        'Toggle aktivieren speichert reminder_enabled in SharedPreferences',
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

    testWidgets('Standard-Zeit 20:00 ist nach Aktivieren sichtbar',
        (tester) async {
      await pumpScreen(tester, prefs: {'reminder_enabled': true});
      await scrollTo(tester, 'reminder_time_0');
      expect(find.text('20:00'), findsOneWidget);
    });

    testWidgets('Zeit löschen entfernt sie aus der Liste', (tester) async {
      // Two times required: deletion is blocked when only 1 remains (Fix 2).
      await pumpScreen(tester, prefs: {
        'reminder_enabled': true,
        'reminder_times': '["20:00","08:00"]',
      });
      await scrollTo(tester, 'reminder_time_0');
      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('reminder_time_0')),
          matching: find.byIcon(Icons.delete_outline),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('08:00'), findsNothing);
      expect(find.text('20:00'), findsOneWidget);
    });

    testWidgets('Zeit-hinzufügen-Button ist vorhanden wenn aktiviert',
        (tester) async {
      await pumpScreen(tester, prefs: {'reminder_enabled': true});
      await scrollTo(tester, 'reminder_add_time');
      expect(find.byKey(const ValueKey('reminder_add_time')), findsOneWidget);
    });

    testWidgets('letzte Uhrzeit kann nicht entfernt werden', (tester) async {
      await pumpScreen(tester, prefs: {'reminder_enabled': true});
      await scrollTo(tester, 'reminder_time_0');
      final button = tester.widget<IconButton>(
        find.descendant(
          of: find.byKey(const ValueKey('reminder_time_0')),
          matching: find.byType(IconButton),
        ),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('doppelte Uhrzeit zeigt verständlichen Fehler', (tester) async {
      await pumpScreen(tester, prefs: {'reminder_enabled': true});
      await scrollTo(tester, 'reminder_add_time');
      await tester.tap(find.byKey(const ValueKey('reminder_add_time')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(
          find.text('Diese Uhrzeit ist bereits eingetragen.'), findsOneWidget);
    });

    testWidgets('Mo–Fr Chips sind standardmäßig ausgewählt', (tester) async {
      await pumpScreen(tester, prefs: {'reminder_enabled': true});
      await scrollTo(tester, 'reminder_weekday_1');
      for (int i = 1; i <= 5; i++) {
        final chip = tester.widget<FilterChip>(
          find.byKey(ValueKey('reminder_weekday_$i')),
        );
        expect(chip.selected, isTrue,
            reason: 'Wochentag $i soll ausgewählt sein');
      }
      for (int i = 6; i <= 7; i++) {
        final chip = tester.widget<FilterChip>(
          find.byKey(ValueKey('reminder_weekday_$i')),
        );
        expect(chip.selected, isFalse,
            reason: 'Wochentag $i soll nicht ausgewählt sein');
      }
    });

    testWidgets('Wochentag-Chip toggeln wählt ihn aus', (tester) async {
      await pumpScreen(tester, prefs: {'reminder_enabled': true});
      await scrollTo(tester, 'reminder_weekday_6');
      await tester.tap(find.byKey(const ValueKey('reminder_weekday_6')));
      await tester.pumpAndSettle();
      final chip = tester.widget<FilterChip>(
        find.byKey(const ValueKey('reminder_weekday_6')),
      );
      expect(chip.selected, isTrue);
    });

    testWidgets('letzter Wochentag kann nicht abgewählt werden',
        (tester) async {
      await pumpScreen(tester, prefs: {
        'reminder_enabled': true,
        'reminder_weekdays': '[1]',
      });
      await scrollTo(tester, 'reminder_weekday_1');
      final chip = tester.widget<FilterChip>(
        find.byKey(const ValueKey('reminder_weekday_1')),
      );
      expect(chip.onSelected, isNull);
    });

    testWidgets('verweigerte Berechtigung behält deaktivierten Zustand', (
      tester,
    ) async {
      final spy = NoOpNotificationScheduler(
        scheduleResult: NotificationScheduleResult.permissionDenied,
      );
      await pumpScreen(tester, scheduler: spy);
      await tester.tap(find.byKey(const ValueKey('reminder_toggle')));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Benachrichtigungen sind nicht erlaubt. Bitte in den Einstellungen aktivieren.',
        ),
        findsOneWidget,
      );
      final toggle = tester.widget<SwitchListTile>(
        find.byKey(const ValueKey('reminder_toggle')),
      );
      expect(toggle.value, isFalse);
      expect(spy.scheduleCalls, 2);
    });

    testWidgets('Schedulingfehler zeigt Meldung und behält Zustand', (
      tester,
    ) async {
      final spy = NoOpNotificationScheduler(
        scheduleError: StateError('Schedulingfehler'),
      );
      await pumpScreen(tester, scheduler: spy);
      await tester.tap(find.byKey(const ValueKey('reminder_toggle')));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Die Erinnerung konnte nicht gespeichert werden. Bitte versuche es erneut.',
        ),
        findsOneWidget,
      );
      final toggle = tester.widget<SwitchListTile>(
        find.byKey(const ValueKey('reminder_toggle')),
      );
      expect(toggle.value, isFalse);
    });

    testWidgets('Berechtigungsstatus wird nach Rückkehr erneut geprüft', (
      tester,
    ) async {
      final spy = NoOpNotificationScheduler(notificationsEnabled: false);
      await pumpScreen(
        tester,
        prefs: {'reminder_enabled': true},
        scheduler: spy,
      );

      expect(
        find.text(
          'Benachrichtigungen sind nicht erlaubt. Bitte in den Einstellungen aktivieren.',
        ),
        findsOneWidget,
      );

      spy.notificationsEnabled = true;
      tester.binding.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Benachrichtigungen sind nicht erlaubt. Bitte in den Einstellungen aktivieren.',
        ),
        findsNothing,
      );
    });
  });
}
