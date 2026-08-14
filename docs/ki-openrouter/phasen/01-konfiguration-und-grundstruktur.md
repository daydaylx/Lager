# Phase 1 – Private Konfiguration und Grundstruktur

## Rolle

Du arbeitest als Senior Flutter Engineer und bereitest die Integration so vor,
dass UI, Speicherung und Provider sauber getrennt bleiben.

## Ziel

Führe die minimale technische Grundstruktur für OpenRouter ein, ohne bereits
echte Netzwerkaufrufe aus dem Nutzerflow zu starten.

## Voraussetzung

Phase 0 ist vollständig abgeschlossen. Modell-ID, ZDR-Regel, Prompt-Version und
Budgetgrenze sind keine Platzhalter mehr.

## Pflichtkontext

- `docs/ki-openrouter/PLAN.md`
- Ergebnisse und Diff aus Phase 0
- `lib/app/bootstrap.dart`
- `lib/app/app.dart`
- `lib/main.dart`
- `lib/core/storage/daily_entry_storage.dart`
- `lib/core/storage/hive_daily_entry_storage.dart`
- `lib/core/services/export_service.dart`
- `android/app/src/main/AndroidManifest.xml`
- `pubspec.yaml`
- `scripts/check_repo_hygiene.sh`
- relevante Bootstrap-, Storage- und Hygiene-Tests

## Arbeitsauftrag

1. Lege eine kleine unveränderliche OpenRouter-Konfiguration an, die ausschließlich
   aus Compile-Time-Werten liest:
   - `OPENROUTER_API_KEY`
   - `OPENROUTER_MODEL_ID`
   - `OPENROUTER_ENABLED`
2. Definiere klares Verhalten für fehlende oder unvollständige Konfiguration:
   KI deaktiviert, lokaler Bericht aktiv, kein App-Startfehler.
3. Ergänze eine schlüssellose Beispielkonfiguration. Die echte private Datei
   muss durch `.gitignore` ausgeschlossen sein.
4. Erweitere `scripts/check_repo_hygiene.sh` um Prüfungen gegen OpenRouter-Key-
   Muster und private Konfigurationsdateien. Keine Schlüsselwerte ausgeben.
5. Ergänze nur die begründeten Dependencies für HTTP und stabilen SHA-256-
   Fingerprint. Kein Dio, keine Codegenerierung und kein State-Management-Paket.
6. Lege die Interfaces und Datenobjekte für `ReportEnhancer`, `AiReportCache`,
   `ReportEnhancementCoordinator` und `ResolvedReport` an.
7. Implementiere eine separate Hive-Box für abgeleitete KI-Berichte. `DailyEntry`
   und sein Adapter bleiben unverändert.
8. Injiziere Konfiguration, Cache und Koordinator über `AppBootstrap` und
   `BerichtsheftApp`. Noch keine Anfrage aus `TodayScreen` starten.
9. Ergänze die `INTERNET`-Permission im Produktivmanifest erst zusammen mit der
   dokumentierten Datenschutzänderung aus Phase 0.
10. Sorge dafür, dass Debug- und CI-Builds ohne privaten Schlüssel vollständig
    funktionieren.

## Architekturgrenzen

- Kein globaler Singleton mit verstecktem Zustand.
- Keine Netzwerklogik in Widgets.
- Keine KI-Felder im `DailyEntry` und keine Migration der `entries`-Box.
- Cachefehler dürfen den App-Start und die lokale Speicherung nicht blockieren.
- Der Schlüssel darf weder Getter-Ausgaben, `toString`, Exceptions noch Logs
  erreichen.

## Tests

- Konfiguration vollständig, deaktiviert und unvollständig
- Bootstrap mit funktionsfähigem und fehlerhaftem KI-Cache
- Cache-Roundtrip und korrupter Einzelwert
- CI-/Debug-Verhalten ohne Schlüssel
- Hygiene-Skript erkennt Test-Secret in isoliertem Fixture, ohne echten Schlüssel
- `flutter analyze`
- vollständiger `flutter test`
- `flutter build apk --debug`

## Abschlusskriterien

- App verhält sich ohne Schlüssel exakt wie vorher.
- Neue Servicegrenzen sind injizierbar und mit Fakes testbar.
- KI-Cache ist vollständig vom `DailyEntry` getrennt.
- Repository und Git-Historie enthalten keinen echten Schlüssel.
- Produktivmanifest und Datenschutzdokumentation widersprechen sich nicht.
- Alle Tests und der Debug-Build sind grün.

Schwierigkeiten: 7/10 | Thinking: high
