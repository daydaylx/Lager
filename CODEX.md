# CODEX.md — Codex CLI Regeln

Private Flutter-App für Auszubildende in der Lagerlogistik. Tätigkeiten täglich speichern, Berichtsheft am Wochenende leichter schreiben. Kein Backend, keine Cloud, kein Login.

**Zuerst lesen:** `AGENTS.md` → `TASKS.md` → `PROJECT_STATUS.md`

---

## Tech-Stack

- Flutter / Dart (Android-first)
- Material 3
- Lokale Speicherung: Hive CE für Tageseinträge, SharedPreferences für Profil
- Kein Backend, keine Cloud, kein State-Management-Framework ohne Bedarf

## Aktuelle Phase

**Phase 6: Vorlagenverwaltung** — vordefinierte und eigene Tätigkeitsvorlagen verwalten.

## Dateikarte

```
lib/main.dart                                  → App-Einstieg
lib/app/app.dart                               → MaterialApp + NavigationBar Shell (4 Tabs)
lib/app/theme.dart                             → buildAppTheme() — Material 3
lib/app/router.dart                            → AppRoutes Konstanten
lib/core/constants.dart                        → AppStrings + SharedPreferences-Konstanten
lib/core/profile_storage.dart                  → Ausbildungsprofil in SharedPreferences
lib/core/enums/                                → Tageseintrag-Enums
lib/core/models/                               → DailyEntry + ActivityTemplate
lib/core/data/default_activities.dart          → 87 Standardtätigkeiten
lib/core/storage/                              → DailyEntryStorage + Hive-CE-Persistenz
lib/core/week_utils.dart                       → ISO-Kalenderwochen-Helfer
lib/features/onboarding/onboarding_screen.dart → vollständiges Onboarding
lib/features/today/today_screen.dart           → persistenter Tageseintrag
lib/features/week/week_screen.dart             → persistente Wochenübersicht
lib/features/templates/templates_screen.dart   → aktive Phase
lib/features/profile/profile_screen.dart       → Ausbildungsprofil bearbeiten
lib/shared/widgets/placeholder_screen.dart     → Icon + Titel + Beschreibung
docs/DATA_MODEL.md                             → Enums und Models
```

## Nicht bauen

PDF · Cloud · Login · Backend · KI · iOS · BLoC/Riverpod · Mehrbenutzer · Unterschrift

## Flutter-Befehle

```bash
/home/d/flutter/bin/flutter analyze       # 0 Issues nach jeder Dart-Änderung
/home/d/flutter/bin/flutter test
/home/d/flutter/bin/flutter pub get       # nach pubspec-Änderungen
/home/d/flutter/bin/flutter run
```

Flutter liegt unter `/home/d/flutter/bin/flutter` — nicht im System-PATH.

## Codier-Regeln

- Dateinamen: `snake_case.dart` — Klassen: `PascalCase`
- Imports: relativ (nicht `package:berichtsheft_merker/...`)
- `const` wo möglich — analyze erzwingt es
- Theme immer via `Theme.of(context)`, nie `buildAppTheme()` direkt
- Neue Pakete erst in `pubspec.yaml` eintragen, dann `flutter pub get`

## Datenmodell

Vollständig in `docs/DATA_MODEL.md`. Phase-3-Modelle und Enums sind als Dart-Code vorhanden.
Kernmodelle: `DailyEntry`, `ActivityTemplate`, `UserProfile`.
Kernenums: `DayType`, `TrainingArea`, `ActivityCategory`.
