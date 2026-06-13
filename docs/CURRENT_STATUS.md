# CURRENT_STATUS.md — Agent-Handoff

Stand: 2026-06-13

---

## Aktive Phase

**Phase 9: Lokale Erinnerungen** — Code committed, Checks auf Entwicklermaschine ausstehend

---

## Was fertig ist

Phasen 0–8 vollständig abgeschlossen. Phase 9 Code-Implementierung abgeschlossen:

- Flutter-Projektsetup, Android-Konfiguration
- Onboarding (Profil mit Name, Beruf, Jahr, Betrieb)
- Heute-Screen (Tageseintrag mit 87 Tätigkeiten, Hive-Persistenz)
- Wochenübersicht (7 Kacheln, Zusammenfassung)
- Profil anzeigen und bearbeiten
- Vorlagenverwaltung (vordefiniert + eigene)
- App-Version anzeigen, Alle Daten löschen (mit Bestätigung)
- App-Icon (teal, Berichtsheft-Metapher) in allen mipmap-Dichten
- Splash Screen (einfarbig #2E7D6B)
- App-Label: "Berichtsheft-Merker"
- TemplatesScreen: Fehlerzustand + Icon im Empty State + try/catch bei Save/Delete
- ProfileScreen: Fehler-Icon konsistent ergänzt
- Release-APK gebaut (22.4 MB, debug-signing)
- Erinnerungen (Phase 9): ReminderSettings-Modell, ReminderStorage, NotificationScheduler-Interface, Profil-Screen-Sektion, 3 neue Test-Dateien

---

## Letzte erfolgreiche Verifikation (Phase 8)

```
flutter analyze  →  0 Issues
flutter test     →  35/35 bestanden
flutter build apk  →  build/app/outputs/flutter-apk/app-release.apk (22.4 MB)
```

NDK-Hinweis: `build.gradle.kts` nutzt NDK 26.3.11579264 (NDK 27 war leer installiert).

## Phase-9-Checks (auf Entwicklermaschine ausführen)

```bash
/home/d/flutter/bin/flutter pub get
/home/d/flutter/bin/flutter analyze          # muss 0 Issues zeigen
/home/d/flutter/bin/flutter test             # muss alle Tests bestehen (35 + ~27 neue)
/home/d/flutter/bin/flutter build apk --debug
```

---

## Nächster Schritt

1. Checks auf Entwicklermaschine durchführen (s.o.)
2. Manuelle Tests auf echtem Android-Gerät:
   - App starten → Profil öffnen → Erinnerungen aktivieren
   - Permission-Dialog erscheint
   - Uhrzeit auf 2 Minuten in Zukunft setzen → App schließen → Notification prüfen
