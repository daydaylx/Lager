# Berichtsheft-Merker

Private Android-App als Gedächtnisstütze für Auszubildende in der Lagerlogistik
und im Einzelhandel.

Die App hilft dabei, täglich kurz festzuhalten, was getan wurde — damit das schriftliche Berichtsheft am Wochenende leichter geführt werden kann. Sie ersetzt kein offizielles Berichtsheft.

## Zielgruppe

Auszubildende in den unterstützten Profilen Fachlagerist/in, Fachkraft für
Lagerlogistik und Verkäufer/in. Für Verkäufer/innen stehen Ausbildungsjahre 1
und 2 sowie eine von vier Wahlqualifikationen zur Verfügung.

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
export PATH="$PWD/.tooling/flutter/bin:$PATH"
flutter pub get
flutter run
```

Für die lokale Verifikation sind diese Tools in `.tooling/` abgelegt:

- Flutter SDK `3.32.1` (Dart `3.8.1`), `.tooling/flutter`
- Eclipse Temurin JDK `17.0.20.1+1`, `.tooling/jdk-17`
- Android SDK Command-line Tools, Paketrevision `15859902` (`sdkmanager` `22.0`)
- Android SDK Platforms `33` (Revision `3`), `34` (Revision `3`), `35` (Revision `2`) und `37.0` (Revision `2`)
- Android Build Tools `34.0.0`, `35.0.0` und `36.0.0`, Platform Tools `37.0.1`
- Android NDK `27.0.12077973` und CMake `3.22.1` (vom Android-Build benötigt)
- Android- und Gradle-Nutzerverzeichnisse samt Gradle-Wrapper-Distribution `8.12` liegen unter `.tooling/`

`scripts/verify.sh` richtet `JAVA_HOME`, `ANDROID_SDK_ROOT`, `ANDROID_USER_HOME`
und `GRADLE_USER_HOME` auf diese lokalen Pfade ein. Andere Installationsorte
lassen sich über `FLUTTER_BIN`, `JAVA_HOME` und `ANDROID_SDK_ROOT` vorgeben.
Die Android-SDK-Lizenzen wurden für diese lokale Arbeitskopie akzeptiert. Der
gesamte Ordner `.tooling/` ist git-ignoriert und wird nicht eingecheckt.

Zielplattform: Android. iOS wird nicht aktiv unterstützt.

### Optionale private Berichtsnachbearbeitung

Die App bleibt ohne zusätzliche Konfiguration vollständig lokal. Die optionale
OpenRouter-Nachbearbeitung ist erst aktiv, wenn du die ignorierte Datei
`config/openrouter.private.json` aus `config/openrouter.example.json` anlegst
und eigene Werte für `OPENROUTER_ENABLED`, `OPENROUTER_MODEL_ID` und
`OPENROUTER_API_KEY` setzt. Starte einen privaten Build dann mit:

```bash
flutter run --dart-define-from-file=config/openrouter.private.json
```

Die Datei, ihr Schlüssel und ein damit gebautes APK dürfen weder committet noch
als CI- oder GitHub-Artefakt veröffentlicht werden. Vor Aktivierung müssen für
das gewählte Modell ZDR und Structured Outputs verfügbar sein; das individuelle
Budget wird beim privaten OpenRouter-Key gesetzt.

Für den normalen lokalen Betrieb sind keine Environment-Variablen oder
API-Schlüssel erforderlich. Die optionale Berichtsnachbearbeitung bleibt ohne
private `--dart-define`-Konfiguration deaktiviert; ihr Schlüssel darf nie in
Git, CI oder öffentliche APK-Artefakte gelangen.

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

Alle Primärdaten bleiben lokal. Nur bei bewusst aktivierter optionaler
Berichtsnachbearbeitung werden positiv gelistete Berichtsdaten an OpenRouter
übertragen; `privateNote`, Profil- und interne IDs bleiben immer lokal.
Android-Cloud-Backup und Gerätetransfer sind für die App deaktiviert.

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
- KI-Chat oder freie LLM-Funktionen (nur die optional deaktivierte, eng begrenzte Berichtsnachbearbeitung ist separat dokumentiert)
- Mehrbenutzer-Verwaltung
- iOS-App

## Nächster Schritt

Siehe `TASKS.md` → Phase 19: Release-QA-Durchlauf nach `docs/QA_RELEASE_CHECKLIST.md`
auf echtem Android-Gerät. Release-Signierung ist abgeschlossen.
