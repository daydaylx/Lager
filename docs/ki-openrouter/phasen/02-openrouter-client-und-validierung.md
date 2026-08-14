# Phase 2 – OpenRouter-Client, Prompt und Validierung

## Rolle

Du arbeitest als Senior Engineer für robuste LLM-API-Clients. Sicherheit und
konservatives Fallback sind wichtiger als eine möglichst kreative Antwort.

## Ziel

Implementiere und teste den isolierten OpenRouter-Client. Noch keine automatische
Auslösung im Heute- oder Wochen-Screen.

## Pflichtkontext

- `docs/ki-openrouter/PLAN.md`
- Phase-0-Entscheidungen und Phase-1-Servicegrenzen
- `lib/core/report/daily_report_generator.dart`
- `lib/core/models/daily_entry.dart`
- `lib/core/models/adhoc_activity.dart`
- Enums für Tagtyp, Bereiche und Besonderheiten
- `test/daily_report_generator_test.dart`
- offizielle OpenRouter-Dokumentation aus `PLAN.md`

## Arbeitsauftrag

1. Implementiere einen Payload-Builder mit Positivliste. Schreibe einen
   Negativtest, der ausdrücklich beweist, dass `privateNote`, Profilwerte,
   Entry-ID, Activity-IDs und Zeitstempel fehlen.
2. Verwende den lokal erzeugten Bericht als Rewrite-Entwurf und übermittle
   zusätzlich nur die erlaubten sichtbaren Fakten.
3. Lege einen versionierten Systemprompt mit diesen harten Regeln fest:
   - Deutsch, Ich-Perspektive, zwei bis vier Sätze,
   - keine erfundenen Fakten,
   - keine Überschrift, Liste oder Markdown,
   - sachlich, natürlich und nicht bürokratisch,
   - ausschließlich die strukturierte Antwort zurückgeben.
4. Fordere ein striktes JSON-Schema mit genau `report` an. Konfiguriere niedrige
   Temperatur und ein knappes Ausgabelimit.
5. Sende an OpenRouter ausschließlich per Bearer-Authentifizierung. Setze die
   Providerregeln für ZDR, abgelehnte Datensammlung, Parameterunterstützung und
   Provider-Fallback innerhalb des festen Modells.
6. Implementiere ein hartes Timeout und eine Fehlerklassifikation:
   - retryfähig: Netzwerkfehler, 408, 429, 5xx,
   - nicht retryfähig: 400, 401, 402, 403,
   - `Retry-After` wird auswertbar an den Koordinator weitergegeben.
7. Validiere die Antwort vor Rückgabe:
   - korrektes JSON und genau erwartetes Feld,
   - nicht leer und innerhalb definierter Textgrenzen,
   - keine Markdown-/HTML-Struktur,
   - keine offensichtliche Fehler- oder Verweigerungsantwort,
   - keine unzulässigen Zusatzfelder.
8. Logge nur technische Kategorien und niemals Schlüssel, Payload oder
   Antworttext.

## Tests

Alle Tests verwenden einen Fake-HTTP-Transport:

- exakte Header ohne Secret-Ausgabe
- feste Modell-ID und Providerparameter
- vollständige erlaubte Payloadfelder
- garantierter Ausschluss von `privateNote` und Profil
- gültige strukturierte Antwort
- ungültiges JSON, leeres Ergebnis, Zusatzfelder und zu langer Text
- Timeout, 400, 401, 402, 403, 408, 429 und 5xx
- Auswertung von `Retry-After`
- kein realer Netzwerkzugriff in Tests oder CI

Zusätzlich:

- `flutter analyze`
- fokussierte Client-/Payload-/Validator-Tests
- vollständiger `flutter test`

## Abschlusskriterien

- Der Client ist vollständig ohne Widget testbar.
- Jede ungültige Antwort wird als Fehler zurückgegeben und nicht gespeichert.
- Das festgelegte Modell und die Datenschutzparameter sind im Request eindeutig.
- Keine Testausgabe enthält einen Schlüssel oder Berichtstext.
- Es gibt noch keinen automatischen Aufruf aus dem Nutzerflow.

Schwierigkeiten: 8/10 | Thinking: high
