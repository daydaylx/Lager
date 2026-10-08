# Phase 33 – Berufsschul-Check-in und Berichtsheft-Integration

## Ziel

Ein Berufsschultag wird nicht mehr über die normale Tätigkeitsauswahl erfasst, sondern über einen eigenen schnellen Flow.

## Flow

### Schritt 1 – Unterricht auswählen
Mehrfachauswahl von Lernfeldern/Fächern.

### Schritt 2 – Themen
Für jeden ausgewählten Block können mehrere kurze Themen erfasst werden.

### Schritt 3 – Optionales Mitnehmen
- Aufgabe anlegen,
- Klassenarbeit/Test anlegen,
- private Notiz.

### Schritt 4 – Prüfen und speichern
Kompakte Zusammenfassung.

## Integration

`SchoolEntry` ist die strukturierte Schulquelle.

Ein `SchoolEntryCoordinator` synchronisiert daraus den kompatiblen Berichtsheft-/DailyEntry-Anteil für denselben Tag.

## Konsistenzregeln

- SchoolEntry ändern → Berichtsheft-Snapshot aktualisieren.
- SchoolEntry löschen → Schulanteil des Tages konsistent behandeln.
- kein unabhängiges Editieren derselben Schuldaten an zwei Stellen.
- Wochenansicht zeigt weiterhin verständlich `Berufsschule · N Themen`.

## Abnahme

Ein Nutzer kann in 30–60 Sekunden einen realistischen Schultag speichern.
