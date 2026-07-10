import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:berichtsheft_merker/app/theme.dart';

void main() {
  group('buildThemeForPreset', () {
    for (final preset in ThemePreset.values) {
      test('liefert gültiges M3-Theme für ${preset.name}', () {
        final theme = buildThemeForPreset(preset);

        expect(theme.useMaterial3, isTrue,
            reason: '${preset.name}: Material 3 erwartet');
        expect(theme.colorScheme.brightness, equals(preset.brightness),
            reason:
                '${preset.name}: Brightness sollte ${preset.brightness} sein');
        expect(theme.colorScheme.primary, isNotNull,
            reason: '${preset.name}: primary darf nicht null sein');
        expect(theme.scaffoldBackgroundColor.a, greaterThan(0),
            reason:
                '${preset.name}: Scaffold-Hintergrund darf nicht transparent sein');
      });
    }

    test('nur "hell" ist Light, alle anderen Presets sind Dark', () {
      for (final preset in ThemePreset.values) {
        final expected =
            preset == ThemePreset.hell ? Brightness.light : Brightness.dark;
        expect(buildThemeForPreset(preset).colorScheme.brightness,
            equals(expected),
            reason: '${preset.name} sollte $expected sein');
      }
    });
  });

  group('ThemePreset.surfaceColor', () {
    test('ist für jedes Preset deckend (nicht transparent)', () {
      for (final preset in ThemePreset.values) {
        expect(preset.surfaceColor.a, equals(1.0),
            reason: '${preset.name}: surfaceColor muss deckend sein');
      }
    });

    test(
        'verhält sich zur seedColor konsistent (beide für jedes Preset gesetzt)',
        () {
      for (final preset in ThemePreset.values) {
        expect(preset.seedColor.a, equals(1.0),
            reason: '${preset.name}: seedColor muss deckend sein');
        expect(preset.surfaceColor, isNot(equals(preset.seedColor)),
            reason:
                '${preset.name}: surfaceColor sollte sich von seedColor unterscheiden');
      }
    });
  });
}
