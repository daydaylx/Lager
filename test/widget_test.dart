import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:berichtsheft_merker/app/app.dart';
import 'package:berichtsheft_merker/core/constants.dart';
import 'package:berichtsheft_merker/core/storage/in_memory_daily_entry_storage.dart';
import 'package:berichtsheft_merker/features/onboarding/onboarding_screen.dart';

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Erststart zeigt das Onboarding', (WidgetTester tester) async {
    await tester.pumpWidget(
      BerichtsheftApp(
        dailyEntryStorage: InMemoryDailyEntryStorage(),
        initialOnboardingCompleted: false,
      ),
    );

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Willkommen'), findsOneWidget);
    expect(find.text('Loslegen'), findsOneWidget);
    expect(find.byType(MainShell), findsNothing);

    final submitButton = tester.widget<FilledButton>(
      find.byKey(const ValueKey('profile_submit_button')),
    );
    expect(submitButton.onPressed, isNull);
  });

  testWidgets('Onboarding speichert vollständiges Profil und öffnet die App', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      BerichtsheftApp(
        dailyEntryStorage: InMemoryDailyEntryStorage(),
        initialOnboardingCompleted: false,
      ),
    );

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
        initialOnboardingCompleted: false,
        initialName: 'Lara Lager',
        initialOccupation: TrainingOccupationValues.fachlagerist,
      ),
    );

    final nameField = tester.widget<TextField>(
      find.byKey(const ValueKey('profile_name_field')),
    );
    expect(nameField.controller?.text, 'Lara Lager');
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.byType(MainShell), findsNothing);
  });

  testWidgets('Abgeschlossenes Onboarding wird übersprungen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      BerichtsheftApp(
        dailyEntryStorage: InMemoryDailyEntryStorage(),
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
        initialOnboardingCompleted: true,
      ),
    );
    await tester.tap(find.text(AppStrings.tabProfile));
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

  testWidgets('Alle vier Tabs sind erreichbar', (WidgetTester tester) async {
    await tester.pumpWidget(
      BerichtsheftApp(
        dailyEntryStorage: InMemoryDailyEntryStorage(),
        initialOnboardingCompleted: true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Noch nicht gespeichert'), findsOneWidget);

    await tester.tap(find.text(AppStrings.tabWeek));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('week_number')), findsOneWidget);

    await tester.tap(find.text(AppStrings.tabTemplates));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Vordefinierte Tätigkeiten für deinen Ausbildungsbereich.\n'
        'Eigene Vorlagen hinzufügen.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text(AppStrings.tabProfile));
    await tester.pumpAndSettle();
    expect(find.text('Profil speichern'), findsOneWidget);
  });
}
