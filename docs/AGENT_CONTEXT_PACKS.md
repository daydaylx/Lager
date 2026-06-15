# AGENT_CONTEXT_PACKS.md — Aufgabenbezogene Dateilisten

Format: Aufgabe → Dateien lesen → Risiken → Mindestchecks

---

## Pack 1: Vorlagenverwaltung und Tagesauswahl

**Aufgabe:** Vorlagen verwalten oder ihre Nutzung im Heute-/Wochen-Screen ändern.

### Dateien lesen (in dieser Reihenfolge)

| Datei                                          | Warum                                                   |
| ---------------------------------------------- | ------------------------------------------------------- |
| `TASKS.md`                                     | Genaue Anforderungen Phase 6                            |
| `lib/features/templates/templates_screen.dart` | Eigene Tätigkeiten verwalten                             |
| `lib/core/data/default_activities.dart`        | 87 Tätigkeiten mit stabilen IDs und Kategorien          |
| `lib/core/models/activity_template.dart`       | ActivityTemplate-Modell                                 |
| `lib/core/enums/activity_category.dart`        | ActivityCategory-Enum (10 Kategorien)                   |
| `lib/features/today/today_screen.dart`         | Wie Tätigkeiten heute gewählt werden (Pattern-Referenz) |
| `docs/UI_UX_SPEC.md`                           | Abschnitt "18. Vorlagen-Screen" (Zeile ~447)            |
| `docs/DATA_MODEL.md`                           | ActivityTemplate-Persistenz-Konzept                     |

### Risiken

- **Stabile IDs:** ActivityTemplate-IDs in `default_activities.dart` sind Fremdschlüssel in gespeicherten DailyEntry-Objekten. Nie ändern, nie löschen.
- **Keine neuen Packages:** Vorlagenverwaltung braucht kein neues Package. Nur vorhandene Hive CE / SharedPreferences nutzen.
- **setState reicht:** Kein State-Management-Framework einführen.
- **Kategorie-Filter als Chips:** Nicht als Dropdown — sieh UI_UX_SPEC.md.
- **Eigene Tätigkeiten:** Stabile IDs nie ändern. Deaktivieren statt hart löschen, damit historische Einträge lesbar bleiben.
- **Katalog-Synchronisierung:** Änderungen müssen Heute- und Wochen-Screen ohne App-Neustart erreichen.

### Mindestchecks nach Änderung

```bash
/home/d/flutter/bin/flutter analyze    # muss 0 Issues zeigen
/home/d/flutter/bin/flutter test       # muss alle 28+ Tests bestehen
```

---

## Pack 2: Datenmodell-Änderung

**Aufgabe:** Enum oder Model ändern (z. B. neuer DayType, neues Feld in DailyEntry).

### Dateien lesen

| Datei                                            | Warum                                                       |
| ------------------------------------------------ | ----------------------------------------------------------- |
| `docs/DATA_MODEL.md`                             | Vollständige Referenz, Persistenz-Strategie                 |
| `lib/core/models/daily_entry.dart`               | Model-Definition                                            |
| `lib/core/storage/daily_entry_adapter.dart`      | Hive-CE-Adapter — muss bei Felderweiterung angepasst werden |
| `lib/core/storage/hive_daily_entry_storage.dart` | Produktiv-Impl.                                             |
| `test/hive_daily_entry_storage_test.dart`        | Persistenz-Tests                                            |
| `test/hive_activity_template_storage_test.dart`  | Bei ActivityTemplate-/Adapter-Änderungen                    |
| `DECISIONS.md`                                   | Warum Hive CE statt SQLite (nicht erneut diskutieren)       |

### Risiken

- **Hive CE Adapter manuell:** Kein Codegenerator. Bei neuen Feldern `daily_entry_adapter.dart` anpassen.
- **Vorwärtskompatibilität:** Bestehende gespeicherte Daten müssen lesbar bleiben. Neue Felder optional (nullable) oder mit Default.
- **Enum-Namen als String gespeichert:** Enum-Werte werden als String-Name persistiert (nicht als Index). Umbenennungen brechen bestehende Daten.

### Mindestchecks

```bash
/home/d/flutter/bin/flutter analyze
/home/d/flutter/bin/flutter test      # besonders hive_daily_entry_storage_test.dart
```

---

## Pack 3: UI-Änderung (bestehender Screen)

**Aufgabe:** Einen bestehenden Screen anpassen (Layout, Widget, Text).

### Dateien lesen

| Datei                                            | Warum                                     |
| ------------------------------------------------ | ----------------------------------------- |
| `docs/UI_UX_SPEC.md`                             | Design-Vorgaben für den jeweiligen Screen |
| Ziel-Screen (z. B. `today_screen.dart`)          | Bestehendes Layout                        |
| `lib/app/theme.dart`                             | Farben, Theme-Tokens                      |
| `lib/shared/widgets/app_ui.dart`                 | Gemeinsame visuelle Bausteine             |
| Relevanter Test (z. B. `today_screen_test.dart`) | Was darf sich nicht ändern                |
| `test/ui_layout_test.dart`                       | Mobile Layout- und Golden-Verträge        |

### Risiken

- **Theme.of(context) nicht buildAppTheme()** — nie direkt aufrufen.
- **Große Touchflächen** — minimum 48×48dp, keine kleinen Buttons.
- **Bottom Navigation bleibt:** 4 Tabs, keine Änderung ohne expliziten Auftrag.
- **Keine Web-App-Elemente:** Kein AppBar mit Zurück-Button als Hauptnavigation.

### Mindestchecks

```bash
/home/d/flutter/bin/flutter analyze
/home/d/flutter/bin/flutter test test/ui_layout_test.dart
```

Manueller Test auf Gerät/Emulator wenn Layout-kritisch.

---

## Pack 4: Phase abschließen

**Aufgabe:** Alle Aufgaben einer Phase sind erledigt, Dokumentation updaten.

### Dateien updaten

| Datei                    | Was ändern                                             |
| ------------------------ | ------------------------------------------------------ |
| `TASKS.md`               | Phase als ✅ markieren                                 |
| `PROJECT_STATUS.md`      | Neue Elemente in "Was existiert", Checks aktualisieren |
| `docs/CURRENT_STATUS.md` | Aktive Phase und nächsten Schritt updaten              |

### Mindestchecks

```bash
/home/d/flutter/bin/flutter analyze
/home/d/flutter/bin/flutter test
```

---

## Pack 5: Reminder, Lifecycle und Android-Release

**Aufgabe:** Reminder-Planung, App-Resume, Android-Manifest, Backup oder Release-Build ändern.

### Dateien lesen

| Datei                                           | Warum                                      |
| ----------------------------------------------- | ------------------------------------------ |
| `lib/core/services/notification_service.dart`   | Reminder-Plan, Berechtigung und Tap-Routing |
| `lib/core/storage/reminder_storage.dart`        | Persistierte Reminder-Einstellungen         |
| `lib/features/profile/profile_screen.dart`      | Reminder-UI und Rollback                    |
| `lib/app/app.dart`                              | Lifecycle, Tageswechsel und Tap-Ziel        |
| `android/app/build.gradle.kts`                  | Application ID, NDK und Release-Signierung  |
| `android/app/src/main/AndroidManifest.xml`      | Permissions, Receiver und Backup-Regeln     |
| `docs/PRIVACY_CONTEXT.md`                       | Lokale Daten und Backup-No-Go               |
| `docs/QA_REMINDER_CHECKLIST.md`                 | Manueller Android-Nachweis                  |

### Risiken

- Notification-IDs müssen für Primär-, Folge- und Wochenhinweise eindeutig bleiben.
- Permission-Verweigerung oder Speicherfehler dürfen den bestehenden Zeitplan nicht unbemerkt zerstören.
- Offene Heute-Eingaben dürfen beim Tageswechsel nicht dem neuen Datum zugeordnet werden.
- Release-Builds dürfen nie mit Debug-Schlüssel signiert werden.
- Keystore, `key.properties` und Passwörter dürfen nie committet werden.

### Mindestchecks

```bash
/home/d/flutter/bin/flutter analyze
/home/d/flutter/bin/flutter test
/home/d/flutter/bin/flutter build apk --debug
```

Danach manueller Gerätetest nach `docs/QA_REMINDER_CHECKLIST.md`.
