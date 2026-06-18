# Detaillierter Abarbeitungsplan für offene Issues #29–#49

> **Historisches Planungsdokument** (Stand 2026-06-17). Issues #29–#36, #38, #40–#49
> wurden in den Phasen 14–18 abgeschlossen und sind auf GitHub zu schließen.
> Aktiv offen sind nur noch **#37** (manueller QA-Durchlauf) und **#39** (Import-Entscheidung).

Stand: 2026-06-17

## Zweck dieses Dokuments

Dieses Dokument ergänzt `TASKS.md`. Es beschreibt zu jedem offenen Issue:

- wie groß die Anpassung realistisch ist,
- welche Tiefe erwartet wird,
- welche Mindestumsetzung akzeptabel ist,
- welche billige Notlösung ausdrücklich nicht akzeptabel ist,
- welche Prüfungen nach der Umsetzung nötig sind.

Ziel ist, dass Coding-Agenten die Issues nicht als Mini-Fix abarbeiten und anschließend vorschnell als erledigt markieren. Einige Aufgaben sehen klein aus, sind aber strukturell wichtig. Genau dort entstehen sonst die typischen halbgaren Lösungen.

---

## Größenklassen

| Klasse | Bedeutung             | Erwartung                                                                                     |
| ------ | --------------------- | --------------------------------------------------------------------------------------------- |
| XS     | sehr kleine Korrektur | 1–2 Dateien, klar begrenzte Änderung, Tests falls sinnvoll                                    |
| S      | kleine Änderung       | wenige Dateien, geringe Architekturwirkung, Tests erwartet                                    |
| M      | mittlere Änderung     | mehrere Dateien oder UI-/Datenfluss betroffen, Tests Pflicht                                  |
| L      | große Änderung        | Struktur, Datenmodell oder größere UI-Bereiche betroffen, sorgfältige Zwischenprüfung Pflicht |
| XL     | sehr große Änderung   | besser in mehrere PRs/Commits splitten, vorher Plan prüfen                                    |

Wichtig: Die Größenklasse ist kein Zeitversprechen. Sie beschreibt Risiko und nötige Sorgfalt.

---

## Globale Arbeitsregeln

1. Keine Issue-Umsetzung ohne vorherige kurze Codeanalyse.
2. Keine neuen Features nebenbei einbauen.
3. Keine bestehende Funktion „vereinfachen“, nur weil sie gerade stört.
4. Nach jeder Phase mindestens:
   - `flutter analyze`
   - `flutter test`
5. Bei UI-Änderungen zusätzlich prüfen:
   - kleine Displays,
   - große Systemschrift,
   - Scroll-Verhalten,
   - Touch-Ziele,
   - visuelle Hierarchie.
6. Bei Datenmodell-/Persistenzänderungen zusätzlich prüfen:
   - Bestandsdaten,
   - Migration/Fallback,
   - unbekannte/alte Werte,
   - keine stillen Datenverluste.
7. Ein Issue gilt erst als erledigt, wenn die Definition of Done fachlich erfüllt ist, nicht nur wenn ein Test grün ist.

---

# Phase 14: Dokumentations- und Datenmodell-Basis absichern

## #43 — DATA_MODEL.md: TrainingOccupation-Widerspruch korrigieren

**Größe:** S  
**Risiko:** Mittel, weil falsche Doku Agenten zu falschen Änderungen verleitet.  
**Betroffene Bereiche:** `docs/DATA_MODEL.md`, ggf. Profil-/Onboarding-Code zur Verifikation.

### Ziel

Die Dokumentation muss exakt zur tatsächlichen Implementierung passen. Wenn Ausbildungsberufe als stabile String-Werte gespeichert werden, darf die Doku nicht gleichzeitig ein klassisches persistiertes Enum suggerieren.

### Erwartete Umsetzung

- Code prüfen: Wo wird `TrainingOccupation` oder ein äquivalentes Konzept definiert?
- Persistenz prüfen: Werden Berufe als String, Enum-Name oder eigene Value-Klasse gespeichert?
- `docs/DATA_MODEL.md` korrigieren.
- Gültige Werte klar dokumentieren.
- Bestandsdatenverhalten beschreiben.

### Nicht akzeptabel

- Nur einen Satz in der Doku umformulieren, ohne Code/Persistenz geprüft zu haben.
- Widerspruch durch vage Formulierungen verstecken.
- Neue Persistenzlogik einbauen, obwohl nur Doku-Korrektur nötig ist.

### Prüfung

- Doku mit tatsächlichem Code abgleichen.
- Falls Code geändert wird: `flutter test`.

---

## #44 — UI_UX_SPEC.md an aktuelle Bereichsauswahl anpassen

**Größe:** S  
**Risiko:** Mittel, weil falsche UI-Spec spätere UI-Agenten in die falsche Richtung schickt.  
**Betroffene Bereiche:** `docs/UI_UX_SPEC.md`, `TodayScreen`/Bereichsauswahl zur Prüfung.

### Ziel

Die UI-Spezifikation soll die aktuell bewusst bessere zweispaltige Bereichsauswahl beschreiben oder klar begründen, falls sie geändert werden soll.

### Erwartete Umsetzung

- Aktuelle Bereichsauswahl im Code prüfen.
- Screenshot/visuelle Struktur gedanklich gegen Spec abgleichen.
- Spec aktualisieren:
  - zweispaltige Karten/Grid,
  - mobile-first,
  - Touch-Ziele,
  - keine horizontale Chip-Tapete.
- Falls Spec bewusst von Code abweicht, Entscheidung dokumentieren.

### Nicht akzeptabel

- Nur „Chips“ durch „Karten“ ersetzen und den Rest stehen lassen.
- Spec und Code weiterhin widersprüchlich lassen.
- UI-Code ändern, nur um zur alten Spec zu passen.

### Prüfung

- Doku lesbar für Agenten.
- Keine Codeänderung nötig, außer ein echter Bug wird gefunden.

---

## #42 — App-Version aus einer Quelle pflegen oder Drift verhindern

**Größe:** S bis M  
**Risiko:** Niedrig bis mittel. Kleine Aufgabe, aber typischer Wartungsfehler.  
**Betroffene Bereiche:** `pubspec.yaml`, Profil/App-Info, ggf. Package-Info-Abhängigkeit.

### Ziel

Die App-Version darf nicht in mehreren Stellen auseinanderlaufen.

### Erwartete Umsetzung

- Prüfen, wo Version aktuell steht.
- Entscheidung treffen:
  - bevorzugt dynamisch aus Package-Info lesen, oder
  - bewusst eine dokumentierte Fallback-/Teststrategie verwenden.
- Profilanzeige anpassen, falls nötig.
- Tests stabil halten.

### Nicht akzeptabel

- Eine weitere Version-Konstante einführen.
- Nur Kommentar schreiben, aber Drift weiter ermöglichen.
- Dynamische Version einbauen und Tests dadurch flaky machen.

### Prüfung

- Profil zeigt erwartete Version.
- Tests für Version-/Profilanzeige anpassen, falls vorhanden.
- `flutter analyze`, `flutter test`.

---

## #48 — Enum-/Hive-Persistenz robuster gegen spätere Änderungen absichern

**Größe:** M bis L  
**Risiko:** Hoch, weil Persistenzfehler Bestandsdaten beschädigen können.  
**Betroffene Bereiche:** Hive-Adapter, Enum-Parsing, Storage, Tests, Doku.

### Ziel

Persistierte Werte müssen robust gegen alte/unbekannte Werte sein. Agenten dürfen nicht aus Versehen Enum-Namen ändern und damit alte Daten unlesbar machen.

### Erwartete Umsetzung

- Alle persistierten Enums identifizieren.
- Prüfen, ob per `name`, Index oder String-Code gespeichert wird.
- Leselogik auf unbekannte Werte prüfen.
- Saubere Fallbacks definieren.
- Tests für alte/unbekannte Werte ergänzen.
- Doku mit klarer Warnung ergänzen: persistierte Codes sind stabil.

### Nicht akzeptabel

- Nur einen Kommentar „Enum nicht umbenennen“ einfügen.
- Fehler beim Lesen alter Werte still verschlucken, ohne nachvollziehbaren Fallback.
- Migration ohne Tests.
- Persistierte Werte ändern, ohne Bestandsdatenstrategie.

### Prüfung

- Tests für unbekannte Enum-Werte.
- Tests für bestehende gültige Werte.
- `flutter analyze`, `flutter test`.

---

## #38 — Ausbildungsjahr abhängig vom Ausbildungsberuf validieren

**Größe:** M  
**Risiko:** Mittel, weil Profil-/Onboarding-Daten und Bestandsdaten betroffen sind.  
**Betroffene Bereiche:** Onboarding, Profilbearbeitung, Profilmodell/Persistenz, Tests.

### Ziel

Fachlagerist/in darf nur Ausbildungsjahr 1–2 wählen; Fachkraft für Lagerlogistik darf 1–3 wählen.

### Erwartete Umsetzung

- Ausbildungsberuf-Werte prüfen.
- Erlaubte Jahre zentral definieren, nicht verstreut in UI-Widgets.
- Onboarding-Auswahl begrenzen.
- Profilbearbeitung begrenzen.
- Bestandsdaten behandeln: Wenn Fachlagerist/in + Jahr 3 vorhanden ist, sauber korrigieren oder Nutzer zur Korrektur führen.
- Tests für beide Berufe ergänzen.

### Nicht akzeptabel

- Nur den dritten Button im Onboarding verstecken.
- Profilbearbeitung vergessen.
- Bestandsdaten ignorieren.
- Logik doppelt in mehreren Widgets hart codieren.

### Prüfung

- Widget-Tests Onboarding.
- Widget-Tests Profilbearbeitung.
- Test für ungültige Bestandskombination.

---

# Phase 15: TodayScreen strukturell entlasten

## #47 — TodayScreen vor weiteren Tätigkeiten-Features in kleinere Widgets zerlegen

**Größe:** L  
**Risiko:** Hoch, weil Kernscreen betroffen ist.  
**Betroffene Bereiche:** `today_screen.dart`, neue Widgets/Dateien, Tests.

### Ziel

Der `TodayScreen` muss vor weiteren Tätigkeiten-Features zerlegt werden. Sonst wird jede spätere Änderung unnötig riskant.

### Erwartete Umsetzung

Extraktion ohne Verhaltensänderung:

- Statuskarte in eigene Datei.
- Bereichsauswahl in eigenes Widget.
- Tätigkeitsauswahl in eigenes Widget.
- Besonderheiten/Notiz-Abschnitt in eigenes Widget.
- SaveBar in eigene Datei.
- Berichtsvorschau/Berichtskarte vorbereitend isolieren.
- State bleibt zunächst im Screen, wenn vollständiges State-Refactoring zu groß wird.

### Nicht akzeptabel

- Nebenbei UI ändern.
- State-Management komplett neu erfinden.
- Tests löschen oder massiv abschwächen.
- Nur ein Widget auslagern und Issue als erledigt markieren.
- Die Datei minimal kürzen, aber die Kopplung gleich lassen.

### Prüfung

- Vorher/Nachher-Verhalten identisch.
- Bestehende Widget-Tests bleiben grün.
- `flutter analyze`, `flutter test`.
- Bei visueller Änderung: Golden-/Screenshot-Prüfung.

---

# Phase 16: Tagesbericht fachlich und sichtbar verbessern

## #40 — Tagesbericht-Generator: ignorierte Besonderheiten und Notizen sauber einbinden

**Größe:** M  
**Risiko:** Mittel, weil Textqualität und bestehende Tests betroffen sind.  
**Betroffene Bereiche:** `DailyReportGenerator`, Tests, ggf. SpecialFlag-Doku.

### Ziel

Ausgewählte Besonderheiten dürfen nicht wirkungslos sein. Kontrolle, Fehlerkorrektur, Probleme und Notizen müssen sinnvoll und kurz eingebunden werden.

### Erwartete Umsetzung

- Alle `SpecialFlag`-Werte prüfen.
- Entscheiden, welche Flags textlich eingebunden werden.
- Kontrolle und Fehlerkorrektur sinnvoll formulieren.
- Problemfälle nicht nur generisch „Zusatznotiz“ nennen, sondern vorsichtig aus vorhandener Notiz ableiten.
- Notizen kurz und ohne dramatische Sprache integrieren.
- Betrieb und Berufsschule getrennt behandeln.

### Nicht akzeptabel

- Nur zwei neue Sätze stumpf anhängen.
- Notiz immer blind anfügen und dadurch Berichte aufblasen.
- Inhalte erfinden.
- Bestehenden Test so ändern, dass schwaches Verhalten weiter akzeptiert wird.

### Prüfung

- Unit-Tests für jede relevante Flag.
- Kombinationstests: Kontrolle + Fehler, Problem + Notiz, Berufsschule + Notiz.
- Text bleibt kurz.

---

## #35 — Tagesbericht-Generator mit mehreren Satzmustern verbessern

**Größe:** M bis L  
**Risiko:** Mittel bis hoch, weil viele Kombinationen sprachlich kippen können.  
**Betroffene Bereiche:** `DailyReportGenerator`, Tests.

### Ziel

Berichte sollen weniger nach Copy-Paste klingen, aber weiter deterministisch, kurz und glaubwürdig bleiben.

### Erwartete Umsetzung

- Mehrere feste Satzmuster definieren.
- Muster abhängig machen von:
  - Tagtyp,
  - Bereich,
  - Anzahl Tätigkeiten,
  - Selbstständigkeit/Anleitung,
  - Notiz/Besonderheiten.
- Keine Zufälligkeit, die Tests instabil macht.
- Auswahl deterministisch, z. B. nach Datum, Kategorie oder stabiler Hash-Logik.
- Grammatik für 1, 2, mehrere Tätigkeiten prüfen.

### Nicht akzeptabel

- Random-Auswahl ohne Testkontrolle.
- ChatGPT-artige Texte.
- Lange Absätze.
- Satzmuster, die nur für Wareneingang funktionieren.
- Fachlich falsche Verben erfinden.

### Prüfung

- Snapshot-/String-Tests für typische Kombinationen.
- Tests für 1/2/3 Tätigkeiten.
- Tests für Betrieb und Berufsschule.
- Tests bleiben deterministisch.

---

## #49 — Tagesbericht als prominente Berichtskarte im Heute-Screen anzeigen

**Größe:** M  
**Risiko:** Mittel, weil Kernflow und mobile UI betroffen sind.  
**Betroffene Bereiche:** Heute-Screen, Berichtskomponente, SaveBar, Widget-Tests.

### Ziel

Der Bericht darf nicht länger nur hinter einem kleinen Vorschau-Button versteckt sein. Er muss nach gültiger Auswahl als klare Berichtskarte sichtbar werden.

### Erwartete Umsetzung

- Berichtskarte als eigenes Widget.
- Sichtbar, sobald `_canSave == true`.
- Status anzeigen:
  - Vorschau aus aktueller Auswahl,
  - noch nicht gespeichert,
  - gespeichert.
- Direktes Kopieren aus der Karte.
- Optional Bearbeiten-Aktion: zu Eingaben scrollen oder relevanten Abschnitt fokussieren.
- SaveBar entlasten: Vorschau-Button entfernen oder klar sekundär machen.

### Nicht akzeptabel

- Nur Bottom Sheet größer machen.
- Nur einen zweiten kleinen Button hinzufügen.
- Berichtskarte als winziges Textfeld irgendwo zwischen Formularteilen verstecken.
- Generatorlogik im Widget duplizieren.

### Prüfung

- Widget-Test: Karte erscheint nach gültiger Auswahl.
- Widget-Test: Kopieren funktioniert.
- Visuelle Prüfung auf kleinem Display.
- Keine Überladung der SaveBar.

---

# Phase 17: Tätigkeitskatalog und Tätigkeiten-UI skalierbar machen

## #30 — Tätigkeiten-UI um Häufig genutzt, Suche und kompakte Anzeige erweitern

**Größe:** L  
**Risiko:** Hoch, weil Kernbedienung betroffen ist.  
**Betroffene Bereiche:** Tätigkeitsauswahl, Storage/Nutzungsdaten, UI, Tests.

### Ziel

Die Tätigkeitsauswahl muss auch bei größerem Katalog schnell bleiben.

### Erwartete Umsetzung

- Suchfeld innerhalb passender Tätigkeiten.
- Kompakte Standardanzeige.
- Häufig/zuletzt genutzt nur, wenn Daten sauber verfügbar sind.
- Keine Überfrachtung des Screens.
- Auswahlzustand stabil halten, auch bei Suche/Filter.
- Gute Empty States.

### Nicht akzeptabel

- Einfach alle Tätigkeiten anzeigen und hoffen, dass Suche reicht.
- Suche ohne Debounce/saubere Normalisierung.
- Ausgewählte Tätigkeiten verschwinden lassen, wenn Filter aktiv ist.
- Häufig genutzt faken, ohne echte Datenbasis.

### Prüfung

- Widget-Tests Suche.
- Widget-Tests Auswahl bleibt bei Filter erhalten.
- Test für leere Suchergebnisse.
- Kleine Displayprüfung.

---

## #31 — Tätigkeiten nach Arbeitsschritten / Untergruppen strukturieren

**Größe:** L  
**Risiko:** Hoch, weil Datenstruktur und UI betroffen sein können.  
**Betroffene Bereiche:** ActivityTemplate, Default-Katalog, UI-Gruppierung, Tests.

### Ziel

Tätigkeiten sollen fachlich besser gruppiert werden, ohne die Bedienung schwerer zu machen.

### Erwartete Umsetzung

- Datenmodell prüfen: Braucht `ActivityTemplate` ein optionales Untergruppenfeld?
- Untergruppen pro Bereich definieren.
- UI so bauen, dass Gruppen einklappbar oder kompakt sind.
- Bestehende eigene Tätigkeiten ohne Untergruppe sauber behandeln.
- Suchfunktion aus #30 berücksichtigen.

### Nicht akzeptabel

- Untergruppen nur als Überschrift in eine Liste werfen.
- Bestehende eigene Tätigkeiten unauffindbar machen.
- Starre Sonderlogik pro Bereich im Widget verteilen.

### Prüfung

- Tests für Gruppierung.
- Tests für eigene Tätigkeiten ohne Untergruppe.
- UI-Prüfung bei vielen Tätigkeiten.

---

## #41 — Eigene Tätigkeiten gegen Duplikate prüfen

**Größe:** S bis M  
**Risiko:** Mittel, weil Vorlagenverwaltung und Nutzerfeedback betroffen sind.  
**Betroffene Bereiche:** Vorlagen-Speichern, Normalisierung, UI-Fehleranzeige, Tests.

### Ziel

Offensichtliche doppelte eigene Tätigkeiten verhindern.

### Erwartete Umsetzung

- Titel normalisieren:
  - trimmen,
  - mehrere Leerzeichen reduzieren,
  - Groß-/Kleinschreibung ignorieren.
- Gegen aktive eigene Tätigkeiten prüfen.
- Entscheidung treffen: Auch gegen deaktivierte eigene Tätigkeiten prüfen oder Reaktivierung anbieten.
- Verständliche Fehlermeldung anzeigen.

### Nicht akzeptabel

- Nur exakte String-Gleichheit prüfen.
- Fehlermeldung ohne Hinweis, welche Tätigkeit schon existiert.
- Standardtätigkeiten versehentlich blockieren, ohne klare Entscheidung.

### Prüfung

- Unit-Test Normalisierung.
- Widget-Test Fehlermeldung.
- Test für Groß-/Kleinschreibung und Mehrfachspaces.

---

## #29 — Tätigkeitskatalog fachlich für Lagerlogistik erweitern

**Größe:** M bis L  
**Risiko:** Mittel. Inhaltlich groß, technisch nur dann sauber, wenn #30/#31 vorbereitet sind.  
**Betroffene Bereiche:** Default-Katalog, Tests, ggf. Generator-Beispiele.

### Ziel

Der Katalog soll fachlicher und praxisnäher werden, ohne die App aufzublähen.

### Erwartete Umsetzung

- Bestehende Kategorien prüfen.
- Tätigkeiten konkret, aber kurz formulieren.
- Keine doppelten oder fast gleichen Einträge.
- Fachlagerist/Fachkraft für Lagerlogistik berücksichtigen.
- Bestehende IDs stabil lassen.
- Neue IDs konsistent benennen.

### Nicht akzeptabel

- Einfach 100 neue Tätigkeiten einfügen.
- Tätigkeiten mit schwammigen Formulierungen wie „viel gelernt“.
- IDs ändern und historische Einträge beschädigen.
- UI-Skalierung ignorieren.

### Prüfung

- Tests für Katalogintegrität, falls vorhanden.
- Manuelle Prüfung: Auswahl bleibt bedienbar.
- Keine rohen IDs im Bericht.

---

## #32 — EDV-, Scanner- und Warenwirtschafts-Tätigkeiten ergänzen

**Größe:** M  
**Risiko:** Mittel. Inhaltlich wichtig, technisch Teil des Katalogausbaus.  
**Betroffene Bereiche:** Default-Katalog, ggf. Gruppierung.

### Ziel

Moderne Lagerlogistik darf nicht nur nach körperlicher Arbeit aussehen. Scanner, MDE und Warenwirtschaft gehören fachlich dazu.

### Erwartete Umsetzung

- EDV-/Scanner-Tätigkeiten pro passender Kategorie ergänzen.
- Formulierungen kurz und berichtshefttauglich halten.
- Keine firmenspezifischen Systeme erfinden.
- Optional eigene Untergruppe „EDV / Scanner / Warenwirtschaft“ nutzen, falls #31 umgesetzt ist.

### Nicht akzeptabel

- Übertriebene IT-Begriffe.
- Konkrete Software nennen, die Nutzerin nicht angegeben hat.
- Alles in eine generische Sicherheitskategorie kippen.

### Prüfung

- Katalogprüfung.
- Berichtsgenerator zeigt Titel korrekt.

---

## #34 — Qualität, Ordnung und 5S praxisnäher erfassen

**Größe:** M  
**Risiko:** Mittel. Gefahr: Putzplan statt fachlicher Lagerlogistik.  
**Betroffene Bereiche:** Default-Katalog, ggf. SpecialFlags/Kategorien.

### Ziel

Qualität und Ordnung sollen fachlich sichtbar werden, ohne lächerlich nach „ich habe aufgeräumt“ zu klingen.

### Erwartete Umsetzung

- Qualitätsbezogene Tätigkeiten ergänzen.
- Ordnungs-/5S-Tätigkeiten konkret und beruflich formulieren.
- Abgrenzen: Tätigkeit, Besonderheit oder Qualitätssicherung?
- Nicht zu viele Einträge.

### Nicht akzeptabel

- Putzplan-Formulierungen.
- Doppelte Einträge zu Kontrolle/Fehlerkorrektur.
- Unklare Sammelbegriffe.

### Prüfung

- Stichproben in Tagesbericht-Texten.
- Keine peinlichen/übertriebenen Formulierungen.

---

## #33 — Ausbildungsfortschritt und Unterweisung als Tätigkeiten/Besonderheiten abbilden

**Größe:** M bis L  
**Risiko:** Hoch, weil konzeptionelle Einordnung wichtig ist.  
**Betroffene Bereiche:** Tätigkeiten, SpecialFlags, ggf. neuer Abschnitt „Lernen & Anleitung“, Generator.

### Ziel

Die App soll Ausbildungscharakter abbilden, ohne Arbeitsschritte und Lernfortschritt zu vermischen.

### Erwartete Umsetzung

- Entscheiden, ob Einträge Tätigkeiten, Besonderheiten oder eigener Abschnitt sind.
- Empfehlung: Nicht alles in normale Tätigkeiten mischen.
- Lern-/Anleitungsaspekte kurz und konkret halten.
- Generator muss diese Informationen sinnvoll verwenden können.

### Nicht akzeptabel

- Alles als normale Tätigkeit in den Katalog werfen.
- Floskeln wie „viel gelernt“.
- UI mit zusätzlichem Pflichtbereich überladen.
- Generator ignoriert die neuen Angaben.

### Prüfung

- Beispielberichte mit Anleitung/Selbstständigkeit.
- UI bleibt unter einer Minute bedienbar.

---

## #36 — Tätigkeiten optional nach Ausbildungsjahr priorisieren

**Größe:** M bis L  
**Risiko:** Mittel bis hoch, weil Profil und Tätigkeitsauswahl zusammenwirken.  
**Betroffene Bereiche:** Profil, Katalog-Metadaten, Sortierung/Filterung, UI.

### Ziel

Tätigkeiten sollen optional besser zum Ausbildungsjahr passen.

### Erwartete Umsetzung

- Erst nach #38 und nach stabilerer Tätigkeitsstruktur umsetzen.
- Tätigkeiten mit optionaler Jahrgangspriorität versehen.
- Nicht hart verstecken, sondern priorisieren oder filtern mit klarer Option.
- Nutzer darf trotzdem andere Tätigkeiten finden.

### Nicht akzeptabel

- Tätigkeiten hart ausblenden und damit echte Arbeitstage blockieren.
- Ausbildungsjahr-Logik direkt in UI verstreuen.
- Ohne Katalog-Metadaten raten.

### Prüfung

- Tests für Sortierung/Priorisierung.
- Tests für Profilwechsel.
- UI-Prüfung, dass nichts Wichtiges verschwindet.

---

# Phase 18: Reminder-/Alltagskomfort und lokale Sicherung

## #45 — Notification-Initialisierungsfehler sichtbar diagnostizierbar machen

**Größe:** M  
**Risiko:** Mittel, weil Native-/Plugin-Fehler nicht crashen dürfen.  
**Betroffene Bereiche:** NotificationScheduler, App-Start, Profil/Reminder-UI, Tests.

### Ziel

Wenn Notifications technisch nicht verfügbar sind, darf die App nicht schweigend so tun, als wäre alles gut.

### Erwartete Umsetzung

- Fehlerstatus erfassen.
- App bleibt nutzbar.
- Profil-/Reminder-Bereich zeigt verständliche Warnung.
- Retry oder Diagnosehinweis anbieten.
- Keine Crashs wegen Plugin-Problemen.

### Nicht akzeptabel

- Fehler nur loggen.
- Pauschal Reminder deaktivieren ohne Hinweis.
- App-Start blockieren.

### Prüfung

- Test mit Fake-Scheduler, der Fehler wirft.
- UI-Test Warnung im Profil.

---

## #46 — SnackBar „Eintrag fehlt“ mit direkter Aktion erweitern

**Größe:** S  
**Risiko:** Niedrig bis mittel. Kleine UX-Verbesserung, aber Navigation muss sauber bleiben.  
**Betroffene Bereiche:** App-Start-/Reminder-Hinweis, Navigation zum Heute-Screen.

### Ziel

Wenn ein Eintrag fehlt, muss die Meldung eine direkte Aktion anbieten.

### Erwartete Umsetzung

- SnackBar mit Action „Eintragen“ oder „Öffnen“.
- Tap führt zum passenden Heute-/Tageseintrag.
- Keine doppelte Navigation.
- Keine Action bei Kontexten, wo Navigation nicht möglich ist.

### Nicht akzeptabel

- Nur Text ändern.
- Button anzeigen, der nichts oder falsch navigiert.
- SnackBar mehrfach stapeln.

### Prüfung

- Widget-Test für SnackBar-Action.
- Navigationstest, falls vorhandene Struktur das erlaubt.

---

## #39 — Lokalen Datenexport und Import als einfache Sicherung prüfen

**Größe:** L bis XL  
**Risiko:** Hoch, weil Datenverlust möglich ist.  
**Betroffene Bereiche:** Storage, JSON-Serialisierung, Datei-/Share-Integration, UI, Tests.

### Ziel

Lokale Sicherung prüfen und nur umsetzen, wenn sie robust und einfach bleibt.

### Erwartete Umsetzung

Muss in zwei Schritte geteilt werden:

1. Konzept/Spike:
   - Welche Daten müssen exportiert werden?
   - JSON-Schema definieren.
   - Versionierung des Exportformats.
   - Import-Konfliktstrategie.
2. Umsetzung:
   - Export lokal/Share-Sheet.
   - Import aus Datei.
   - Validierung vor Import.
   - Sicherer Umgang mit ungültigen Dateien.

### Nicht akzeptabel

- Schnell irgendein JSON dumpen.
- Import ohne Validierung.
- Bestehende Daten beim Import ungefragt überschreiben.
- Cloud, Account oder PDF daraus machen.

### Prüfung

- Unit-Tests Export/Import.
- Test ungültige Datei.
- Test Versionsfeld.
- Test Konfliktverhalten.
- Manueller Android-Test Datei-Auswahl/Share.

---

# Phase 19: Release-QA auf echtem Android-Gerät

## #37 — Manuellen Android-Release-QA-Durchlauf dokumentieren und durchführen

**Größe:** M  
**Risiko:** Hoch für Release-Qualität, niedrig für Code.  
**Betroffene Bereiche:** QA-Dokumentation, reale APK, echtes Gerät.

### Ziel

Die App muss auf echter Hardware geprüft werden. Automatische Tests ersetzen das nicht.

### Erwartete Umsetzung

- Signierte Release-APK installieren.
- Frische Installation testen.
- Bestehende Daten testen.
- Tagesbericht erstellen, kopieren, Woche prüfen.
- Reminder-Permission und echte Notification prüfen.
- Theme-Persistenz prüfen.
- App schließen/öffnen, Tageswechsel, Datenlöschung prüfen.
- Ergebnisse dokumentieren.

### Nicht akzeptabel

- Nur Debug-Build testen.
- Nur Emulator testen.
- Checkliste abhaken ohne Ergebnisnotizen.
- Fehler finden und trotzdem Issue schließen.

### Prüfung

- QA-Dokument mit Datum, Gerät, Android-Version, APK-Typ.
- Bekannte Probleme als neue Issues oder Kommentare dokumentieren.

---

# Empfohlene Reihenfolge mit Aufwand

| Reihenfolge | Issues                  | Größe | Begründung                                                      |
| ----------: | ----------------------- | ----- | --------------------------------------------------------------- |
|           1 | #43, #44                | S     | Doku muss stimmen, bevor Agenten weiterarbeiten.                |
|           2 | #42, #48, #38           | S–L   | Datenmodell/Persistenz absichern, bevor neue Datenlogik kommt.  |
|           3 | #47                     | L     | Struktur schaffen, sonst werden spätere UI-Änderungen riskant.  |
|           4 | #40, #35, #49           | M–L   | Tagesbericht erst fachlich verbessern, dann prominent anzeigen. |
|           5 | #30, #31, #41           | S–L   | Tätigkeiten-UI skalierbar machen, bevor Katalog wächst.         |
|           6 | #29, #32, #34, #33, #36 | M–L   | Katalog fachlich ausbauen, aber nicht als Button-Müllhalde.     |
|           7 | #45, #46                | S–M   | Alltagskomfort und Diagnose verbessern.                         |
|           8 | #39                     | L–XL  | Lokale Sicherung nur sauber, nicht als schneller JSON-Hack.     |
|           9 | #37                     | M     | Release-QA erst nach den größeren Änderungen wirklich sinnvoll. |

---

# Abschlusskriterium für diese Issue-Gruppe

Die Issue-Gruppe #29–#49 gilt erst als sauber abgearbeitet, wenn:

- `TASKS.md` und relevante Doku aktuell sind,
- alle geschlossenen Issues eine nachvollziehbare Umsetzung haben,
- `flutter analyze` sauber ist,
- `flutter test` sauber ist,
- UI-Änderungen auf kleinem Display plausibel geprüft wurden,
- Persistenzänderungen Bestandsdaten berücksichtigen,
- ein manueller Android-Test nachgezogen wurde.

Alles darunter ist wieder nur Kosmetik mit grünem Haken. Genau das soll dieses Dokument verhindern.
