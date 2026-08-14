# KI-Nachbearbeitung über OpenRouter

Dieses Verzeichnis enthält den abgestimmten Plan für eine automatische,
nicht blockierende Nachbearbeitung gespeicherter Tagesberichte über OpenRouter.
Es enthält noch keine Implementierung und keinen API-Schlüssel.
Die Umsetzung beginnt erst nach einem ausdrücklichen `Go`.

## Dokumente

| Dokument | Zweck |
| --- | --- |
| [`PLAN.md`](PLAN.md) | Zielarchitektur, Datenfluss, Risiken und Gesamt-Abnahmekriterien |
| [`phasen/00-entscheidung-und-vertrag.md`](phasen/00-entscheidung-und-vertrag.md) | Bestehende No-Gos kontrolliert ablösen und verbindlichen Produktvertrag festlegen |
| [`phasen/01-konfiguration-und-grundstruktur.md`](phasen/01-konfiguration-und-grundstruktur.md) | Private Build-Konfiguration, Servicegrenzen, Persistenz und Wiring vorbereiten |
| [`phasen/02-openrouter-client-und-validierung.md`](phasen/02-openrouter-client-und-validierung.md) | OpenRouter-Client, Promptvertrag, strukturierte Antwort und Fehlerbehandlung bauen |
| [`phasen/03-cache-und-hintergrundablauf.md`](phasen/03-cache-und-hintergrundablauf.md) | Cache, Deduplizierung, Pending-Queue und nicht blockierende Ausführung integrieren |
| [`phasen/04-ui-export-datenschutz.md`](phasen/04-ui-export-datenschutz.md) | Berichtsauswahl, Kennzeichnung, Kopieren, Export, Löschen und Datenschutz angleichen |
| [`phasen/05-tests-release-und-abnahme.md`](phasen/05-tests-release-und-abnahme.md) | Tests, Release-Härtung, Kostenkontrolle und Geräteabnahme durchführen |

## Ausführungsregeln

1. Phasen in der angegebenen Reihenfolge ausführen. Keine Phase überspringen.
2. Pro Phase ein eigener Pull Request oder mindestens ein klar abgegrenzter Commit.
3. Keine echte OpenRouter-Anfrage in Unit-, Widget- oder CI-Tests.
4. Kein API-Schlüssel, Request-Inhalt oder Modelloutput in Git oder Logs.
5. Der lokale `DailyReportGenerator` bleibt jederzeit funktionsfähig und ist der
   verbindliche Fallback.
6. Eine Phase gilt erst nach ihren Abschlusskriterien und dem Documentation
   Freshness Check als erledigt.

## Vor Phase 1 festzulegen

- exakte OpenRouter-Modell-ID, nicht nur ein Anzeigename
- Zero Data Retention bleibt zwingend: empfohlen **ja**
- Provider-Fallback innerhalb desselben Modells: empfohlen **ja**
- maximales monatliches Budget des dedizierten API-Schlüssels

Der API-Schlüssel selbst wird niemals in einem Planungsdokument hinterlegt.
