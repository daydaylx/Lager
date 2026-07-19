# PRODUCT_CONCEPT.md  
# Berichtsheft-Merker Lagerlogistik

> **Historisches Produktkonzept.** Dieses Dokument erklärt Ursprung und
> Produktziel, ist aber keine aktive Roadmap oder technische Spezifikation.
> Aktuelle Grenzen stehen in `AGENTS.md` und `DECISIONS.md`; aktuelle Aufgaben in
> `TASKS.md`.

## 1. Projektname

**Berichtsheft-Merker Lagerlogistik**

Alternative Namen:

- Azubi-Merker Lager
- Lagerlogistik-Merker
- Wochenhelfer Lager
- Ausbildungsnotizen Lager

Empfohlener Name:

**Berichtsheft-Merker Lagerlogistik**

Der Name ist klar, verständlich und vermeidet den falschen Eindruck, dass die App ein offizielles Berichtsheftsystem ersetzt.

---

## 2. Kurzbeschreibung

Der **Berichtsheft-Merker Lagerlogistik** ist eine einfache mobile App für Auszubildende im Bereich Lagerlogistik.

Die App hilft dabei, täglich kurz festzuhalten, welche Tätigkeiten im Betrieb oder in der Berufsschule gemacht wurden. Ziel ist, am Ende der Woche das schriftliche Berichtsheft leichter und vollständiger führen zu können.

Die App ersetzt nicht das offizielle Berichtsheft. Sie dient ausschließlich als private Gedächtnisstütze.

---

## 3. Hauptziel

Die Nutzerin soll jeden Ausbildungstag in unter einer Minute speichern können.

Der Ablauf soll sein:

```text
App öffnen
Tag prüfen
Bereich auswählen
Tätigkeiten antippen
optional kurze Notiz schreiben
speichern
fertig
```

Wenn die App mehr Aufwand macht als eine normale Notiz, ist sie gescheitert.

---

## 4. Zielgruppe

Primäre Zielgruppe:

- Auszubildende im Bereich Lagerlogistik
- Fachlagerist/in
- Fachkraft für Lagerlogistik
- Nutzung hauptsächlich auf Android-Smartphones
- private Nutzung als Wochenhilfe für das schriftliche Berichtsheft

Nicht-Zielgruppe:

- Ausbildungsbetriebe
- Ausbilderverwaltung
- Kammern
- Schulen
- mehrere Nutzer in einem System

---

## 5. Problem

Berichtshefte werden häufig nicht täglich geschrieben. Dadurch entstehen typische Probleme:

- Tätigkeiten werden vergessen
- Tage bleiben leer
- Einträge werden zu allgemein
- Formulierungen wiederholen sich
- Berufsschultage werden ungenau dokumentiert
- am Wochenende muss aus dem Gedächtnis geraten werden

Die App löst genau dieses Problem: Sie sammelt täglich kleine, verwertbare Stichpunkte.

---

## 6. Kernidee

Die App ist keine Formularverwaltung, sondern ein schneller Tages-Merker.

Jeder Tag besteht aus:

- Datum
- Tagestyp
- Bereich
- Tätigkeiten
- Besonderheiten
- kurze Notiz

Am Ende der Woche zeigt die App eine einfache Zusammenfassung, die als Grundlage für das schriftliche Berichtsheft dient.

---

## 7. App-Charakter

Die App soll sich wie eine normale moderne Handy-App anfühlen.

Sie soll nicht wirken wie:

- eine Webseite im App-Gewand
- ein Behördenformular
- ein Tabellenprogramm
- ein Admin-Dashboard
- ein überladenes Schulportal

Sie soll wirken wie:

- eine kleine Alltags-App
- schnell
- freundlich
- übersichtlich
- ruhig
- modern
- praktisch

---

## 8. MVP-Funktionen

### 8.1 Tagesnotiz

Für jeden Tag kann ein Eintrag erstellt werden.

Felder:

- Datum
- Tagestyp
- Ausbildungsbereich
- Tätigkeiten
- eigene Tätigkeit
- Besonderheiten
- kurze Notiz
- Status

Beispiel:

```text
Dienstag, 16.06.2026

Typ:
Betrieb

Bereich:
Wareneingang

Tätigkeiten:
- Ware angenommen
- Lieferung anhand des Lieferscheins geprüft
- Ware eingelagert

Besonderheit:
- unter Anleitung gearbeitet

Notiz:
Neue Abläufe bei der Warenannahme erklärt bekommen.
```

---

### 8.2 Tagestypen

Mögliche Tagestypen:

- Betrieb
- Berufsschule
- Frei
- Urlaub
- Krankheit
- Feiertag
- Sonstiges

Je nach Tagestyp sollen passende Eingaben angezeigt werden.

Beispiel:

Bei **Betrieb**:

- Bereich auswählen
- Tätigkeiten auswählen
- Besonderheit auswählen
- Notiz schreiben

Bei **Berufsschule**:

- Unterrichtsthemen auswählen
- Lernfeld oder Fach eintragen
- kurze Notiz schreiben

Bei **Frei / Urlaub / Krankheit / Feiertag**:

- nur speichern
- keine Tätigkeiten nötig

---

### 8.3 Ausbildungsprofil

Beim ersten Start soll die App ein Ausbildungsprofil abfragen.

Felder:

- Ausbildungsberuf
- Ausbildungsjahr
- optional Name
- optional Betrieb

Ausbildungsberufe:

- Fachlagerist/in
- Fachkraft für Lagerlogistik

Ausbildungsjahre:

- 1. Ausbildungsjahr
- 2. Ausbildungsjahr
- 3. Ausbildungsjahr

Das Ausbildungsjahr wird im Profil gespeichert. Eine Filterung oder Sortierung
der Tätigkeiten nach Ausbildungsjahr ist aktuell nicht implementiert.

---

### 8.4 Tätigkeitsauswahl

Die App bietet vordefinierte Tätigkeiten passend zur Lagerlogistik.

Die Nutzerin kann Tätigkeiten per Chip, Checkbox oder Karte auswählen.

Eigene Tätigkeiten können ergänzt werden.

Eigene Tätigkeiten werden im Vorlagen-Screen dauerhaft gespeichert und können
deaktiviert oder reaktiviert werden. Eine nur für einen einzelnen Tag angelegte
freie Tätigkeit ist nicht implementiert.

---

### 8.5 Wochenübersicht

Die Wochenübersicht zeigt alle Tage einer Kalenderwoche.

Beispiel:

```text
KW 25 / 2026

Montag: Betrieb - Wareneingang - 4 Tätigkeiten
Dienstag: Betrieb - Kommissionierung - 3 Tätigkeiten
Mittwoch: Berufsschule - 2 Themen
Donnerstag: leer
Freitag: Betrieb - Versand - 5 Tätigkeiten

Fehlende Tage:
- Donnerstag
```

Ziel:

Die Nutzerin sieht sofort, welche Tage vollständig sind und wo noch etwas fehlt.

---

### 8.6 Wochenzusammenfassung

Die App erzeugt aus den Tagesnotizen eine einfache Wochenübersicht.

Beispiel:

```text
Diese Woche:

Montag:
- Ware angenommen
- Lieferung geprüft
- Ware eingelagert

Dienstag:
- Kundenauftrag kommissioniert
- Artikel gescannt
- Auftrag auf Vollständigkeit geprüft

Mittwoch:
- Berufsschule: Lagerarten und Kommissionierung behandelt

Donnerstag:
- kein Eintrag

Freitag:
- Ware verpackt
- Versandlabel angebracht
- Sendung bereitgestellt
```

Diese Übersicht wird nicht als offizieller Export verstanden. Sie dient nur als Vorlage zum handschriftlichen oder schriftlichen Übertragen.

---

## 9. Lagerlogistik-Kategorien

### 9.1 Wareneingang

- Ware angenommen
- Lieferung anhand des Lieferscheins geprüft
- Liefermenge kontrolliert
- Artikelnummern mit Lieferpapieren abgeglichen
- Verpackung auf Schäden geprüft
- beschädigte Ware gemeldet
- Ware ausgepackt
- Ware sortiert
- Wareneingang dokumentiert
- Ware für die Einlagerung vorbereitet

---

### 9.2 Einlagerung / Lagerung

- Ware eingelagert
- geeigneten Lagerplatz ermittelt
- Ware nach Lagerordnung einsortiert
- Lagerbestand geprüft
- Ware umgelagert
- Lagerplatz beschriftet
- Mindesthaltbarkeitsdaten und FIFO-Reihenfolge kontrolliert
- Lagerbereich gereinigt und geordnet
- Lagerfläche vorbereitet
- Ware gegen Beschädigung gesichert

---

### 9.3 Innerbetrieblicher Transport

- Ware mit Hubwagen transportiert
- Ware mit Rollwagen transportiert
- Ware zum vorgesehenen Lagerplatz gebracht
- Ware zur Versandzone gebracht
- Transportwege kontrolliert und Hindernisse entfernt
- Fördermittel vor dem Einsatz geprüft
- Ware auf Ladungsträger umgesetzt und gesichert

---

### 9.4 Kommissionierung

- Kundenauftrag kommissioniert
- Artikel nach Pickliste zusammengestellt
- Ware aus dem Lager entnommen
- Artikel gescannt
- Menge kontrolliert
- Fehlbestand festgestellt und gemeldet
- kommissionierten Auftrag bereitgestellt
- Auftrag auf Vollständigkeit geprüft

---

### 9.5 Verpackung

- Ware transportsicher verpackt
- passende Verpackung ausgewählt
- Paket mit Füllmaterial gepolstert
- Paket verschlossen
- Versandlabel angebracht
- Ware für den Versand vorbereitet
- Ladeeinheit zusammengestellt
- Verpackungsmaterial aufgefüllt

---

### 9.6 Versand / Verladung

- Sendung für den Versand vorbereitet
- Versandpapiere geprüft
- Lieferschein beigelegt
- Paket beschriftet
- Ware zur Verladung bereitgestellt
- Lkw-Beladung unterstützt
- Ladung für den Transport gesichert
- Ware auf Palette gestapelt
- Palette foliert
- Versandbereich aufgeräumt

---

### 9.7 Bestandskontrolle / Inventur

- Lagerbestand gezählt
- Bestand mit System verglichen
- Fehlmengen gemeldet
- Zählarbeiten bei der Inventur durchgeführt
- Artikel gezählt
- Bestandsabweichung dokumentiert
- Lagerkennzahlen besprochen

---

### 9.8 Retouren / Reklamation

- Retoure angenommen
- zurückgesendete Ware geprüft
- beschädigte Ware aussortiert
- Reklamation dokumentiert
- Ware wieder eingelagert
- nicht verwendbare Ware gekennzeichnet

---

### 9.9 Berufsschule

- Fachinhalte zur Lagerlogistik bearbeitet
- Aufgaben zu einem Lernfeld bearbeitet
- Aufgaben im Bereich Lagerlogistik bearbeitet
- Warenannahme theoretisch behandelt
- Lagerarten besprochen
- Kommissionierung besprochen
- Verpackung und Versand behandelt
- Arbeitssicherheit behandelt
- Wirtschafts- und Sozialkunde bearbeitet
- Klassenarbeit geschrieben
- Unterrichtsinhalte wiederholt

---

### 9.10 Ordnung / Qualität / Unterweisung

- Arbeitsbereich gereinigt und geordnet
- Verpackungsabfälle getrennt und entsorgt
- Ware auf Qualitätsmängel geprüft
- Arbeitsbereich nach 5S geprüft und geordnet
- Qualitätsmangel festgestellt und gemeldet
- an einer Arbeitsschutzunterweisung teilgenommen
- Prüfpunkte einer Arbeitsanweisung nachvollzogen

Passive Pflichtaussagen und Angaben wie „unter Anleitung“ oder „selbstständig“
gehören nicht zu den Tätigkeiten; Letztere werden als Besonderheiten erfasst.

---

## 10. Funktionen, die bewusst nicht in Version 1 gehören

Nicht in V1:

- PDF-Export
- Cloud-Sync
- Login
- Mehrbenutzer-System
- Ausbilderzugang
- digitale Unterschrift
- Kalender-Sync
- KI-Chat
- offizielles Kammerlayout
- Web-Dashboard

Begründung:

Diese Funktionen lösen nicht das Kernproblem. Sie machen das Projekt größer, fehleranfälliger und schwerer nutzbar.

Der Kern ist:

```text
Nicht vergessen, was gemacht wurde.
```

Alles andere ist zweitrangig.

---

## 11. Technische Grundrichtung

Empfohlene Technik:

- Flutter
- lokale Speicherung
- Android-App als Hauptziel
- Android als einzige unterstützte Zielplattform
- kein Backend
- keine Cloud
- keine Anmeldung

Warum Flutter?

- echte App-Wirkung
- gute mobile Bedienung
- moderne UI möglich
- APK-Erstellung direkt möglich
- lokal speichernde Einzel-App passt gut zum Projekt

---

## 12. Erfolgskriterien

Die App ist erfolgreich, wenn:

- ein Tagesbericht in unter einer Minute gespeichert werden kann
- die Nutzerin die App freiwillig nutzt
- die Wochenübersicht wirklich beim Berichtsheft hilft
- fehlende Tage sofort sichtbar sind
- Tätigkeiten zur Lagerlogistik passen
- die Oberfläche modern und angenehm wirkt
- keine unnötigen Funktionen ablenken

Die App ist schlecht, wenn:

- sie wie eine Webseite wirkt
- sie zu viele Pflichtfelder hat
- sie mehr Arbeit macht als Papier
- sie mit unnötigen Features überladen ist
- die Bedienung nicht sofort verständlich ist
- Daten verloren gehen können

---

## 13. Historische Prioritäten

Die folgende Liste dokumentiert frühe Ideen und ist keine aktive Roadmap.
`TASKS.md` ist die einzige Quelle für aktuelle Phasen und offene Aufgaben.

### Phase 1: Nutzbarer Kern

- Onboarding
- Tagesnotiz
- Tätigkeitsauswahl
- eigene Tätigkeit hinzufügen
- lokale Speicherung
- Wochenübersicht

### Phase 2: Alltagstauglichkeit

- fehlende Tage anzeigen
- Wochenzusammenfassung
- Tätigkeit vom Vortag übernehmen
- zuletzt genutzte Tätigkeiten oben anzeigen
- Favoriten

### Phase 3: Komfort

- Tätigkeiten verwalten
- Ausbildungsjahr-Filter
- Berufsschulthemen besser erfassen
- einfache Formulierungshilfe
- lokales Backup

### Phase 4: Optional

- Erinnerungen
- APK-Release
- weitere Ausbildungsprofile

PDF-Export, KI-Funktionen, Cloud, Backup-Sync und iOS sind ohne neue explizite
Entscheidung ausgeschlossen.

---

## 14. Zusammenfassung

Der Berichtsheft-Merker Lagerlogistik ist eine kleine private App, die Auszubildenden im Lagerbereich hilft, tägliche Tätigkeiten schnell festzuhalten.

Sie ersetzt kein offizielles Berichtsheft, sondern verhindert, dass am Ende der Woche aus dem Gedächtnis geraten werden muss.

Der richtige Fokus ist:

- einfache Bedienung
- moderne App-Oberfläche
- passende Lagerlogistik-Tätigkeiten
- Wochenübersicht
- lokale Speicherung
- keine unnötige Bürokratie
