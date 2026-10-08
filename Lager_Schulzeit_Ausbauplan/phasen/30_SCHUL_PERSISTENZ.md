# Phase 30 – Schul-Persistenz

## Ziel

Schultage, Aufgaben und Leistungsnachweise unabhängig vom Berichtsheft speichern.

## Modelle

- `SchoolEntry`
- `SchoolBlock`
- `SchoolTask`
- `SchoolAssessment`

## Storage

Abstraktionen analog zu bestehenden Storage-Interfaces erstellen.

Hive-Boxen:

- `school_entries`
- `school_tasks`
- `school_assessments`

## Tests

- Speichern/Laden,
- Update,
- Löschen,
- Neustart/Box-Reopen,
- unbekannte/alte Felder fehlertolerant,
- mehrere Schulblöcke an einem Tag,
- Sortierung nach Datum/Fälligkeit.

## Abnahme

Kein bestehender `DailyEntry`-Adapter muss für diese Phase geändert werden.
