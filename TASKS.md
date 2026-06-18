# TASKS.md — Projektphasen und Aufgaben

## Aktuelle Phase

**Phase 16: Tagesbericht fachlich und sichtbar verbessern** ✅ — Code abgeschlossen; visuelle Prüfung auf Gerät noch offen.

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
- [x] Tätigkeitsliste aus 132 vordefinierten Vorlagen wählen
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

### Tätigkeiten-Erfassung #29–#36

- [x] #29 Tätigkeitskatalog fachlich erweitert: 132 vordefinierte Tätigkeiten
- [x] #30 Heute-Screen: Suche, häufig genutzt und ausgewählte Tätigkeiten als Chips
- [x] #31 Untergruppen / Arbeitsschritte: optionales `subcategory`-Feld, UI-Untergruppen
- [x] #32 EDV-, Scanner- und Warenwirtschafts-Tätigkeiten ergänzt
- [x] #33 Unterweisung punktuell über Tätigkeiten/Besonderheiten abbildbar
- [x] #34 Qualität, Ordnung und 5S praxisnäher ergänzt
- [x] #35 Tagesbericht-Generator mit mehreren festen Satzmustern erweitert
- [x] #36 Ausbildungsjahr-Priorisierung als weiche Empfehlung, ohne Tätigkeiten zu verstecken
- [x] `flutter analyze` — 0 Issues
- [x] `flutter test` — 168/168 bestanden

### Robustheits- und Doku-Issues #38–#48

- [x] #38 Ausbildungsjahr abhängig vom Ausbildungsberuf validieren
- [ ] #39 Lokalen Datenexport/-import prüfen; separate Produktentscheidung offen
- [x] #40 Tagesbericht-Generator bindet Notizen, Kontrolle, Probleme und Fehlerkorrektur ein
- [x] #41 Eigene Tätigkeiten gegen normalisierte Duplikate prüfen
- [x] #42 App-Version per Test gegen `pubspec.yaml` absichern
- [x] #43 `DATA_MODEL.md`: `TrainingOccupation`-Widerspruch korrigiert
- [x] #44 `UI_UX_SPEC.md`: Bereichsauswahl an aktuelle zweispaltige Multi-Select-UI angepasst
- [x] #45 Notification-Initialisierungsfehler im Profil sichtbar machen
- [x] #46 SnackBar „Eintrag fehlt“ mit direkter Aktion zur Heute-Ansicht
- [x] #47 TodayScreen weiter in kleinere Widgets für Aktivitätsgruppen zerlegt
- [x] #48 Enum-/Hive-Persistenz über zentrale Parser und Tests abgesichert
- [x] `flutter analyze` — 0 Issues
- [x] `flutter test` — 168/168 bestanden

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
- [x] Release-Keystore lokal erstellen und signierten Release-Build prüfen

---

## Nächste Schritte: priorisierte Abarbeitung offener Issues #29–#49

Diese Reihenfolge ist bewusst nicht nach Issue-Nummern sortiert. Einige Issues hängen technisch voneinander ab. Vor allem darf der Tätigkeitskatalog nicht stark erweitert werden, bevor die UI und der `TodayScreen` dafür vorbereitet sind. Sonst entsteht nur eine größere Button-Tapete mit mehr Wartungsrisiko.

Detaillierter Umsetzungsplan mit Größenklasse, Risiko, Mindestumfang und „nicht akzeptabel“-Grenzen: [`docs/ISSUE_EXECUTION_PLAN.md`](docs/ISSUE_EXECUTION_PLAN.md)

### Phase 14: Dokumentations- und Datenmodell-Basis absichern

Ziel: Erst die Grundlagen korrigieren, damit Agenten und spätere Änderungen nicht gegen falsche Dokumentation oder fragile Persistenz arbeiten.

- [x] #43 `DATA_MODEL.md`: `TrainingOccupation`-Widerspruch korrigiert.
- [x] #44 `UI_UX_SPEC.md`: zweispaltige Bereichsauswahl dokumentiert.
- [x] #42 App-Version: Konstante + Test gegen `pubspec.yaml`; Strategie dokumentiert.
- [x] #48 Enum-/Hive-Persistenz: `LazyBox` + per-Entry-Fehlerhandling + Integrationstest.
- [x] #38 Ausbildungsjahr: Validierung zentral + Widget-Test für Profilbearbeitung mit Berufsänderung.
- [x] `flutter analyze` — 0 Issues
- [x] `flutter test` — 170/170 bestanden

### Phase 15: Heute-Screen entlasten, bevor neue UI-Features dazukommen

Ziel: Struktur schaffen, bevor weitere Tätigkeiten-, Such- und Berichtsfunktionen eingebaut werden. Ohne diese Phase wird jede spätere Änderung unnötig riskant.

- [x] #47 `TodayScreen` in kleinere wartbare Widgets/Dateien zerlegt.
- [x] Extraktion ohne Verhaltensänderung: `DayStatusCard`, `SaveBar`, `AreaGrid`, `DayTypeSelector`, `SpecialFlagsAndNoteSection`, `ActivitySection`-Widgets in `widgets/`-Unterordner.
- [x] Bestehende Widget-Tests unverändert grün (170/170).
- [x] `flutter analyze` — 0 Issues
- [x] `flutter test` — 170/170 bestanden

### Phase 16: Tagesbericht fachlich und sichtbar verbessern

Ziel: Erst Textqualität verbessern, dann die prominente UI-Karte einbauen. Eine schöne Karte mit schwachem Text wäre nur hübsch verpackter Mittelmaß-Kram.

- [x] #40 Tagesbericht-Generator: Besonderheiten und Notizen nach Tagtyp differenziert (Betrieb vs. Berufsschule).
- [x] #35 Tagesbericht-Generator: datumsbasierte Satzmuster-Variation; Berufsschule 3+ mit 3 Alternativen.
- [x] #49 Tagesbericht als prominente Berichtskarte im Heute-Screen; Bottom-Sheet-Preview entfernt.
- [x] Bestehenden Bottom-Sheet-Preview-Flow entfernt; durch Berichtskarte ersetzt.
- [x] Unit-Tests für Generator-Kombinationen erweitert (7 neue Berufsschule-Flag-Tests + 5 Datumsvarianten-Tests).
- [x] Widget-Tests für Berichtskarte (erscheint, Status, Kopieren) ergänzt.
- [x] `flutter analyze` — 0 Issues
- [x] `flutter test` — 184/184 bestanden

### Phase 17: Tätigkeitskatalog und Tätigkeiten-UI skalierbar machen ✅

Bereits in früheren Phasen implementiert; Phase-17-Einträge waren stale.

- [x] #30 Tätigkeiten-UI: Häufig genutzt, Suche, Auswahlchips (in `today_screen.dart` / `activity_section.dart`)
- [x] #31 Untergruppen via `activitySubcategories.dart` und `ActivityGroup`-Widget
- [x] #41 Eigene Tätigkeiten gegen normalisierte Duplikate prüfen (Fehlermeldung mit Konfliktnamen: s. Robustheitskorrekturen)
- [x] #29 Tätigkeitskatalog: 132 vordefinierte Lagerlogistik-Tätigkeiten
- [x] #32 EDV-, Scanner- und Warenwirtschafts-Tätigkeiten
- [x] #34 Qualität, Ordnung und 5S
- [x] #33 Unterweisung punktuell über Tätigkeiten/Besonderheiten
- [x] #36 Ausbildungsjahr-Priorisierung als weiche Empfehlung

### Phase 18: Reminder-/Alltagskomfort und lokale Sicherung 🔨

- [x] #45 Notification-Initialisierungsfehler sichtbar — in `profile_screen.dart`
- [x] #46 SnackBar „Eintrag fehlt” mit direkter Aktion — in `today_screen.dart`
- [ ] #39 Lokalen Datenexport und Import — bewusst offen (Produktentscheidung)
- [ ] Export/Import nur lokal und einfach halten; keine Cloud, kein Account, kein PDF-Overhead.

### Phase 19: Release-QA auf echtem Android-Gerät

Ziel: Erst nach den obigen Änderungen ernsthaft testen. Vorher ist ein kompletter manueller Release-Test nur Beschäftigungstherapie, weil danach ohnehin wieder UI und Datenmodell verändert werden.

- [ ] #37 Manuellen Android-Release-QA-Durchlauf dokumentieren und durchführen.
- [ ] Offene manuelle Tests aus Phase 8–13 zusammenführen.
- [ ] Installation, App-Start, Tagesbericht, Woche, Vorlagen, Profil, Reminder, Theme-Persistenz und Datenlöschung prüfen.
- [ ] Signierte Release-APK auf echtem Android-Gerät testen.
- [ ] Ergebnis in QA-Dokumentation festhalten.

### Harte Arbeitsregel für die nächsten Phasen

- Pro Phase möglichst kleine PRs/Commits statt einem Riesenumbau.
- Nach jeder Phase mindestens `flutter analyze` und `flutter test`.
- Bei UI-Änderungen Screenshots/Golden-Referenzen prüfen.
- Keine neuen Features einbauen, die nicht durch ein Issue gedeckt sind.
- Keine KI/API/PDF/Cloud-Funktion einschleppen, solange die App bewusst lokaler Berichtsheft-Merker bleibt.

---

## Spätere Phase: Toolchain- und Dependency-Modernisierung

- [ ] Flutter, Android Gradle Plugin, Kotlin und Dependencies gemeinsam aktualisieren
- [ ] Migration separat planen und mit vollständiger Regression absichern
