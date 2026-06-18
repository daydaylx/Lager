import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:berichtsheft_merker/app/theme.dart';
import 'package:berichtsheft_merker/core/storage/theme_preset_storage.dart';

void main() {
  group('ThemePresetStorage', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Frisches Laden gibt Default lagerTeal zurück', () async {
      expect(await ThemePresetStorage.load(), ThemePreset.lagerTeal);
    });

    test('Roundtrip: save und load für alle Presets', () async {
      for (final preset in ThemePreset.values) {
        SharedPreferences.setMockInitialValues({});
        await ThemePresetStorage.save(preset);
        expect(await ThemePresetStorage.load(), preset);
      }
    });

    test('Ungültiger String-Wert fällt auf lagerTeal zurück', () async {
      SharedPreferences.setMockInitialValues({'theme_preset': 'gibtEsNicht'});
      expect(await ThemePresetStorage.load(), ThemePreset.lagerTeal);
    });

    test('Leerer String-Wert fällt auf lagerTeal zurück', () async {
      SharedPreferences.setMockInitialValues({'theme_preset': ''});
      expect(await ThemePresetStorage.load(), ThemePreset.lagerTeal);
    });

    test('save() schreibt den Preset-Namen unter theme_preset', () async {
      await ThemePresetStorage.save(ThemePreset.nachtGruen);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_preset'), 'nachtGruen');
    });
  });
}
