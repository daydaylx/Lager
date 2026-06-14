# CURRENT_STATUS.md — Agent-Handoff

Stand: 2026-06-14

---

## Aktive Phase

**Phase 11: UI-Redesign** — Code und automatisierte UI-Checks abgeschlossen

---

## Was fertig ist

Phasen 0–11 im Code abgeschlossen:

- Flutter-Projektsetup, Android-Konfiguration
- Onboarding (Profil mit Name, Beruf, Jahr, Betrieb)
- Heute-Screen (Standard- und eigene Tätigkeiten, Hive-Persistenz, Schutz vor Eingabeverlust)
- Wochenübersicht (kompakte Tagesliste, Zusammenfassung mit eigenen Tätigkeitstiteln)
- Profil anzeigen und bearbeiten
- Vorlagenverwaltung (vordefiniert + eigene, deaktivieren/reaktivieren)
- App-Version anzeigen, Alle Daten löschen (mit Bestätigung)
- App-Icon (teal, Berichtsheft-Metapher) in allen mipmap-Dichten
- Splash Screen (einfarbig #2E7D6B)
- App-Label: "Berichtsheft-Merker"
- TemplatesScreen: lazy Liste, Validierung, Aktivstatus und Screen-Synchronisierung
- ProfileScreen: Fehler-Icon konsistent ergänzt
- Release-APK gebaut (22.4 MB, debug-signing)
- Erinnerungen: Gerätezeitzone, Permission-/Fehlerstatus, Rollback, Android-Receiver
- Alle Daten löschen bricht geplante Erinnerungen ab
- Reduziertes Material-3-Komponententheme und gemeinsame UI-Bausteine
- Zweistufiges Onboarding, Profilübersicht mit separater Bearbeitung
- Tätigkeits-Checklisten, kompakte Wochenliste, Vorlagensuche und Bottom Sheet
- Layouttests für kleine Displays, große Schrift, Tastatur und Touchflächen
- Vier Golden-Referenzen unter `test/goldens/`

---

## Letzte erfolgreiche Verifikation

```
flutter analyze  →  0 Issues
flutter test     →  103/103 bestanden
flutter build apk --debug  →  erfolgreich, build/app/outputs/flutter-apk/app-debug.apk
adb install -r   →  erfolgreich auf Gerät RFCY210JHMJ
```

GitHub Actions CI unter `.github/workflows/flutter-ci.yml` eingerichtet.

## Was neu ist (2026-06-14)

- **GitHub CI (#7):** `.github/workflows/flutter-ci.yml` — analyze + test bei Push/PR
- **ReminderSettings robuster (#10):** JSON-Fehlerbehandlung, Wochentag-Validierung/Deduplizierung/Sortierung, `copyWith` gibt unmodifiable Listen zurück, 7 neue Tests
- **TodayScreen aufgeteilt (#8):** `_DayStatusCard` und `_SaveBar` als eigene private Widgets
- **Persistenzstabilität (#11):** `test/persistence_stability_test.dart` — 9 Tests sichern Enum-Namen und Activity-IDs
- **WeekScreen/Profile (#9):** `_ReminderSection` als eigene StatelessWidget-Klasse
- **Docs (#1–4):** AGENTS.md gestaffelt, Dopplungen entfernt, README aktualisiert, PDF-Scope geklärt

## Nächster Schritt

Manuelle Tests auf echtem Android-Gerät (APK ist installiert):

- Eigene Tätigkeit hinzufügen → Heute auswählen → Woche prüfen
- Verlustreiche Wechsel und Android-Zurück-Geste prüfen
- App starten → Profil öffnen → Erinnerungen aktivieren
- Permission-Dialog erscheint
- Uhrzeit auf 2 Minuten in Zukunft setzen → App schließen → Notification prüfen
- Alle Daten löschen → keine weitere Notification
- UI auf kleinem Display und mit großer Systemschrift visuell prüfen
- Tastaturverhalten in Heute-Notiz und Vorlagen-Bottom-Sheet prüfen
