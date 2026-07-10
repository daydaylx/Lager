import 'package:berichtsheft_merker/app/bootstrap.dart';
import 'package:berichtsheft_merker/app/theme.dart';
import 'package:berichtsheft_merker/core/constants.dart';
import 'package:berichtsheft_merker/core/services/notification_service.dart';
import 'package:berichtsheft_merker/core/storage/in_memory_activity_template_storage.dart';
import 'package:berichtsheft_merker/core/storage/in_memory_daily_entry_storage.dart';
import 'package:berichtsheft_merker/core/storage/default_activity_state_storage.dart';
import 'package:berichtsheft_merker/features/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Bootstrap-Fehler kann ohne Datenlöschung erneut versucht werden',
      (
    tester,
  ) async {
    var attempts = 0;
    Future<BootstrapData> loader() async {
      attempts++;
      if (attempts == 1) throw StateError('Lokaler Lesefehler');
      return BootstrapData(
        dailyEntryStorage: InMemoryDailyEntryStorage(),
        templateStorage: InMemoryActivityTemplateStorage(),
        defaultActivityStateStorage: const DefaultActivityStateStorage(),
        profile: (
          name: null,
          company: null,
          occupation: null,
          trainingYear: null,
          onboardingCompleted: false,
        ),
        themePreset: ThemePreset.lagerTeal,
      );
    }

    await tester.pumpWidget(
      AppBootstrap(
        loader: loader,
        notificationScheduler: NoOpNotificationScheduler(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('App-Daten nicht verfügbar'), findsOneWidget);
    expect(find.byKey(const ValueKey('retry_bootstrap')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('retry_bootstrap')));
    await tester.pumpAndSettle();

    expect(attempts, 2);
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });

  testWidgets('ungültige Beruf-Jahr-Kombination öffnet Onboarding', (
    tester,
  ) async {
    Future<BootstrapData> loader() async {
      return BootstrapData(
        dailyEntryStorage: InMemoryDailyEntryStorage(),
        templateStorage: InMemoryActivityTemplateStorage(),
        defaultActivityStateStorage: const DefaultActivityStateStorage(),
        profile: (
          name: null,
          company: null,
          occupation: TrainingOccupationValues.fachlagerist,
          trainingYear: 3,
          onboardingCompleted: true,
        ),
        themePreset: ThemePreset.lagerTeal,
      );
    }

    await tester.pumpWidget(
      AppBootstrap(
        loader: loader,
        notificationScheduler: NoOpNotificationScheduler(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);
  });
}
