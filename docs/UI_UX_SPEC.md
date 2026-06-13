# UI_UX_SPEC.md  
# UI/UX-Spezifikation für Berichtsheft-Merker Lagerlogistik

## 1. Ziel der Oberfläche

Die App soll sich wie eine moderne, normale Handy-App anfühlen.

Sie darf nicht wirken wie:

- eine Webseite
- ein Formularsystem
- ein Behördenportal
- eine Tabellenansicht
- ein Admin-Dashboard

Die Nutzerin soll ohne Erklärung verstehen:

```text
Wo bin ich?
Was muss ich antippen?
Was ist gespeichert?
Was fehlt noch?
```

Die Oberfläche muss auf schnelle tägliche Nutzung ausgelegt sein.

---

## 2. Designrichtung

Gewünschter Stil:

- modern
- ruhig
- freundlich
- weich
- sauber
- alltagstauglich
- mobile-first
- nicht verspielt
- nicht technisch kalt
- nicht überladen

Die App soll angenehm wirken, aber nicht kindisch oder kitschig.

---

## 3. Visuelle Grundidee

Empfohlener Look:

- heller oder sanft gedämpfter Hintergrund
- abgerundete Karten
- große Touchflächen
- klare Icons
- deutliche Statusanzeigen
- dezente Akzentfarbe
- ruhige Typografie
- einfache Animationen

Die App soll ungefähr in diese Richtung gehen:

```text
Google Keep + moderne Android-App + kleiner Produktivitätshelfer
```

Nicht:

```text
Notion-Klon
Adminpanel
Schulportal
Excel-App
```

---

## 4. Farbkonzept

Empfohlene Farblogik:

### Hintergrund

- sehr helles Grau
- warmes Off-White
- optional dunkler Modus später

### Primärfarbe

Geeignete Richtungen:

- sanftes Blau
- Türkis
- Flieder
- ruhiges Grün

Nicht geeignet:

- aggressives Rot
- Neonfarben
- zu dunkles Grau
- übertriebene Verläufe
- grelles Pink

### Statusfarben

- Grün: gespeichert / vollständig
- Gelb oder Orange: teilweise gefüllt
- Rot oder Koralle: fehlt
- Grau: neutral / nicht relevant

Wichtig:

Farben dürfen unterstützen, aber nicht die einzige Information sein. Status muss auch über Text oder Icons erkennbar sein.

---

## 5. Typografie

Anforderungen:

- gut lesbar auf kleinen Bildschirmen
- klare Hierarchie
- keine verspielten Schriftarten
- keine zu kleinen Labels

Empfohlene Größenlogik:

- Screen-Titel groß und klar
- Abschnittstitel mittel
- Tätigkeitschips gut antippbar
- Hilfetexte klein, aber lesbar
- keine Textwände auf dem Hauptscreen

---

## 6. Navigation

Für diese App ist eine Bottom Navigation sinnvoll.

Tabs:

1. Heute
2. Woche
3. Vorlagen
4. Profil

Begründung:

Die App ist klein und wird regelmäßig genutzt. Eine Bottom Navigation ist schneller als ein Hamburger-Menü.

Ein Hamburger-Menü wäre hier unnötig versteckt und für den Alltag schlechter.

---

## 7. Hauptscreen: Heute

Der Heute-Screen ist der wichtigste Screen der App.

Er muss direkt nach dem Start erscheinen.

### Aufbau

Oben:

- Begrüßung oder kurzer Titel
- aktuelles Datum
- Tagesstatus

Beispiel:

```text
Heute
Dienstag, 16. Juni
Noch nicht gespeichert
```

Darunter:

- Tagestyp-Auswahl
- Bereichsauswahl
- Tätigkeiten
- Besonderheiten
- Notiz
- Speichern-Button

---

## 8. Tagestyp-Auswahl

Darstellung als große Chips oder segmentierte Auswahl.

Optionen:

- Betrieb
- Berufsschule
- Frei
- Urlaub
- Krank
- Feiertag

Die Auswahl muss sofort sichtbar sein.

Kein Dropdown, wenn es vermeidbar ist.

Begründung:

Dropdowns sind auf dem Handy oft unnötig langsam. Für sechs Optionen sind Chips besser.

---

## 9. Bereichsauswahl

Nur anzeigen, wenn Tagestyp **Betrieb** gewählt ist.

Bereiche:

- Wareneingang
- Lager
- Transport
- Kommissionierung
- Verpackung
- Versand
- Retoure
- Inventur

Darstellung:

- horizontale Chips
- maximal zwei Zeilen
- ausgewählter Bereich deutlich markiert

---

## 10. Tätigkeitsauswahl

Tätigkeiten sollen als antippbare Karten oder Checkbox-Chips dargestellt werden.

Beispiel:

```text
[ ] Ware angenommen
[ ] Lieferung geprüft
[ ] Ware eingelagert
[ ] Bestand kontrolliert
[ ] Auftrag kommissioniert
```

Anforderungen:

- gut antippbar
- ausgewählt/nicht ausgewählt klar erkennbar
- keine winzigen Checkboxen
- Kategorie sichtbar
- häufig genutzte Tätigkeiten oben
- aktive eigene Tätigkeiten passend zur Kategorie anzeigen
- deaktivierte eigene Tätigkeiten nur in historischen Einträgen lesbar halten

Optional:

- Favoritenbereich
- zuletzt benutzt

---

## 11. Eigene Tätigkeit hinzufügen

Unterhalb der Tätigkeiten:

```text
+ Eigene Tätigkeit hinzufügen
```

Nach Antippen öffnet sich ein kleines Eingabefeld oder Bottom Sheet.

Felder:

- Tätigkeitstext
- Option: nur heute verwenden
- Option: als Vorlage speichern

Wichtig:

Nicht direkt auf dem Hauptscreen zu viel Platz verschwenden. Eigene Tätigkeit soll schnell erreichbar sein, aber nicht dominieren.

---

## 12. Besonderheiten

Darstellung als Chips:

- unter Anleitung
- selbstständig
- neue Aufgabe gelernt
- Problem aufgetreten
- Kontrolle durchgeführt
- Fehler korrigiert
- wiederholt/geübt

Diese Angaben helfen später beim Formulieren des Berichtshefts.

---

## 13. Notizfeld

Das Notizfeld soll optional sein.

Beispiel-Placeholder:

```text
Kurze Notiz, falls etwas Besonderes war ...
```

Anforderungen:

- nicht zu groß
- nicht verpflichtend
- maximal 2 bis 4 Zeilen sichtbar
- keine Roman-Erwartung erzeugen

Die App darf nicht so wirken, als müsse man jeden Tag einen langen Text schreiben.

---

## 14. Speichern-Button

Der Speichern-Button soll am unteren Rand gut erreichbar sein.

Empfehlung:

- sticky/fixed am unteren Bereich
- klar sichtbar
- großer Button
- deaktiviert, wenn gar nichts gewählt wurde
- nach Speichern kurzes Feedback

Beispiel:

```text
Heute speichern
```

Nach Speichern:

```text
Gespeichert
```

Keine übertriebene Animation. Kurz, klar, fertig.

---

## 15. Wochen-Screen

Der Wochen-Screen zeigt Montag bis Sonntag.

### Aufbau

Oben:

- Kalenderwoche
- Wechsel vorherige/nächste Woche
- Fortschritt

Beispiel:

```text
KW 25
4 von 5 Tagen eingetragen
```

Darunter Tageskarten:

```text
Montag
Betrieb · Wareneingang · 4 Tätigkeiten
Status: vollständig

Dienstag
Betrieb · Kommissionierung · 3 Tätigkeiten
Status: vollständig

Mittwoch
Berufsschule · 2 Themen
Status: vollständig

Donnerstag
Kein Eintrag
Status: fehlt
```

---

## 16. Tagesstatus

Mögliche Status:

- leer
- begonnen
- gespeichert
- frei/krank/urlaub
- fehlt

Status muss visuell und textlich erkennbar sein.

Beispiel:

```text
Fehlt
Gespeichert
Berufsschule
Frei
```

---

## 17. Wochenzusammenfassung

Im Wochen-Screen soll es einen Button geben:

```text
Wochenzusammenfassung anzeigen
```

Die Zusammenfassung zeigt die Daten geordnet nach Tagen.

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

Ziel:

Die Nutzerin soll daraus ihr schriftliches Berichtsheft leichter schreiben können.

---

## 18. Vorlagen-Screen

Hier werden Tätigkeitsvorlagen verwaltet.

Funktionen:

- Tätigkeiten anzeigen
- nach Kategorie filtern
- eigene Tätigkeit hinzufügen
- Tätigkeit deaktivieren
- deaktivierte eigene Tätigkeit reaktivieren

Wichtig:

Vordefinierte Tätigkeiten sollten nicht hart gelöscht werden. Besser deaktivieren.

Eigene Tätigkeitstitel werden aktuell nicht bearbeitet, damit bereits gespeicherte
Tageseinträge nicht rückwirkend ihre Bedeutung ändern.

Deaktivieren ersetzt hartes Löschen. Deaktivierte Tätigkeiten verschwinden aus
neuen Tageseinträgen, bleiben in historischen Einträgen und Zusammenfassungen lesbar.

---

## 19. Profil-Screen

Der Profil-Screen bleibt einfach.

Felder:

- Ausbildungsberuf
- Ausbildungsjahr
- optional Name
- optional Betrieb
- Datenverwaltung

Datenverwaltung:

- lokale Daten löschen
- später Backup exportieren
- später Backup importieren

Keine überladene Einstellungsseite.

---

## 20. Onboarding

Beim ersten Start:

Screen 1:

```text
Wofür ist die App?
Kurze Erklärung:
Diese App hilft dir, täglich kurz festzuhalten, was du gemacht hast.
Sie ersetzt nicht dein offizielles Berichtsheft.
```

Screen 2:

```text
Welche Ausbildung?
[ Fachlagerist/in ]
[ Fachkraft für Lagerlogistik ]
```

Screen 3:

```text
Welches Ausbildungsjahr?
[ 1. Jahr ]
[ 2. Jahr ]
[ 3. Jahr ]
```

Screen 4:

```text
Fertig.
Du kannst jetzt deinen ersten Tag eintragen.
```

Onboarding darf nicht länger sein. Kein Registrierungsquatsch.

---

## 21. App-Feeling

Wichtige Details:

- schnelle Reaktion beim Antippen
- weiche Übergänge
- keine Ladebildschirme ohne Grund
- kein Browser-Scroll-Gefühl
- keine winzigen Elemente
- keine Textwände
- klare leere Zustände
- gute Einhandbedienung

---

## 22. Empty States

Leere Zustände sollen hilfreich sein.

Beispiel Heute:

```text
Noch nichts ausgewählt.
Wähle einfach 2–3 Tätigkeiten aus, die du heute gemacht hast.
```

Beispiel Woche:

```text
Für diese Woche gibt es noch keine Einträge.
Starte mit dem heutigen Tag.
```

Nicht verwenden:

```text
Keine Daten vorhanden.
```

Das klingt wie Datenbankfehler und ist für Nutzerinnen unschön.

---

## 23. Fehlerzustände

Fehler müssen einfach formuliert werden.

Beispiele:

```text
Der Eintrag konnte nicht gespeichert werden.
Bitte versuche es erneut.
```

```text
Die Tätigkeit darf nicht leer sein.
```

```text
Für diesen Tag gibt es schon einen Eintrag.
Du kannst ihn bearbeiten.
```

Keine technischen Fehlermeldungen auf dem Hauptscreen.

---

## 24. Datenschutz und lokale Daten

Die App speichert Daten lokal auf dem Gerät.

In der UI sollte klar sein:

```text
Deine Einträge bleiben auf diesem Gerät.
```

Kein Konto, keine Cloud, keine externe Übertragung.

Das schafft Vertrauen und reduziert Aufwand.

---

## 25. Qualitätskriterien UI/UX

Die Oberfläche ist gut, wenn:

- die App beim Öffnen direkt verständlich ist
- die Nutzerin ohne Anleitung einen Tag speichern kann
- die wichtigsten Aktionen mit dem Daumen erreichbar sind
- ein Tagesbericht unter einer Minute möglich ist
- der Wochenstatus sofort erkennbar ist
- die App freundlich wirkt, aber nicht verspielt
- die App nicht nach Webseite aussieht

Die Oberfläche ist schlecht, wenn:

- zu viele Felder sichtbar sind
- zu viel Text auf dem Heute-Screen steht
- Buttons zu klein sind
- Navigation versteckt ist
- die App wie ein Formularportal wirkt
- die Nutzerin zu viel tippen muss
- die App nicht klar zeigt, was gespeichert ist

---

## 26. Priorisierte UI-Entscheidungen

Muss:

- Bottom Navigation
- Heute als Startscreen
- Tätigkeiten als Chips/Karten
- große Touchflächen
- klare Wochenübersicht
- moderne App-Optik
- lokale Speicherung sichtbar machen

Sollte:

- Favoriten
- zuletzt genutzte Tätigkeiten
- Tätigkeit vom Vortag übernehmen
- einfache Wochenzusammenfassung

Später:

- Dark Mode
- Erinnerungen
- Backup
- Export
- KI-Formulierungshilfe
