# Phase 3 – Cache und nicht blockierender Hintergrundablauf

## Rolle

Du arbeitest als Senior Flutter Engineer für asynchrone Abläufe, Persistenz und
Race-Condition-Vermeidung.

## Ziel

Verbinde den getesteten Client mit dem Speicherflow. Der lokale Save muss immer
zuerst erfolgreich sein und darf niemals auf OpenRouter warten.

## Pflichtkontext

- `docs/ki-openrouter/PLAN.md`
- alle Ergebnisse aus Phase 1 und 2
- `lib/features/today/today_screen.dart`, besonders `_saveEntry`, `_undoEntry`,
  `_currentReport` und `_copyReport`
- `lib/features/today/today_entry_draft.dart`
- `lib/core/report/daily_report_generator.dart`
- DailyEntry- und KI-Cache-Storage
- `lib/app/bootstrap.dart`
- relevante Today-, Bootstrap- und Storage-Tests

## Arbeitsauftrag

1. Erzeuge aus ausschließlich erlaubten Berichtsdaten eine kanonische
   Darstellung und daraus einen SHA-256-Fingerprint. Reihenfolgen müssen stabil
   sein; Laufzeit-Hashfunktionen sind unzulässig.
2. Definiere die Eignungsregel zentral:
   - Betrieb und Berufsschule mit speicherbarem Bericht,
   - Sonstiges nur bei sinnvoller `reportNote`, falls in Phase 0 freigegeben,
   - keine Abwesenheitstage.
3. Implementiere `ensureEnhanced(entry)` mit Deduplizierung nach Entry-ID,
   Fingerprint, Modell-ID und Prompt-Version.
4. Starte die Hintergrundarbeit unmittelbar nach erfolgreichem lokalem Save,
   ohne sie zu `await`en und ohne den Witz-/Undo-Flow zu verzögern.
5. Führe höchstens zwei Retries mit exponentiellem Backoff aus. Respektiere
   `Retry-After` und speichere begrenzte Pending-Metadaten.
6. Setze Pending-Aufträge beim nächsten App-Start kontrolliert fort. Begrenze
   die Anzahl pro Start und verhindere Endlosschleifen.
7. Lade vor dem Cache-Schreiben den aktuellen `DailyEntry` erneut und vergleiche
   seinen Fingerprint. Verwirf verspätete Antworten nach Bearbeitung oder Löschung.
8. Lösche beziehungsweise invalidiere KI-Zustand bei Undo und beim Löschen eines
   Eintrags.
9. Stelle aktualisierte Berichte über einen kleinen `Listenable`-/Callback-
   Vertrag bereit. Kein neues State-Management-Framework.
10. Die Wochenansicht darf den Cache lesen, aber keine Massenanfragen für alte
    Einträge auslösen.

## Kritische Race-Szenarien

- Eintrag wird während der Anfrage bearbeitet.
- Eintrag wird per Undo gelöscht, während eine Antwort unterwegs ist.
- Zwei schnelle Saves desselben Eintrags erzeugen zwei Fingerprints.
- App wird nach dem lokalen Save beendet.
- 429 liefert eine lange `Retry-After`-Zeit.
- Cache-Schreiben schlägt fehl, der Tageseintrag ist aber korrekt gespeichert.

In allen Fällen bleibt der lokale Eintrag erhalten. Eine alte Antwort darf nie
als aktueller Bericht sichtbar werden.

## Tests

- Save kehrt zurück, bevor der Fake-Client antwortet
- genau ein Request pro unverändertem Fingerprint
- Edit erzeugt genau einen neuen Request
- parallele identische Aufrufe werden zusammengeführt
- verspätete Antwort nach Edit oder Undo wird verworfen
- Pending-Auftrag wird nach Neustart einmal fortgesetzt
- Retrygrenzen und `Retry-After`
- nicht retryfähige Fehler bleiben lokal
- Cachefehler beeinflusst DailyEntry-Speicherung nicht
- vollständiger `flutter test` und `flutter analyze`

## Abschlusskriterien

- Kein UI- oder Storage-Pfad wartet auf OpenRouter.
- Deduplizierung und Aktualitätsprüfung sind automatisiert bewiesen.
- App-Neustart, Undo und Bearbeitung erzeugen keine veralteten Berichte.
- Fehlender Schlüssel und Offline-Modus bleiben vollständig funktionsfähig.
- Kein WorkManager oder anderer Android-Hintergrunddienst wurde eingeführt.

Schwierigkeiten: 9/10 | Thinking: xhigh
