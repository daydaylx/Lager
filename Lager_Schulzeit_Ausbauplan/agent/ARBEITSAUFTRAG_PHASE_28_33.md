# Arbeitsauftrag – Schulbasis Phase 28–33

Repository: `https://github.com/daydaylx/Lager`

Ausgangsbasis: aktuelles `main`. Vor Beginn Remote-Stand verifizieren und bestehende Agentenregeln (`AGENTS.md`, relevante Context Packs, Decisions, Data Model und UI/UX Spec) lesen.

## Ziel

Implementiere die Schulbasis als additiven Ausbau des bestehenden Berichtsheft-Merkers.

Der bestehende Tages-, Wochen-, Vorlagen-, Profil-, Reminder- und Berichtsmechanismus darf funktional nicht regressieren.

## Scope

### Phase 28 – Profil

- `Kaufmann/Kauffrau im Einzelhandel` ergänzen.
- Ausbildungsjahre 1–3.
- Bestehende Verkäuferprofile kompatibel halten.
- Wahlqualifikationsmodell so erweitern, dass Verkäufer und Kaufmann fachlich getrennt abbildbar sind.
- Keine bestehende persistierte Enum-/Storage-ID umbenennen.

### Phase 29 – Curriculum

- eigenständige Curriculum-Domäne einführen.
- `CurriculumUnit` mit stabiler ID, Beruf, Region, Jahr, Typ, Code und Titel.
- `CurriculumRegistry`/`CurriculumPack` einführen.
- Start mit `DE-SN`.
- Fachlagerist, Fachkraft Lagerlogistik, Verkäufer und Kaufmann getrennt abbilden.
- Allgemeine Unterrichtsfächer neben Lernfeldern unterstützen.

### Phase 30 – Persistenz

Neue eigenständige Modelle:

- SchoolEntry,
- SchoolBlock,
- SchoolTask,
- SchoolAssessment.

Separate Hive-Boxen und Storage-Abstraktionen verwenden.

`DailyEntry` nicht mit Schulorganisationsfeldern aufblasen.

### Phase 31 – Navigation

Bottom Navigation:

```text
Heute | Woche | Schule | Profil
```

Vorlagenverwaltung bleibt erhalten und wird über Profil/Einstellungen erreichbar.

### Phase 32 – Schule Home

Mobile-first, ruhig, kein Dashboard.

Anzeigen:

- heutiger Schulstatus,
- maximal 3 offene Aufgaben,
- nächste Klassenarbeit/Test,
- relevante aktuelle Lernfelder/Fächer.

Keine erfundenen Fortschrittsprozente.

### Phase 33 – Berufsschul-Flow

Bei `DayType.berufsschule` eigener Flow:

1. Lernfelder/Fächer mehrfach wählen,
2. Themen je Block erfassen,
3. optional Aufgabe/Assessment/private Notiz,
4. prüfen und speichern.

`SchoolEntry` ist die strukturierte Quelle. Ein klar abgegrenzter Koordinator aktualisiert den Berichtsheft-Snapshot für denselben Tag.

Es darf nicht zwei unabhängig editierbare Wahrheiten geben.

## Nicht-Ziele

Nicht implementieren:

- Karteikarten,
- Spaced Repetition,
- Fachrechnen,
- Prüfungsmodus,
- PDF/Foto-Materialverwaltung,
- Lern-KI,
- Cloud/Login,
- Lehrer-/Klassenfunktionen,
- Android-Aufgabenreminder.

## Migrationsanforderungen

- bestehende Profile unverändert lesbar,
- bestehende DailyEntry-Daten unverändert lesbar,
- vorhandene Verkäuferdaten nicht migrieren, wenn nicht nötig,
- additive Storage-Änderungen bevorzugen,
- kein Datenverlust bei Fehlern neuer Schulboxen.

## Tests

Mindestens:

- Occupation-/Jahresvalidierung,
- Verkäufer/Kaufmann-Migration,
- Curriculum-ID-Eindeutigkeit,
- Curriculum-Jahrfilter,
- SchoolEntry Persistence/Reopen,
- Multi-Block-Schultag,
- Task/Assessment Persistence,
- Navigation,
- Schule-Home-Zustände,
- Berufsschul-Flow,
- SchoolEntry → Berichtssynchronisierung,
- Edit-Synchronisierung,
- Export/Reset,
- 360×640,
- Textscale 1.5,
- bestehende Regressionstests.

## Validierung

```bash
./.tooling/flutter/bin/flutter analyze
./.tooling/flutter/bin/flutter test
bash scripts/check_repo_hygiene.sh
./.tooling/flutter/bin/flutter build apk --debug
```

## Abschlusskriterien

Der Block ist fertig, wenn ein Nutzer einen realistischen Berufsschultag mit mehreren Fächern/Lernfeldern in höchstens ca. 60 Sekunden erfassen kann und danach gleichzeitig:

- der strukturierte Schuleintrag existiert,
- Today/Woche konsistent bleiben,
- ein brauchbarer Berichtshefttext erzeugt wird,
- optionale Aufgabe/Assessment im Schulbereich auftaucht,
- Neustart keine Daten verliert,
- bestehende Berichtsheftdaten unverändert lesbar sind,
- alle Pflichtchecks grün sind.

## Arbeitsweise

- erst Repository- und Datenmodellprüfung,
- dann kurzer Implementierungsplan,
- kleine nachvollziehbare Commits pro Phase/Teilphase,
- keine opportunistischen Großrefactorings,
- Doku nach jeder abgeschlossenen Phase aktualisieren,
- bei Persistenzänderungen alte Daten explizit testen.
