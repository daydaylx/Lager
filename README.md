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

Unterstützte lokale und CI-Toolchain:

- Flutter `3.32.1`
- Dart `3.8.1`
- Android Gradle Plugin `8.7.3`
- Kotlin `2.1.0`
- Gradle `8.12`
- Android NDK `27.0.12077973`

Toolchain- und Dependency-Upgrades werden nur gemeinsam in einer separat
geplanten Modernisierung durchgeführt.

```bash
/home/d/flutter/bin/flutter pub get
/home/d/flutter/bin/flutter run
```

Flutter liegt unter `/home/d/flutter/bin/flutter` — nicht im System-PATH.

Zielplattform: Android. iOS wird nicht aktiv unterstützt.

Es sind keine Environment-Variablen, API-Schlüssel, Backend-Dienste oder
Cloud-Zugänge erforderlich.

## Android-Release

Application ID: `com.daydaylx.berichtsheftmerker`

Release-Builds verwenden bewusst **nicht** den Debug-Schlüssel. Für einen
signierten lokalen Release-Build muss `android/key.properties` angelegt werden:

```properties
storeFile=/absoluter/pfad/zum/release-key.jks
storePassword=...
keyAlias=...
keyPassword=...
```

`android/key.properties` und Keystore-Dateien sind ignoriert und dürfen nicht
committet werden. Ohne diese Datei erzeugt der Release-Build nur ein
unsigniertes, nicht zur Installation oder Verteilung bestimmtes APK.

Alle App-Daten bleiben lokal. Android-Cloud-Backup und Gerätetransfer sind für
die App deaktiviert.

## Projektdokumente

| Datei                         | Inhalt                                        |
| ----------------------------- | --------------------------------------------- |
| `AGENTS.md`                   | Zentrale Regeln für alle Coding-Agenten       |
| `CLAUDE.md`                   | Claude-Code-Einstieg (verweist auf AGENTS.md) |
| `TASKS.md`                    | Aktueller Arbeitsstand nach Phasen            |
| `DECISIONS.md`                | Architekturentscheidungen                     |
| `docs/CODEMAP.md`             | Kompakte Projektkarte und wichtige Pfade      |
| `docs/AGENT_CONTEXT_PACKS.md` | Taskbezogene Kontextpakete für Agenten        |
| `docs/AGENT_HANDOFF_TEMPLATE.md` | Einheitliche Vorlage für Agenten-Übergaben  |
| `docs/CURRENT_STATUS.md`      | Aktueller Projektstand für Agent-Handoff      |
| `docs/VALIDATION_MATRIX.md`   | Prüfkommandos pro Änderungstyp                |
| `docs/DATA_MODEL.md`          | Datenmodell, Storage und Persistenzregeln     |
| `docs/UI_UX_SPEC.md`          | UI-/UX-Regeln und visuelle Vorgaben           |
| `docs/PRODUCT_CONCEPT.md`     | Historisches Produktkonzept, keine Roadmap    |

Tool-spezifische Dateien wie `CLAUDE.md`, `CODEX.md`, `GEMINI.md`,
`opencode.json`, Cursor- und Copilot-Regeln bleiben bewusst dünn und verweisen
auf `AGENTS.md`.

## Nicht in dieser App

- Offizielles IHK-Berichtsheft / Kammerformular
- PDF-Export
- Cloud-Sync oder Login
- Backend oder Server
- KI-Funktionen
- Mehrbenutzer-Verwaltung
- iOS-App

## Nächster Schritt

Siehe `TASKS.md` → Phase 19: Release-QA-Durchlauf nach `docs/QA_RELEASE_CHECKLIST.md`
auf echtem Android-Gerät. Release-Signierung ist abgeschlossen.
