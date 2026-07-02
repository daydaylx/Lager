# VALIDATION_MATRIX.md — Mindestprüfungen pro Änderungstyp

Flutter-Pfad: `/home/d/flutter/bin/flutter` (nicht im System-PATH)

---

## Prüfmatrix

| Änderungstyp                              | Minimale Prüfung                                                         | Erweiterte Prüfung                                                                                                                                                                                |
| ----------------------------------------- | ------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Dart-Datei ändern (UI, Logik)             | `flutter analyze`                                                        | `flutter test`                                                                                                                                                                                    |
| Neue Dart-Datei hinzufügen                | `flutter analyze`                                                        | `flutter test`                                                                                                                                                                                    |
| `pubspec.yaml` ändern                     | `flutter pub get` → `flutter analyze`                                    | `flutter test`                                                                                                                                                                                    |
| Enum-Wert hinzufügen                      | `flutter analyze`                                                        | `flutter test` (alle)                                                                                                                                                                             |
| Enum-Wert umbenennen                      | ⛔ **Nicht tun** — bricht Hive-Persistenz                                | Erst `DECISIONS.md` lesen                                                                                                                                                                         |
| Model-Feld hinzufügen                     | `flutter analyze`                                                        | `flutter test` (besonders Hive-Tests)                                                                                                                                                             |
| Hive-Adapter ändern                       | `flutter analyze`                                                        | `flutter test` (passender Hive-Storage-Test)                                                                                                                                                      |
| `default_activities.dart` ändern          | `flutter analyze`                                                        | `flutter test` (default_activities_test.dart)                                                                                                                                                     |
| Reminder / Android-Manifest ändern        | `flutter analyze` + `flutter test`                                       | `flutter build apk --debug` + manueller Gerätetest                                                                                                                                                |
| Application ID / Signing / Backup ändern  | `flutter analyze` + `flutter test`                                       | `flutter build apk --debug` + Manifest prüfen + signierten Release-Build lokal prüfen                                                                                                             |
| Layout / Theme / kritischer Screen ändern | `flutter analyze` + `flutter test test/ui_layout_test.dart`              | `flutter test` + manueller Gerätetest                                                                                                                                                             |
| ThemePreset / Theme-Persistenz ändern     | `flutter analyze` + `flutter test`                                       | App-Neustart und Datenlöschung manuell prüfen                                                                                                                                                     |
| Berichtsgenerator ändern                  | `flutter analyze` + `flutter test test/daily_report_generator_test.dart` | `flutter test`                                                                                                                                                                                    |
| Export-Funktion (manuell)                 | `flutter analyze` + manueller Gerätetest                                 | Eintrag erstellen → Profil-Tab → „Daten exportieren" tippen → Share-Sheet erscheint → „In Downloads speichern" wählen → Datei-App öffnen → `berichtsheft_export_*.json` vorhanden → Inhalt lesbar |
| Golden bewusst aktualisieren              | Änderung visuell prüfen                                                  | `flutter test test/ui_layout_test.dart --update-goldens`                                                                                                                                          |
| Nur Dokumentation ändern                  | Links, Pfade und Aussagen gegen ausführbare Quellen prüfen               | bei Befehlsänderungen betroffene Befehle ausführen                                                                                                                                                |
| Phase abschließen                         | `flutter analyze` + `flutter test`                                       | `PROJECT_STATUS.md` + `TASKS.md` + `docs/CURRENT_STATUS.md` updaten                                                                                                                               |
| Repo-Hygiene (Imports, Secrets, Backup)   | `bash scripts/check_repo_hygiene.sh`                                     | `flutter test test/android_backup_test.dart` + `test/persistence_stability_test.dart`                                                                                                             |

---

## CI

`.github/workflows/flutter-ci.yml` (Job `flutter-checks`) läuft bei jedem Push
auf `main` und jedem Pull Request gegen `main` und prüft verpflichtend:

```bash
flutter pub get
bash scripts/check_repo_hygiene.sh   # relative Imports, keine Secrets, Backup aus
flutter analyze
flutter test
flutter build apk --debug
```

Der Debug-APK-Build wird als Artefakt (`debug-apk`) hochgeladen. `main` ist
per Branch Protection so abgesichert, dass diese Status-Prüfung grün sein
muss, bevor gemergt werden darf.

---

## Befehle

```bash
# Pflicht nach jeder Dart-Änderung
/home/d/flutter/bin/flutter analyze

# Nach Feature-Implementierung
/home/d/flutter/bin/flutter test

# Nach pubspec.yaml-Änderung (zuerst)
/home/d/flutter/bin/flutter pub get

# Einzelnen Test ausführen
/home/d/flutter/bin/flutter test test/hive_daily_entry_storage_test.dart
/home/d/flutter/bin/flutter test test/hive_activity_template_storage_test.dart
/home/d/flutter/bin/flutter test test/ui_layout_test.dart

# App starten (Gerät/Emulator muss verbunden sein)
/home/d/flutter/bin/flutter run

# Android-Konfiguration und Debug-Artefakt prüfen
/home/d/flutter/bin/flutter build apk --debug

# Ohne android/key.properties: bewusst unsignierten Release-Fallback prüfen
/home/d/flutter/bin/flutter build apk --release

# Mit android/key.properties: signierten Release-Build lokal prüfen
/home/d/flutter/bin/flutter build apk --release
```

---

## Harte Regeln

- `flutter analyze` muss immer **0 Issues** zeigen — kein Merge mit Warnings
- Enum-Werte **nie umbenennen** — sie werden als String-Namen in Hive gespeichert
- ActivityTemplate-IDs in `default_activities.dart` **nie ändern** — Fremdschlüssel in DailyEntry
- Neue Packages: erst `flutter pub get`, dann `flutter analyze`
- Release-Builds nie mit Debug-Schlüssel signieren; Keystores und Passwörter nie committen
- Android-Backup und Gerätetransfer für lokale Daten nicht ohne explizite Entscheidung aktivieren
- Flutter 3.32.1, Dart 3.8.1, AGP 8.7.3, Kotlin 2.1.0, Gradle 8.12 und
  NDK 27.0.12077973 nicht nebenbei aktualisieren
