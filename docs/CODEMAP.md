# CODEMAP.md — Schnellreferenz Projektstruktur

Flutter Android-App „Berichtsheft-Merker Lagerlogistik". Aktueller Arbeitsstand:
`docs/CURRENT_STATUS.md`.

---

## Einstiegspunkte

```
lib/main.dart                → runApp mit AppBootstrap
lib/app/bootstrap.dart       → lokale Speicher und Theme öffnen, Startfehler + Retry
lib/app/app.dart             → MaterialApp, ThemePreset, MainShell, IndexedStack, NavigationBar
lib/app/theme.dart           → ThemePreset + buildThemeForPreset(), M3-Komponententheme
```

---

## Features (lib/features/)

| Datei                               | Status    | Beschreibung                                                  |
| ----------------------------------- | --------- | ------------------------------------------------------------- |
| `onboarding/onboarding_screen.dart` | ✅ fertig | Zweistufiger Erststart                                        |
| `today/today_screen.dart`           | ✅ fertig | Tageseintrag, Berichtsvorschau und Eingabeverlustschutz       |
| `week/week_screen.dart`             | ✅ fertig | Wochenliste, Zusammenfassung und kopierbare Tagesberichte     |
| `templates/templates_screen.dart`   | ✅ fertig | Suche, hinzufügen, filtern, deaktivieren/reaktivieren         |
| `profile/profile_screen.dart`       | ✅ fertig | Profil, Erinnerungen, Theme-Auswahl und Datenverwaltung       |

---

## Core (lib/core/)

### Enums

| Datei                          | Inhalt                                                                      |
| ------------------------------ | --------------------------------------------------------------------------- |
| `enums/day_type.dart`          | `DayType` — Betrieb, Berufsschule, Frei, Urlaub, Krank, Feiertag, Sonstiges |
| `enums/training_area.dart`     | `TrainingArea` — 8 Lagerbereiche                                            |
| `enums/activity_category.dart` | `ActivityCategory` — 10 Kategorien                                          |
| `enums/special_flag.dart`      | `SpecialFlag` — 7 Lern-Flags (unter Anleitung, selbstständig …)             |

### Models

| Datei                           | Inhalt                                                                                       |
| ------------------------------- | -------------------------------------------------------------------------------------------- |
| `models/daily_entry.dart`       | `DailyEntry` — id, date, dayType, area?, selectedActivities, specialFlags, note?, timestamps |
| `models/activity_template.dart` | `ActivityTemplate` — id (stabil!), title, category, isCustom, isActive                       |
| `models/reminder_settings.dart` | `ReminderTime` + `ReminderSettings` (enabled, times, weekdays, defaults, copyWith)           |

### Storage

| Datei                                        | Inhalt                                       |
| -------------------------------------------- | -------------------------------------------- |
| `storage/daily_entry_storage.dart`           | Abstraktes Interface                         |
| `storage/daily_entry_adapter.dart`           | Hive-CE-Adapter, handgeschrieben (typeId: 0) |
| `storage/hive_daily_entry_storage.dart`      | Produktiv-Impl., Box `entries`               |
| `storage/in_memory_daily_entry_storage.dart` | Test-Mock                                    |
| `storage/activity_template_storage.dart`      | Interface für eigene Tätigkeiten             |
| `storage/activity_template_adapter.dart`      | Hive-CE-Adapter, handgeschrieben (typeId: 1) |
| `storage/hive_activity_template_storage.dart` | Produktiv-Impl., Box `custom_templates`      |
| `storage/reminder_storage.dart`              | Reminder-Einstellungen in SharedPreferences  |
| `storage/theme_preset_storage.dart`          | Gewähltes ThemePreset in SharedPreferences   |
| `storage/preferences_write.dart`             | Prüft SharedPreferences-Schreibergebnisse    |

### Services

| Datei                              | Inhalt                                                                              |
| ---------------------------------- | ----------------------------------------------------------------------------------- |
| `services/notification_service.dart` | Scheduler-Interface, Reminder-Plan, Tap-Routing und Produktiv-/Testimplementierung |
| `report/daily_report_generator.dart` | Deterministische lokale Tagesberichtstexte ohne KI |

### Sonstiges Core

| Datei                               | Inhalt                                        |
| ----------------------------------- | --------------------------------------------- |
| `core/constants.dart`               | `AppStrings` + SharedPreferences-Schlüssel    |
| `core/profile_storage.dart`         | `StoredProfile` in SharedPreferences           |
| `core/week_utils.dart`              | ISO-Kalenderwochen-Helfer                     |
| `core/data/default_activities.dart` | 87 vordefinierte Tätigkeiten mit stabilen IDs |

---

## Shared Widgets (lib/shared/widgets/)

| Datei                     | Inhalt                                                     |
| ------------------------- | ---------------------------------------------------------- |
| `profile_form.dart`       | Profilmaske (Onboarding + Profil-Screen teilen sich diese) |
| `app_ui.dart`             | Abschnittsköpfe, Statusmeldungen, Empty States, Gruppen    |

---

## Persistenz-Fluss

```
Tageseintrag:
  today_screen.dart
    → HiveDailyEntryStorage (hive_daily_entry_storage.dart)
    → Hive CE Box "entries"
    → daily_entry_adapter.dart (Serialisierung)

Profil:
  onboarding_screen.dart / profile_screen.dart / profile_form.dart
    → profile_storage.dart
    → SharedPreferences

Erinnerungen:
  profile_screen.dart (_buildReminderSection)
    → reminder_storage.dart
    → SharedPreferences (reminder_enabled, reminder_times, reminder_weekdays)
    → notification_service.dart (FlutterLocalNotificationScheduler)
    → flutter_timezone + flutter_local_notifications

Theme:
  profile_screen.dart
    → theme_preset_storage.dart
    → SharedPreferences ("theme_preset")
    → app.dart / theme.dart

Berichtsvorschlag:
  today_screen.dart / week_screen.dart
    → report/daily_report_generator.dart
    → deterministischer lokaler Text + Clipboard

App-Start:
  main.dart
    → app/bootstrap.dart
    → Hive-Speicher + Profil + Theme
    → app.dart
```

---

## Tests (test/)

| Datei                                | Getestet                           |
| ------------------------------------ | ---------------------------------- |
| `widget_test.dart`                      | Onboarding, Navigation, Profil                    |
| `today_screen_test.dart`                | Formular, Speicherung, Bearbeitung                |
| `week_screen_test.dart`                 | Wochenstatus, Navigation                          |
| `week_utils_test.dart`                  | ISO-Kalenderwochen, Jahreswechsel                 |
| `default_activities_test.dart`          | 87 Einträge, eindeutige IDs                       |
| `hive_daily_entry_storage_test.dart`    | Persistenz über Box-Neuöffnung                    |
| `hive_activity_template_storage_test.dart` | Aktivstatus + Rückwärtskompatibilität          |
| `reminder_settings_test.dart`           | Modell-Defaults, Gleichheit, Serialisierung       |
| `reminder_storage_test.dart`            | SharedPreferences-Roundtrip, mehrere Zeiten/Tage  |
| `profile_reminder_screen_test.dart`     | Profil-Screen Erinnerungs-UI (Toggle, Zeiten, Tage) |
| `notification_service_test.dart`        | IDs, Folgeerinnerung über Mitternacht, Kaltstart-Payload |
| `daily_report_generator_test.dart`      | Deterministische Berichtstexte je Tagtyp und Flag        |
| `bootstrap_test.dart`                   | sichtbarer Startfehler und Retry                          |
| `preferences_write_test.dart`           | fehlgeschlagene SharedPreferences-Schreibvorgänge        |
| `ui_layout_test.dart`                    | Kleine Displays, große Schrift, Tastatur, Touchflächen, Goldens |

Letzten verifizierten Lauf siehe `docs/CURRENT_STATUS.md`.

---

## Wichtige Dokumente

| Datei                         | Wofür                                                |
| ----------------------------- | ---------------------------------------------------- |
| `AGENTS.md`                   | Regeln, No-Gos, Patterns — immer lesen               |
| `TASKS.md`                    | Aktive Phase und offene Aufgaben                     |
| `docs/DATA_MODEL.md`          | Vollständige Enum/Model-Referenz                     |
| `docs/AGENT_CONTEXT_PACKS.md` | Aufgabenbezogene Dateilisten                         |
| `docs/VALIDATION_MATRIX.md`   | Mindestprüfungen pro Änderungstyp                    |
| `docs/UI_UX_SPEC.md`          | Design-Vorgaben, Screen-Layouts                      |
| `DECISIONS.md`                | Architekturentscheidungen (nicht erneut diskutieren) |
