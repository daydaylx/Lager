# VALIDATION_MATRIX.md — Mindestprüfungen pro Änderungstyp

Flutter-Pfad: `/home/d/flutter/bin/flutter` (nicht im System-PATH)

---

## Prüfmatrix

| Änderungstyp                     | Minimale Prüfung                          | Erweiterte Prüfung                                             |
| -------------------------------- | ----------------------------------------- | -------------------------------------------------------------- |
| Dart-Datei ändern (UI, Logik)    | `flutter analyze`                         | `flutter test`                                                 |
| Neue Dart-Datei hinzufügen       | `flutter analyze`                         | `flutter test`                                                 |
| `pubspec.yaml` ändern            | `flutter pub get` → `flutter analyze`     | `flutter test`                                                 |
| Enum-Wert hinzufügen             | `flutter analyze`                         | `flutter test` (alle)                                          |
| Enum-Wert umbenennen             | ⛔ **Nicht tun** — bricht Hive-Persistenz | Erst `DECISIONS.md` lesen                                      |
| Model-Feld hinzufügen            | `flutter analyze`                         | `flutter test` (besonders Hive-Tests)                          |
| Hive-Adapter ändern              | `flutter analyze`                         | `flutter test` (passender Hive-Storage-Test)                    |
| `default_activities.dart` ändern | `flutter analyze`                         | `flutter test` (default_activities_test.dart)                  |
| Reminder / Android-Manifest ändern | `flutter analyze` + `flutter test`      | `flutter build apk --debug` + manueller Gerätetest             |
| Layout / Theme / kritischer Screen ändern | `flutter analyze` + `flutter test test/ui_layout_test.dart` | `flutter test` + manueller Gerätetest |
| Golden bewusst aktualisieren       | Änderung visuell prüfen                  | `flutter test test/ui_layout_test.dart --update-goldens`       |
| Phase abschließen                | `flutter analyze` + `flutter test`        | `PROJECT_STATUS.md` + `TASKS.md` + `CURRENT_STATUS.md` updaten |

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
```

---

## Harte Regeln

- `flutter analyze` muss immer **0 Issues** zeigen — kein Merge mit Warnings
- Enum-Werte **nie umbenennen** — sie werden als String-Namen in Hive gespeichert
- ActivityTemplate-IDs in `default_activities.dart` **nie ändern** — Fremdschlüssel in DailyEntry
- Neue Packages: erst `flutter pub get`, dann `flutter analyze`
