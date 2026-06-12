# DATA_MODEL.md — Datenmodell-Referenz

Dieses Dokument beschreibt die geplanten Dart-Datenstrukturen.
**Status: Konzept — noch nicht als Dart-Code vorhanden. Implementierung ab Phase 3/4.**

Vollständiger Tätigkeitskatalog (100+ Einträge): `docs/AGENT_IMPLEMENTATION_PROMPT.md`

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

## Konzept-Modelle

### DailyEntry

```dart
class DailyEntry {
  final String id;                        // UUID, z.B. mit package:uuid
  final DateTime date;                    // Datum des Eintrags
  final DayType dayType;                  // Tagtyp
  final TrainingArea? area;               // nur wenn dayType == betrieb
  final List<String> selectedActivities;  // IDs aus ActivityTemplate
  final List<String> customActivities;    // freie Texteingaben
  final List<SpecialFlag> specialFlags;   // Besonderheiten
  final String? note;                     // optionale Freitext-Notiz
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### ActivityTemplate

```dart
class ActivityTemplate {
  final String id;                  // UUID
  final String title;               // Anzeigetext, z.B. "Wareneingangsprüfung durchführen"
  final ActivityCategory category;  // Kategorie
  final bool isDefault;             // true = vordefiniert, false = nutzerdefiniert
  final bool isActive;              // kann vom User deaktiviert werden
  final int usageCount;             // Häufigkeit der Nutzung (für Sortierung)
  final DateTime createdAt;
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

## Zieldateistruktur

Ab Phase 3 werden Models als Dart-Dateien erstellt:

```
lib/core/
  models/
    daily_entry.dart
    activity_template.dart
    user_profile.dart
  enums/
    day_type.dart
    training_area.dart
    activity_category.dart
    training_occupation.dart
    special_flag.dart
  data/
    default_activities.dart    ← 100+ vordefinierte Tätigkeiten als const List
```

---

## Persistenz (ab Phase 4)

**Speicher-Technologie:** Hive (noch nicht eingebaut)

Hive-Boxen:
| Box-Name | Typ | Inhalt |
|---|---|---|
| `'entries'` | `Box<DailyEntry>` | Alle Tageseinträge, Schlüssel = Datum als String `'yyyy-MM-dd'` |
| `'templates'` | `Box<ActivityTemplate>` | Vorlagen, Schlüssel = UUID |
| `'profile'` | `Box<UserProfile>` | Genau ein Eintrag (Key `'profile'`) |

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
| sonstiges                        | nein               | optional                     |

---

## Vordefinierte Tätigkeitskategorien (Übersicht)

Vollständige Liste mit 100+ Einträgen: `docs/AGENT_IMPLEMENTATION_PROMPT.md`

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
