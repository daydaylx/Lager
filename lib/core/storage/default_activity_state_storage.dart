import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

/// Persistiert die Aktiv/Inaktiv-Auswahl des Nutzers für Standardtätigkeiten.
///
/// Standardtätigkeiten tragen in [defaultActivities] eine Werksvorgabe
/// (`isActive`). Nutzer können jede Standardtätigkeit im Vorlagen-Screen
/// aktivieren oder deaktivieren; Abweichungen von der Werksvorgabe werden hier
/// als `Map<String, bool>` gespeichert (JSON in SharedPreferences). Fehlt ein
/// Eintrag, gilt die Werksvorgabe.
///
/// Persistenz entspricht dem Muster von [ProfileStorage]/[ReminderStorage]
/// (SharedPreferences, testbar via `SharedPreferences.setMockInitialValues`).
class DefaultActivityStateStorage {
  const DefaultActivityStateStorage();

  Future<Map<String, bool>> loadOverrides() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(PreferenceKeys.defaultActivityOverrides);
    if (raw == null || raw.isEmpty) return <String, bool>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return <String, bool>{};
      return {
        for (final entry in decoded.entries)
          if (entry.key is String && entry.value is bool)
            entry.key as String: entry.value as bool,
      };
    } catch (_) {
      return <String, bool>{};
    }
  }

  Future<void> setActive(String id, bool active) async {
    final overrides = await loadOverrides();
    overrides[id] = active;
    await _save(overrides);
  }

  Future<void> clearAll() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(PreferenceKeys.defaultActivityOverrides);
  }

  Future<void> _save(Map<String, bool> overrides) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      PreferenceKeys.defaultActivityOverrides,
      jsonEncode(overrides),
    );
  }
}
