# AGENTS.md — Regeln für Coding-Agenten

Dieses Dokument gilt für **alle** Coding-Agenten: Claude Code, Codex CLI, OpenCode und ähnliche Tools.
Agentenspezifische Dateien: `CLAUDE.md` (Claude Code), `CODEX.md` (Codex CLI), `opencode.json` (OpenCode).

---

## Projektziel

Kleine private Android-App für Auszubildende in der Lagerlogistik.
Die App speichert täglich kurz, was getan wurde — als Gedächtnisstütze für das wöchentliche Berichtsheft.
Sie ist keine offizielle Anwendung und hat kein Backend.

---

## Pflichtlektüre vor der Arbeit

| Dokument                              | Inhalt                                                          |
| ------------------------------------- | --------------------------------------------------------------- |
| `TASKS.md`                            | Aktuelle Phase und offene Aufgaben — immer zuerst lesen         |
| `PROJECT_STATUS.md`                   | Was existiert, was noch fehlt                                   |
| `docs/DATA_MODEL.md`                  | Datenmodell-Referenz: Enums, Models, Dateistruktur              |
| `docs/PRODUCT_CONCEPT.md`             | Was die App kann, welche Features in welcher Phase              |
| `docs/UI_UX_SPEC.md`                  | Wie die App aussehen soll, Screen-Layouts                       |
| `docs/AGENT_IMPLEMENTATION_PROMPT.md` | Technische Umsetzungsdetails, Akzeptanzkriterien                |
| `DECISIONS.md`                        | Getroffene Architekturentscheidungen — nicht erneut diskutieren |

---

## Aktuelle Phase

**Phase 6: Vorlagenverwaltung** — vordefinierte und eigene Tätigkeitsvorlagen verwalten.

---

## Dateikarte

```
lib/main.dart                                    → runApp(BerichtsheftApp)
lib/app/app.dart                                 → MaterialApp + MainShell (IndexedStack + NavigationBar)
lib/app/theme.dart                               → buildAppTheme() — M3, ColorScheme.fromSeed grün-teal
lib/app/router.dart                              → AppRoutes (statische String-Konstanten)
lib/core/constants.dart                          → AppStrings + SharedPreferences-Konstanten
lib/core/profile_storage.dart                    → Ausbildungsprofil in SharedPreferences
lib/core/enums/                                  → DayType, TrainingArea, ActivityCategory, SpecialFlag
lib/core/models/                                 → DailyEntry, ActivityTemplate
lib/core/data/default_activities.dart            → 87 vordefinierte Tätigkeiten
lib/core/storage/                                → DailyEntryStorage + Hive-CE-Persistenz
lib/core/week_utils.dart                         → ISO-Kalenderwochen-Helfer
lib/features/onboarding/onboarding_screen.dart   → Erststart mit vollständigem Ausbildungsprofil
lib/features/today/today_screen.dart             → Persistenter Tageseintrag
lib/features/week/week_screen.dart               → Persistente Wochenübersicht + Zusammenfassung
lib/features/templates/templates_screen.dart     → Platzhalter — aktive Phase baut hier
lib/features/profile/profile_screen.dart         → Ausbildungsprofil anzeigen und bearbeiten
lib/shared/widgets/profile_form.dart             → Gemeinsame Profilmaske
lib/shared/widgets/placeholder_screen.dart       → Wiederverwendbar: Icon + Titel + Beschreibung
docs/DATA_MODEL.md                               → Enums, Model-Konzepte, Zieldateistruktur
docs/PRODUCT_CONCEPT.md                          → Fachliche Spezifikation
docs/UI_UX_SPEC.md                               → Design-Vorgaben
docs/AGENT_IMPLEMENTATION_PROMPT.md              → Technische Umsetzung, Tätigkeitskatalog
```

---

## Datenmodell-Überblick

Vollständige Referenz: `docs/DATA_MODEL.md`

Zentrale Konzepte:

- **DailyEntry** — ein Tageseintrag (Datum, Tagtyp, Bereich, Tätigkeiten, Notiz)
- **ActivityTemplate** — vordefinierte oder eigene Tätigkeit
- **UserProfile** — Ausbildungsprofil der Nutzerin
- **DayType** — Betrieb | Berufsschule | Frei | Urlaub | Krank | Feiertag | Sonstiges

`DailyEntry` und `ActivityTemplate` sowie die benötigten Enums sind implementiert.
Tageseinträge werden über `DailyEntryStorage` in Hive CE gespeichert; das Profil bleibt in SharedPreferences.

---

## Harte Nicht-Ziele — baue das NICHT

- PDF-Export oder Druckfunktion
- Cloud-Sync, Firebase, Supabase oder ähnliches
- Login, Registrierung, Authentifizierung
- Backend, REST-API, GraphQL
- KI-Chat, Sprachsteuerung, Autovervollständigung per LLM
- Kalender-Sync (Google Calendar, iCal)
- Digitale Unterschrift
- Ausbilderportal oder Mehrbenutzer-Verwaltung
- Offizielles IHK-/Kammerformular
- iOS-spezifische Funktionen
- State-Management-Framework (BLoC, Provider, Riverpod, GetX) ohne explizite Anforderung

---

## Arbeitsregeln

1. **Erst analysieren, dann umsetzen.** Relevante Dateien lesen bevor du änderst.
2. **Kein Feature ohne Plan.** Größere Änderungen erst abstimmen.
3. **Phase einhalten.** Nur bauen was in der aktiven Phase steht (`TASKS.md`).
4. **Keine Architektur-Inflation.** `setState` reicht für den MVP.
5. **Keine Dependencies ohne Grund.** Pakete nur hinzufügen wenn konkret benötigt.
6. **UI/UX respektieren.** Material 3, Bottom Navigation, große Touchflächen, kein Web-App-Feel.
7. **Analyze nach jeder Dart-Änderung.** 0 Issues ist Pflicht.
8. **Docs aktuell halten.** Nach Phase-Abschluss `PROJECT_STATUS.md` und `TASKS.md` aktualisieren.

---

## Codierungs-Patterns

**Dateinamen:** `snake_case.dart` — Klassen: `PascalCase`

**Imports innerhalb von lib/:** relativ (nicht absolut)

```dart
import '../../shared/widgets/placeholder_screen.dart';  // korrekt
import 'package:berichtsheft_merker/shared/...';        // vermeiden
```

**Const wo möglich** — `flutter analyze` erzwingt es:

```dart
const Scaffold(body: PlaceholderScreen(...))  // korrekt
Scaffold(body: const PlaceholderScreen(...))  // auch ok
```

**PlaceholderScreen** für leere Feature-Screens:

```dart
PlaceholderScreen(
  icon: Icons.today_outlined,
  title: 'Heute',
  description: 'Hier entsteht die schnelle Tagesnotiz.',
)
```

**Theme:** Immer aus Context, nie `buildAppTheme()` direkt aufrufen:

```dart
final theme = Theme.of(context);          // korrekt
final color = theme.colorScheme.primary;
```

---

## Häufige Agenten-Fehler

- Absoluten Import statt relativen verwenden → `flutter analyze` schlägt an
- `setState` vergessen nach Zustandsänderungen in StatefulWidgets
- Neue Pakete in `pubspec.yaml` eintragen ohne danach `flutter pub get` auszuführen
- Features aus späteren Phasen einbauen ohne Abstimmung
- `buildAppTheme()` aus theme.dart direkt aufrufen statt `Theme.of(context)` zu verwenden

---

## Flutter-Befehle

Flutter ist unter `/home/d/flutter/bin/flutter` installiert — **nicht** im System-PATH.

```bash
/home/d/flutter/bin/flutter pub get       # nach pubspec-Änderungen
/home/d/flutter/bin/flutter analyze       # nach jeder Dart-Änderung — muss 0 Issues zeigen
/home/d/flutter/bin/flutter test          # nach Feature-Implementierung
/home/d/flutter/bin/flutter run           # App starten (Gerät/Emulator)
/home/d/flutter/bin/flutter build apk    # Android APK (Phase 8)
```

---

## Technologie-Stack

- Flutter 3.x / Dart 3.x
- Android-first (Kotlin-Wrapper generiert)
- Material 3
- Lokale Speicherung: Hive CE für Tageseinträge, SharedPreferences für Profil
- SharedPreferences: Onboarding-Flag, Profil (ab Phase 2)
- Kein Backend, keine Cloud, kein Login
