# CURRENT_STATUS.md — Agent-Handoff

Stand: 2026-06-13

---

## Aktive Phase

**Phase 10: Kernflow- und UX-Stabilisierung** — Code und automatisierte Checks abgeschlossen

---

## Was fertig ist

Phasen 0–10 im Code abgeschlossen:

- Flutter-Projektsetup, Android-Konfiguration
- Onboarding (Profil mit Name, Beruf, Jahr, Betrieb)
- Heute-Screen (Standard- und eigene Tätigkeiten, Hive-Persistenz, Schutz vor Eingabeverlust)
- Wochenübersicht (7 Kacheln, Zusammenfassung mit eigenen Tätigkeitstiteln)
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

---

## Letzte erfolgreiche Verifikation

```
flutter analyze  →  0 Issues
flutter test     →  77/77 bestanden
flutter build apk --debug  →  erfolgreich, build/app/outputs/flutter-apk/app-debug.apk
```

Der Debug-Build nutzt NDK 26.3.11579264. Die lokal vorhandene NDK-27-Kopie
ist unvollständig; die abweichende Plugin-Empfehlung blockiert den Build nicht.
Ein echter Android-UI-Test war nicht möglich, weil kein ADB-Gerät oder Emulator
verfügbar war.

## Nächster Schritt

Manuelle Tests auf echtem Android-Gerät:

- Eigene Tätigkeit hinzufügen → Heute auswählen → Woche prüfen
- Verlustreiche Wechsel und Android-Zurück-Geste prüfen
- App starten → Profil öffnen → Erinnerungen aktivieren
- Permission-Dialog erscheint
- Uhrzeit auf 2 Minuten in Zukunft setzen → App schließen → Notification prüfen
- Alle Daten löschen → keine weitere Notification
