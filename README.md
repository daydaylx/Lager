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
| `docs/CURRENT_STATUS.md`      | Aktueller Projektstand für Agent-Handoff      |
| `docs/VALIDATION_MATRIX.md`   | Prüfkommandos pro Änderungstyp                |
| `docs/DATA_MODEL.md`          | Datenmodell, Storage und Persistenzregeln     |
| `docs/UI_UX_SPEC.md`          | UI-/UX-Regeln und visuelle Vorgaben           |
| `docs/PRODUCT_CONCEPT.md`     | Fachliche Spezifikation und Features          |

## Nicht in dieser App

- Offizielles IHK-Berichtsheft / Kammerformular
- PDF-Export
- Cloud-Sync oder Login
- Backend oder Server
- KI-Funktionen
- Mehrbenutzer-Verwaltung
- iOS-App

## Nächster Schritt

Siehe `TASKS.md` → manueller Android-Gerätetest und lokale Release-Signierung
für Phase 13.
