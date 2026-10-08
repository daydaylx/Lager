# Phase 28 – Ausbildungsprofil erweitern

## Ziel

`Kaufmann/Kauffrau im Einzelhandel` als eigenständigen Ausbildungsberuf unterstützen und das Wahlqualifikationsmodell so vorbereiten, dass Verkäufer und Kaufmann fachlich korrekt abbildbar sind.

## Änderungen

- `TrainingOccupation.kaufmannEinzelhandel` additiv ergänzen.
- Jahre 1–3 erlauben.
- Bestehende Einzelhandelsbereiche soweit möglich wiederverwenden.
- Kein duplizierter Tätigkeitskatalog nur wegen des neuen Berufs.
- Wahlqualifikationen fachlich in Grund- und Vertiefungsauswahl trennen.
- Alte Verkäufer-Storage-Werte kompatibel halten.

## Nicht tun

- Verkäufer intern einfach in Kaufmann umbenennen.
- Jahr 3 als Sonderfall des Verkäuferprofils modellieren.
- alte Enum-Namen ändern.

## Abnahme

- bestehende Profile laden unverändert,
- Kaufmann Jahr 1–3 auswählbar,
- Verkäufer weiterhin nur Jahr 1–2,
- Berufswechsel validiert Wahlqualifikationen,
- Profil-/Persistenztests grün.
