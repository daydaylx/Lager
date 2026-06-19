import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:berichtsheft_merker/app/app.dart';
import 'package:berichtsheft_merker/core/constants.dart';
import 'package:berichtsheft_merker/core/models/reminder_settings.dart';
import 'package:berichtsheft_merker/core/services/notification_service.dart';
import 'package:berichtsheft_merker/core/storage/in_memory_activity_template_storage.dart';
import 'package:berichtsheft_merker/core/storage/in_memory_daily_entry_storage.dart';
import 'package:berichtsheft_merker/features/onboarding/onboarding_screen.dart';

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

class DelayedInitialNotificationScheduler implements NotificationScheduler {
  final Completer<String?> initialPayload = Completer<String?>();

  @override
  Future<String?> initialize(void Function(String?) onTap) {
    return initialPayload.future;
  }

  @override
  void clearOnTap() {}

  @override
  Future<bool> areNotificationsEnabled() async => true;

  @override
  Future<void> cancelAll() async {}

  @override
  Future<NotificationScheduleResult> schedule(ReminderSettings settings) async {
    return settings.enabled
        ? NotificationScheduleResult.scheduled
        : NotificationScheduleResult.disabled;
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Erststart zeigt das Onboarding', (WidgetTester tester) async {
    await tester.pumpWidget(
      BerichtsheftApp(
        dailyEntryStorage: InMemoryDailyEntryStorage(),
        templateStorage: InMemoryActivityTemplateStorage(),
        initialOnboardingCompleted: false,
      ),
    );

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Jeden Tag kurz festhalten.'), findsOneWidget);
    expect(find.text('Profil einrichten'), findsOneWidget);
    expect(find.byType(MainShell), findsNothing);

    final continueButton = tester.widget<FilledButton>(
      find.byKey(const ValueKey('onboarding_continue')),
    );
    expect(continueButton.onPressed, isNotNull);
  });

  testWidgets('Onboarding speichert vollständiges Profil und öffnet die App', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      BerichtsheftApp(
        dailyEntryStorage: InMemoryDailyEntryStorage(),
        templateStorage: InMemoryActivityTemplateStorage(),
        initialOnboardingCompleted: false,
      ),
    );

    await tester.tap(find.byKey(const ValueKey('onboarding_continue')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('profile_name_field')),
      '  Lara Lager  ',
    );
    await tester.enterText(
      find.byKey(const ValueKey('profile_company_field')),
      '  Musterlager GmbH  ',
    );
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tapVisible(
      tester,
      find.byKey(
        const ValueKey(TrainingOccupationValues.fachkraftLagerlogistik),
      ),
    );
    await tapVisible(
      tester,
      find.byKey(const ValueKey('training_year_3')),
    );
    await tapVisible(
      tester,
      find.byKey(const ValueKey('profile_submit_button')),
    );

    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getBool(PreferenceKeys.onboardingCompleted),
      isTrue,
    );
    expect(preferences.getString(PreferenceKeys.profileName), 'Lara Lager');
    expect(
      preferences.getString(PreferenceKeys.profileCompany),
      'Musterlager GmbH',
    );
    expect(
      preferences.getString(PreferenceKeys.trainingOccupation),
      TrainingOccupationValues.fachkraftLagerlogistik,
    );
    expect(preferences.getInt(PreferenceKeys.trainingYear), 3);
    expect(find.byType(MainShell), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
  });

  testWidgets('Vorhandenes Phase-1-Profil wird im Onboarding vorausgefüllt', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      BerichtsheftApp(
        dailyEntryStorage: InMemoryDailyEntryStorage(),
        templateStorage: InMemoryActivityTemplateStorage(),
        initialOnboardingCompleted: false,
        initialName: 'Lara Lager',
        initialOccupation: TrainingOccupationValues.fachlagerist,
      ),
    );

    await tester.tap(find.byKey(const ValueKey('onboarding_continue')));
    await tester.pumpAndSettle();
    final nameField = tester.widget<TextField>(
      find.byKey(const ValueKey('profile_name_field')),
    );
    expect(nameField.controller?.text, 'Lara Lager');
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.byType(MainShell), findsNothing);
  });

  testWidgets('Fachlagerist-Profil erlaubt nur erstes und zweites Jahr', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      BerichtsheftApp(
        dailyEntryStorage: InMemoryDailyEntryStorage(),
        templateStorage: InMemoryActivityTemplateStorage(),
        initialOnboardingCompleted: false,
      ),
    );

    await tester.tap(find.byKey(const ValueKey('onboarding_continue')));
    await tester.pumpAndSettle();
    await tapVisible(
      tester,
      find.byKey(const ValueKey(TrainingOccupationValues.fachlagerist)),
    );

    expect(find.byKey(const ValueKey('training_year_1')), findsOneWidget);
    expect(find.byKey(const ValueKey('training_year_2')), findsOneWidget);
    expect(find.byKey(const ValueKey('training_year_3')), findsNothing);
  });

  testWidgets('ungültiges altes Ausbildungsjahr muss korrigiert werden', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      BerichtsheftApp(
        dailyEntryStorage: InMemoryDailyEntryStorage(),
        templateStorage: InMemoryActivityTemplateStorage(),
        initialOnboardingCompleted: false,
        initialOccupation: TrainingOccupationValues.fachlagerist,
        initialTrainingYear: 3,
      ),
    );

    await tester.tap(find.byKey(const ValueKey('onboarding_continue')));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('passt nicht zu diesem Beruf'),
      findsOneWidget,
    );
    var submitButton = tester.widget<FilledButton>(
      find.byKey(const ValueKey('profile_submit_button')),
    );
    expect(submitButton.onPressed, isNull);

    await tapVisible(tester, find.byKey(const ValueKey('training_year_2')));
    submitButton = tester.widget<FilledButton>(
      find.byKey(const ValueKey('profile_submit_button')),
    );
    expect(submitButton.onPressed, isNotNull);
  });

  testWidgets('Abgeschlossenes Onboarding wird übersprungen', (
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

    expect(find.byType(MainShell), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.text('Heute'), findsWidgets);
  });

  testWidgets('Profil kann bearbeitet und gespeichert werden', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      PreferenceKeys.onboardingCompleted: true,
      PreferenceKeys.profileName: 'Alter Name',
      PreferenceKeys.profileCompany: 'Alter Betrieb',
      PreferenceKeys.trainingOccupation: TrainingOccupationValues.fachlagerist,
      PreferenceKeys.trainingYear: 1,
    });

    await tester.pumpWidget(
      BerichtsheftApp(
        dailyEntryStorage: InMemoryDailyEntryStorage(),
        templateStorage: InMemoryActivityTemplateStorage(),
        initialOnboardingCompleted: true,
      ),
    );
    await tester.tap(find.text(AppStrings.tabProfile));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('profile_header')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('profile_name_field')),
      'Neuer Name',
    );
    await tester.enterText(
      find.byKey(const ValueKey('profile_company_field')),
      'Neuer Betrieb',
    );
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tapVisible(
      tester,
      find.byKey(
        const ValueKey(TrainingOccupationValues.fachkraftLagerlogistik),
      ),
    );
    await tapVisible(
      tester,
      find.byKey(const ValueKey('training_year_2')),
    );
    await tapVisible(
      tester,
      find.byKey(const ValueKey('profile_submit_button')),
    );

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString(PreferenceKeys.profileName), 'Neuer Name');
    expect(
      preferences.getString(PreferenceKeys.profileCompany),
      'Neuer Betrieb',
    );
    expect(
      preferences.getString(PreferenceKeys.trainingOccupation),
      TrainingOccupationValues.fachkraftLagerlogistik,
    );
    expect(preferences.getInt(PreferenceKeys.trainingYear), 2);
    expect(find.text('Profil gespeichert.'), findsOneWidget);
  });

  testWidgets(
      'Profilbearbeitung: Berufsänderung begrenzt Ausbildungsjahr-Auswahl', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      PreferenceKeys.onboardingCompleted: true,
      PreferenceKeys.trainingOccupation:
          TrainingOccupationValues.fachkraftLagerlogistik,
      PreferenceKeys.trainingYear: 3,
    });

    await tester.pumpWidget(
      BerichtsheftApp(
        dailyEntryStorage: InMemoryDailyEntryStorage(),
        templateStorage: InMemoryActivityTemplateStorage(),
        initialOnboardingCompleted: true,
      ),
    );
    await tester.tap(find.text(AppStrings.tabProfile));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('profile_header')));
    await tester.pumpAndSettle();

    // Zu Fachlagerist wechseln — Jahr 3 war gültig für Fachkraft, nicht für Fachlagerist.
    await tapVisible(
      tester,
      find.byKey(const ValueKey(TrainingOccupationValues.fachlagerist)),
    );

    expect(find.byKey(const ValueKey('training_year_1')), findsOneWidget);
    expect(find.byKey(const ValueKey('training_year_2')), findsOneWidget);
    expect(find.byKey(const ValueKey('training_year_3')), findsNothing);
    expect(
      find.textContaining('passt nicht zu diesem Beruf'),
      findsOneWidget,
    );

    final submitButton = tester.widget<FilledButton>(
      find.byKey(const ValueKey('profile_submit_button')),
    );
    expect(submitButton.onPressed, isNull);

    await tapVisible(tester, find.byKey(const ValueKey('training_year_2')));
    final submitButtonAfter = tester.widget<FilledButton>(
      find.byKey(const ValueKey('profile_submit_button')),
    );
    expect(submitButtonAfter.onPressed, isNotNull);
  });

  testWidgets('Alle vier Tabs sind erreichbar', (WidgetTester tester) async {
    await tester.pumpWidget(
      BerichtsheftApp(
        dailyEntryStorage: InMemoryDailyEntryStorage(),
        templateStorage: InMemoryActivityTemplateStorage(),
        initialOnboardingCompleted: true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Noch offen'), findsOneWidget);

    await tester.tap(find.text(AppStrings.tabWeek));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('week_number')), findsOneWidget);

    await tester.tap(find.text(AppStrings.tabTemplates));
    await tester.pumpAndSettle();
    expect(find.text('Vorlagen'), findsWidgets);
    expect(find.text('Alle'), findsOneWidget);

    await tester.tap(find.text(AppStrings.tabProfile));
    await tester.pumpAndSettle();
    expect(find.text('Dein Profil'), findsOneWidget);
  });

  testWidgets('Notification-Tap öffnet den Heute-Tab', (tester) async {
    final scheduler = NoOpNotificationScheduler();
    await tester.pumpWidget(
      BerichtsheftApp(
        dailyEntryStorage: InMemoryDailyEntryStorage(),
        templateStorage: InMemoryActivityTemplateStorage(),
        initialOnboardingCompleted: true,
        notificationScheduler: scheduler,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.tabProfile));
    await tester.pumpAndSettle();

    scheduler.emitTap('today');
    await tester.pumpAndSettle();

    final navigation = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navigation.selectedIndex, 0);
  });

  testWidgets('Notification-Kaltstart öffnet den Heute-Tab', (tester) async {
    final scheduler = DelayedInitialNotificationScheduler();
    await tester.pumpWidget(
      BerichtsheftApp(
        dailyEntryStorage: InMemoryDailyEntryStorage(),
        templateStorage: InMemoryActivityTemplateStorage(),
        initialOnboardingCompleted: true,
        notificationScheduler: scheduler,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.tabProfile));
    await tester.pumpAndSettle();

    scheduler.initialPayload.complete('today');
    await tester.pumpAndSettle();

    final navigation = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navigation.selectedIndex, 0);
  });

  testWidgets('Notification-Initialisierungsfehler erscheint im Profil', (
    tester,
  ) async {
    final scheduler = NoOpNotificationScheduler(
      initializeError: StateError('Plugin nicht verfügbar'),
    );
    await tester.pumpWidget(
      BerichtsheftApp(
        dailyEntryStorage: InMemoryDailyEntryStorage(),
        templateStorage: InMemoryActivityTemplateStorage(),
        initialOnboardingCompleted: true,
        notificationScheduler: scheduler,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.tabProfile));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.textContaining('Reminder konnten nicht initialisiert werden'),
      200,
      scrollable: find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Reminder konnten nicht initialisiert werden'),
      findsOneWidget,
    );
  });

  testWidgets('Eintrag-fehlt-SnackBar führt zur Heute-Ansicht', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      PreferenceKeys.reminderEnabled: true,
    });
    await tester.pumpWidget(
      BerichtsheftApp(
        dailyEntryStorage: InMemoryDailyEntryStorage(),
        templateStorage: InMemoryActivityTemplateStorage(),
        initialOnboardingCompleted: true,
        notificationScheduler: NoOpNotificationScheduler(),
        clock: () => DateTime(2026, 6, 17),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Eintragen'), findsOneWidget);
    await tester.tap(find.text(AppStrings.tabProfile));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eintragen'));
    await tester.pumpAndSettle();

    final navigation = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navigation.selectedIndex, 0);
  });

  testWidgets('Resume nach Tageswechsel aktualisiert den Heute-Screen', (
    tester,
  ) async {
    var now = DateTime(2026, 6, 12, 23, 50);
    await tester.pumpWidget(
      BerichtsheftApp(
        dailyEntryStorage: InMemoryDailyEntryStorage(),
        templateStorage: InMemoryActivityTemplateStorage(),
        initialOnboardingCompleted: true,
        notificationScheduler: NoOpNotificationScheduler(),
        clock: () => now,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Freitag, 12. Juni'), findsOneWidget);

    now = DateTime(2026, 6, 13, 0, 10);
    tester.binding.handleAppLifecycleStateChanged(
      AppLifecycleState.resumed,
    );
    await tester.pumpAndSettle();

    expect(find.text('Samstag, 13. Juni'), findsOneWidget);
  });

  testWidgets('Alle Daten löschen bricht geplante Erinnerungen ab', (
    WidgetTester tester,
  ) async {
    final scheduler = NoOpNotificationScheduler();
    await tester.pumpWidget(
      BerichtsheftApp(
        dailyEntryStorage: InMemoryDailyEntryStorage(),
        templateStorage: InMemoryActivityTemplateStorage(),
        initialOnboardingCompleted: true,
        notificationScheduler: scheduler,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.tabProfile));
    await tester.pumpAndSettle();
    expect(find.text('Dein Profil'), findsOneWidget);
    final vertical = find.byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('delete_all_data')),
      300,
      scrollable: vertical,
    );
    await tester.drag(vertical, const Offset(0, -160));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('delete_all_data')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alle Daten löschen').last);
    await tester.pumpAndSettle();

    expect(scheduler.cancelAllCalls, 1);
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });
}
