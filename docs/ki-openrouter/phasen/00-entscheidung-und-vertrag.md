# Phase 0 – Architekturentscheidung und Datenvertrag

## Rolle

Du arbeitest als Senior Flutter Engineer mit Schwerpunkt Datenschutz,
API-Integration und wartbarer Offline-First-Architektur.

## Ziel

Schaffe einen widerspruchsfreien, verbindlichen Architekturvertrag für die
OpenRouter-Nachbearbeitung, bevor Netzwerkcode entsteht. Die bisherige
Entscheidung „keine KI und keine API“ wird nicht gelöscht, sondern in
`DECISIONS.md` nachvollziehbar durch die neue, eng begrenzte Entscheidung
ersetzt beziehungsweise als überholt markiert.

## Pflichtkontext

Lies vollständig:

- `AGENTS.md`
- `TASKS.md`
- `docs/CURRENT_STATUS.md`
- `docs/AGENT_CONTEXT_PACKS.md`, besonders Pack 2, 5 und 6
- `DECISIONS.md`
- `README.md`
- `docs/PRIVACY_CONTEXT.md`
- `docs/DATA_MODEL.md`
- `docs/VALIDATION_MATRIX.md`
- `docs/ki-openrouter/PLAN.md`

Prüfe zusätzlich die aktuelle OpenRouter-Dokumentation für das festgelegte
Modell, Structured Outputs und ZDR. Dokumentiere das Prüfdatum.

## Arbeitsauftrag

1. Trage die KI-Integration als neue, explizit freigegebene Projektphase in
   `TASKS.md` ein, ohne die offene Release-QA fälschlich als erledigt zu markieren.
2. Ergänze `DECISIONS.md` um eine Entscheidung „lokaler Bericht plus optionale
   OpenRouter-Nachbearbeitung“. Halte fest:
   - lokaler Generator bleibt Fallback,
   - kein Backend bei rein privater APK,
   - Schlüssel in APK ist extrahierbar,
   - keine Übertragung von `privateNote`, Profil oder IDs,
   - ZDR ist verpflichtend,
   - festes Modell, aber Provider-Fallback innerhalb dieses Modells.
3. Ersetze die pauschalen Verbote in `AGENTS.md` und
   `docs/PRIVACY_CONTEXT.md` durch eine enge Erlaubnis ausschließlich über die
   geplante Servicegrenze. Andere Netzwerk-, Cloud- und Trackingfunktionen
   bleiben verboten.
4. Ergänze ein eigenes Context Pack für OpenRouter-Berichte mit Pflichtdateien,
   Risiken und Mindestchecks.
5. Ergänze die Validation Matrix um API-Client-, Payload-, Secret-, Cache- und
   Offline-Prüfungen.
6. Lege die exakte Modell-ID und `promptVersion` fest. Keine Implementierung mit
   einem Platzhaltermodell beginnen.
7. Definiere in der Datenschutzdokumentation eine Positivliste aller
   übertragbaren Felder und eine klare Negativliste.
8. Dokumentiere, dass private Builds mit Schlüssel nicht als öffentliches
   GitHub- oder CI-Artefakt veröffentlicht werden dürfen.

## Nicht-Ziele

- noch keine Dependency ergänzen
- noch keine Manifest-Permission ändern
- noch keine Dart-Datei anlegen
- keinen API-Schlüssel erfassen oder testen
- keine bestehende Release-QA als erledigt markieren

## Abschlusskriterien

- Alle kanonischen Dokumente beschreiben denselben neuen Scope.
- Modell-ID, ZDR-Regel, Provider-Fallback und Budgetgrenze sind entschieden.
- Die zulässigen Request-Felder sind eindeutig und schließen `privateNote` aus.
- Der lokale Fallback und das Verhalten ohne Schlüssel sind dokumentiert.
- Alte pauschale „keine KI“-Aussagen sind entweder korrekt eingegrenzt oder
  nachvollziehbar als frühere Entscheidung erhalten.
- Documentation Freshness Check ist vollständig.

## Übergabe

Liste alle geänderten Dokumente, die endgültige Modell-ID, offene Risiken und
die für Phase 1 verbindlichen Konfigurationsnamen auf. Keine Phase-1-Arbeit
vorwegnehmen.

Schwierigkeiten: 6/10 | Thinking: high
