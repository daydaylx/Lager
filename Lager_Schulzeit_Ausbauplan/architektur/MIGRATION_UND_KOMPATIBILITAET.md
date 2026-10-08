# Migration und Kompatibilität

## Unverhandelbar

Bestehende Installationen müssen ihre aktuellen Daten behalten.

## Regeln

1. Bestehende `TrainingOccupation`-Storage-Keys nicht umbenennen.
2. Neue Berufe nur additiv ergänzen.
3. Bestehende `DailyEntry`-Hive-Feldnummern/Adapter nicht unnötig ändern.
4. Schulboxen separat öffnen; ein Fehler in optionalen Schulboxen darf bestehende Tagesdaten nicht löschen.
5. Bestehende Verkäuferprofile ohne neue Kaufmann-Felder bleiben gültig.
6. Profilwechsel müssen ungültige Wahlqualifikationskombinationen sichtbar behandeln.
7. Export erhält eine explizite Schema-Version.

## Fail-safe

Wenn die Schul-Persistenz nicht geöffnet werden kann:

- Berichtsheftdaten nicht löschen,
- keine automatische Box-Neuerstellung mit Datenverlust,
- sichtbare Retry-/Fehlerbehandlung für den Schulbereich,
- Today/Week nur dann blockieren, wenn eine echte Konsistenzverletzung besteht.
