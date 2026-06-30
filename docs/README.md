# Historisches Planungsarchiv

Dieses Verzeichnis enthält aktive technische Dokumentation und historische
Konzeptunterlagen der bereits implementierten Android-App.

Erstellt am: 2026-06-12

## Historische Dokumente

1. `PRODUCT_CONCEPT.md`  
   Ursprüngliche Produktidee und frühe Roadmap. Keine aktive Bauanweisung.

2. `AGENT_IMPLEMENTATION_PROMPT.md`
   Ursprünglicher Bootstrap-Prompt. Darf nicht als aktueller Auftrag verwendet werden.

## Aktive Dokumente

- `CURRENT_STATUS.md` — aktueller Agent-Handoff
- `AGENT_CONTEXT_PACKS.md` — Mindestkontext je Änderungstyp
- `CODEMAP.md` — aktuelle Architektur
- `DATA_MODEL.md` — aktuelle Daten- und Persistenzverträge
- `UI_UX_SPEC.md` — aktuelle UI-/UX-Regeln
- `PRIVACY_CONTEXT.md` — lokale Datenhaltung und No-Gos
- `VALIDATION_MATRIX.md` — erforderliche Prüfungen
- `QA_REMINDER_CHECKLIST.md` — offener manueller Android-Test
- `QA_RELEASE_CHECKLIST.md` — Release-QA auf echtem Gerät

## Ziel des Projekts

Die App soll Auszubildenden im Bereich Lagerlogistik helfen, täglich kurz Tätigkeiten festzuhalten, damit das schriftliche Berichtsheft am Ende der Woche einfacher geführt werden kann.

Die App ersetzt kein offizielles Berichtsheft. Sie ist nur eine private Gedächtnisstütze.

## Aktuelle technische Richtung

- Flutter
- Android-App
- lokale Speicherung
- kein Login
- keine Cloud
- kein Backend
- keine PDF-Funktion in Version 1

## Quelle der Wahrheit

Bei Abweichungen gelten zuerst Code, Build-Konfiguration, Tests und CI. Für
Agenten ist `AGENTS.md` im Repository-Root kanonisch.
