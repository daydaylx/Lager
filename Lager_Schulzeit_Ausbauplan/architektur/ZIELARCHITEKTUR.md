# Zielarchitektur

## Grundsatz

Der bestehende Berichtsheft-Kern bleibt eigenständig. Schul- und Lerndaten werden nicht in `DailyEntry` hineingezogen.

## Zielstruktur

```text
lib/
├── core/
│   ├── domain/
│   │   ├── occupation/
│   │   ├── curriculum/
│   │   └── exam/
│   └── school/
│       ├── models/
│       ├── storage/
│       └── services/
├── features/
│   ├── today/
│   ├── week/
│   ├── school/
│   ├── templates/
│   └── profile/
```

Die konkrete Verschiebung vorhandener `occupation.dart`-Dateien ist **kein Muss** für Phase 28. Keine reine Ordnerrefaktorierung ohne funktionalen Nutzen.

## Verantwortlichkeiten

### `DailyEntry`
- Berichtsheft-/Tagesdaten
- Betrieb/Abwesenheit
- kompatibler Schul-Snapshot
- bestehende Wochen- und Reportfunktion

### `SchoolEntry`
- strukturierter Schultag
- mehrere Lernfelder/Fächer an einem Tag
- Themen pro Block
- Schulnotiz

### `SchoolTask`
- Hausaufgabe/Arbeitsblatt/Lernauftrag/Projekt
- optional Curriculum-Bezug
- Fälligkeit und Status

### `SchoolAssessment`
- Klassenarbeit/Test/Lernkontrolle/Präsentation/mündliche Leistung
- Datum, Status, optional Ergebnis

### `CurriculumRegistry`
- statische fachliche Definitionen
- Beruf + Region + Jahr
- Lernfelder und allgemeine Fächer

### `ExamRegistry`
- ab Phase 39
- getrennt von Curriculum
- Zuordnung von Lerninhalten zu Prüfungsbereichen

## Kopplungsregel

`SchoolEntry` ist die strukturierte Wahrheit für den Schulbereich.

Beim Speichern aktualisiert ein Koordinator den passenden Berichtsheft-Snapshot. Es darf nicht zwei unabhängig editierbare Wahrheiten geben.
