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

Implementierter Look seit Phase 11:

- reduzierte native Material-3-Optik
- standardmäßig dunkles Theme `Lager Teal`
- neun lokal wählbare und persistierte Farbthemes (acht dunkle, ein helles):
  Lager Teal, Nacht Grün, Warm Sand, Blau Grau, Hell, Nacht Teal, Flieder Nacht,
  Terrakotta Nacht, Anthrazit — seedColor/surfaceColor je Preset in `lib/app/theme.dart`
- Auswahl über ein Farbkachel-Grid mit Live-Vorschau (Theme-Hintergrund + Akzentbalken/-punkt);
  das aktive Theme wird mit einem Ring und Häkchen markiert
- Karten nur zur sinnvollen Gruppierung
- große Touchflächen
- klare Icons
- deutliche Statusanzeigen
- ruhige Akzentfarbe aus dem gewählten Theme-Preset
- ruhige Typografie
- explizite Komponentenregeln aus `lib/app/theme.dart`

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

- dunkle Presets: ruhige, kontrastreiche dunkle Flächen
- helles Preset: sehr helles neutrales Grau
- Preset-Auswahl im Profil unter „Darstellung“

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

Die App nutzt zentrale Statusfarben für Tages- und Wochenansicht:

- `primary` / `primaryContainer`: gespeichert / vollständig
- `tertiary` / `tertiaryContainer`: offen / noch nachzutragen
- `secondary` / `secondaryContainer`: Abwesenheit (Frei, Urlaub, Krank, Feiertag)
- `onSurfaceVariant` / neutrale Container: neutral / kein relevanter Status

Rot (`error` / `errorContainer`) bleibt echten Fehlern vorbehalten, zum Beispiel
Ladefehlern oder Vorlagen-Warnungen. Normale offene Werktage sollen nicht mit Rot
wirken, sondern mit dem ruhigen Tertiär-Akzent.

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
Noch nicht abgeschlossen
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
- Sonstiges

Die Auswahl muss sofort sichtbar sein.

Kein Dropdown, wenn es vermeidbar ist.

Begründung:

Dropdowns sind auf dem Handy oft unnötig langsam. Für sieben Optionen sind Chips besser.

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

Darstellung (zweispaltiges FilterChip-Grid):

- zweispaltiges Grid aus `FilterChip`-Kacheln mit Icon, Titel und Unterzeile
- Antippen schaltet den Bereich ein/aus (Multi-Select)
- ausgewählte Bereiche deutlich markiert (Primary-Farben)
- große Touchflächen für mobile Bedienung

---

## 10. Tätigkeitsauswahl

Tätigkeiten werden als kompakte antippbare Checklistenzeilen dargestellt.

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
- gesamte Zeile antippbar, mindestens 48 dp hoch
- Kategorie sichtbar
- Arbeitsschritt-Untergruppen innerhalb großer Kategorien sichtbar machen
- lokale Suche innerhalb der aktuell passenden Tätigkeiten
- ausgewählte Tätigkeiten als kompakte Chip-Leiste sichtbar halten
- häufig genutzte Tätigkeiten aus gespeicherten Einträgen oben anbieten
- passende Tätigkeiten zum Ausbildungsjahr als weiche Empfehlung oben anbieten
- aktive eigene Tätigkeiten passend zur Kategorie anzeigen
- deaktivierte eigene Tätigkeiten nur in historischen Einträgen lesbar halten

Nicht implementiert und nicht ohne neue Entscheidung ergänzen:

- Favoritenbereich
- Tätigkeiten vom Vortag übernehmen

---

## 11. Eigene Tätigkeit hinzufügen

Eigene Tätigkeiten werden im Vorlagen-Screen über ein keyboard-sicheres Modal
Bottom Sheet mit Titel und Kategorie angelegt. Danach erscheinen aktive eigene
Tätigkeiten passend zur Kategorie im Heute-Screen.

Offensichtliche Duplikate werden beim Speichern verhindert. Die Prüfung trimmt
den Titel, normalisiert Mehrfachspaces und ignoriert Groß-/Kleinschreibung.

Es gibt bewusst keine direkte „nur heute“-Eingabe im Heute-Screen.

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
Tag abschließen
```

Nach Speichern:

```text
Erledigt
```

Keine übertriebene Animation. Kurz, klar, fertig.

---

## 15. Wochen-Screen

Der Wochen-Screen zeigt Montag bis Sonntag.

### Aufbau

Oben:

- Kalenderwoche
- Wechsel vorherige/nächste Woche
- Fortschritt als Punkt-Leiste (Mo–So) statt Prozent

Beispiel:

```text
KW 25
15.06. – 21.06.
3 / 5 Tage erledigt
● ● ○ ◎ · · ·
```

Die Punkt-Leiste zeigt at-a-glance den Wochenfortschritt: gefüllter Punkt =
erledigt, Ring = offen, blasser Punkt = nicht fällig (Wochenende/Zukunft),
Rahmen = heute. Die genaue Zahl steht als Text daneben („3 / 5 Tage erledigt").

Darunter eine zusammenhängende kompakte Tagesliste:

```text
Montag
Betrieb · Wareneingang · 4 Tätigkeiten
Status: Erledigt

Dienstag
Betrieb · Kommissionierung · 3 Tätigkeiten
Status: Erledigt

Mittwoch
Berufsschule · 2 Themen
Status: Erledigt

Donnerstag
Noch nichts erfasst
Status: Offen
```

---

## 16. Tagesstatus

Mögliche Status:

- noch nicht abgeschlossen
- Aktualisierung offen
- erledigt
- Abwesenheit (Frei, Urlaub, Krank, Feiertag)
- nicht fällig / Wochenende, Zukunft

Status muss visuell und textlich erkennbar sein.

Beispiel:

```text
Noch nicht abgeschlossen
Aktualisierung offen
Erledigt
Frei
Urlaub
Krank
Nicht fällig
```

---

## 17. Wochenzusammenfassung

Im Wochen-Screen gibt es in der AppBar ein Wochenzusammenfassungs-Icon:

```text
summarize_outlined
```

Die Zusammenfassung öffnet einen eigenen Screen und zeigt die gespeicherten Daten
geordnet nach Tagen.

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
- Noch nichts erfasst
```

Ziel:

Die Nutzerin soll daraus ihr schriftliches Berichtsheft leichter schreiben können.

Zusätzlich erzeugt die App lokal einen deterministischen Berichtsvorschlag pro
Tag. Er ist in Heute und in der Wochenzusammenfassung sichtbar und kopierbar. Das
ist keine KI-Funktion und keine offizielle Exportfunktion.

---

## 18. Vorlagen-Screen

Hier werden Tätigkeitsvorlagen verwaltet.

Funktionen:

- Tätigkeiten anzeigen
- lokal durchsuchen
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

Eigene Tätigkeiten werden in einem keyboard-sicheren Modal Bottom Sheet angelegt.

---

## 19. Profil-Screen

Der Profil-Screen bleibt einfach und startet als Übersicht.

Felder:

- Ausbildungsberuf
- Ausbildungsjahr
- optional Name
- optional Betrieb
- Datenverwaltung
- Darstellung / Farbtheme — Farbkachel-Grid (kein Dialog): jede Kachel zeigt eine
  Miniatur-Vorschau aus `surfaceColor` (Hintergrund = Helligkeit) und `seedColor`
  (Akzentbalken + Punkt = Farbton) sowie den Preset-Namen; das aktive Theme ist
  mit Ring + Häkchen markiert

Die Profilfelder selbst liegen auf einem separaten Bearbeitungsscreen.
Erinnerungen sowie Daten & Datenschutz sind klar getrennte Einstellungsgruppen.

Datenverwaltung:

- **Daten exportieren** — öffnet das Android-Share-Sheet mit einer
  JSON-Datei (`berichtsheft_export_YYYY-MM-DD_HHmmss.json`). Enthält
  alle Tageseinträge, eigene Tätigkeiten und Profildaten. Kein
  Cloud-Upload, keine Berechtigungen erforderlich. Der Nutzer wählt
  selbst, wo die Datei gespeichert wird (z. B. Downloads, Google Drive).
- lokale Daten löschen
- Hinweis, dass alle Inhalte lokal bleiben

Keine überladene Einstellungsseite.

---

## 20. Onboarding

Beim ersten Start gibt es genau zwei kompakte Schritte:

Screen 1:

```text
Wofür ist die App?
Kurze Erklärung:
Diese App hilft dir, täglich kurz festzuhalten, was du gemacht hast.
Sie ersetzt nicht dein offizielles Berichtsheft.
```

Screen 2:

```text
Ausbildungsprofil
[ Fachlagerist/in ]
[ Fachkraft für Lagerlogistik ]
[ 1. Jahr ]
[ 2. Jahr ]
[ 3. Jahr ]
```

Der erste Schritt ist scrollbar und hat eine sticky Weiter-Aktion. Kein
Registrierungsflow, Berechtigungsdialog oder Tutorial-Karussell.

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

Automatisierte Mindestabsicherung:

- kleines Display mit 360 × 640 dp
- große Systemschrift bis Faktor 1,5
- Tastatur auf Heute-Notiz und Vorlagen-Bottom-Sheet
- Touchflächen mindestens 48 dp
- Golden-Referenzen für Onboarding, Heute, Woche und Profil

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

Implementiert:

- einfache Wochenzusammenfassung
- lokaler kopierbarer Tagesberichtsvorschlag
- Tätigkeitssuche und häufig genutzte Tätigkeiten im Heute-Screen
- Tätigkeits-Untergruppen und Ausbildungsjahr-Empfehlungen im Heute-Screen

Bewusst nicht ohne neue Entscheidung:

- Favoriten oder Tätigkeiten vom Vortag übernehmen
- Backup oder Export
- KI-Formulierungshilfe
