# AGENT_CONTEXT_PACKS.md — Aufgabenbezogene Dateilisten

Format: Aufgabe → Dateien lesen → Risiken → Mindestchecks

Context Packs definieren den **Mindestkontext**. Direkte Abhängigkeiten, Aufrufer,
ausführbare Konfigurationen und relevante Tests zusätzlich lesen, wenn die
Änderung sie berührt.

---

## Pack 1: Vorlagenverwaltung und Tagesauswahl

**Aufgabe:** Vorlagen verwalten oder ihre Nutzung im Heute-/Wochen-Screen ändern.

### Dateien lesen (in dieser Reihenfolge)

| Datei                                          | Warum                                                    |
| ---------------------------------------------- | -------------------------------------------------------- |
| `TASKS.md`                                     | Genaue Anforderungen Phase 6                             |
| `lib/features/templates/templates_screen.dart` | Eigene Tätigkeiten verwalten                             |
| `lib/core/data/default_activities.dart`        | 132 stabile IDs, 123 auswählbare Tätigkeiten             |
| `lib/core/data/activity_subcategories.dart`    | UI-Untergruppen für vordefinierte Tätigkeiten            |
| `lib/core/models/activity_template.dart`       | ActivityTemplate-Modell                                  |
| `lib/core/enums/activity_category.dart`        | ActivityCategory-Enum (10 Kategorien)                    |
| `lib/features/today/today_screen.dart`         | Heute-Orchestrierung, Speichern und Screen-State         |
| `lib/features/today/activity_picker_model.dart` | Suche, Gruppen, Quick Access und historische IDs         |
| `lib/features/today/activity_recommender.dart` | Häufig genutzt und Ausbildungsjahr-Empfehlungen          |
| `lib/features/today/widgets/activity_picker_section.dart` | Aktivitätsauswahl-UI mit bestehenden Keys      |
| `docs/UI_UX_SPEC.md`                           | Abschnitt "18. Vorlagen-Screen" (Zeile ~447)             |
| `docs/DATA_MODEL.md`                           | ActivityTemplate-Persistenz-Konzept                      |

### Risiken

- **Stabile IDs:** ActivityTemplate-IDs in `default_activities.dart` sind Fremdschlüssel in gespeicherten DailyEntry-Objekten. Nie ändern, nie löschen. Fachlich aussortierte IDs bleiben in `retiredDefaultActivityIds` nur zur historischen Auflösung erhalten.
- **Keine neuen Packages:** Vorlagenverwaltung braucht kein neues Package. Nur vorhandene Hive CE / SharedPreferences nutzen.
- **setState reicht:** Kein State-Management-Framework einführen.
- **Kategorie-Filter als Chips:** Nicht als Dropdown — sieh UI_UX_SPEC.md.
- **Eigene Tätigkeiten:** Stabile IDs nie ändern. Deaktivieren statt hart löschen, damit historische Einträge lesbar bleiben.
- **Duplikate:** Eigene Tätigkeiten gegen normalisierte Standard- und eigene Titel prüfen.
- **Katalog-Synchronisierung:** Änderungen müssen Heute- und Wochen-Screen ohne App-Neustart erreichen.

### Mindestchecks nach Änderung

```bash
/home/d/flutter/bin/flutter analyze    # muss 0 Issues zeigen
/home/d/flutter/bin/flutter test
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
| `lib/core/storage/persisted_enum.dart`           | Kontrollierte Parser für persistierte Enum-Namen            |
| `lib/core/storage/hive_daily_entry_storage.dart` | Produktiv-Impl.                                             |
| `test/hive_daily_entry_storage_test.dart`        | Persistenz-Tests                                            |
| `test/hive_activity_template_storage_test.dart`  | Bei ActivityTemplate-/Adapter-Änderungen                    |
| `DECISIONS.md`                                   | Warum Hive CE statt SQLite (nicht erneut diskutieren)       |

### Risiken

- **Hive CE Adapter manuell:** Kein Codegenerator. Bei neuen Feldern `daily_entry_adapter.dart` anpassen.
- **Vorwärtskompatibilität:** Bestehende gespeicherte Daten müssen lesbar bleiben. Neue Felder optional (nullable) oder mit Default.
- **Enum-Namen als String gespeichert:** Enum-Werte werden als String-Name persistiert (nicht als Index). Umbenennungen brechen bestehende Daten.
- **Enum-Reads:** Keine direkten `values.byName(...)` in Adaptern; zentrale Parser verwenden, damit Fehler diagnostizierbar bleiben.

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
| `lib/core/storage/theme_preset_storage.dart`     | Bei Theme-Auswahl oder Persistenz         |
| `lib/shared/widgets/app_ui.dart`                 | Gemeinsame visuelle Bausteine             |
| Relevante Screen-Widgets (für Heute insbesondere `today_flow.dart`, `area_grid.dart`, `activity_picker_section.dart`) | Direkte UI-Abhängigkeiten |
| Relevanter Test (z. B. `today_screen_test.dart`) | Was darf sich nicht ändern                |
| `test/ui_layout_test.dart`                       | Mobile Layout- und Golden-Verträge        |

### Risiken

- **Theme.of(context) in Widgets:** `buildThemeForPreset()` wird nur zentral beim
  Aufbau der App verwendet.
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

| Datei                                                    | Warum                                       |
| -------------------------------------------------------- | ------------------------------------------- |
| `lib/core/services/notification_service.dart`            | Reminder-Plan, Berechtigung und Tap-Routing |
| `lib/core/storage/reminder_storage.dart`                 | Persistierte Reminder-Einstellungen         |
| `lib/features/profile/profile_reminder_controller.dart`  | Laden, Speichern, Berechtigung, Rollback und Edit-Regeln |
| `lib/features/profile/profile_screen.dart`               | Profil-Orchestrierung und Reminder-State    |
| `lib/features/profile/widgets/profile_header.dart`       | Profil-Header (Avatar, Begrüßung, Unterzeile, Tap→Editor) |
| `lib/features/profile/widgets/profile_edit_screen.dart`  | Profil-Bearbeitungsscreen (shared ProfileForm) |
| `lib/features/profile/widgets/profile_theme_section.dart`| Theme-Auswahl als Farbkachel-Grid mit Live-Vorschau |
| `lib/features/profile/widgets/reminder_section.dart`     | Reminder-UI mit stabilen Test-Keys          |
| `lib/app/app.dart`                                       | Lifecycle, Tageswechsel und Tap-Ziel        |
| `android/app/build.gradle.kts`                           | Application ID, NDK und Release-Signierung  |
| `android/app/src/main/AndroidManifest.xml`               | Permissions, Receiver und Backup-Regeln     |
| `android/app/src/main/res/xml/backup_rules.xml`          | Backup-Regeln bis Android 11                |
| `android/app/src/main/res/xml/data_extraction_rules.xml` | Backup und Gerätetransfer ab Android 12     |
| `docs/PRIVACY_CONTEXT.md`                                | Lokale Daten und Backup-No-Go               |
| `docs/QA_REMINDER_CHECKLIST.md`                          | Manueller Android-Nachweis                  |

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

Danach manueller Gerätetest:

- `docs/QA_REMINDER_CHECKLIST.md` — für isolierte Reminder-Prüfung
- `docs/QA_RELEASE_CHECKLIST.md` — für vollständigen Release-QA-Durchlauf

---

## Pack 6: Berichtsvorschlag

**Aufgabe:** Formulierung, Anzeige oder Kopieren des lokalen Tagesberichts ändern.

### Dateien lesen

| Datei                                         | Warum                                                              |
| --------------------------------------------- | ------------------------------------------------------------------ |
| `lib/core/report/daily_report_generator.dart` | Deterministische Textlogik                                         |
| `lib/features/today/today_screen.dart`        | Tageseintrag-Steuerung und Report-Trigger                          |
| `lib/features/today/today_entry_draft.dart`   | DailyEntry-Entwurf für Speichern und Berichtsvorschau              |
| `lib/features/today/widgets/report_card.dart` | Berichtskarten-Widget (ab Phase 16, ersetzt Bottom-Sheet-Vorschau) |
| `lib/features/week/week_screen.dart`          | Bericht in Wochenzusammenfassung                                   |
| `test/daily_report_generator_test.dart`       | Textverträge je Tagtyp und Flag                                    |
| `test/today_screen_test.dart`                 | Heute-Integration                                                  |
| `test/week_screen_test.dart`                  | Wochen-Integration                                                 |

### Risiken

- Keine KI, API oder Netzwerkabhängigkeit einführen.
- Berichtstext ist nur Vorschlag; gespeicherte Einträge nicht verändern.
- Unbekannte historische Tätigkeits-IDs müssen lesbar bleiben.

### Mindestchecks

```bash
/home/d/flutter/bin/flutter analyze
/home/d/flutter/bin/flutter test test/daily_report_generator_test.dart
/home/d/flutter/bin/flutter test
```

---

## Pack 7: Profil, Onboarding und Theme

**Aufgabe:** Ausbildungsprofil, Onboarding, Theme-Auswahl oder deren Persistenz ändern.

### Dateien lesen

| Datei                                        | Warum                                              |
| -------------------------------------------- | -------------------------------------------------- |
| `lib/core/profile_storage.dart`              | Profil- und Onboarding-Persistenz                  |
| `lib/core/constants.dart`                    | Ausbildungsberufe, zulässige Jahre und App-Version |
| `lib/core/storage/theme_preset_storage.dart` | Theme-Persistenz                                   |
| `lib/app/theme.dart`                         | ThemePreset-Vertrag                                |
| `lib/app/bootstrap.dart`                     | Initiales Laden                                    |
| `lib/app/app.dart`                           | App-weite Zustandsübergabe und Reset               |
| `lib/features/profile/profile_screen.dart`   | Profil-Orchestrierung, Export/Delete, Section-Wiring |
| `lib/features/profile/widgets/profile_header.dart`       | Profil-Header (Avatar, Begrüßung, Unterzeile, Tap→Editor) |
| `lib/features/profile/widgets/profile_edit_screen.dart`  | Profil-Bearbeitungsscreen (shared ProfileForm) |
| `lib/features/profile/widgets/profile_theme_section.dart`| Theme-Auswahl als Farbkachel-Grid mit Live-Vorschau |
| `lib/features/profile/widgets/reminder_section.dart`     | Reminder-UI (Toggle, Zeiten, Wochentage, Samsung-Hinweis) |
| Ziel-Screen und relevante Widget-Tests       | UI- und Verhaltensvertrag                          |

### Risiken

- „Alle Daten löschen“ muss Profil, Reminder und Theme zurücksetzen.
- Fachlagerist/in erlaubt nur Ausbildungsjahr 1–2; Fachkraft für Lagerlogistik 1–3.
- Theme-Namen sind persistierte Werte; Umbenennungen brauchen Migration.
- `pubspec.yaml` und `kAppVersion` müssen synchron bleiben; `test/version_consistency_test.dart` prüft das.

### Mindestchecks

```bash
/home/d/flutter/bin/flutter analyze
/home/d/flutter/bin/flutter test
```
