# CURRENT_STATUS.md — Agent-Handoff

Stand: 2026-06-15 (nach signierter Release-APK-Installation)

---

## Aktive Phase

**Phase 13: Robustheit und Release-Härtung** — Code, automatisierte Prüfungen und lokale Release-Signierung abgeschlossen; manueller Android-Gerätetest offen

---

## Was fertig ist

Phasen 0–13 im Code abgeschlossen, plus UI/UX-Audit Phasen 1–3. Neu in Audit Phase 3:

- `today_screen.dart`: `_DayStatusCard` aus ListView extrahiert → bleibt beim Scrollen sichtbar
- `week_screen.dart`: `_WeekHeader` aus ListView extrahiert → bleibt beim Scrollen sichtbar
- `week_screen.dart`: `Semantics(label, value)` auf `LinearProgressIndicator` in `_WeekHeader`
- `ui_layout_test.dart`: 5 neue Accessibility-Guideline-Tests (WCAG-Kontrast für 3 Screens + helles Preset, Tap-Target)
- Golden-Referenzen (`today_empty.png`, `week_mixed.png`) nach Sticky-Header-Änderung aktualisiert
- `flutter test` → 150/150 bestanden

Neu im UI-Audit Phase 1 und Phase 2:

- `app_ui.dart`: `AppMessageTone.success` nutzt jetzt `secondaryContainer` statt `primaryContainer`
- `today_screen.dart`: Besonderheiten & Notiz hinter `ExpansionTile` (optional, auto-expandiert bei Sonstiges), Report-Vorschau als Bottom Sheet via SaveBar-Button, Selektionszähler direkt in SaveBar
- `week_screen.dart`: „Wochenzusammenfassung"-Button aus `_WeekHeader` nach AppBar verschoben
- Tests: `today_screen_test.dart` und `ui_layout_test.dart` angepasst, alle Golden-Referenzen aktualisiert

Neu in Phase 13:

- Sichtbarer Bootstrap-Fehler mit Retry statt stiller oder destruktiver Wiederherstellung
- Tageswechsel bei Resume; offene Heute-Eingaben bleiben dem bisherigen Datum zugeordnet
- Notification-Taps inklusive Kaltstart öffnen zuverlässig den Heute-Tab
- Deterministischer Reminder-Plan mit eindeutigen IDs, Mitternachtswechsel und maximal 7 Uhrzeiten
- Ehrliche Folgeerinnerung, Permission-Neuprüfung und Rollback bei Speicher-/Planungsfehlern
- SharedPreferences-Schreibfehler werden geprüft; Hive wird nach Komplettlöschung komprimiert
- Android-Backup und Gerätetransfer sind für alle lokalen Daten deaktiviert
- Application ID `com.daydaylx.berichtsheftmerker`; Release nutzt keinen Debug-Schlüssel
- Lokale Release-Signierung ist in dieser Arbeitskopie über ignorierte Dateien `android/key.properties` und `android/app/upload-keystore.jks` eingerichtet
- CI führt zusätzlich `flutter build apk --debug` aus

Weitere akzeptierte aktuelle Funktionen:

- Deterministischer lokaler Tagesberichtsvorschlag in Heute und Woche, inklusive Kopieren
- Fünf lokal persistierte Farbthemes; `Lager Teal` ist das dunkle Standardpreset
- Theme-Auswahl im Profil und Zurücksetzen über „Alle Daten löschen“

---

## Letzte erfolgreiche Verifikation

```
flutter analyze  →  0 Issues
flutter test     →  150/150 bestanden (inkl. 5 neue Accessibility-Tests und aktualisierte Goldens)
flutter build apk --debug    →  erfolgreich mit NDK 27
flutter build apk --release  →  erfolgreich signiert erzeugt (24.1 MB)
adb install -r app-release.apk auf Samsung SM-S931B  →  erfolgreich
```

Das zusammengeführte Release-Manifest bestätigt
`com.daydaylx.berichtsheftmerker`, `allowBackup=false` und die
Backup-/Transfer-Regeln. `apksigner` bestätigt v1/v2-Signatur mit lokalem
Release-Zertifikat; der installierte Build meldet `apkSigningVersion=2`.

---

## Nächster Schritt

1. Installierte Release-APK auf echtem Android-Gerät nach `docs/QA_REMINDER_CHECKLIST.md` testen, einschließlich Reminder, Theme-Auswahl und Neustart.
2. Lokalen Release-Keystore sicher aufbewahren; spätere Release-Updates müssen mit demselben Keystore signiert werden.
3. Toolchain- und Dependency-Modernisierung als separate spätere Phase planen.
