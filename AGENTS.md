# AGENTS.md — Regeln für Coding-Agenten

Dieses Dokument gilt für **alle** Coding-Agenten: Claude Code, Codex CLI,
Gemini CLI, OpenCode, Cursor, Kilo Code, Copilot und ähnliche Tools.
Tool-spezifische Dateien bleiben dünne Verweise auf diese kanonischen Regeln.

---

## Projektziel

Kleine private Android-App für Auszubildende in der Lagerlogistik.
Die App speichert täglich kurz, was getan wurde — als Gedächtnisstütze für das wöchentliche Berichtsheft.
Sie ist keine offizielle Anwendung und hat kein Backend.

---

## Pflichtlektüre vor der Arbeit

**Immer lesen** (minimaler Pflichtkontext):

| Dokument                 | Inhalt                                         |
| ------------------------ | ---------------------------------------------- |
| `TASKS.md`               | Aktuelle Phase und offene Aufgaben             |
| `docs/CURRENT_STATUS.md` | Aktiver Stand, letzte Checks, nächster Schritt |

**Dann:** `docs/AGENT_CONTEXT_PACKS.md` öffnen und das passende Context Pack zur Aufgabe wählen.
Context Packs sind **Mindestkontext**, keine abschließenden Dateilisten. Direkte
Abhängigkeiten, Aufrufer, Tests und ausführbare Konfigurationen müssen zusätzlich
gelesen werden, wenn sie für eine sichere Änderung relevant sind.

**Nur bei konkretem Bedarf** (nicht pauschal):

| Dokument             | Wann nötig                                  |
| -------------------- | ------------------------------------------- |
| `docs/CODEMAP.md`    | Orientierung zu Pfaden und Einstiegspunkten |
| `docs/DATA_MODEL.md` | Datenmodell, Enums, Persistenzregeln        |
| `docs/UI_UX_SPEC.md` | UI-/Design-Fragen                           |
| `DECISIONS.md`       | Vor Architektur- oder Scope-Fragen          |

---

## Aktuelle Phase

Die einzige Quelle für aktive Phase und offene Aufgaben ist `TASKS.md`.

---

## Harte Nicht-Ziele — baue das NICHT

- PDF-Export oder Druckfunktion (nicht in V1/MVP; nur nach expliziter neuer Entscheidung)
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
3. **Phase einhalten.** Nur bauen was in `TASKS.md` steht oder vom User
   ausdrücklich beauftragt wurde. Bugfixes, Sicherheitskorrekturen und
   Dokumentationskorrekturen dürfen nicht wegen einer Phasenbezeichnung ignoriert
   werden.
4. **Keine Architektur-Inflation.** `setState` reicht für den MVP.
5. **Keine Dependencies ohne Grund.** Pakete nur hinzufügen wenn konkret benötigt.
6. **UI/UX respektieren.** Material 3, Bottom Navigation, große Touchflächen, kein Web-App-Feel.
7. **Analyze nach jeder Dart-Änderung.** 0 Issues ist Pflicht.
8. **Docs aktuell halten.** Nach Phase-Abschluss `PROJECT_STATUS.md`, `TASKS.md` und `docs/CURRENT_STATUS.md` aktualisieren.
9. **Fremde Änderungen schützen.** Bestehende uncommittete Änderungen nie
   verwerfen, überschreiben oder ungefragt in den eigenen Scope aufnehmen.
10. **Git-Aktionen nur auf Auftrag.** Nicht ungefragt committen, pushen, resetten,
    auschecken oder Dateien stagen. Destruktive Git-Befehle sind ohne explizite
    Freigabe verboten.
11. **Toolchain nicht nebenbei aktualisieren.** Flutter, Dart, Gradle, AGP,
    Kotlin, NDK und Dependencies nur im Rahmen einer separat geplanten
    Modernisierung ändern.

---

## Documentation Freshness Rule

This rule applies to all coding agents working in this repository.

Before handoff, every agent must check whether its changes require updates to project documentation or agent context files.

### Required check

After any code, config, UI, data model, build, test, deployment, security, privacy, or workflow change, review the current diff and decide whether documentation must be updated.

Check the relevant existing files, such as:

- `README.md`
- `AGENTS.md`
- `CLAUDE.md`
- `GEMINI.md`
- `CODEX.md`
- `opencode.json`
- `.cursor/rules/agents.mdc`
- `.github/copilot-instructions.md`
- `docs/CODEMAP.md`
- `docs/AGENT_CONTEXT_PACKS.md`
- `docs/CURRENT_STATUS.md`
- `docs/VALIDATION_MATRIX.md`
- `docs/UI_UX_SPEC.md`
- `docs/DATA_MODEL.md`
- `docs/PRIVACY_CONTEXT.md`
- `docs/QA_REMINDER_CHECKLIST.md`
- `DECISIONS.md`
- `PROJECT_STATUS.md`
- `TASKS.md`

Only update files that exist and are relevant to the current change.

### Documentation must be updated when

Update documentation if the change affects:

- setup, installation, or development workflow
- build, test, lint, typecheck, smoke, or deployment commands
- repository structure or important file paths
- architecture, module boundaries, or data flow
- UI, design system, navigation, or critical screens
- data model, storage, schema, migrations, settings, or export behavior
- API/provider behavior
- security, privacy, permissions, secrets, logs, or local data handling
- deployment, hosting, CI, or release process
- agent workflow, context packs, validation matrix, or no-go rules
- current status, known issues, or completed work
- product or architecture decisions that should be captured as ADRs

### Documentation should not be updated when

Do not update documentation if:

- the change is only a small internal implementation detail
- existing documentation remains accurate
- no documented command, path, behavior, architecture, or rule changed
- the update would only add noise
- the information would duplicate another canonical source

Keep documentation compact, current, and useful. Do not add documentation just for completeness.

### Required handoff section

Every implementation handoff must include:

```md
## Documentation Freshness Check

| Area                                   | Docs affected? | Action               |
| -------------------------------------- | -------------: | -------------------- |
| README / setup                         |         yes/no | updated / not needed |
| Agent context                          |         yes/no | updated / not needed |
| Validation matrix                      |         yes/no | updated / not needed |
| UI / data / security / deployment docs |         yes/no | updated / not needed |

Result:

- `No documentation update needed`
- or `Documentation updated`
- or `Documentation update still required`
```

### Source of truth

If documentation and executable project sources disagree, trust executable sources first:

1. Code
2. Build/config files
3. Scripts
4. CI/workflow files
5. `AGENTS.md`
6. Active documentation under `docs/`
7. Tool-specific compatibility files such as `CLAUDE.md`, `GEMINI.md`, Copilot/Cursor/Cline/Kilo rules

Tool-specific files should stay thin and should not duplicate long project documentation from `AGENTS.md` or `docs/`.

---

## Codierungs-Patterns

**Dateinamen:** `snake_case.dart` — Klassen: `PascalCase`

**Imports innerhalb von lib/:** relativ (nicht absolut)

```dart
import '../../shared/widgets/app_ui.dart';  // korrekt
import 'package:berichtsheft_merker/shared/...';        // vermeiden
```

**Const wo möglich** — `flutter analyze` erzwingt es:

```dart
const SizedBox(height: 12)  // korrekt
SizedBox(height: 12)        // vermeiden
```

**Leere und Fehlerzustände:** Vorhandene Bausteine aus
`lib/shared/widgets/app_ui.dart` verwenden. Keine neuen Placeholder-Screens für
bereits implementierte Features einführen.

**Theme:** In Widgets immer aus dem Context lesen. Die App wählt das persistierte
`ThemePreset` zentral über `buildThemeForPreset()`:

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
- Theme-Presets oder `ThemePresetStorage` bei UI-Änderungen übersehen

---

## Flutter-Befehle

Flutter ist unter `/home/d/flutter/bin/flutter` installiert — **nicht** im System-PATH.

```bash
/home/d/flutter/bin/flutter pub get       # nach pubspec-Änderungen
/home/d/flutter/bin/flutter analyze       # nach jeder Dart-Änderung — muss 0 Issues zeigen
/home/d/flutter/bin/flutter test          # nach Feature-Implementierung
/home/d/flutter/bin/flutter run           # App starten (Gerät/Emulator)
/home/d/flutter/bin/flutter build apk --debug  # Android-Konfiguration prüfen
```

---

## Technologie-Stack

- Flutter 3.32.1 / Dart 3.8.1
- Android-first (Kotlin-Wrapper generiert)
- Material 3
- Lokale Speicherung: Hive CE für Tageseinträge und eigene Tätigkeiten
- SharedPreferences: Profil, Onboarding, Reminder und Theme-Preset
- Deterministischer lokaler Tagesberichtsgenerator; keine KI
- Kein Backend, keine Cloud, kein Login
