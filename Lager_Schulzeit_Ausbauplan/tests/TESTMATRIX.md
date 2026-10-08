# Testmatrix

| Bereich | Mindesttests |
|---|---|
| Occupation | Berufe, gültige Jahre, Migration bestehender Profile |
| Wahlqualifikation | Verkäufer/Kaufmann-Regeln, Berufswechsel |
| Curriculum | eindeutige IDs, Jahrfilter, Beruffilter, Region |
| SchoolEntry | mehrere Blocks, Speichern/Laden/Ändern/Löschen |
| SchoolTask | Fälligkeit, offen/erledigt, Sortierung |
| SchoolAssessment | geplant/abgeschlossen, Ergebnis optional |
| Navigation | Schule statt Vorlagen, Vorlagen weiterhin erreichbar |
| School Home | Empty, heutiger Eintrag, Aufgaben, Assessment |
| Today Integration | Berufsschule startet School-Flow |
| Sync | SchoolEntry → Berichtsheft-Snapshot |
| Edit Sync | Schuländerung aktualisiert Bericht |
| Delete | definierte Konsistenz beim Löschen |
| Export | Schema-Version und neue Daten |
| Reset | alle Boxen werden gelöscht |
| Layout | 360×640, Textscale 1.5, Tastatur |
| Regression | bestehende Today/Week/Profile/Templates Tests |

## Pflichtchecks je Phase

```bash
./.tooling/flutter/bin/flutter analyze
./.tooling/flutter/bin/flutter test
bash scripts/check_repo_hygiene.sh
```

Bei UI-/Android-relevanten Änderungen zusätzlich:

```bash
./.tooling/flutter/bin/flutter build apk --debug
```
