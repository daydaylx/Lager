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
- KI-Chat, Sprachsteuerung oder freie LLM-Autovervollständigung; ausschließlich die dokumentierte, optional deaktivierte OpenRouter-Nachbearbeitung gespeicherter Berichte ist erlaubt
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

## Pull Requests und Übergaben

- Änderungen laufen über Pull Requests gegen `main`. Die CI (`Flutter CI`,
  siehe `.github/workflows/flutter-ci.yml`) prüft `flutter analyze`,
  `flutter test` und den Debug-APK-Build — sie muss grün sein.
- Beim Erstellen/Überschreiben eines PR wird das Pflichttemplate
  `.github/pull_request_template.md` automatisch eingeblendet: Summary,
  Validation, Documentation Freshness Check und Risk Check sind auszufüllen.
- Übergaben an den nächsten Agenten folgen `docs/AGENT_HANDOFF_TEMPLATE.md`
  (kurz: Aufgabe, Dateien, Tests, Risiken, Doku-Check, nächster Schritt).

---

## Documentation Freshness Rule

Vor jeder Übergabe prüfen, ob die Änderung Doku oder Agenten-Kontext berührt, und nur dann aktualisieren:

- **Aktualisieren bei:** geänderten Setup-/Build-/Test-Befehlen, Struktur oder wichtigen Pfaden, Architektur oder Datenmodell, UI/Navigation, Persistenz und Export, Datenschutz/Berechtigungen/Secrets, CI/Release, Agenten-Workflow oder Nicht-Zielen, Status oder abgeschlossener Arbeit, Entscheidungen, die als ADR in `DECISIONS.md` gehören.
- **Nicht aktualisieren bei:** kleinen internen Details, bereits korrekter Doku oder Dopplung einer anderen kanonischen Quelle. Doku kompakt halten, nichts „der Vollständigkeit halber“ ergänzen.
- **Welche Dateien:** nur vorhandene und betroffene. Kandidaten sind `README.md`, die Tool-Dateien (`CLAUDE.md`, `GEMINI.md`, `CODEX.md`, `opencode.json`, `.cursor/rules/agents.mdc`, `.github/copilot-instructions.md`), `docs/*` (u. a. `CODEMAP`, `AGENT_CONTEXT_PACKS`, `CURRENT_STATUS`, `VALIDATION_MATRIX`, `UI_UX_SPEC`, `DATA_MODEL`, `PRIVACY_CONTEXT`, `QA_REMINDER_CHECKLIST`), `DECISIONS.md`, `PROJECT_STATUS.md`, `TASKS.md`.
- **Handoff:** Jede Übergabe enthält den Abschnitt „Documentation Freshness Check“ mit Ergebnis `No documentation update needed`, `Documentation updated` oder `Documentation update still required`. Vorlage: `docs/AGENT_HANDOFF_TEMPLATE.md`.

**Quelle der Wahrheit bei Widerspruch** (von oben nach unten): Code → Build-/Konfigurationsdateien → Skripte → CI-Workflows → `AGENTS.md` → `docs/` → tool-spezifische Dateien. Tool-Dateien bleiben dünn und duplizieren keine langen Inhalte aus `AGENTS.md` oder `docs/`.

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

Flutter muss im PATH liegen oder mit vollem Pfad aufgerufen werden (Stand 2026-10-07 auf diesem Rechner nicht installiert).

```bash
flutter pub get       # nach pubspec-Änderungen
flutter analyze       # nach jeder Dart-Änderung — muss 0 Issues zeigen
flutter test          # nach Feature-Implementierung
flutter run           # App starten (Gerät/Emulator)
flutter build apk --debug  # Android-Konfiguration prüfen
```

---

## Technologie-Stack

- Flutter 3.32.1 / Dart 3.8.1
- Android-first (Kotlin-Wrapper generiert)
- Material 3
- Lokale Speicherung: Hive CE für Tageseinträge und eigene Tätigkeiten
- SharedPreferences: Profil, Onboarding, Reminder und Theme-Preset
- Deterministischer lokaler Tagesberichtsgenerator als verbindlicher Fallback; optionale OpenRouter-Nachbearbeitung nur über die dokumentierte Servicegrenze, mit ZDR und ohne private Notizen
- Kein Backend, keine Cloud-Synchronisation, kein Login
