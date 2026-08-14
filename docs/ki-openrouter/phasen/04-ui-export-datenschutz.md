# Phase 4 – UI, Kopieren, Export, Löschen und Datenschutz

## Rolle

Du arbeitest als Senior Flutter Product Engineer. Die KI bleibt unaufdringlich,
aber ihre Nutzung darf nicht unsichtbar oder irreführend sein.

## Ziel

Heute- und Wochenansicht verwenden konsistent den aufgelösten Bericht. Export,
Undo und „Alle Daten löschen“ berücksichtigen den neuen Cache. Nutzertexte und
Dokumentation beschreiben den externen Netzwerkzugriff ehrlich.

## Pflichtkontext

- `docs/ki-openrouter/PLAN.md`
- Ergebnisse aus Phase 0 bis 3
- `lib/features/today/today_screen.dart`
- `lib/features/today/widgets/report_card.dart`
- `lib/features/week/week_screen.dart`
- `lib/core/services/export_service.dart`
- Profil-/Alle-Daten-löschen-Flow in `lib/app/app.dart` und Profil-Screen
- `docs/UI_UX_SPEC.md`
- `docs/PRIVACY_CONTEXT.md`
- `docs/DATA_MODEL.md`
- Today-, Week-, Export- und Layout-Tests

## Arbeitsauftrag

1. Verwende für gespeicherte Einträge zentral `ResolvedReport`:
   gültiger KI-Cache zuerst, sonst `DailyReportGenerator`.
2. Ungespeicherte Entwürfe bleiben vollständig lokal und lösen keine Anfrage aus.
3. Aktualisiere `ReportCard`, sobald ein gültiger Hintergrundbericht eintrifft,
   ohne Modal, Spinner oder blockierende Meldung.
4. Kennzeichne nur tatsächlich verwendete KI-Texte dezent mit `KI-optimiert`.
   `Entwurf` und `Gespeichert` dürfen nicht mit der KI-Herkunft vermischt werden.
5. Stelle sicher, dass der Kopierbutton exakt den sichtbaren Bericht kopiert.
   Der aktuelle direkte Neuaufruf von `DailyReportGenerator` darf keinen anderen
   Text in die Zwischenablage legen.
6. Verwende in der Wochenansicht denselben Resolver und Cache. Beim Öffnen der
   Wochenansicht entstehen keine neuen Requests.
7. Erweitere den JSON-Export um den aktuell gültigen KI-Bericht inklusive Modell,
   Prompt-Version und Fingerprint. Exportiere niemals den API-Schlüssel oder
   technische Requestdaten.
8. Bereinige KI-Cache und Pending-Aufträge bei Einzellöschung, Undo und
   „Alle Daten löschen“. Komprimiere die neue Hive-Box entsprechend den
   bestehenden Datenschutzregeln.
9. Ergänze eine ruhige Diagnose für dauerhaft ungültige Konfiguration nur dort,
   wo sie sinnvoll administrierbar ist. Kein Fehlerbanner im normalen Tagesflow.
10. Aktualisiere alle betroffenen Produkt-, Datenschutz-, Setup-, Codemap- und
    Datenmodelldokumente. Die Aussage „alle Daten bleiben lokal“ darf nicht
    unverändert bestehen bleiben.

## UI-Regeln

- Material 3 und vorhandene Theme-Tokens verwenden.
- Keine neue Einstellungsseite nur für die feste Privatkonfiguration.
- Keine manuelle „Mit KI verbessern“-Schaltfläche im Hauptflow.
- Kein animierter Dauerstatus und keine Erfolgsmeldung pro KI-Antwort.
- Lokaler Fallback ist ein normaler Zustand, kein roter Fehler.

## Tests

- ReportCard lokal, pending und KI-optimiert
- KI-Antwort aktualisiert nur passenden gespeicherten Eintrag
- Kopieren entspricht immer dem sichtbaren Text
- WeekScreen verwendet Cache, startet aber keinen Client
- Export mit und ohne gültigen KI-Bericht
- Export enthält weder API-Schlüssel noch Request-Metadaten
- Undo, Einzellöschung und Alle-Daten-löschen bereinigen Cache/Pending
- Layout-, Semantics- und Golden-Prüfungen bei sichtbarer Chip-Änderung
- `flutter analyze`, vollständiger `flutter test`, Debug-APK-Build

## Abschlusskriterien

- Heute, Woche und Zwischenablage zeigen denselben aufgelösten Bericht.
- KI-Herkunft ist erkennbar, der Hintergrundablauf bleibt unaufdringlich.
- Alte beziehungsweise ungültige Cache-Einträge werden niemals angezeigt.
- Export und Löschpfade sind vollständig.
- Datenschutz-, Setup- und Architekturtexte entsprechen dem realen Verhalten.

Schwierigkeiten: 8/10 | Thinking: high
