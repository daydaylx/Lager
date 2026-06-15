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

**Immer lesen** (minimaler Pflichtkontext):

| Dokument                 | Inhalt                                         |
| ------------------------ | ---------------------------------------------- |
| `TASKS.md`               | Aktuelle Phase und offene Aufgaben             |
| `docs/CURRENT_STATUS.md` | Aktiver Stand, letzte Checks, nächster Schritt |

**Dann:** `docs/AGENT_CONTEXT_PACKS.md` öffnen und das passende Context Pack zur Aufgabe wählen. Nur die dort genannten Dateien laden.

**Nur bei konkretem Bedarf** (nicht pauschal):

| Dokument             | Wann nötig                                  |
| -------------------- | ------------------------------------------- |
| `docs/CODEMAP.md`    | Orientierung zu Pfaden und Einstiegspunkten |
| `docs/DATA_MODEL.md` | Datenmodell, Enums, Persistenzregeln        |
| `docs/UI_UX_SPEC.md` | UI-/Design-Fragen                           |
| `DECISIONS.md`       | Vor Architektur- oder Scope-Fragen          |

---

## Aktuelle Phase

**Phase 13: Robustheit und Release-Härtung** — Code und automatisierte Prüfungen abgeschlossen; manueller Android-Gerätetest und lokale Release-Signierung offen.

---

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
3. **Phase einhalten.** Nur bauen was in der aktiven Phase steht (`TASKS.md`).
4. **Keine Architektur-Inflation.** `setState` reicht für den MVP.
5. **Keine Dependencies ohne Grund.** Pakete nur hinzufügen wenn konkret benötigt.
6. **UI/UX respektieren.** Material 3, Bottom Navigation, große Touchflächen, kein Web-App-Feel.
7. **Analyze nach jeder Dart-Änderung.** 0 Issues ist Pflicht.
8. **Docs aktuell halten.** Nach Phase-Abschluss `PROJECT_STATUS.md`, `TASKS.md` und `docs/CURRENT_STATUS.md` aktualisieren.

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
- `.github/copilot-instructions.md`
- `docs/CODEMAP.md`
- `docs/AGENT_CONTEXT_PACKS.md`
- `docs/CURRENT_STATUS.md`
- `docs/VALIDATION_MATRIX.md`
- `docs/UI_CONTEXT.md`
- `docs/DESIGN_CONTEXT.md`
- `docs/DATA_MODEL.md`
- `docs/SECURITY_PRIVACY_CONTEXT.md`
- `docs/PRIVACY_CONTEXT.md`
- `docs/MANUAL_TEST_SCENARIOS.md`
- `docs/OPEN_ISSUES_AGENT.md`
- `docs/DEPLOYMENT_CONTEXT.md`
- `docs/MODEL_PROVIDER_CONTEXT.md`
- `docs/decisions/*.md`

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
