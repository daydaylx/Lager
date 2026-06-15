# CURRENT_STATUS.md — Agent-Handoff

Stand: 2026-06-15

---

## Aktive Phase

**Phase 13: Robustheit und Release-Härtung** — Code und automatisierte Prüfungen abgeschlossen

---

## Was fertig ist

Phasen 0–13 im Code abgeschlossen. Neu in Phase 13:

- Sichtbarer Bootstrap-Fehler mit Retry statt stiller oder destruktiver Wiederherstellung
- Tageswechsel bei Resume; offene Heute-Eingaben bleiben dem bisherigen Datum zugeordnet
- Notification-Taps inklusive Kaltstart öffnen zuverlässig den Heute-Tab
- Deterministischer Reminder-Plan mit eindeutigen IDs, Mitternachtswechsel und maximal 7 Uhrzeiten
- Ehrliche Folgeerinnerung, Permission-Neuprüfung und Rollback bei Speicher-/Planungsfehlern
- SharedPreferences-Schreibfehler werden geprüft; Hive wird nach Komplettlöschung komprimiert
- Android-Backup und Gerätetransfer sind für alle lokalen Daten deaktiviert
- Application ID `com.daydaylx.berichtsheftmerker`; Release nutzt keinen Debug-Schlüssel
- Optionale lokale Release-Signierung über ignorierte Datei `android/key.properties`
- CI führt zusätzlich `flutter build apk --debug` aus

---

## Letzte erfolgreiche Verifikation

```
flutter analyze  →  0 Issues
flutter test     →  145/145 bestanden
flutter build apk --debug    →  erfolgreich mit NDK 27
flutter build apk --release  →  erfolgreich erzeugt, bewusst unsigniert
```

Das zusammengeführte Release-Manifest bestätigt
`com.daydaylx.berichtsheftmerker`, `allowBackup=false` und die
Backup-/Transfer-Regeln. `apksigner` bestätigt, dass der Release-Build ohne
lokalen Keystore keine Debug-Signatur enthält.

---

## Nächster Schritt

1. Debug-APK auf echtem Android-Gerät nach `docs/QA_REMINDER_CHECKLIST.md` testen.
2. Lokalen Release-Keystore konfigurieren und signierten Release-Build prüfen.
3. Toolchain- und Dependency-Modernisierung als separate spätere Phase planen.
