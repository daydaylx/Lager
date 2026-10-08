# Phase 29 – CurriculumRegistry

## Ziel

Berufsschulstoff nicht mehr nur als generische Tätigkeitsvorlagen behandeln, sondern als stabile fachliche Struktur.

## Umsetzung

Ein `CurriculumRegistry` liefert `CurriculumPack`s anhand von:

```text
region + occupation + trainingYear
```

Startregion: `DE-SN`.

`CurriculumUnit` unterstützt mindestens:

- Lernfeld,
- allgemeines Fach,
- Wahl-/Zusatzbereich,
- benutzerdefinierten Eintrag.

## Anforderungen

- stabile IDs,
- lesbare Codes (`LF 1`, `LF 8`),
- Titel,
- Jahrzuordnung,
- keine Identifikation nur über Lernfeldnummer,
- statische Daten ohne Netzwerk.

## Abnahme

- jeder unterstützte Beruf liefert ein valides Curriculum,
- Jahrfilter korrekt,
- IDs eindeutig,
- Fachlagerist und Fachkraft dürfen unterschiedliche LF-Mappings besitzen,
- Unit-Tests gegen Duplikate und ungültige Jahre.
