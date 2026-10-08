# Datenmodell

## CurriculumUnit

Vorgesehene Felder:

```text
id                stabile ID, z. B. de_sn_lager_fk_lf08
occupation        Ausbildungsberuf
region            zunächst DE-SN
trainingYear      1..3
unitType          learningField | generalSubject | elective | custom
displayCode       z. B. LF 8
title             z. B. Güter verladen
keywords          optionale Such-/Zuordnungshilfe
```

Keine globale Identität nur über `LF 8`.

## SchoolEntry

```text
id
date
blocks[]
createdAt
updatedAt
```

### SchoolBlock

```text
curriculumUnitId
topics[]
note?
```

Ein Tag kann mehrere Blocks besitzen.

## SchoolTask

```text
id
title
curriculumUnitId?
createdAt
dueDate?
status: open | done
type: homework | worksheet | learningTask | presentation | project | other
note?
```

## SchoolAssessment

```text
id
title
curriculumUnitId?
date
status: planned | completed
kind: classTest | test | learningCheck | presentation | oral | other
result?
note?
```

## Persistenz

Empfohlene getrennte Hive-Boxen:

```text
school_entries
school_tasks
school_assessments
```

Später:

```text
flashcards
review_state
```

## Export

Neues Exportformat mit `schemaVersion` einführen.

Beispiel logisch:

```text
schemaVersion: 2
profile
dailyEntries
templates
schoolEntries
schoolTasks
schoolAssessments
```

`Alle Daten löschen` muss alle neuen Boxen einbeziehen.
