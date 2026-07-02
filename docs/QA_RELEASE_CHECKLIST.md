# QA Release Checklist — Berichtsheft Merker

Diese Checkliste deckt alle offenen manuellen Tests aus den Phasen 8–18 ab.
Sie ersetzt keine automatisierten Tests, sondern ergänzt sie.

## Build-Info (beim Testen ausfüllen)

| Feld                    | Wert                               |
| ----------------------- | ---------------------------------- |
| Datum                   |                                    |
| Gerät + Android-Version |                                    |
| APK-Typ                 | Release (signiert)                 |
| APK-Größe (ca.)         | ~24 MB                             |
| Installationsweg        | adb / manuell                      |
| Testergebnis            | bestanden / offen / fehlgeschlagen |

---

## 1. Installation

- [ ] APK lässt sich per `adb install -r app-release.apk` installieren
- [ ] Frische Installation: App öffnet Onboarding
- [ ] Update-Installation: App öffnet direkt den Heute-Screen
- [ ] App-Version im Profil stimmt mit `pubspec.yaml` überein

---

## 2. Erster Start / Onboarding

- [ ] Onboarding erscheint beim ersten Start
- [ ] Schritt 1: Name (optional) und Ausbildungsberuf wählbar
- [ ] Schritt 2: Ausbildungsjahr — Fachlagerist/in zeigt nur Jahr 1–2
- [ ] Schritt 2: Fachkraft für Lagerlogistik zeigt Jahr 1–3
- [ ] Onboarding erscheint nicht beim zweiten Start

---

## 3. Tageseintrag — Heute-Screen

### 3.1 Betriebstag

- [ ] Tagtyp „Betrieb“ auswählen
- [ ] Bereich über Carousel wählen → passende Tätigkeiten erscheinen; mehrere Bereiche bleiben möglich
- [ ] Tätigkeit auswählen → Auswahlchip erscheint oben
- [ ] Berichtskarte erscheint sichtbar nach Bereich + Tätigkeit
- [ ] Berichtskarte zeigt „Entwurf“
- [ ] „Bericht kopieren“ kopiert den Text → Clipboard-Inhalt prüfen
- [ ] „Tag abschließen“ → Berichtskarte zeigt „Erledigt“
- [ ] Bestätigung per SnackBar „Tag abgeschlossen.“
- [ ] Gespeicherter Eintrag lädt beim nächsten Öffnen korrekt

### 3.2 Berufsschultag

- [ ] Tagtyp „Berufsschule" auswählen
- [ ] Thema wählen
- [ ] Berichtskarte erscheint mit schulspezifischem Text (z. B. „In der Berufsschule habe ich …")
- [ ] Besonderheit „Selbstständig" → Text enthält „erarbeitet" (nicht „gearbeitet")

### 3.3 Abwesenheit

- [ ] Tagtyp „Frei" / „Urlaub" / „Krank" / „Feiertag" → direkt speicherbar ohne weitere Eingabe
- [ ] Keine Berichtskarte bei Abwesenheitstypen

### 3.4 Sonstiges

- [ ] Tagtyp „Sonstiges" → Notizfeld erscheint automatisch
- [ ] Eintrag speicherbar

### 3.5 Besonderheiten & Notiz

- [ ] Besonderheiten-Abschnitt ist eingeklappt und ausklappbar
- [ ] Notiz wird im Tagesbericht korrekt eingebunden (als „Notiz: …")
- [ ] Problem-Flag + Notiz → Bericht enthält „Ein Problem wurde notiert: …"

### 3.6 Suche und häufig genutzt

- [ ] Suchfeld filtert Tätigkeiten korrekt
- [ ] Häufig genutzte Tätigkeiten erscheinen oben (nach einigen gespeicherten Tagen)

### 3.7 Tageswechsel nach Pause

- [ ] App nach Mitternacht wieder öffnen → Banner „Ein neuer Tag hat begonnen“
- [ ] Offene Eingaben bleiben dem alten Tag zugeordnet

---

## 4. Wochenübersicht

- [ ] 7 Tageskacheln zeigen korrekten Status (Erledigt / Offen / Abwesenheit / Nicht fällig)
- [ ] Navigation eine Woche zurück und vorwärts möglich
- [ ] Navigation in die Zukunft ist nicht möglich
- [ ] Punkt-Leiste und Zusammenfassung korrekt; kein Prozentbalken sichtbar
- [ ] Banner „X Tag/Tage warten noch“ erscheint neutral bei unvollständiger Woche
- [ ] Tap auf einen Tag öffnet den Tageseintrag
- [ ] Wochenzusammenfassung über AppBar-Icon öffnen
- [ ] Pro vorhandenem Eintrag: Berichtsvorschlag sichtbar und kopierbar

---

## 5. Vorlagenverwaltung

- [ ] Alle Kategorien anzeigbar und filterbar
- [ ] Suche filtert Tätigkeiten korrekt
- [ ] Eigene Tätigkeit hinzufügen → erscheint in der Liste
- [ ] Duplikat-Prüfung: gleicher Name → Fehlermeldung mit dem Konfliktnamen (z. B. „Diese Tätigkeit existiert bereits: „Ware angenommen".")
- [ ] Großschreibung / Leerzeichen ignoriert beim Duplikat-Check
- [ ] Eigene Tätigkeit deaktivieren → nicht mehr in Heute auswählbar
- [ ] Eigene Tätigkeit reaktivieren → wieder sichtbar
- [ ] Deaktivierte historische Tätigkeit bleibt in alten Einträgen lesbar

---

## 6. Profil

### 6.1 Ausbildungsdaten

- [ ] Name und Ausbildungsdaten änderbar
- [ ] Berufsänderung (Fachlagerist → Fachkraft) passt Ausbildungsjahr-Auswahl an
- [ ] Ungültige Kombination (Fachlagerist + Jahr 3) wird nicht akzeptiert

### 6.2 Theme

- [ ] 9 Farbthemes auswählbar
- [ ] Gewähltes Theme überlebt App-Neustart
- [ ] „Lager Teal“ ist das dunkle Standardtheme

### 6.3 Erinnerungen

- [ ] Toggle aktiviert/deaktiviert Erinnerungen
- [ ] Uhrzeit und Wochentage einstellbar
- [ ] Bei Android 13+: Permission-Dialog erscheint beim ersten Aktivieren
- [ ] Samsung-Hinweis (Akku, Nicht-Stören) als ausklappbares Element sichtbar
- [ ] Notification-Initialisierungsfehler wird im Profil sichtbar (falls relevant)

---

## 7. Reminder / Notifications (→ auch `docs/QA_REMINDER_CHECKLIST.md`)

- [ ] Permission-Dialog erscheint (Android 13+)
- [ ] Notification erscheint zur gesetzten Zeit
- [ ] Tap auf Notification öffnet den Heute-Tab
- [ ] Tap bei laufender App leitet zum Heute-Tab
- [ ] Kaltstart-Tap öffnet ebenfalls den Heute-Tab
- [ ] Folgeerinnerung (+30 min) erscheint wenn erster Eintrag noch fehlt
- [ ] Freitagserinnerung (Wochencheck) erscheint bei unvollständiger Woche

---

## 8. Datenlöschung

- [ ] „Alle Daten löschen" im Profil zeigt Bestätigungs-Dialog
- [ ] Nach Bestätigung: alle Einträge, Vorlagen und Einstellungen gelöscht
- [ ] App startet danach wie frisch installiert (Onboarding erscheint)
- [ ] Erinnerungen werden beim Löschen abgebrochen

---

## 9. App-Neustart und Stabilität

- [ ] Alle Einträge überleben App-Neustart
- [ ] Profil-/Einstellungsdaten überleben Neustart
- [ ] Keine sichtbaren Ladezeiten-Probleme bei normaler Datenmenge
- [ ] App stürzt bei keinem der obigen Schritte ab

---

## 10. Ergebnis

| Bereich         | Ergebnis | Notizen |
| --------------- | -------- | ------- |
| Installation    |          |         |
| Onboarding      |          |         |
| Heute-Screen    |          |         |
| Wochenübersicht |          |         |
| Vorlagen        |          |         |
| Profil          |          |         |
| Reminder        |          |         |
| Datenlöschung   |          |         |
| Stabilität      |          |         |

**Gesamt:**

Gefundene Probleme → als neue GitHub Issues oder direkt in dieser Datei dokumentieren.
