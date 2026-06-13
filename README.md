# Berichtsheft-Merker Lagerlogistik

Private Android-App als Gedächtnisstütze für Auszubildende in der Lagerlogistik.

Die App hilft dabei, täglich kurz festzuhalten, was getan wurde — damit das schriftliche Berichtsheft am Wochenende leichter geführt werden kann. Sie ersetzt kein offizielles Berichtsheft.

## Zielgruppe

Auszubildende im Bereich Lagerlogistik (Fachlagerist/in, Fachkraft für Lagerlogistik).

## Technik

- Flutter / Dart
- Android-first
- Lokale Speicherung (kein Backend, keine Cloud)
- Material 3

## Setup

Flutter SDK installieren: https://docs.flutter.dev/get-started/install

```bash
/home/d/flutter/bin/flutter pub get
/home/d/flutter/bin/flutter run
```

Flutter liegt unter `/home/d/flutter/bin/flutter` — nicht im System-PATH.

Zielplattform: Android. iOS wird nicht aktiv unterstützt.

## Projektdokumente

| Datei                                 | Inhalt                                                       |
| ------------------------------------- | ------------------------------------------------------------ |
| `docs/PRODUCT_CONCEPT.md`             | Fachliche Spezifikation, Features, Phasen                    |
| `docs/UI_UX_SPEC.md`                  | Design-Richtlinien, Screen-Layouts                           |
| `docs/AGENT_IMPLEMENTATION_PROMPT.md` | ⚠️ Historisch — Bootstrap-Dokument; nur zur Konzept-Referenz |
| `TASKS.md`                            | Aktueller Arbeitsstand nach Phasen                           |
| `PROJECT_STATUS.md`                   | Was existiert, was fehlt noch                                |
| `AGENTS.md`                           | Regeln für alle Coding-Agenten                               |
| `CLAUDE.md`                           | Kurzregeln für Claude Code                                   |
| `DECISIONS.md`                        | Architekturentscheidungen                                    |

## Nicht in dieser App

- Offizielles IHK-Berichtsheft / Kammerformular
- PDF-Export
- Cloud-Sync oder Login
- Backend oder Server
- KI-Funktionen
- Mehrbenutzer-Verwaltung
- iOS-App

## Nächster Schritt

Siehe `TASKS.md` → Phase 6: Vorlagenverwaltung.
