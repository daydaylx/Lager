# DATA_MODEL.md — Datenmodell-Referenz

Dieses Dokument beschreibt die aktuell implementierten Dart-Datenstrukturen und
Persistenzverträge. Der ausführbare Code bleibt die Quelle der Wahrheit.

**Status:** `DailyEntry`, eigene Tätigkeiten und strukturierte Schul-Einträge,
Aufgaben und Leistungsnachweise werden mit Hive CE persistiert; Profil,
Onboarding, Reminder und Theme-Preset liegen in SharedPreferences. Abgeleitete
optionale KI-Berichte liegen getrennt in einer eigenen Hive-Box und verändern
weder `DailyEntry` noch seinen Adapter.

Vollständiger Tätigkeitskatalog in `lib/core/data/default_activities.dart`:
132 unveränderte Lagerlogistik-IDs plus 138 Verkäufer-IDs im ausschließlich
`verkauf_*`-Namespace. Verkäufer-Berufsschulthemen werden im Picker auf Jahr 1
bzw. 2 begrenzt; historische Einträge und eigene Tätigkeiten bleiben auflösbar.
Die Offline-Curriculum-Registry bildet sächsische Lernfelder berufs- und
jahrgangsbezogen ab. Allgemeine Fachnamen/Jahrgangszuordnungen werden nicht
ergänzt, wenn die offiziellen Quellen sie nicht benennen.

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
  verkaufsflaeche,
  kundenberatung,
  kasse,
  warenpraesentation,
  wareneingangVerkauf,
  lagerBestand,
  reklamationService,
  werbungVerkaufsfoerderung,
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
  sicherheit,     // Ordnung/Qualität/Unterweisung (persistierter Enum-Name)
  verkaufsflaeche,
  kundenberatung,
  kasse,
  warenpraesentation,
  wareneingangVerkauf,
  lagerBestand,
  reklamationService,
  werbungVerkaufsfoerderung,
  preis,
  allgemein,
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
  final String? department;               // optionale Verkäufer-Abteilung/Warengruppe
  final List<TrainingArea> areas;         // nur wenn dayType == betrieb
  final List<String> selectedActivities;  // IDs aus ActivityTemplate
  final List<SpecialFlag> specialFlags;   // Besonderheiten
  final String? reportNote;               // Ergänzung für das Berichtsheft
  final String? privateNote;              // Private Notiz (niemals im Bericht)
  final List<AdhocActivity> adhocActivities; // Einmalige Freitext-Tätigkeiten
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
  final bool isActive;              // false = nicht vorausgewählt, ggf. reaktivierbar
  final String? subcategory;        // optionale Arbeitsschritt-Untergruppe
}
```

### Profilrepräsentation

```dart
typedef StoredProfile = ({
  String? name,
  String? company,
  String? occupation,
  int? trainingYear,
  String? wahlqualifikation,
  List<String> vertiefungswahlqualifikationen,
  bool onboardingCompleted,
});
```

Es gibt bewusst keine persistierte `UserProfile`-Klasse. Der
`TrainingOccupation`-Enum und die `Wahlqualifikation` werden als stabile
String-Werte in SharedPreferences gespeichert; bestehende Lagerprofile bleiben
ohne Wahlqualifikation gültig.

Gültige Ausbildungsberufe:

| String-Wert | Bedeutung | Zulässige Ausbildungsjahre |
| ----------- | --------- | -------------------------- |
| `fachlagerist` | Fachlagerist/in | 1, 2 |
| `fachkraft_lagerlogistik` | Fachkraft für Lagerlogistik | 1, 2, 3 |
| `verkaeufer` | Verkäufer/in | 1, 2 |
| `kaufmann_einzelhandel` | Kaufmann/Kauffrau im Einzelhandel | 1, 2, 3 |

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
    default_activities.dart    ← Lagerkatalog + Verkäuferkatalog
    verkaeufer_activities.dart ← 138 `verkauf_*`-IDs, davon 20 Schul-Themen
  domain/
    occupation.dart            ← Berufe, Jahre und Wahlqualifikationen
    occupation_config.dart     ← Berufskonfiguration
    occupation_registry.dart   ← zentrale Registry
    curriculum_unit.dart       ← statische Curriculum- und Fachtypen
    curriculum_registry.dart   ← DE-SN-Lernfelder nach Beruf/Jahr
  school/
    models/                    ← SchoolEntry, SchoolTask, SchoolAssessment
    storage/                   ← Hive- und In-Memory-Schulspeicher
    services/                  ← Synchronisation zum DailyEntry-Snapshot
  ai/
    ai_report_cache.dart
    hive_ai_report_cache.dart
    report_enhancement_coordinator.dart
    resolved_report.dart
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
| `'ai_reports'` | `Box<String>` | Abgeleitete Berichte, Fingerprint, Modell-/Prompt-Version, Status und begrenzte Retry-Metadaten |
| `'school_entries'` | `Box<String>` | Strukturierte Schultage und private Schulnotiz als JSON |
| `'school_tasks'` | `Box<String>` | Aufgaben mit optionaler Fälligkeit und Status |
| `'school_assessments'` | `Box<String>` | Leistungsnachweise mit Datum, Art und optionalem Ergebnis |

**DailyEntryStorage-Schnittstelle:**
- `loadByDate(DateTime date)` — Lädt Eintrag für ein bestimmtes Datum
- `loadAll()` — Lädt alle Einträge (für Häufigkeit-Berechnung)
- `save(DailyEntry entry)` — Speichert/aktualisiert einen Eintrag
- `delete(String id)` — Löscht einen Eintrag (wird für Undo-Funktionalität verwendet)

`DailyEntry` verwendet einen handgeschriebenen Adapter mit dauerhaft reserviertem
`typeId: 0`. Enum-Werte werden als Namen gespeichert, damit keine zusätzlichen
Enum-Adapter benötigt werden. Das aktuelle `areas`-Feld liest auch ältere
Einträge mit einem einzelnen gespeicherten Bereich. Das optionale Feld
`department` wird als neues Hive-Feld 11 gespeichert; bei älteren Einträgen
fehlt es und wird als `null` gelesen. Es wird nur für Betriebstage aus dem
Tagesentwurf übernommen.
Gespeicherte Enum-Strings werden über zentrale Parser gelesen; unbekannte Werte
werfen eine lesbare `FormatException` statt eines unklaren `byName`-Fehlers.

`ai_reports` speichert keine primären Eingabedaten und keine API-Schlüssel oder
Requestkörper. Ein Cache-Eintrag ist nur bei gleichem Fingerprint,
Modell und `promptVersion` gültig; Undo, Einzellöschung und „Alle Daten löschen"
bereinigen ihn. Fehler oder Korruption des Caches dürfen lokale Einträge und den
lokalen Bericht nie blockieren.

`DailyEntryStorage.loadAll()` liefert die lokal gespeicherten Einträge für
abgeleitete UI-Funktionen wie „Häufig genutzt"; es speichert keine zusätzlichen
Zähler. `department` ist eine kurze freiwillige Kontextangabe (z. B. „Textil"
oder „Kasse") und darf keine Kundennamen, Kaufdaten oder Identifikationsnummern
enthalten.

`ActivityTemplate` verwendet `typeId: 1`. Die Felder `isActive` und
`subcategory` sind rückwärtskompatibel: Fehlt `isActive`, wird `true`
verwendet; fehlt `subcategory`, bleibt die Untergruppe `null`. Eigene
Tätigkeiten werden deaktiviert statt hart gelöscht. Vordefinierte Tätigkeiten
werden im UI zusätzlich über stabile ID-Bereiche fachlich untergruppiert.
Passive Pflichtaussagen und durch `SpecialFlag` abgedeckte Altvorlagen stehen in
`retiredDefaultActivityIds`: Sie bleiben zur Auflösung historischer Einträge im
Katalog, werden aber in Vorlagenverwaltung, Suche und neuer Auswahl nicht mehr
angeboten.

**SharedPreferences-Schlüssel:**

- Profil und Onboarding: `onboarding_completed`, `profile_name`,
  `profile_company`, `training_occupation`, `training_year`,
  `wahlqualifikation`, `vertiefungswahlqualifikationen`
- Reminder: `reminder_enabled`, `reminder_times`, `reminder_weekdays`
- Darstellung: `theme_preset`

Reminder-Zeiten und Wochentage werden als JSON-Listen gespeichert und beim Laden
normalisiert. `theme_preset` speichert den stabilen Namen des `ThemePreset`.

---

## Tagestyp-Logik

| DayType                          | Bereiche erforderlich?  | Tätigkeiten wählbar?         |
| -------------------------------- | ----------------------- | ---------------------------- |
| betrieb                          | ja, mindestens einer    | ja                           |
| berufsschule                     | nein                    | ja; strukturierte Schuldaten liegen zusätzlich separat in `SchoolEntry` |
| frei / urlaub / krank / feiertag | nein                    | nein                         |
| sonstiges                        | nein                    | nein; Besonderheiten/Notiz   |

---

## Vordefinierte Tätigkeitskategorien (Übersicht)

Kanonische vollständige Liste mit stabilen IDs:
`lib/core/data/default_activities.dart`

| Kategorie          | Beispiel-Tätigkeiten                                            |
| ------------------ | --------------------------------------------------------------- |
| Wareneingang       | Lieferschein prüfen, Scanner-Erfassung, Begleitpapiere          |
| Einlagerung/Lager  | Einlagerung, Lagerplatz im System prüfen, FIFO anwenden         |
| Transport          | Hubwagen, Transportauftrag nachvollziehen, Ladehilfsmittel      |
| Kommissionierung   | Pickliste, Entnahme scannen, Fehlbestand melden                 |
| Verpackung         | Packliste abgleichen, Füllmaterial, Versandlabel                |
| Versand/Verladung  | Versandpapiere, Tourenliste, Palette sichern                    |
| Inventur           | Bestand zählen, Scanner-Zählung, Doppelzählung unterstützen     |
| Retouren           | Retoure erfassen, Retourengrund, Prüfung bereitstellen          |
| Berufsschule       | Lernfeld, Ladungssicherung, Warenwirtschaft, Qualitätsgrundlagen |
| Ordnung/Qualität/Unterweisung | 5S, Qualitätsprüfung, Qualitätsmangel melden, Unterweisung |

Für Verkäufer/innen ergänzt `verkaeufer_activities.dart` die Bereiche
Verkaufsfläche, Kundenberatung, Kasse, Warenpräsentation, Warenannahme,
Lager/Bestand, Reklamation/Service und Werbung/Verkaufsförderung. Die vier
Wahlqualifikationen beeinflussen die Empfehlungssortierung; sie ändern keine
IDs oder Hive-TypeIDs.
