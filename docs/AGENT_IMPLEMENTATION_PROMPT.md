> ⚠️ **HISTORISCHES DOKUMENT** — Dieser Prompt wurde verwendet, um die App initial zu bootstrappen.
> Die App ist bereits implementiert (Phase 5 abgeschlossen). Dieses Dokument nicht als Bauanweisung lesen.
> Für den aktuellen Stand: `docs/CURRENT_STATUS.md` → `TASKS.md` → `docs/AGENT_CONTEXT_PACKS.md`

---

# AGENT_IMPLEMENTATION_PROMPT.md

# Ursprünglicher Bootstrap-Prompt (Konzept-Referenz)

## Rolle

Du bist ein erfahrener Mobile-App-Entwickler mit Fokus auf Flutter, lokale Datenspeicherung, saubere Architektur und moderne Mobile-UI.

Du entwickelst eine kleine private Android-App namens **Berichtsheft-Merker Lagerlogistik**.

Die App soll Auszubildenden im Bereich Lagerlogistik helfen, täglich kurz festzuhalten, welche Tätigkeiten sie gemacht haben, damit sie am Ende der Woche ihr schriftliches Berichtsheft leichter ausfüllen können.

Wichtig:

Die App ersetzt kein offizielles Berichtsheft. Sie ist nur eine private Gedächtnisstütze.

---

## Ziel

Erstelle eine moderne, einfache Flutter-App mit echter App-Wirkung.

Die App soll:

- lokal auf dem Gerät speichern
- ohne Login funktionieren
- keine Cloud verwenden
- keine externe API verwenden
- keine PDF-Funktion in V1 enthalten
- kein Backend benötigen
- auf Android ausgerichtet sein
- später als APK baubar sein

Der wichtigste Nutzungsfall:

```text
App öffnen
heutigen Tag sehen
Tätigkeiten auswählen
optional kurze Notiz schreiben
speichern
am Ende der Woche Zusammenfassung sehen
```

---

## Harte Einschränkungen

Baue in Version 1 NICHT:

- Login
- Cloud-Sync
- Backend
- PDF-Export
- digitale Unterschrift
- Ausbilderportal
- Mehrbenutzerverwaltung
- KI-Chat
- Kalender-Sync
- offizielles Kammerformular
- überladene Einstellungen

Diese Funktionen sind bewusst ausgeschlossen.

Wenn du sie trotzdem einbaust, ist das ein Fehler.

---

## Technische Zielrichtung

Verwende:

- Flutter
- Dart
- lokale Speicherung
- klare Ordnerstruktur
- sauberes State Management
- moderne Material-3-nahe UI
- Android als Hauptziel

Bevorzuge eine Architektur, die für eine kleine App nicht übertrieben ist.

Keine Enterprise-Architektur für eine Mini-App. Kein Architekturtheater.

Die App soll wartbar sein, aber nicht unnötig kompliziert.

---

## Gewünschte App-Struktur

Screens:

1. Onboarding
2. Heute
3. Woche
4. Vorlagen
5. Profil

Navigation:

- Bottom Navigation
- Heute als Startscreen nach abgeschlossenem Onboarding

---

## Screen 1: Onboarding

Beim ersten Start soll ein kurzes Onboarding erscheinen.

### Onboarding Schritt 1

Zweck erklären:

```text
Diese App hilft dir, täglich kurz festzuhalten, was du in der Ausbildung gemacht hast.
Sie ersetzt nicht dein offizielles Berichtsheft, sondern hilft dir beim Erinnern.
```

### Onboarding Schritt 2

Ausbildungsberuf auswählen:

- Fachlagerist/in
- Fachkraft für Lagerlogistik

### Onboarding Schritt 3

Ausbildungsjahr auswählen:

- 1. Ausbildungsjahr
- 2. Ausbildungsjahr
- 3. Ausbildungsjahr

### Onboarding Schritt 4

Abschluss:

```text
Fertig. Du kannst jetzt deinen ersten Tag eintragen.
```

Danach soll die App direkt zum Heute-Screen wechseln.

---

## Screen 2: Heute

Der Heute-Screen ist der wichtigste Screen.

Er soll beim Öffnen der App direkt angezeigt werden.

### Inhalt

- Titel: Heute
- aktuelles Datum
- Status des Tages
- Tagestyp-Auswahl
- Bereichsauswahl
- Tätigkeitsauswahl
- Besonderheiten
- optionale Notiz
- Speichern-Button

### Tagestypen

- Betrieb
- Berufsschule
- Frei
- Urlaub
- Krank
- Feiertag
- Sonstiges

### Bereichsauswahl bei Betrieb

- Wareneingang
- Lager
- Transport
- Kommissionierung
- Verpackung
- Versand
- Retoure
- Inventur

### Besonderheiten

- unter Anleitung
- selbstständig
- neue Aufgabe gelernt
- Problem aufgetreten
- Kontrolle durchgeführt
- Fehler korrigiert
- wiederholt/geübt

### Anforderungen

- Tätigkeiten als große antippbare Chips oder Karten
- ausgewählte Tätigkeiten klar sichtbar markieren
- eigene Tätigkeit hinzufügen
- eigene Tätigkeit optional als Vorlage speichern
- Speichern-Button gut erreichbar
- keine kleinen Checkboxen
- kein Formularmonster

---

## Screen 3: Woche

Der Wochen-Screen zeigt eine Kalenderwoche.

### Inhalt

- Kalenderwoche
- Fortschritt
- Montag bis Sonntag
- Status pro Tag
- kurze Zusammenfassung je Tag
- fehlende Tage markieren
- Button: Wochenzusammenfassung anzeigen

### Beispiel

```text
KW 25
4 von 5 Tagen eingetragen

Montag
Betrieb · Wareneingang · 4 Tätigkeiten

Dienstag
Betrieb · Kommissionierung · 3 Tätigkeiten

Mittwoch
Berufsschule · 2 Themen

Donnerstag
Kein Eintrag

Freitag
Betrieb · Versand · 5 Tätigkeiten
```

### Wochenzusammenfassung

Die Zusammenfassung soll die Tagesdaten geordnet anzeigen.

Beispiel:

```text
Montag:
- Ware angenommen
- Lieferung geprüft
- Ware eingelagert

Dienstag:
- Auftrag kommissioniert
- Ware verpackt

Donnerstag:
- kein Eintrag
```

Diese Zusammenfassung ist keine PDF-Funktion. Sie wird nur in der App angezeigt.

---

## Screen 4: Vorlagen

Der Vorlagen-Screen verwaltet Tätigkeitsvorlagen.

### Funktionen

- Tätigkeiten anzeigen
- nach Kategorie filtern
- eigene Tätigkeit hinzufügen
- eigene Tätigkeit bearbeiten
- Tätigkeit deaktivieren
- Nutzungshäufigkeit berücksichtigen

Vordefinierte Tätigkeiten sollen nicht gelöscht werden. Sie können deaktiviert werden.

Eigene Tätigkeiten dürfen bearbeitet werden.

---

## Screen 5: Profil

Der Profil-Screen bleibt einfach.

### Inhalte

- Ausbildungsberuf
- Ausbildungsjahr
- optional Name
- optional Betrieb
- Info: Daten bleiben lokal auf dem Gerät
- lokale Daten löschen

Keine überladene Einstellungsseite.

---

## Vordefinierte Tätigkeitskategorien

### Wareneingang

- Ware angenommen
- Lieferung anhand des Lieferscheins geprüft
- Menge kontrolliert
- Artikelnummern verglichen
- Verpackung auf Schäden geprüft
- beschädigte Ware gemeldet
- Ware ausgepackt
- Ware sortiert
- Wareneingang dokumentiert
- Ware für die Einlagerung vorbereitet

### Einlagerung / Lagerung

- Ware eingelagert
- Lagerplatz gesucht
- Ware nach Lagerordnung einsortiert
- Lagerbestand geprüft
- Ware umgelagert
- Lagerplatz beschriftet
- Mindesthaltbarkeitsdatum kontrolliert
- Ordnung und Sauberkeit im Lager hergestellt
- Lagerfläche vorbereitet
- Ware gegen Beschädigung gesichert

### Innerbetrieblicher Transport

- Ware mit Hubwagen transportiert
- Ware mit Rollwagen transportiert
- Ware zum vorgesehenen Lagerplatz gebracht
- Ware zur Versandzone gebracht
- Transportwege freigehalten
- Fördermittel geprüft
- Sicherheitsvorgaben beim Transport beachtet

### Kommissionierung

- Kundenauftrag kommissioniert
- Artikel nach Pickliste zusammengestellt
- Ware aus dem Lager entnommen
- Artikel gescannt
- Menge kontrolliert
- Fehlbestand gemeldet
- kommissionierte Ware bereitgestellt
- Auftrag auf Vollständigkeit geprüft

### Verpackung

- Ware verpackt
- passende Verpackung ausgewählt
- Paket gepolstert
- Paket verschlossen
- Versandlabel angebracht
- Ware für den Versand vorbereitet
- Ladeeinheit zusammengestellt
- Verpackungsmaterial aufgefüllt

### Versand / Verladung

- Sendung für den Versand vorbereitet
- Versandpapiere geprüft
- Lieferschein beigelegt
- Paket beschriftet
- Ware zur Verladung bereitgestellt
- LKW-Beladung unterstützt
- Ladungssicherung beachtet
- Ware auf Palette gestapelt
- Palette foliert
- Versandbereich aufgeräumt

### Bestandskontrolle / Inventur

- Lagerbestand gezählt
- Bestand mit System verglichen
- Fehlmengen gemeldet
- Inventur unterstützt
- Artikel gezählt
- Bestandsabweichung dokumentiert
- Lagerkennzahlen besprochen

### Retouren / Reklamation

- Retoure angenommen
- zurückgesendete Ware geprüft
- beschädigte Ware aussortiert
- Reklamation dokumentiert
- Ware wieder eingelagert
- nicht verwendbare Ware gekennzeichnet

### Berufsschule

- Fachunterricht besucht
- Lernfeld bearbeitet
- Aufgaben im Bereich Lagerlogistik bearbeitet
- Warenannahme theoretisch behandelt
- Lagerarten besprochen
- Kommissionierung besprochen
- Verpackung und Versand behandelt
- Arbeitssicherheit behandelt
- Wirtschafts- und Sozialkunde gehabt
- Klassenarbeit geschrieben
- Unterrichtsinhalte wiederholt

### Sicherheit / Ordnung / Qualität

- persönliche Schutzausrüstung getragen
- Sicherheitsvorschriften beachtet
- Arbeitsplatz gereinigt
- Verkehrswege freigehalten
- Verpackungsmüll entsorgt
- Qualität der Ware kontrolliert
- Arbeitsanweisung beachtet
- unter Anleitung gearbeitet
- selbstständig gearbeitet
- neue Aufgabe gelernt

---

## Datenmodell auf Konzeptebene

### DailyEntry

Enthält:

- id
- date
- dayType
- area
- selectedActivities
- customActivities
- specialFlags
- note
- status
- createdAt
- updatedAt

### ActivityTemplate

Enthält:

- id
- title
- category
- recommendedTrainingYears
- isDefault
- isCustom
- isActive
- usageCount
- createdAt
- updatedAt

### UserProfile

Enthält:

- trainingOccupation
- trainingYear
- optionalName
- optionalCompany
- onboardingCompleted

---

## UI-Anforderungen

Die App soll modern und appig wirken.

Pflicht:

- Material-3-nahe Gestaltung
- Bottom Navigation
- große Touchflächen
- abgerundete Karten
- Chips für schnelle Auswahl
- klare Statusanzeigen
- keine Textwände
- kein Web-App-Gefühl
- kein Adminpanel-Look
- keine winzigen Formulare

Designrichtung:

- ruhig
- freundlich
- modern
- hell
- übersichtlich
- wenig visuelles Chaos

Statusfarben:

- Grün: vollständig / gespeichert
- Gelb oder Orange: begonnen / teilweise
- Rot oder Koralle: fehlt
- Grau: neutral

---

## Akzeptanzkriterien

Die Implementierung gilt nur dann als brauchbar, wenn:

- die App ohne Backend läuft
- Onboarding funktioniert
- Heute-Screen funktioniert
- Einträge lokal gespeichert werden
- gespeicherte Einträge nach App-Neustart erhalten bleiben
- Tätigkeiten auswählbar sind
- eigene Tätigkeiten hinzugefügt werden können
- Wochenübersicht gespeicherte Tage anzeigt
- fehlende Tage erkennbar sind
- Wochenzusammenfassung angezeigt werden kann
- Bottom Navigation funktioniert
- UI auf Smartphone-Größe gut bedienbar ist
- keine ausgeschlossenen Funktionen eingebaut wurden

---

## Arbeitsmodus

Arbeite in dieser Reihenfolge:

1. Analysiere die Anforderungen.
2. Schlage eine saubere Projektstruktur vor.
3. Schlage die wichtigsten Datenmodelle vor.
4. Schlage das State-Management vor.
5. Schlage lokale Speicherung vor.
6. Plane die Screens und Komponenten.
7. Erstelle erst danach die Implementierung.

Wichtig:

Vor der Implementierung zuerst einen kurzen Plan ausgeben.

Keine unnötigen Rückfragen, außer eine Entscheidung ist wirklich blockierend.

---

## Definition of Done

Das Projekt ist in Version 1 fertig, wenn:

- eine lauffähige Flutter-App existiert
- das Onboarding funktioniert
- Tagesnotizen erstellt und gespeichert werden können
- Tätigkeiten aus Lagerlogistik-Vorlagen gewählt werden können
- eigene Tätigkeiten ergänzt werden können
- Wochenübersicht funktioniert
- Wochenzusammenfassung funktioniert
- Profil gespeichert wird
- Daten lokal bleiben
- die App optisch wie eine moderne Mobile-App wirkt
- Android-Build grundsätzlich möglich ist

---

## Wichtiger Hinweis

Baue nicht zu viel.

Der Zweck der App ist nicht, ein perfektes Berichtsheftsystem zu sein.

Der Zweck ist:

```text
Jeden Tag schnell merken, was gemacht wurde,
damit das schriftliche Berichtsheft am Wochenende leichter wird.
```

Alles, was diesen Zweck nicht direkt unterstützt, gehört nicht in Version 1.
