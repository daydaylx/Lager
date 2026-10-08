# Phase 5 – Härtung, privater Release und Abnahme

## Rolle

Du arbeitest als unabhängiger Reviewer und Release Engineer. Prüfe nicht nur den
Happy Path, sondern beweise, dass die lokale App bei jedem Providerfehler
benutzbar bleibt.

## Ziel

Schließe die Integration erst ab, wenn Datenschutz, Kostenkontrolle,
Race-Sicherheit, Offline-Fallback und privater Android-Release nachgewiesen sind.

## Pflichtkontext

- `docs/ki-openrouter/PLAN.md`
- Diffs und Übergaben aller vorherigen Phasen
- vollständige betroffene Implementierung und Tests
- `scripts/check_repo_hygiene.sh`
- `.github/workflows/flutter-ci.yml`
- `.github/pull_request_template.md`
- `docs/VALIDATION_MATRIX.md`
- `docs/QA_RELEASE_CHECKLIST.md`
- alle aktualisierten Datenschutz- und Setup-Dokumente

## Arbeitsauftrag

1. Führe einen Code-first-Review des gesamten Datenflusses durch:
   Save → lokaler Bericht → Pending → OpenRouter → Validierung → Cache → UI →
   Kopieren/Export/Löschen.
2. Suche gezielt nach direkten HTTP-Aufrufen außerhalb des Clients und nach
   versehentlicher Übertragung von `privateNote`, Profil oder IDs.
3. Prüfe Repository und Git-Diff auf Secrets, private Konfigurationen,
   Build-Artefakte und geloggte Requestdaten.
4. Beweise mit Tests beziehungsweise Fakes:
   - Offline-Modus,
   - fehlender oder ungültiger Schlüssel,
   - 401, 402, 403, 408, 429 und 5xx,
   - Timeout und ungültige JSON-Antwort,
   - Edit/Undo während laufender Anfrage,
   - App-Neustart mit Pending-Auftrag,
   - Cachekorruption,
   - fehlender ZDR-Endpunkt.
5. Stelle sicher, dass CI keine echte API aufruft und keinen Schlüssel benötigt.
6. Führe die vollständigen Repository-Checks aus:
   - `scripts/check_repo_hygiene.sh`
   - `./.tooling/flutter/bin/flutter pub get`
   - `./.tooling/flutter/bin/flutter analyze`
   - `./.tooling/flutter/bin/flutter test`
   - `./.tooling/flutter/bin/flutter build apk --debug`
7. Erzeuge anschließend lokal einen signierten privaten Release-Build mit der
   ignorierten OpenRouter-Konfiguration. Lade dieses APK nicht als öffentliches
   Artefakt hoch.
8. Teste auf einem echten Android-Gerät mindestens:
   - Speichern online und offline,
   - sofort sichtbaren lokalen Bericht,
   - spätere stille Aktualisierung,
   - Kopieren in Heute und Woche,
   - Bearbeiten und Undo während langsamer Antwort,
   - Neustart mit ausstehendem Auftrag,
   - Datenexport und Alle-Daten-löschen.
9. Prüfe im OpenRouter-Konto, dass ausschließlich das festgelegte Modell genutzt
   wird und das Key-/Budgetlimit greift. Verwende dafür keine sensiblen
   Screenshots im Repository.
10. Aktualisiere Status-, Task- und QA-Dokumente erst nach tatsächlichem Nachweis.

## Ablehnungsgründe

Die Integration ist nicht releasefähig, wenn einer dieser Punkte zutrifft:

- Speichern wartet auf das Netzwerk.
- App-Start scheitert ohne OpenRouter.
- `privateNote` kann den Payload erreichen.
- Ein alter Request kann einen neuen Eintragstext überschreiben.
- WeekScreen erzeugt Requests für alle sichtbaren Tage.
- API-Schlüssel oder private Build-Datei ist versioniert.
- ZDR wird stillschweigend deaktiviert, um Verfügbarkeit zu erhöhen.
- CI oder Tests verbrauchen echtes OpenRouter-Guthaben.
- UI kopiert einen anderen Bericht als den angezeigten.
- Datenschutztext behauptet weiterhin ausschließlich lokale Verarbeitung.

## Abschlusskriterien

- Alle automatisierten Checks sind grün.
- Alle definierten Fehlerfälle enden beim lokalen Fallback ohne Datenverlust.
- Manueller Android-Test ist mit Datum, Gerät und Ergebnis dokumentiert.
- OpenRouter-Nutzung ist auf Modell und Budget begrenzt.
- Keine Secrets oder privaten APKs wurden veröffentlicht.
- `TASKS.md`, `PROJECT_STATUS.md` und `docs/CURRENT_STATUS.md` entsprechen dem
  nachgewiesenen Stand.
- Documentation Freshness Check ist vollständig.

## Übergabeformat

Dokumentiere kompakt:

- geprüfter Commit
- verwendete Modell-ID, niemals den Schlüssel
- automatisierte Checks mit Ergebnis
- manuelle Geräteszenarien mit Ergebnis
- verbleibende Risiken
- klare Entscheidung: releasefähig oder nicht releasefähig

Schwierigkeiten: 8/10 | Thinking: high
