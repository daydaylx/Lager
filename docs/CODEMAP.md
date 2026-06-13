# CODEMAP.md — Schnellreferenz Projektstruktur

Flutter Android-App „Berichtsheft-Merker Lagerlogistik". Phase 5 abgeschlossen, Phase 6 aktiv.

---

## Einstiegspunkte

```
lib/main.dart                → runApp, Hive-Init, Profil laden
lib/app/app.dart             → MaterialApp, MainShell, IndexedStack, NavigationBar
lib/app/router.dart          → AppRoutes (String-Konstanten)
lib/app/theme.dart           → buildAppTheme(), M3, ColorScheme.fromSeed grün-teal
```

---

## Features (lib/features/)

| Datei                               | Zeilen | Status    | Beschreibung                                              |
| ----------------------------------- | -----: | --------- | --------------------------------------------------------- |
| `onboarding/onboarding_screen.dart` |     63 | ✅ fertig | Erststart, Profil anlegen                                 |
| `today/today_screen.dart`           |    683 | ✅ fertig | Tageseintrag: Typ, Bereich, Tätigkeiten, Notiz, Speichern |
| `week/week_screen.dart`             |    682 | ✅ fertig | Wochenübersicht 7 Kacheln + Zusammenfassung               |
| `templates/templates_screen.dart`   |     18 | 🔨 aktiv  | Platzhalter — **hier baut Phase 6**                       |
| `profile/profile_screen.dart`       |    104 | ✅ fertig | Profil anzeigen + bearbeiten                              |

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
| `models/activity_template.dart` | `ActivityTemplate` — id (stabil!), title, category                                           |

### Storage

| Datei                                        | Inhalt                                       |
| -------------------------------------------- | -------------------------------------------- |
| `storage/daily_entry_storage.dart`           | Abstraktes Interface                         |
| `storage/daily_entry_adapter.dart`           | Hive-CE-Adapter, handgeschrieben (typeId: 0) |
| `storage/hive_daily_entry_storage.dart`      | Produktiv-Impl., Box `entries`               |
| `storage/in_memory_daily_entry_storage.dart` | Test-Mock                                    |

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

Onboarding-Flag:
  main.dart / constants.dart (SharedPreferences-Key)
```

---

## Tests (test/)

| Datei                                | Getestet                           |
| ------------------------------------ | ---------------------------------- |
| `widget_test.dart`                   | Onboarding, Navigation, Profil     |
| `today_screen_test.dart`             | Formular, Speicherung, Bearbeitung |
| `week_screen_test.dart`              | Wochenstatus, Navigation           |
| `week_utils_test.dart`               | ISO-Kalenderwochen, Jahreswechsel  |
| `default_activities_test.dart`       | 87 Einträge, eindeutige IDs        |
| `hive_daily_entry_storage_test.dart` | Persistenz über Box-Neuöffnung     |

Letzter Lauf: 28/28 bestanden.

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
