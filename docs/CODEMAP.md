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

| Datei                                      | Status    | Beschreibung                                                                                                                               |
| ------------------------------------------ | --------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `onboarding/onboarding_screen.dart`        | ✅ fertig | Zweistufiger Erststart                                                                                                                     |
| `today/today_screen.dart`                  | ✅ fertig | Geführte Tageseintrag-Orchestrierung, Laden/Speichern, Tageswechsel, Undo und Tagesübersicht                                               |
| `today/activity_picker_model.dart`         | ✅ fertig | Tätigkeitsauswahl-Logik: Suche, Gruppen, häufig genutzt, Empfehlungen und historische IDs                                                  |
| `today/today_entry_draft.dart`             | ✅ fertig | DailyEntry-Entwurf für Validierung, Speichern und Berichtsvorschau                                                                         |
| `today/activity_recommender.dart`          | ✅ fertig | Häufig-genutzt-Sortierung und Ausbildungsjahr-Empfehlungen                                                                                 |
| `today/widgets/`                           | ✅ fertig | UI-Bausteine: `TodayFlow` (Check-in-Schritte, Tätigkeitsauswahl und Übersicht), `TodayHeader`, `DayTypeRow`, `AbsenceSheet`, `SaveBar`, `AreaGrid`, `SpecialFlagsAndNoteSection`, `ActivityPickerSection` |
| `today/widgets/report_card.dart`           | ✅ fertig | Generierte Berichtskarte mit Entwurf/Erledigt-Chip und Kopier-Button                                                                       |
| `week/week_screen.dart`                    | ✅ fertig | Wochenliste, Zusammenfassung und kopierbare Tagesberichte                                                                                  |
| `templates/templates_screen.dart`          | ✅ fertig | Suche, hinzufügen, filtern, deaktivieren/reaktivieren                                                                                      |
| `profile/profile_screen.dart`              | ✅ fertig | Profil-Orchestrierung, Datenverwaltung, Export/Delete und Section-Wiring                                                                   |
| `profile/profile_reminder_controller.dart` | ✅ fertig | Reminder laden/speichern, Berechtigung, Rollback und Edit-Regeln                                                                           |
| `profile/widgets/profile_header.dart`        | ✅ fertig | Profil-Header (Avatar, Begrüßung, Unterzeile, Tap→Editor)                                                           |
| `profile/widgets/profile_edit_screen.dart`   | ✅ fertig | Profil-Bearbeitungsscreen (shared ProfileForm)                                                                      |
| `profile/widgets/profile_theme_section.dart` | ✅ fertig | Theme-Auswahl als Farbkachel-Grid mit Live-Vorschau                                                                 |
| `profile/widgets/reminder_section.dart`      | ✅ fertig | Reminder-UI (Toggle, Zeiten, Wochentage, Samsung-Hinweis)                                                            |

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
| `models/daily_entry.dart`       | `DailyEntry` — id, date, dayType, areas, selectedActivities, specialFlags, note?, timestamps |
| `models/activity_template.dart` | `ActivityTemplate` — id (stabil!), title, category, isCustom, isActive, subcategory?         |
| `models/reminder_settings.dart` | `ReminderTime` + `ReminderSettings` (enabled, times, weekdays, defaults, copyWith)           |

### Storage

| Datei                                         | Inhalt                                                 |
| --------------------------------------------- | ------------------------------------------------------ |
| `storage/daily_entry_storage.dart`            | Abstraktes Interface (`loadByDate`, `loadAll`, `save`) |
| `storage/daily_entry_adapter.dart`            | Hive-CE-Adapter, handgeschrieben (typeId: 0)           |
| `storage/hive_daily_entry_storage.dart`       | Produktiv-Impl., Box `entries`                         |
| `storage/in_memory_daily_entry_storage.dart`  | Test-Mock                                              |
| `storage/activity_template_storage.dart`      | Interface für eigene Tätigkeiten                       |
| `storage/activity_template_adapter.dart`      | Hive-CE-Adapter, handgeschrieben (typeId: 1)           |
| `storage/hive_activity_template_storage.dart` | Produktiv-Impl., Box `custom_templates`                |
| `storage/persisted_enum.dart`                 | Kontrollierte Parser für gespeicherte Enum-Namen       |
| `storage/reminder_storage.dart`               | Reminder-Einstellungen in SharedPreferences            |
| `storage/theme_preset_storage.dart`           | Gewähltes ThemePreset in SharedPreferences             |
| `storage/preferences_write.dart`              | Prüft SharedPreferences-Schreibergebnisse              |

### Services

| Datei                                | Inhalt                                                                             |
| ------------------------------------ | ---------------------------------------------------------------------------------- |
| `services/notification_service.dart` | Scheduler-Interface, Reminder-Plan, Tap-Routing und Produktiv-/Testimplementierung |
| `report/daily_report_generator.dart` | Deterministische lokale Tagesberichtstexte ohne KI                                 |

### Sonstiges Core

| Datei                                   | Inhalt                                             |
| --------------------------------------- | -------------------------------------------------- |
| `core/constants.dart`                   | `AppStrings` + SharedPreferences-Schlüssel         |
| `core/profile_storage.dart`             | `StoredProfile` in SharedPreferences               |
| `core/week_utils.dart`                  | ISO-Kalenderwochen-Helfer                          |
| `core/data/default_activities.dart`     | 132 stabile IDs; 123 fachlich auswählbare Tätigkeiten |
| `core/data/activity_subcategories.dart` | Fachliche Untergruppen für Tätigkeitslisten        |
| `core/data/lager_jokes.dart`            | 300 lokale Lagerlogistik-Witze, deterministisch pro Kalendertag |
| `core/ui/day_status_colors.dart`        | Zentrale Statusfarben (saved/open/absence/neutral) |

---

## Shared Widgets (lib/shared/widgets/)

| Datei               | Inhalt                                                     |
| ------------------- | ---------------------------------------------------------- |
| `profile_form.dart` | Profilmaske (Onboarding + Profil-Screen teilen sich diese) |
| `app_ui.dart`       | Abschnittsköpfe, Statusmeldungen, Empty States, Gruppen |

---

## Persistenz-Fluss

```
Tageseintrag:
  today_screen.dart
    → today_entry_draft.dart
    → HiveDailyEntryStorage (hive_daily_entry_storage.dart)
    → Hive CE Box "entries"
    → daily_entry_adapter.dart (Serialisierung)

Profil:
  onboarding_screen.dart / profile_screen.dart / profile_form.dart / profile/widgets/profile_edit_screen.dart
    → profile_storage.dart
    → SharedPreferences

Erinnerungen:
  profile_screen.dart
    → profile_reminder_controller.dart
    → reminder_storage.dart
    → SharedPreferences (reminder_enabled, reminder_times, reminder_weekdays)
    → notification_service.dart (FlutterLocalNotificationScheduler)
    → flutter_timezone + flutter_local_notifications

Theme:
  profile_screen.dart
    → profile/widgets/profile_theme_section.dart
    → theme_preset_storage.dart
    → SharedPreferences ("theme_preset")
    → app.dart / theme.dart

Häufig genutzte Tätigkeiten:
  today_screen.dart
    → DailyEntryStorage.loadAll()
    → activity_recommender.dart
    → activity_picker_model.dart

Ausbildungsjahr-Empfehlungen:
  app.dart / profile_screen.dart
    → Profiländerung aktualisiert App-State
    → activity_picker_model.dart / activity_recommender.dart

Berichtsvorschlag:
  today_screen.dart / week_screen.dart
    → today_entry_draft.dart (Heute)
    → report/daily_report_generator.dart
    → deterministische lokale Satzmuster + Clipboard

App-Start:
  main.dart
    → app/bootstrap.dart
    → Hive-Speicher + Profil + Theme
    → app.dart
```

---

## Tests (test/)

| Datei                                      | Getestet                                                           |
| ------------------------------------------ | ------------------------------------------------------------------ |
| `widget_test.dart`                         | Onboarding, Navigation, Profil, Reminder-SnackBar                  |
| `today_screen_test.dart`                   | Formular, Speicherung, Suche, Untergruppen, Empfehlungen           |
| `today_entry_draft_test.dart`              | Heute-Draft: Pflichtfelder, Entry-Erzeugung, Notiz/Flags           |
| `activity_picker_model_test.dart`          | Tätigkeitsauswahl: Gruppen, Suche, Custom-/historische IDs         |
| `activity_recommender_test.dart`           | Häufig-genutzt-Sortierung                                          |
| `week_screen_test.dart`                    | Wochenstatus, Navigation                                           |
| `templates_screen_test.dart`               | Vorlagenverwaltung (Suche, Hinzufügen, Deaktivieren)               |
| `week_utils_test.dart`                     | ISO-Kalenderwochen, Jahreswechsel                                  |
| `default_activities_test.dart`             | 132 stabile IDs, 123 auswählbare Einträge, 38 aktive Vorlagen      |
| `hive_daily_entry_storage_test.dart`       | Persistenz über Box-Neuöffnung                                     |
| `hive_activity_template_storage_test.dart` | Aktivstatus + Rückwärtskompatibilität                              |
| `reminder_settings_test.dart`              | Modell-Defaults, Gleichheit, Serialisierung                        |
| `reminder_storage_test.dart`               | SharedPreferences-Roundtrip, mehrere Zeiten/Tage                   |
| `profile_reminder_controller_test.dart`    | Reminder speichern, Permission, Rollback und Edit-Regeln           |
| `profile_reminder_screen_test.dart`        | Profil-Screen Erinnerungs-UI (Toggle, Zeiten, Tage)                |
| `notification_service_test.dart`           | IDs, Folgeerinnerung über Mitternacht, Kaltstart-Payload           |
| `daily_report_generator_test.dart`         | Deterministische Berichtstexte je Tagtyp und Flag                  |
| `bootstrap_test.dart`                      | sichtbarer Startfehler und Retry                                   |
| `preferences_write_test.dart`              | fehlgeschlagene SharedPreferences-Schreibvorgänge                  |
| `persistence_stability_test.dart`          | stabile Enum-Namen, Parser und Tätigkeits-IDs                      |
| `android_backup_test.dart`               | Android-Cloud-Backup und Gerätetransfer bleiben deaktiviert         |
| `version_consistency_test.dart`            | `pubspec.yaml`-Version gegen `kAppVersion`                         |
| `ui_layout_test.dart`                      | Kleine Displays, große Schrift, Tastatur, Touchflächen, Goldens    |
| `export_service_test.dart`                 | JSON-Export: Profil, Einträge, eigene Tätigkeiten (`generateJson`) |
| `profile_storage_test.dart`                | Profil save/load, Validierung Beruf/Jahr, Onboarding-Status        |
| `theme_preset_storage_test.dart`           | Theme-Preset-Roundtrip und Fallback auf `lagerTeal`                |
| `theme_test.dart`                          | `buildThemeForPreset` pro Preset: M3, Brightness, primary          |
| `profile_theme_grid_test.dart`             | Farbkachel-Grid: alle Presets gerendert, eins markiert             |
| `lager_jokes_test.dart`                    | Witzliste und deterministische Kalendertag-Auswahl                 |

Letzten verifizierten Lauf siehe `docs/CURRENT_STATUS.md`.

---

## Wichtige Dokumente

| Datei                         | Wofür                                                |
| ----------------------------- | ---------------------------------------------------- |
| `AGENTS.md`                   | Regeln, No-Gos, Patterns — immer lesen               |
| `TASKS.md`                    | Aktive Phase und offene Aufgaben                     |
| `docs/DATA_MODEL.md`          | Vollständige Enum/Model-Referenz                     |
| `docs/AGENT_CONTEXT_PACKS.md` | Aufgabenbezogene Dateilisten                         |
| `docs/AGENT_HANDOFF_TEMPLATE.md` | Einheitliche Agenten-Übergabevorlage              |
| `docs/VALIDATION_MATRIX.md`   | Mindestprüfungen pro Änderungstyp                    |
| `docs/UI_UX_SPEC.md`          | Design-Vorgaben, Screen-Layouts                      |
| `docs/QA_RELEASE_CHECKLIST.md`  | Manueller Release-Test auf echtem Android-Gerät      |
| `docs/QA_REMINDER_CHECKLIST.md` | Manueller Reminder-/Notification-Test                |
| `DECISIONS.md`                  | Architekturentscheidungen (nicht erneut diskutieren) |
