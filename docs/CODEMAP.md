# CODEMAP.md — Schnellreferenz Projektstruktur

Flutter Android-App „Berichtsheft-Merker Lagerlogistik". Phasen 0–11 im Code abgeschlossen; manueller Android-Test offen.

---

## Einstiegspunkte

```
lib/main.dart                → runApp, Hive-Init, Profil laden
lib/app/app.dart             → MaterialApp, MainShell, IndexedStack, NavigationBar
lib/app/router.dart          → AppRoutes (String-Konstanten)
lib/app/theme.dart           → buildAppTheme(), reduziertes M3-Komponententheme
```

---

## Features (lib/features/)

| Datei                               | Zeilen | Status    | Beschreibung                                              |
| ----------------------------------- | -----: | --------- | --------------------------------------------------------- |
| `onboarding/onboarding_screen.dart` |    208 | ✅ fertig | Zweistufiger Erststart                                    |
| `today/today_screen.dart`           |    909 | ✅ fertig | Tageseintrag mit Checklisten und Eingabeverlustschutz     |
| `week/week_screen.dart`             |    758 | ✅ fertig | Kompakte Wochenliste + Zusammenfassung                    |
| `templates/templates_screen.dart`   |    458 | ✅ fertig | Suche, hinzufügen, filtern, deaktivieren/reaktivieren     |
| `profile/profile_screen.dart`       |    549 | ✅ fertig | Übersicht, Bearbeitung, Erinnerungen, Datenverwaltung     |

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

### Services

| Datei                              | Inhalt                                                                              |
| ---------------------------------- | ----------------------------------------------------------------------------------- |
| `services/notification_service.dart` | `NotificationScheduler` (Interface), `NoOpNotificationScheduler` (Tests), `FlutterLocalNotificationScheduler` (Produktiv) |

### Sonstiges Core

| Datei                               | Inhalt                                        |
| ----------------------------------- | --------------------------------------------- |
| `core/constants.dart`               | `AppStrings` + SharedPreferences-Schlüssel    |
| `core/profile_storage.dart`         | `UserProfile` in SharedPreferences            |
| `core/week_utils.dart`              | ISO-Kalenderwochen-Helfer                     |
| `core/data/default_activities.dart` | 87 vordefinierte Tätigkeiten mit stabilen IDs |

---

## Shared Widgets (lib/shared/widgets/)

| Datei                     | Inhalt                                                     |
| ------------------------- | ---------------------------------------------------------- |
| `placeholder_screen.dart` | Wiederverwendbar: Icon + Titel + Beschreibung              |
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

Onboarding-Flag:
  main.dart / constants.dart (SharedPreferences-Key)
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
| `ui_layout_test.dart`                    | Kleine Displays, große Schrift, Tastatur, Touchflächen, Goldens |

Letzter Lauf (Phase 11): 87/87 bestanden.

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
