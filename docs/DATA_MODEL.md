# DATA_MODEL.md — Datenmodell-Referenz

Dieses Dokument beschreibt die aktuell implementierten Dart-Datenstrukturen und
Persistenzverträge. Der ausführbare Code bleibt die Quelle der Wahrheit.

**Status:** `DailyEntry` und eigene Tätigkeiten werden mit Hive CE persistiert;
Profil, Onboarding, Reminder und Theme-Preset liegen in SharedPreferences.

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

### Profilrepräsentation

```dart
typedef StoredProfile = ({
  String? name,
  String? company,
  String? occupation,
  int? trainingYear,
  bool onboardingCompleted,
});
```

Es gibt bewusst keine persistierte `UserProfile`-Klasse und keinen
`TrainingOccupation`-Enum. Ausbildungsberufe werden als stabile String-Werte aus
`TrainingOccupationValues` gespeichert.

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

Reminder-Einstellungen liegen in `ReminderSettings`; das gewählte Farbtheme ist
ein `ThemePreset` aus `lib/app/theme.dart`.

---

## Persistenz

**Speicher-Technologie:** Hive CE für Tageseinträge und eigene Tätigkeiten;
SharedPreferences für kleine Einstellungen.

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

**SharedPreferences-Schlüssel:**

- Profil und Onboarding: `onboarding_completed`, `profile_name`,
  `profile_company`, `training_occupation`, `training_year`
- Reminder: `reminder_enabled`, `reminder_times`, `reminder_weekdays`
- Darstellung: `theme_preset`

Reminder-Zeiten und Wochentage werden als JSON-Listen gespeichert und beim Laden
normalisiert. `theme_preset` speichert den stabilen Namen des `ThemePreset`.

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

Kanonische vollständige Liste mit stabilen IDs:
`lib/core/data/default_activities.dart`

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
