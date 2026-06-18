import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:berichtsheft_merker/app/theme.dart';
import 'package:berichtsheft_merker/core/storage/in_memory_activity_template_storage.dart';
import 'package:berichtsheft_merker/core/storage/in_memory_daily_entry_storage.dart';
import 'package:berichtsheft_merker/features/profile/profile_screen.dart';

/// Oberflächen-Tests für das Farbtheme-Kachel-Grid im Profil-Screen.
///
/// Großer Viewport, damit die scrollbare Profil-Liste vollständig gebaut wird
/// (ein ListView rendert sonst nur den sichtbaren Ausschnitt und lässt die
/// außerhalb liegenden Kacheln weg).
const _surfaceSize = Size(400, 3200);

Widget _pumpProfile() => MaterialApp(
      theme: buildThemeForPreset(ThemePreset.lagerTeal),
      home: ProfileScreen(
        dailyEntryStorage: InMemoryDailyEntryStorage(),
        templateStorage: InMemoryActivityTemplateStorage(),
        onDataCleared: () async {},
      ),
    );

void main() {
  testWidgets('für jedes ThemePreset wird genau eine Farbkachel gerendert',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(_surfaceSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_pumpProfile());
    await tester.pumpAndSettle();

    for (final preset in ThemePreset.values) {
      expect(
        find.byKey(ValueKey('theme_${preset.name}')),
        findsOneWidget,
        reason: '${preset.name}-Kachel sollte genau einmal gerendert werden',
      );
    }
  });

  testWidgets('genau das voreingestellte Theme ist markiert', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(_surfaceSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_pumpProfile());
    await tester.pumpAndSettle();

    // Default-Preset lagerTeal => genau eine Markierung (Häkchen-Icon).
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });
}
