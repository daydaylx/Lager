# TASKS.md — Projektphasen und Aufgaben

## Aktuelle Phase

**Phase 8: Polishing und Android-Build** — NÄCHSTE PHASE

---

## Phase 0: Projektsetup ✅

- [x] ZIP-Dokumente nach `docs/` entpackt
- [x] `README.md` erstellt
- [x] `AGENTS.md` erstellt
- [x] `CLAUDE.md` erstellt
- [x] `TASKS.md` erstellt
- [x] `PROJECT_STATUS.md` erstellt
- [x] `DECISIONS.md` erstellt
- [x] Flutter-Projektstruktur (`pubspec.yaml`, `lib/`, `test/`) angelegt
- [x] Platzhalter-Screens für alle 4 Tabs erstellt
- [x] Bottom Navigation Shell eingerichtet
- [x] `flutter pub get`
- [x] `flutter analyze` — 0 Issues

---

## Phase 1: App-Grundgerüst ✅

Voraussetzung: Flutter SDK installiert, `flutter pub get` erfolgreich.

- [x] Flutter SDK installieren (siehe README)
- [x] `flutter pub get` ausführen
- [x] `flutter analyze` — 0 Fehler
- [x] App-Start strukturell durch Widget-Tests geprüft; manuelle Android-Prüfung auf Nutzerwunsch übersprungen
- [x] Bottom Navigation funktioniert (4 Tabs)
- [x] Alle Platzhalter-Screens erreichbar
- [x] Onboarding-Flow: einfacher erster Start (optionaler Name, Ausbildungsberuf)
- [x] Onboarding wird nur beim ersten Start gezeigt (SharedPreferences-Flag)

---

## Phase 2: Onboarding erweitern ✅

- [x] Name optional eingeben (bereits in Phase 1)
- [x] Ausbildungsberuf wählen (bereits in Phase 1)
- [x] Screen: Ausbildungsjahr wählen (1, 2, 3)
- [x] Optionalen Betrieb erfassen
- [x] Bestehende Profildaten ergänzen und bearbeiten
- [x] Erweiterte Profildaten lokal speichern (SharedPreferences)
- [x] Weiterleitung zum Heute-Screen nach Abschluss

---

## Phase 3: Heute-Screen ✅

- [x] Tageseintrag erstellen (Datum, Tagtyp, Bereich, Tätigkeiten, Besonderheiten, Notiz)
- [x] Tagtypen: Betrieb, Berufsschule, Frei, Urlaub, Krank, Feiertag, Sonstiges
- [x] Tätigkeitsliste aus 87 vordefinierten Vorlagen wählen
- [x] Freie Notiz hinzufügen
- [x] Eintrag speichern und bearbeiten (zunächst im Arbeitsspeicher)
- [x] Bestehenden Eintrag für heute anzeigen wenn vorhanden
- [x] Bedingte Eingaben und Validierung je Tagtyp

---

## Phase 4: Lokale Speicherung ✅

- [x] Hive CE als lokale Datenbank einrichten
- [x] DailyEntry-Modell mit handgeschriebenem Hive-Adapter
- [x] Temporären Heute-Eintrag auf Hive CE umstellen
- [x] Daten überleben App-Neustart
- [x] Lade- und Speicherfehler verständlich behandeln

---

## Phase 5: Wochenübersicht ✅

- [x] 7-Tage-Kacheln mit Wechsel zwischen vergangenen Wochen
- [x] Kalenderbewusster Kachelstatus: eingetragen / fehlt / Frei/Urlaub/Krank
- [x] Wochenzusammenfassung als lesbare Liste
- [x] Navigation zum Tageseintrag aus Wochenansicht

---

## Phase 6: Vorlagenverwaltung ✅

- [x] Vordefinierte Tätigkeiten pro Kategorie anzeigen
- [x] Eigene Tätigkeit hinzufügen
- [x] Eigene Tätigkeit löschen
- [x] Kategorie-Filter

---

## Phase 7: Profil-Screen ✅

- [x] Profilname und Ausbildungsdaten bearbeiten (bereits in Phase 2)
- [x] App-Version anzeigen
- [x] Alle Daten löschen (mit Bestätigung)

---

## Phase 8: Polishing und Android-Build ✅

- [x] App-Icon erstellen (teal, Berichtsheft-Metapher via ImageMagick)
- [x] Splash Screen (einfarbig teal #2E7D6B)
- [x] Android APK bauen: `flutter build apk` → `build/app/outputs/flutter-apk/app-release.apk` (22.4 MB)
- [ ] Manuelle Tests auf echtem Android-Gerät
- [ ] Ladezeiten und Performance prüfen
- [x] Leere Zustände (Empty States) überall vorhanden
- [x] Fehlermeldungen verständlich

---

## Phase 9: Lokale Erinnerungen (Reminder) 🔨

- [x] `ReminderSettings`-Modell mit Defaults (20:00 Uhr, Mo–Fr)
- [x] `ReminderStorage` (SharedPreferences, JSON-Serialisierung)
- [x] `NotificationScheduler`-Interface + `NoOpNotificationScheduler` (Tests) + `FlutterLocalNotificationScheduler` (Produktiv)
- [x] Profil-Screen: Erinnerungen-Sektion (Toggle, Zeiten, Wochentage)
- [x] Android-Permissions: `RECEIVE_BOOT_COMPLETED`, `SCHEDULE_EXACT_ALARM`, `POST_NOTIFICATIONS`
- [x] `flutter_local_notifications` + `timezone` in pubspec.yaml
- [x] Tests: `reminder_settings_test.dart`, `reminder_storage_test.dart`, `profile_reminder_screen_test.dart`
- [ ] `flutter pub get` → `flutter analyze` → `flutter test` → `flutter build apk --debug` auf Entwicklermaschine ausführen
- [ ] Manuelle Tests auf echtem Android-Gerät (Permission-Dialog, Notification erscheint)
