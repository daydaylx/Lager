# TASKS.md — Projektphasen und Aufgaben

## Aktuelle Phase

**Phase 13: Robustheit und Release-Härtung** — Code und automatisierte Prüfungen abgeschlossen, manueller Android-Gerätetest und lokale Release-Signierung offen

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
- [x] Eigene Tätigkeit deaktivieren und reaktivieren
- [x] Kategorie-Filter

---

## Phase 7: Profil-Screen ✅

- [x] Profilname und Ausbildungsdaten bearbeiten (bereits in Phase 2)
- [x] App-Version anzeigen
- [x] Alle Daten löschen (mit Bestätigung)

---

## Phase 8: Polishing und Android-Build ✅ Code abgeschlossen; Gerätetest in Phase 13 offen

- [x] App-Icon erstellen (teal, Berichtsheft-Metapher via ImageMagick)
- [x] Splash Screen (einfarbig teal #2E7D6B)
- [x] Android APK bauen: `flutter build apk` → `build/app/outputs/flutter-apk/app-release.apk` (22.4 MB)
- [ ] Manuelle Tests auf echtem Android-Gerät
- [ ] Ladezeiten und Performance prüfen
- [x] Leere Zustände (Empty States) überall vorhanden
- [x] Fehlermeldungen verständlich

---

## Phase 9: Lokale Erinnerungen (Reminder) ✅ Code abgeschlossen; Gerätetest in Phase 13 offen

- [x] `ReminderSettings`-Modell mit Defaults (20:00 Uhr, Mo–Fr)
- [x] `ReminderStorage` (SharedPreferences, JSON-Serialisierung)
- [x] `NotificationScheduler`-Interface + `NoOpNotificationScheduler` (Tests) + `FlutterLocalNotificationScheduler` (Produktiv)
- [x] Profil-Screen: Erinnerungen-Sektion (Toggle, Zeiten, Wochentage)
- [x] Android-Permissions und Receiver: `RECEIVE_BOOT_COMPLETED`, `POST_NOTIFICATIONS`
- [x] `flutter_local_notifications` + `timezone` + `flutter_timezone` in pubspec.yaml
- [x] Tests: `reminder_settings_test.dart`, `reminder_storage_test.dart`, `profile_reminder_screen_test.dart`
- [x] `flutter pub get` → `flutter analyze` → `flutter test` auf Entwicklermaschine ausführen
- [x] Debug-APK mit lokaler Reminder-Konfiguration bauen: `build/app/outputs/flutter-apk/app-debug.apk`
- [ ] Manuelle Tests auf echtem Android-Gerät (Permission-Dialog, Notification erscheint)

---

## Phase 10: Kernflow- und UX-Stabilisierung ✅

- [x] Eigene Tätigkeiten im Heute-Screen und in der Wochenzusammenfassung nutzbar machen
- [x] Eigene Tätigkeiten deaktivieren statt hart löschen; historische Einträge lesbar halten
- [x] Verlustreiche Tagestyp-/Bereichswechsel und Zurück-Navigation bestätigen
- [x] Vorlagen-Ladefehler blockieren Standardtätigkeiten nicht
- [x] Leere Wochenzusammenfassung deaktivieren und Empty State präzisieren
- [x] Reminder-Berechtigung, Fehler, doppelte Zeiten und Mindest-Auswahl verständlich behandeln
- [x] Gerätezeitzone für lokale Erinnerungen setzen
- [x] Geplante Erinnerungen bei „Alle Daten löschen“ abbrechen
- [x] `flutter analyze` — 0 Issues
- [x] `flutter test` — 77/77 bestanden
- [x] `flutter build apk --debug` — erfolgreich
- [ ] Manueller Android-Test: Zurück-Geste, Vorlagen-Sync, Permission-Dialog, lokale Uhrzeit, Datenlöschung

---

## Phase 11: UI-Redesign ✅ Code abgeschlossen; Gerätetest in Phase 13 offen

- [x] Explizites Material-3-Komponententheme und gemeinsame UI-Bausteine
- [x] Onboarding auf zwei kompakte, klar geführte Schritte umstellen
- [x] Heute-Screen mit Statuskopf, Tätigkeits-Checklisten und ruhiger Sticky-Speicheraktion
- [x] Woche als kompakte Tagesliste mit Zusammenfassung im Kopf
- [x] Vorlagen mit lokaler Suche und keyboard-sicherem Bottom Sheet
- [x] Profil als Übersicht mit separatem Bearbeitungsscreen und gruppierten Einstellungen
- [x] Kleine Displays, große Systemschrift, Touchflächen und Tastatur automatisiert prüfen
- [x] Vier Golden-Referenzen für zentrale UI-Zustände
- [x] `flutter analyze` — 0 Issues
- [x] `flutter test` — 87/87 bestanden
- [ ] Manueller Android-Test: visuelle Wirkung, Einhandbedienung, Tastatur und große Systemschrift

---

## Phase 12: Reminder-Stack verbessern ✅ Code abgeschlossen; Gerätetest in Phase 13 offen

Issues #14–#20 aus GitHub abgearbeitet.

- [x] #14 Android 13+ Permission-Feedback: Warnung + Button "Benachrichtigungseinstellungen öffnen" (`app_settings`)
- [x] #15 Notification-Channel mit `Importance.high`, `Priority.high`, Ton und Vibration
- [x] #16 Bessere Notification-Copy: Titel und Text überarbeitet, Tap-Payload `'today'` → öffnet Heute-Tab
- [x] #17 Eskalationslogik: zweite Erinnerung 30 min nach primärer, Wochencheck freitags 19:00
- [x] #18 Samsung-Hinweis als `ExpansionTile` im Profil-Screen (Akku, Nicht-Stören, Kategorien)
- [x] #19 Wochenansicht: Banner "X Tage fehlen noch", App-Start-SnackBar bei fehlendem Eintrag
- [x] #20 QA-Checkliste `docs/QA_REMINDER_CHECKLIST.md` für manuellen Samsung-Test erstellt
- [x] `flutter analyze` — 0 Issues
- [x] `flutter test` — 130/130 bestanden
- [x] `flutter build apk --debug` — erfolgreich
- [ ] Manueller Android-Gerätetest: Permission-Dialog, Notifications, Samsung-spezifisches Verhalten

---

## Bereits implementierte Ergänzungen

### UI/UX-Audit Phase 1 + Phase 2 ✅

- [x] `AppMessageTone.success` → `secondaryContainer` (nicht `primaryContainer`)
- [x] Besonderheiten & Notiz hinter `ExpansionTile` (auto-expandiert bei Sonstiges, `maintainState: true`)
- [x] Report-Vorschau als Bottom Sheet über SaveBar-Button „Vorschau"
- [x] Selektionszähler in SaveBar integriert (immer sichtbar beim Scrollen)
- [x] WeekHeader entschlackt — „Wochenzusammenfassung" → AppBar-IconButton
- [x] Golden-Referenzen und Tests nach strukturellen UI-Änderungen aktualisiert

### UI/UX-Audit Phase 3 ✅

- [x] `_DayStatusCard` aus ListView extrahiert — bleibt beim Scrollen sichtbar (Heute-Screen)
- [x] `_WeekHeader` aus ListView extrahiert — bleibt beim Scrollen sichtbar (Woche-Screen)
- [x] `Semantics(label, value)` auf `LinearProgressIndicator` in `_WeekHeader`
- [x] WCAG-Kontrast-Tests für Heute, Woche und Profil (Standard-Theme)
- [x] Kontrast-Test für helles Preset ("Hell")
- [x] Tap-Target-Richtlinien-Test für Heute-Screen
- [x] `flutter test` — 150/150 bestanden (14 neue Tests in `ui_layout_test.dart`)

### Issues #12/#13 und #21–#28 (ebenfalls abgeschlossen):

- [x] Deterministischer lokaler Tagesberichtsvorschlag in Heute und Woche
- [x] Berichtsvorschläge lokal kopierbar, ohne KI oder externe API
- [x] Fünf persistierte Farbthemes inklusive hellem Preset
- [x] Profil-Screen mit separater Darstellungsgruppe
- [x] Zusätzliche mobile UI-Verbesserungen und Kontrastkorrekturen
- [ ] Theme-Auswahl und Theme-Persistenz auf echtem Android-Gerät prüfen

---

## Phase 13: Robustheit und Release-Härtung 🔨

- [x] App-Startfehler sichtbar behandeln und ohne Datenlöschung erneut versuchen
- [x] Tageswechsel nach Resume in Heute- und Wochenansicht aktualisieren; offene Eingaben schützen
- [x] Notification-Taps bei laufender App und Kaltstart zuverlässig zum Heute-Tab leiten
- [x] Reminder-Plan normalisieren, auf 7 Uhrzeiten begrenzen und eindeutige IDs verwenden
- [x] Folgeerinnerung ehrlich formulieren und Mitternachtswechsel korrekt planen
- [x] Reminder-Speicherung und nativen Zeitplan bei Fehlern zurückrollen
- [x] Benachrichtigungsberechtigung nach Rückkehr aus Android-Einstellungen neu prüfen
- [x] Fehlgeschlagene SharedPreferences-Schreibvorgänge sichtbar machen
- [x] Hive-Dateien nach „Alle Daten löschen“ komprimieren
- [x] Android-Backup und Gerätetransfer für lokale App-Daten deaktivieren
- [x] Eindeutige Application ID und optionale lokale Release-Signierung konfigurieren
- [x] CI um Debug-APK-Build erweitern
- [x] `flutter analyze` — 0 Issues
- [x] `flutter test` — 145/145 bestanden
- [x] `flutter build apk --debug` mit NDK 27 — erfolgreich
- [x] Release-Build ohne Keystore ist unsigniert und nicht mit Debug-Key signiert
- [ ] Manueller Android-Gerätetest nach `docs/QA_REMINDER_CHECKLIST.md`
- [ ] Release-Keystore lokal erstellen und signierten Release-Build prüfen

---

## Spätere Phase: Toolchain- und Dependency-Modernisierung

- [ ] Flutter, Android Gradle Plugin, Kotlin und Dependencies gemeinsam aktualisieren
- [ ] Migration separat planen und mit vollständiger Regression absichern
