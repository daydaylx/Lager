# DATA_MODEL.md — Datenmodell-Referenz

Dieses Dokument beschreibt die Dart-Datenstrukturen und ihre geplanten Erweiterungen.
**Status: Phase-3-Modelle und Enums implementiert. DailyEntry wird seit Phase 4 mit Hive CE persistiert.**

Vollständiger Tätigkeitskatalog (87 Einträge): `lib/core/data/default_activities.dart`

---

## Enums

```dart
enum DayType {
  betrieb,        // normaler Arbeitstag im Betrieb
  berufsschule,   // Berufsschultag
  frei,           // Freier Tag / Wochenende
  urlaub,
  krank,
  feiertag,
  sonstiges,
}

enum TrainingArea {
  // Bereiche im Betrieb — nur relevant wenn dayType == betrieb
  wareneingang,
  lager,
  transport,
  kommissionierung,
  verpackung,
  versand,
  inventur,
  retouren,
}

enum ActivityCategory {
  // Kategorien für Tätigkeitsvorlagen
  wareneingang,
  einlagerung,
  transport,
  kommissionierung,
  verpackung,
  versand,
  inventur,
  retouren,
  berufsschule,
  sicherheit,     // Sicherheit/Ordnung/Qualität
}

enum TrainingOccupation {
  fachlagerist,           // Fachlagerist/in (2 Jahre)
  fachkraftLagerlogistik, // Fachkraft für Lagerlogistik (3 Jahre)
}

enum SpecialFlag {
  // Besonderheiten beim Tageseintrag
  selbststaendig,
  unterAnleitung,
  neuesGelernt,
  problemAufgetreten,
  kontrolle,
  fehlerKorrigiert,
  wiederholt,
}
```

---

## Modelle

`DailyEntry` und `ActivityTemplate` sind implementiert. Eigene Vorlagen werden
in Hive CE gespeichert und über einen Aktivstatus aus der neuen Auswahl entfernt,
ohne historische Tageseinträge unlesbar zu machen.

### DailyEntry

```dart
class DailyEntry {
  final String id;                        // Datum im Format yyyy-MM-dd
  final DateTime date;                    // Datum des Eintrags
  final DayType dayType;                  // Tagtyp
  final TrainingArea? area;               // nur wenn dayType == betrieb
  final List<String> selectedActivities;  // IDs aus ActivityTemplate
  final List<SpecialFlag> specialFlags;   // Besonderheiten
  final String? note;                     // optionale Freitext-Notiz
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### ActivityTemplate

```dart
class ActivityTemplate {
  final String id;                  // stabile, eindeutige Katalog-ID
  final String title;               // Anzeigetext, z.B. "Wareneingangsprüfung durchführen"
  final ActivityCategory category;  // Kategorie
  final bool isCustom;              // true bei selbst angelegten Tätigkeiten
  final bool isActive;              // false = nur noch für historische Einträge sichtbar
}
```

### UserProfile

```dart
class UserProfile {
  final TrainingOccupation occupation; // Ausbildungsberuf
  final int trainingYear;              // 1, 2 oder 3
  final String? name;                  // optional — kein Login
  final String? company;               // optional — Betriebsname
  final bool onboardingCompleted;      // steuert ob Onboarding gezeigt wird
}
```

---

## Dateistruktur

```
lib/core/
  models/
    daily_entry.dart
    activity_template.dart
  enums/
    day_type.dart
    training_area.dart
    activity_category.dart
    special_flag.dart
  data/
    default_activities.dart    ← 87 vordefinierte Tätigkeiten als const List
  storage/
    daily_entry_storage.dart
    daily_entry_adapter.dart
    hive_daily_entry_storage.dart
    activity_template_storage.dart
    activity_template_adapter.dart
    hive_activity_template_storage.dart
```

`UserProfile` und `TrainingOccupation` werden aktuell durch
`StoredProfile`, Konstanten und SharedPreferences abgebildet.

---

## Persistenz

**Speicher-Technologie:** Hive CE für Tageseinträge, SharedPreferences für das Profil.

Hive-CE-Boxen:
| Box-Name | Typ | Inhalt |
|---|---|---|
| `'entries'` | `Box<DailyEntry>` | Alle Tageseinträge, Schlüssel = Datum als String `'yyyy-MM-dd'` |
| `'custom_templates'` | `Box<ActivityTemplate>` | Eigene Tätigkeiten mit stabilem Schlüssel und Aktivstatus |

`DailyEntry` verwendet einen handgeschriebenen Adapter mit dauerhaft reserviertem
`typeId: 0`. Enum-Werte werden als Namen gespeichert, damit keine zusätzlichen
Enum-Adapter benötigt werden.

`ActivityTemplate` verwendet `typeId: 1`. Das Feld `isActive` ist
rückwärtskompatibel: Fehlt es in bestehenden Hive-Daten, wird `true` verwendet.
Eigene Tätigkeiten werden deaktiviert statt hart gelöscht.

**SharedPreferences** (ab Phase 2):

- `'onboarding_completed'` (bool)
- Profildaten als Alternative zu Hive in Phase 2 (einfacher für MVP)

---

## Tagestyp-Logik

| DayType                          | area erforderlich? | Tätigkeiten wählbar?         |
| -------------------------------- | ------------------ | ---------------------------- |
| betrieb                          | ja                 | ja                           |
| berufsschule                     | nein               | ja (Kategorie: berufsschule) |
| frei / urlaub / krank / feiertag | nein               | nein                         |
| sonstiges                        | nein               | nein; Besonderheiten/Notiz   |

---

## Vordefinierte Tätigkeitskategorien (Übersicht)

Vollständige Liste mit 87 Einträgen: `docs/AGENT_IMPLEMENTATION_PROMPT.md`

| Kategorie          | Beispiel-Tätigkeiten                                            |
| ------------------ | --------------------------------------------------------------- |
| Wareneingang       | Lieferschein prüfen, Ware ausladen, Wareneingangsprüfung        |
| Einlagerung/Lager  | Einlagerung nach Plan, Lagerplatzverwaltung, FIFO kontrollieren |
| Transport          | Flurförderzeug bedienen, Transportwege planen                   |
| Kommissionierung   | Kommissionierliste abarbeiten, Picklisten bearbeiten            |
| Verpackung         | Waren verpacken, Versandlabels erstellen                        |
| Versand/Verladung  | Lieferung vorbereiten, Laderampe koordinieren                   |
| Inventur           | Bestand zählen, Differenzen erfassen                            |
| Retouren           | Retoure erfassen, Rücksendung prüfen                            |
| Berufsschule       | Lernfeld X, Klassenarbeit, Gruppenarbeit                        |
| Sicherheit/Ordnung | 5S-Methode, Sicherheitsrundgang, Unfallverhütung                |
