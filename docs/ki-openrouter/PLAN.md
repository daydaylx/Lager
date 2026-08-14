# Gesamtplan: automatische KI-Nachbearbeitung über OpenRouter

Status: geplant, noch nicht implementiert  
Ausgangsstand: `main` bei `1be9f474d443fec28e872cd3ca161d2831da62e1`

## Ziel

Nach dem erfolgreichen Speichern eines geeigneten Tageseintrags verbessert ein
festgelegtes OpenRouter-Modell den lokal erzeugten Bericht automatisch im
Hintergrund. Speichern, Navigation und Offline-Nutzung dürfen davon nicht
abhängen. Bis eine geprüfte KI-Antwort vorliegt, bleibt der lokale Bericht
sichtbar. Bei jedem Fehler bleibt er dauerhaft der Fallback.

## Nicht-Ziele

- kein Chat und keine freie Texteingabe an ein Sprachmodell
- keine KI-Anfrage während des Tippens oder bei jedem Widget-Build
- keine Änderung der fachlichen Daten eines `DailyEntry`
- kein Backend, Benutzerkonto oder Cloud-Sync
- kein fest verdrahteter Provider, solange Datenschutzregeln innerhalb des
  festgelegten Modells eingehalten werden
- kein Android-Hintergrunddienst in der ersten Version
- keine automatische Verbesserung von Frei, Urlaub, Krank oder Feiertag

## Kritische Ausgangslage

Die aktuelle Architektur verbietet KI, API-Requests und Netzwerkzugriff
ausdrücklich. Das betrifft mindestens `AGENTS.md`, `DECISIONS.md`, `README.md`,
`docs/PRIVACY_CONTEXT.md`, `docs/AGENT_CONTEXT_PACKS.md` und
`android/app/src/main/AndroidManifest.xml`. Die Integration darf diese Verträge
nicht stillschweigend brechen. Phase 0 ersetzt die betroffenen Aussagen
kontrolliert durch eng begrenzte Regeln.

Ein fest in eine APK eingebauter API-Schlüssel ist außerdem nicht wirklich
geheim. Er kann aus einer APK extrahiert werden. Für eine ausschließlich privat
installierte APK ist das ein bewusst akzeptierbares Restrisiko; bei jeder
Weitergabe der APK wäre ein Backend-Proxy erforderlich.

## Ziel-Datenfluss

1. `TodayScreen` speichert den `DailyEntry` wie bisher lokal.
2. `DailyReportGenerator` erzeugt sofort den deterministischen Fallback.
3. Der Hintergrundkoordinator legt einen deduplizierten Auftrag für den
   gespeicherten Eintrag an und kehrt sofort zurück.
4. Der OpenRouter-Client sendet nur erlaubte Berichtsdaten und den lokalen
   Entwurf.
5. Die Antwort wird strukturell und inhaltlich konservativ validiert.
6. Nur eine gültige, noch aktuelle Antwort landet im separaten KI-Berichtscache.
7. Heute- und Wochenansicht zeigen bevorzugt den passenden Cache-Bericht;
   andernfalls den lokalen Bericht.

## Auszulagernde Komponenten

| Komponente | Verantwortung |
| --- | --- |
| `ReportEnhancer` | Austauschbare Schnittstelle für eine Berichtsnachbearbeitung |
| `OpenRouterReportEnhancer` | HTTP-Anfrage, Authentifizierung, Timeout und Response-Decoding |
| `ReportEnhancementPayloadBuilder` | Positivliste der übertragbaren Felder; schließt `privateNote` aus |
| `AiReportValidator` | JSON-Schema, Textgrenzen und unzulässige Ausgabe prüfen |
| `AiReportCache` | Abgeleitete Berichte und Pending-Status separat von `DailyEntry` speichern |
| `ReportEnhancementCoordinator` | Deduplizierung, Retry, Aktualitätsprüfung und Benachrichtigung |
| `ResolvedReport` | Entscheidet zwischen KI-Bericht und lokalem Fallback |

Die Netzwerklogik darf weder in `TodayScreen` noch in `WeekScreen` liegen.
Es wird kein neues State-Management-Framework eingeführt. Ein kleiner
`Listenable`-/Callback-Vertrag für aktualisierte Berichte reicht.

## Übertragbare Daten

Erlaubt sind ausschließlich:

- Tagtyp `betrieb`, `berufsschule` oder fachlich sinnvoller `sonstiges`-Text
- sichtbare Bereichsbezeichnungen
- sichtbare Tätigkeitstitel einschließlich Ad-hoc-Tätigkeiten
- ausgewählte fachliche Besonderheiten
- `reportNote`
- lokal erzeugter Bericht als zu überarbeitender Entwurf
- gewünschte Sprach- und Formatregeln

Verboten sind:

- `privateNote`
- Profilname, Betrieb und Ausbildungsdaten
- Entry-ID und interne Activity-IDs
- `createdAt` und `updatedAt`
- andere Tageseinträge oder vollständige Exporte
- Schlüssel, Geräteinformationen und Debug-Logs

Der Payload-Builder arbeitet mit einer Positivliste. Ein Blacklist-Ansatz ist
hier zu fehleranfällig.

## Prompt- und Antwortvertrag

Das Modell muss den Bericht nur sprachlich überarbeiten:

- Deutsch und Ich-Perspektive
- zwei bis vier natürliche Sätze
- sachlich und für ein Ausbildungsberichtsheft geeignet
- vorhandene Fakten vollständig bewahren
- keine Tätigkeiten, Werkzeuge, Materialien, Zeiten oder Ergebnisse erfinden
- keine Überschrift, Liste, Markdown oder Vorbemerkung
- keine übertriebene Werbe- oder Verwaltungssprache

Die Antwort soll als striktes JSON-Schema mit genau einem Feld `report`
angefordert werden. Das festgelegte Modell muss strukturierte Ausgaben
unterstützen. Temperatur und Ausgabelimit bleiben niedrig. Prompt und Schema
erhalten eine feste `promptVersion`, damit Cache-Einträge gezielt ungültig
werden können.

## Modell- und Providerregeln

- genau eine konfigurierte OpenRouter-Modell-ID
- Zero Data Retention zwingend aktivieren
- Provider mit Datensammlung ablehnen
- nur Endpunkte verwenden, die die benötigten Parameter unterstützen
- Provider-Fallback innerhalb desselben Modells zulassen
- keine automatische Modell-Fallback-Kette

Existiert für das Modell kein geeigneter ZDR-Endpunkt, schlägt nur die
Verbesserung fehl; die App bleibt beim lokalen Bericht.

## Lokale Konfiguration und Schlüssel

Vorgesehene Build-Werte:

- `OPENROUTER_API_KEY`
- `OPENROUTER_MODEL_ID`
- optional `OPENROUTER_ENABLED`

Die private Release-Konfiguration wird über eine lokal ignorierte Datei an
`--dart-define-from-file` übergeben. Im Repository liegt höchstens eine
schlüssellose Beispieldatei. CI und normale Debug-Builds laufen ohne echten
Schlüssel mit deaktivierter KI und vollständigem lokalen Fallback.

Der Schlüssel muss ein eigener, widerrufbarer OpenRouter-Key mit engem
Ausgabenlimit sein. Build-Artefakte mit Schlüssel dürfen nicht veröffentlicht
oder als CI-Artefakt hochgeladen werden.

## Cache und Aktualität

KI-Berichte werden nicht in `DailyEntry` geschrieben. Eine separate Hive-Box
speichert pro Eintrags-ID mindestens:

- Berichtstext
- kanonischen SHA-256-Fingerprint der erlaubten Quelldaten
- Modell-ID
- Prompt-Version
- Erstellungszeitpunkt
- Status `pending`, `success` oder `failed`
- begrenzte Retry-Metadaten

Ein Cache-Treffer ist nur gültig, wenn Fingerprint, Modell-ID und Prompt-Version
übereinstimmen. Beim Bearbeiten entsteht ein neuer Fingerprint. Beim Löschen,
Undo und „Alle Daten löschen“ wird auch der zugehörige KI-Zustand entfernt.

Vor dem Speichern einer verspäteten Antwort wird der aktuelle Eintrag erneut
geladen und sein Fingerprint verglichen. So kann eine alte Antwort weder einen
bearbeiteten noch einen gelöschten Eintrag überschreiben.

## Hintergrundverhalten

- Anfrage erst nach erfolgreichem lokalen Speichern starten
- Aufruf nicht `await`en; Fehler vollständig im Koordinator behandeln
- pro Entry-Fingerprint höchstens ein laufender Auftrag
- Pending-Aufträge nach App-Neustart kontrolliert fortsetzen
- Wochenansicht löst keine Massenanfragen für alte Einträge aus
- kein WorkManager in der ersten Version

Falls echte Verarbeitung bei vollständig geschlossener App später notwendig
wird, ist das eine eigene Produktentscheidung. Sie rechtfertigt erst dann einen
Android-Hintergrunddienst.

## Fehler- und Kostenregeln

- Timeout ungefähr 15 Sekunden
- höchstens zwei Wiederholungen mit exponentiellem Backoff
- Retry nur bei Netzwerkfehlern, 408, 429 und 5xx
- `Retry-After` beachten
- kein Retry bei 400, 401, 402 oder 403
- keine Endlosschleife beim nächsten App-Start
- begrenzte Eingabe und ungefähr 250 bis 350 Ausgabetokens
- eine Anfrage je geändertem, geeignetem Eintrag
- keine Anfrage für Drafts oder Abwesenheitstage

Fehler werden intern als technischer Status geführt, aber der normale
Speicherflow zeigt keinen blockierenden Dialog. Eine dauerhaft ungültige
Konfiguration darf im Profil eine ruhige Diagnose erhalten; der Tagesflow
bleibt trotzdem nutzbar.

## Berichtsanzeige

- ungespeicherte Entwürfe zeigen ausschließlich den lokalen Bericht
- gespeicherte Einträge zeigen den gültigen KI-Bericht, sobald er verfügbar ist
- der KI-Bericht wird dezent als `KI-optimiert` gekennzeichnet
- Kopieren verwendet exakt den aktuell angezeigten Bericht
- ein fehlender oder ungültiger KI-Bericht ist kein UI-Fehlerzustand

Vollständig unsichtbare KI-Nutzung wird bewusst vermieden. Die Verarbeitung
läuft ohne Benutzeraktion, aber die Herkunft des angezeigten Textes bleibt
transparent.

## Dokumentationsfolgen bei Umsetzung

Mindestens prüfen und gegebenenfalls aktualisieren:

- `AGENTS.md`
- `README.md`
- `DECISIONS.md`
- `TASKS.md`
- `PROJECT_STATUS.md`
- `docs/CURRENT_STATUS.md`
- `docs/CODEMAP.md`
- `docs/AGENT_CONTEXT_PACKS.md`
- `docs/PRIVACY_CONTEXT.md`
- `docs/DATA_MODEL.md`
- `docs/VALIDATION_MATRIX.md`
- `docs/QA_RELEASE_CHECKLIST.md`

## Gesamt-Abnahmekriterien

- Speichern und Bearbeiten funktionieren vollständig offline.
- Der lokale Bericht erscheint ohne Warten auf OpenRouter.
- Pro unverändertem Eintrag entsteht höchstens eine erfolgreiche Anfrage.
- `privateNote` ist in keinem Request, Test-Fixture oder Log enthalten.
- Ein verspätetes Ergebnis kann keine neuere Version überschreiben.
- Undo, Löschen und „Alle Daten löschen“ bereinigen den KI-Cache.
- Heute- und Wochenansicht zeigen und kopieren denselben aufgelösten Bericht.
- Fehlender Schlüssel, 401, 402, 429, Timeout und Offline-Modus sind getestet.
- Kein echter API-Schlüssel ist in Git-Historie, Logs oder CI-Artefakten.
- Datenschutz- und Setup-Dokumentation beschreibt den Netzwerkzugriff ehrlich.
- `flutter analyze`, vollständige Tests, Repo-Hygiene und Debug-APK-Build sind grün.
- Ein privater signierter Release-Build wurde mit Kostenlimit auf einem echten
  Android-Gerät geprüft.

## Offizielle OpenRouter-Referenzen

- [API-Übersicht](https://openrouter.ai/docs/api_reference/overview)
- [Structured Outputs](https://openrouter.ai/docs/guides/features/structured-outputs)
- [Provider Routing](https://openrouter.ai/docs/guides/routing/provider-selection)
- [Zero Data Retention](https://openrouter.ai/docs/guides/features/zdr)
- [Provider Logging](https://openrouter.ai/docs/guides/privacy/provider-logging)
- [Fehlerbehandlung](https://openrouter.ai/docs/api_reference/errors-and-debugging)
- [Rate Limits](https://openrouter.ai/docs/api_reference/limits)
