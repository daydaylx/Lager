import 'package:berichtsheft_merker/app/theme.dart';
import 'package:berichtsheft_merker/shared/widgets/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: buildThemeForPreset(ThemePreset.lagerTeal),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('zeigt korrekte Anzahl Punkte und hebt aktiven Schritt hervor',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const AppStepIndicator(currentStep: 2, totalSteps: 4),
    ));

    expect(find.byKey(const ValueKey('app_step_indicator_dot_1')), findsOneWidget);
    expect(find.byKey(const ValueKey('app_step_indicator_dot_2')), findsOneWidget);
    expect(find.byKey(const ValueKey('app_step_indicator_dot_3')), findsOneWidget);
    expect(find.byKey(const ValueKey('app_step_indicator_dot_4')), findsOneWidget);
    expect(find.byKey(const ValueKey('app_step_indicator_dot_5')), findsNothing);
  });

  testWidgets('aktiver Schritt ist breiter als inaktive Punkte', (tester) async {
    await tester.pumpWidget(_wrap(
      const AppStepIndicator(currentStep: 2, totalSteps: 4),
    ));

    final active = tester.getSize(
      find.byKey(const ValueKey('app_step_indicator_dot_2')),
    );
    final inactive = tester.getSize(
      find.byKey(const ValueKey('app_step_indicator_dot_3')),
    );
    expect(active.width, greaterThan(inactive.width));
  });

  testWidgets('Semantics-Label beschreibt Position', (tester) async {
    await tester.pumpWidget(_wrap(
      const AppStepIndicator(currentStep: 3, totalSteps: 4),
    ));
    final semantics = tester.getSemantics(find.byType(AppStepIndicator));
    expect(
      semantics.label,
      anyOf('Schritt 3 von 4', contains('Schritt 3')),
    );
  });

  test('assert: currentStep < 1 wird abgefangen', () {
    expect(
      () => AppStepIndicator(currentStep: 0, totalSteps: 4),
      throwsA(isA<AssertionError>()),
    );
  });

  test('assert: totalSteps < 1 wird abgefangen', () {
    expect(
      () => AppStepIndicator(currentStep: 1, totalSteps: 0),
      throwsA(isA<AssertionError>()),
    );
  });

  test('assert: currentStep > totalSteps wird abgefangen', () {
    expect(
      () => AppStepIndicator(currentStep: 5, totalSteps: 4),
      throwsA(isA<AssertionError>()),
    );
  });
}
