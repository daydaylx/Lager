import 'dart:convert';

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
        'Toggle aktivieren speichert atomare V2-Einstellung in SharedPreferences',
        (tester) async {
      await pumpScreen(tester);
      await tester.tap(find.byKey(const ValueKey('reminder_toggle')));
      await tester.pumpAndSettle();
      final prefs = await SharedPreferences.getInstance();
      final stored = jsonDecode(prefs.getString('reminder_settings_v2')!)
          as Map<String, dynamic>;
      expect(stored['version'], 2);
      expect(stored['enabled'], isTrue);
      expect(stored['time'], '20:00');
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
      await scrollTo(tester, 'reminder_time');
      expect(find.text('20:00'), findsOneWidget);
    });

    testWidgets('Uhrzeit kann durch Tippen geändert werden', (tester) async {
      await pumpScreen(
        tester,
        prefs: {'reminder_enabled': true},
      );
      await scrollTo(tester, 'reminder_time');
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('reminder_time')));
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsOneWidget);
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

    testWidgets('verweigerte Berechtigung behält Nutzerabsicht aktiv', (
      tester,
    ) async {
      final spy = NoOpNotificationScheduler(
        notificationsEnabled: false,
      );
      await pumpScreen(tester, scheduler: spy);
      await tester.tap(find.byKey(const ValueKey('reminder_toggle')));
      await tester.pumpAndSettle();

      expect(
        find.text('Benachrichtigungen sind blockiert'),
        findsOneWidget,
      );
      final toggle = tester.widget<SwitchListTile>(
        find.byKey(const ValueKey('reminder_toggle')),
      );
      expect(toggle.value, isTrue);
      expect(spy.scheduleCalls, 1);
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
          'Die Einstellung ist gespeichert, aber Android konnte die Erinnerung noch nicht vollständig planen.',
        ),
        findsOneWidget,
      );
      final toggle = tester.widget<SwitchListTile>(
        find.byKey(const ValueKey('reminder_toggle')),
      );
      expect(toggle.value, isTrue);
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
        find.text('Benachrichtigungen sind blockiert'),
        findsOneWidget,
      );

      spy.notificationsEnabled = true;
      tester.binding.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Benachrichtigungen sind blockiert'),
        findsNothing,
      );
      expect(find.text('Bereit – minutengenau'), findsOneWidget);
    });

    testWidgets('fehlende Exaktalarm-Freigabe zeigt Fallback transparent', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        prefs: {'reminder_enabled': true},
        scheduler: NoOpNotificationScheduler(exactAlarmsEnabled: false),
      );

      expect(find.text('Aktiv – Uhrzeit kann abweichen'), findsOneWidget);
      expect(find.text('Minutengenaue Alarme erlauben'), findsOneWidget);
    });

    testWidgets('Testschaltfläche sendet eine Testbenachrichtigung', (
      tester,
    ) async {
      final spy = await pumpScreen(
        tester,
        prefs: {'reminder_enabled': true},
      );
      await scrollTo(tester, 'reminder_test');

      await tester.tap(find.byKey(const ValueKey('reminder_test')));
      await tester.pumpAndSettle();

      expect(spy.testCalls, 1);
      expect(find.textContaining('Testbenachrichtigung wurde gesendet'),
          findsOneWidget);
    });
  });
}
