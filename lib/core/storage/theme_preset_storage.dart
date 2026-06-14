import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme.dart';

class ThemePresetStorage {
  static const _key = 'theme_preset';

  static Future<ThemePreset> load() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_key);
    if (name == null) return ThemePreset.lagerTeal;
    return ThemePreset.values.firstWhere(
      (p) => p.name == name,
      orElse: () => ThemePreset.lagerTeal,
    );
  }

  static Future<void> save(ThemePreset preset) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, preset.name);
  }
}
