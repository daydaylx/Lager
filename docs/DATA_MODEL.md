# DATA_MODEL.md — Datenmodell-Referenz

Dieses Dokument beschreibt die aktuell implementierten Dart-Datenstrukturen und
Persistenzverträge. Der ausführbare Code bleibt die Quelle der Wahrheit.

**Status:** `DailyEntry` und eigene Tätigkeiten werden mit Hive CE persistiert;
Profil, Onboarding, Reminder und Theme-Preset liegen in SharedPreferences.
Abgeleitete optionale KI-Berichte liegen getrennt in einer eigenen Hive-Box und
verändern weder `DailyEntry` noch seinen Adapter.

Vollständiger Tätigkeitskatalog in `lib/core/data/default_activities.dart`:
132 unveränderte Lagerlogistik-IDs plus den bestehenden Verkäuferkatalog sowie
zusätzliche Kaufmann-/Möbel-IDs. Neue IDs liegen ausschließlich in den
`einzelhandel_*`- und `einzelhandel_moebel_*`-Namespaces. Kaufmann-Inhalte und
Berufsschulthemen werden nach Jahr, Wahlqualifikation und optionalem
Branchenprofil gefiltert; historische Einträge und eigene Tätigkeiten bleiben
auflösbar.

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
  List<String> wahlqualifikationen,
  String? industryProfile,
  bool onboardingCompleted,
});
```

Es gibt bewusst keine persistierte `UserProfile`-Klasse. Der
`TrainingOccupation`-Enum und die Wahlqualifikationen werden als stabile
String-Werte in SharedPreferences gespeichert; bestehende Lagerprofile bleiben
ohne Wahlqualifikation gültig. Verkäufer/innen speichern weiterhin genau eine
Wahlqualifikation. Kaufleute speichern genau drei gültige
`EinzelhandelWahlqualifikation`-Werte als JSON-Liste; mindestens eine stammt aus
der ersten offiziellen Gruppe. `industryProfile` ist optional und wird aktuell
nur für Kaufleute im Einzelhandel mit `moebel_einrichtung` gespeichert.

Gültige Ausbildungsberufe:

| String-Wert | Bedeutung | Zulässige Ausbildungsjahre |
| ----------- | --------- | -------------------------- |
| `fachlagerist` | Fachlagerist/in | 1, 2 |
| `fachkraft_lagerlogistik` | Fachkraft für Lagerlogistik | 1, 2, 3 |
| `verkaeufer` | Verkäufer/in | 1, 2 |
| `kaufmann_einzelhandel` | Kaufmann/-frau im Einzelhandel | 1, 2, 3 |

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
    default_activities.dart              ← kombinierter Standardkatalog
    verkaeufer_activities.dart            ← bestehende `verkauf_*`-IDs
    einzelhandel_activities.dart          ← Kaufmann-/Jahr-3-/Schulthemen
    einzelhandel_moebel_activities.dart   ← optionales Möbelprofil
  domain/
    occupation.dart            ← Berufe, Jahre und Wahlqualifikationen
    occupation_config.dart     ← Berufskonfiguration
    occupation_registry.dart   ← zentrale Registry für alle Berufe/Branchen
    industry_profile.dart      ← optionale Branchenprofile
    activity_catalog_metadata.dart ← Jahr-/Branchen-/WQ-Filter ohne Hive-Schema
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
  `wahlqualifikation`, `wahlqualifikationen`, `industry_profile`
- Reminder: `reminder_enabled`, `reminder_times`, `reminder_weekdays`
- Darstellung: `theme_preset`

Reminder-Zeiten und Wochentage werden als JSON-Listen gespeichert und beim Laden
normalisiert. `theme_preset` speichert den stabilen Namen des `ThemePreset`.

---

## Tagestyp-Logik

| DayType                          | Bereiche erforderlich?  | Tätigkeiten wählbar?         |
| -------------------------------- | ----------------------- | ---------------------------- |
| betrieb                          | ja, mindestens einer    | ja                           |
| berufsschule                     | nein                    | ja (Kategorie: berufsschule) |
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
Lager/Bestand, Reklamation/Service und Werbung/Verkaufsförderung. Der
Kaufmannkatalog ergänzt kaufmännische Steuerung, Beschaffung, Bestand,
Onlinehandel, Personal sowie Berufsschulthemen des dritten Jahres. Das optionale
Möbelprofil ergänzt Beratung, Materialkunde, Raum-/Küchenplanung, Auftrag,
Lieferung/Montage und Nachbetreuung. Wahlqualifikationen und Branche beeinflussen
nur Filter und Empfehlungssortierung; sie ändern keine IDs oder Hive-TypeIDs.
