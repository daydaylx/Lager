# CURRENT_STATUS.md — Agent-Handoff

Stand: 2026-07-15 (Phase 26 abgeschlossen — a/b/c UX-Quick-Wins + d Native Patterns; analyze 0 Issues, 280/280 Tests grün)

---

## Letzte Änderung: Phase 26d – Native Patterns & Bewegung (UX-4 B3, B5, B11)

- **B3 App-Shortcuts für Android:** `res/xml/shortcuts.xml` mit Shortcut `open_today` (Intent-Schema `berichtsheftmerker://shortcut/<id>`); `res/values/strings.xml` mit Label-Strings; `AndroidManifest.xml` um `<meta-data android:name="app_shortcuts">` ergänzt; `MainActivity.kt` liest Intent in `configureFlutterEngine` und `onNewIntent` und liefert initialen Shortcut bzw. Live-Aufruf via `MethodChannel` `app_shortcuts`; `lib/core/services/app_shortcut_service.dart` als Flutter-Bridge mit `AppShortcutAction`-Enum; `MainShell` schaltet bei `openToday` auf Tab 0. **Verhalten nur auf echtem Gerät verifizierbar** — manuelle QA im Phase-19-Gerätetest.
- **B5 AnimatedSwitcher zwischen Flow-Schritten:** Step-Inhalt in eigenes `_StepBody`-Widget extrahiert; in `TodayCheckInPage` mit `AnimatedSize` + `AnimatedSwitcher` (FadeTransition, 220 ms, `easeOut`/`easeIn`) umschlossen; stabiler Key enthält Step + DayType, damit State-Updates ohne Step-Wechsel keine neue Animation auslösen.
- **B11 SaveBar-Sichtbarkeit bei Tastatur:** bestehender Test „Heute-Notiz und Speichern bleiben mit Tastatur erreichbar" (`test/ui_layout_test.dart`, 360×640 + 280 dp Tastatur-Inset) deckt das Verhalten bereits ab — SaveBar bleibt nach Tastatur-Öffnung findbar. Zusätzliche `Scrollable.ensureVisible` wäre redundant; bewusst kein Code-Eingriff.
- **Bewusst zurückgestellt:** UX-3 A5 (bedingte Suchfeld-Sichtbarkeit), UX-3 B8 (Witz-Sheet-Toggle im Profil) und die umfangreichen Erweiterungen (Stepper-Pattern, Draft-Persistenz, First-Day-Erfahrung, Onboarding-Illustration, App-Icon-Badge) bleiben eigene zukünftige Phasen.
- **Neue Dateien:** `android/app/src/main/res/xml/shortcuts.xml`, `android/app/src/main/res/values/strings.xml`, `lib/core/services/app_shortcut_service.dart`, `test/app_shortcut_service_test.dart`.
- **Geänderte Dateien:** `android/app/src/main/AndroidManifest.xml`, `android/app/src/main/kotlin/.../MainActivity.kt`, `lib/app/app.dart`, `lib/features/today/widgets/today_flow.dart`.
- `flutter analyze` — 0 Issues; `flutter test` — 280/280 grün; `flutter build apk --debug` — erfolgreich; `scripts/check_repo_hygiene.sh` — OK.

---

## Vorherige Änderung: Phase 26 – UX-Quick-Wins

- **26a — Flow-Orientierung & Haptik:** Schritt-Labels aus `TodayFlowStep` + Tagestyp korrekt abgeleitet (Betrieb 1/4, Berufsschule 1/3, Abwesenheit 1/2) statt hartcodiertem „Schritt 2 von 4"; neuer `AppStepIndicator` (N Punkte, aktiver Schritt breiter in Primärfarbe); Picker-Header trägt Bereichs-Kontext; Haptic auf AreaGrid, `ActivityRow` und SpecialFlag; „Wie gestern starten" von FilledButton.tonalIcon auf OutlinedButton.icon; Abwesend-Chip mit Tooltip + `unfold_more`-Icon.
- **26b — UX-Patterns:** Pull-to-Refresh auf Heute- und Vorlagen-Screen (bisher nur Woche); Pop-Schutz-Differenzierung — reine Notiz-/Flag-Änderungen verwerfen ohne Bestätigungsdialog via `_hasStructuralChanges()`; expliziter Test dokumentiert, dass „Eintrag fehlt"-SnackBar bei Krank-Eintrag nicht mehr erscheint (war faktisch bereits durch `if (entry != null) return;` abgedeckt).
- **26c — Klarheit & Polish:** „Eigene Tätigkeit" von FilledButton.tonalIcon auf kompakten TextButton.icon; Notizfeld-Beschriftungen präzisiert („Notiz fürs Berichtsheft" + Klarheit in der Description); Suchfeld-Hint „Tätigkeiten suchen"; Wochenstatistik gekürzt („X eingetragen · Y offen" + Verteilung im Tooltip).
- **Bewusst zurückgestellt (separater Folge-Scope):** App-Shortcuts (Android-Kotlin), AnimatedSwitcher zwischen Flow-Schritten, SaveBar-Tastatur-Handling, bedingte Suchfeld-Sichtbarkeit, Witz-Sheet-Re-Trigger im Profil.
- **Dokumentation:** `TASKS.md` um Phase 26 erweitert; ADR folgt.
- **Neue Dateien:** `lib/features/today/today_flow_steps.dart` (reine Step-Logik), `test/today_flow_steps_test.dart` (16 Tests), `test/app_step_indicator_test.dart` (6 Tests).
- **Goldens regeneriert:** `today_empty.png` (35×36 px im Abwesend-Chip durch Icon-Wechsel) und `week_mixed.png` (großflächige Layout-Anpassung durch kürzere Wochenstatistik) — beide nach Sichtprüfung aktualisiert.
- `flutter analyze` — 0 Issues; `flutter test` — 274/274 grün; `flutter build apk --debug` — erfolgreich; `scripts/check_repo_hygiene.sh` — OK.

---

## Vorherige Änderung: Vorlagenkatalog fachlich bereinigt

- Passive Pflichtaussagen wie „Persönliche Schutzausrüstung getragen“ und
  „Sicherheitsvorschriften beachtet“ sowie doppelte Angaben zu Besonderheiten
  sind aus Vorlagenverwaltung und neuer Tagesauswahl entfernt.
- Alle 132 stabilen IDs bleiben für historische Einträge auflösbar; 123
  Tätigkeiten sind fachlich auswählbar, 38 davon standardmäßig aktiv.
- Unpassende aktive Vorlagen wurden durch konkrete Tätigkeiten zu
  Ladungsträgern, Qualitätsprüfung, 5S und Qualitätsmängeln ersetzt.
- Zahlreiche Vorlagentitel wurden handlungsorientierter und eindeutiger
  formuliert; Kategorie und Untergruppen heißen jetzt passend
  „Ordnung / Qualität / Unterweisung“.
- Repo-Hygiene OK; `flutter analyze` 0 Issues; `flutter test` 251/251 bestanden.

## Vorherige Änderung: Phase 25 – Geführter Today-Check-in

- TodayScreen als bedingter Ablauf neu aufgebaut: Tagtyp → Bereich (nur Betrieb) → vollflächige Tätigkeitsauswahl → Prüfen & Speichern.
- Die Tätigkeitsauswahl arbeitet bis „Auswahl übernehmen“ mit einer Arbeitsauswahl; Abbrechen verwirft nur diese noch nicht übernommenen Änderungen.
- Gespeicherte Einträge zeigen eine kompakte Tagesübersicht mit Bericht sowie gezielten Aktionen für Tagtyp, Tätigkeiten und Ergänzungen.
- „Wie gestern starten“ bleibt als bestätigter kontextueller Schnellzugriff erhalten.
- Tests und Golden-Referenz `today_empty.png` auf den neuen Flow umgestellt.
- `flutter analyze` — 0 Issues; `flutter test` — 248 bestanden; Repo-Hygiene OK; `flutter build apk --debug` erfolgreich.

---

---

## Historie: Phase 24 – UX-Upgrade (abgeschlossen)

### Abgeschlossen:
- **24a:** `AppSectionDivider`-Widget für dezente Sektions-Trenner im Heute-Screen
- **24b:** `EntryProgress` mit visuellen Fortschritts-Punkten + `_ReportPreview` für Live-Berichtsvorschau
- **24c:** Wochen-Screen Swipe-Gesten, Heute-Badge, Wochenstatistik-Übersicht
- **24d:** Haptic Feedback, Pull-to-Refresh, Success-Animation in SaveBar
- `flutter analyze`: 0 Issues ✅
- `flutter test`: 272/272 bestanden ✅
- `flutter build apk --debug`: erfolgreich ✅

---

## Abschluss Phase 24e – Undo & Tages-Duplikation

- **Undo-SnackBar nach Speichern:** Nach erfolgreichem Speichern eines neuen Eintrags erscheint eine SnackBar mit "Eintrag gespeichert." und einem "Rückgängig"-Button (5 Sekunden sichtbar)
- **"Wie gestern übernehmen"-Button:** Wenn heute noch kein Eintrag vorhanden ist, aber einer von gestern, erscheint ein Button mit Copy-Icon zum Übernehmen der Tätigkeiten
- **Duplikations-Dialog:** Bestätigungsdialog fragt nach, bevor Tagtyp, Bereiche und Tätigkeiten von gestern übernommen werden (Notizen und Besonderheiten bleiben leer)
- **Storage-Vorbereitung:** `delete(String id)` Methode zur DailyEntryStorage-Schnittstelle hinzugefügt für Undo-Funktionalität
- **Tests:** Alle 272 Tests bestanden, Golden `today_empty.png` regeneriert
- `flutter analyze` — 0 Issues; `flutter test` — 272/272 bestanden; `flutter build apk --debug` — erfolgreich.

- **Haptic Feedback bei Tagtyp-Auswahl:** `HapticFeedback.lightImpact()` bei jedem Chip-Tap in `day_type_row.dart`
- **Haptic Feedback bei Speichern:** `HapticFeedback.mediumImpact()` bei Erfolg, `HapticFeedback.heavyImpact()` bei Fehler in `today_screen.dart`
- **Pull-to-Refresh:** `RefreshIndicator` um ListView in Heute-Screen, ruft `_loadEntry()` auf
- **Success-Animation in SaveBar:** Nach erfolgreichem Speichern zeigt Button 1s lang ✓-Icon + "Gespeichert!"-Text, dann Rückkehr zum Normalzustand
- `flutter analyze` — 0 Issues; `flutter test` — 272/272 bestanden;
  `flutter build apk --debug` — erfolgreich.

---

## Letzte Änderung: Phase 24c – Wochen-Screen UX-Upgrade

- **Swipe-Gesten:** Horizontale Swipe-Gesten auf dem WeekHeader für Wochen-Navigation (links/rechts)
- **Heute-Hervorhebung:** Der heutige Tag wird in der Tagesliste mit einem Primary-Rahmen und "Heute"-Badge visuell hervorgehoben
- **Wochenstatistik:** Kompakte Typ-Übersicht im WeekHeader (z.B. "3× Betrieb, 1× Berufsschule, 1× offen")
- **Test-Fix:** Overflow-Fehler in `_DayCard` behoben (Row-Layout mit Flexible/Expanded optimiert)
- Golden `test/goldens/week_mixed.png` regeneriert
- `flutter analyze` — 0 Issues; `flutter test` — 272/272 bestanden;
  `flutter build apk --debug` — erfolgreich.

---

## Letzte Änderung: Phase 24a/b – Heute-Screen UX-Upgrade

- **24a:** `AppSectionDivider`-Widget für dezente Sektions-Trenner im Heute-Screen
- **24b:** `EntryProgress` mit visuellen Fortschritts-Punkten + `_ReportPreview` für Live-Berichtsvorschau
- `flutter analyze`: 0 Issues ✅
- `flutter test`: 272/272 bestanden ✅
- `flutter build apk --debug`: erfolgreich ✅

---

## Letzte Änderung: Phase 23 – Tagestyp-Auswahl im Heute-Screen

- Die Tagestyp-Auswahl wurde auf eine kompakte 3-Chip-Zeile reduziert
  (`DayTypeRow`): Betrieb, Berufsschule, Abwesend. Abwesenheitstage
  (Frei/Urlaub/Krank/Feiertag) und Sonstiges werden über ein Bottom-Sheet
  (`AbsenceSheet`) gewählt.
- `DayStatusCard` wurde durch einen kompakten `TodayHeader` ersetzt
  (Titel, Datum, Status-Chip in einer Zeile). Gespeicherte Abwesenheitstage
  zeigen den Status „Abwesenheit" statt „Gespeichert".
- Neue Dateien: `lib/features/today/widgets/today_header.dart`,
  `lib/features/today/widgets/day_type_row.dart`,
  `lib/features/today/widgets/absence_sheet.dart`.
- Tests an die neue Auswahl angepasst (geteilter Helper
  `selectAbsenceType` in `test/test_helpers.dart`); Golden
  `test/goldens/today_empty.png` regeneriert.
- `flutter analyze` — 0 Issues; `flutter test` — 272/272 bestanden;
  `flutter build apk --debug` — erfolgreich.
- **Hinweis:** Phase 23 ist nun in `TASKS.md` aufgenommen (UI-Stand Phase 23).
  Sie steht nicht im ursprünglichen Projektplan, sondern wurde als in-progress
  Redesign im Arbeitsverzeichnis vervollständigt. Aktive Phase bleibt 19
  (Gerätetest).

## Letzte Änderung: Reminder-Überarbeitung

- Die Benachrichtigungsfunktion wurde auf eine einfache tägliche Erinnerung
  reduziert: einmal pro ausgewähltem Wochentag zur festen Uhrzeit.
- Titel: "Heute schon eingetragen?" / Text: "Tippe, um schnell deinen
  Tageseintrag zu machen."
- Die Erinnerung kommt unabhängig vom aktuellen Eintragsstatus, da der Nutzer
  sich dafür entschieden hat.
- Folgeerinnerung (30 Min) und Wochencheck (Freitag 19:00) wurden entfernt.
- Im Profil kann nur noch eine einzige Uhrzeit festgelegt werden; sie wird per
  TimePicker geändert.
- `ReminderSettings.maxTimes` ist auf 1 reduziert; gespeicherte mehrere Zeiten
  werden beim Laden auf die früheste normalisiert.
- `docs/QA_REMINDER_CHECKLIST.md` wurde an das neue Verhalten angepasst.
- `flutter analyze` 0 Issues; `flutter test` 267/267 bestanden;
  `flutter build apk --debug` erfolgreich.

## Vorherige Änderung: Speicher-Witz-Sheet

- Nach dem ersten erfolgreichen Speichern eines neuen Tageseintrags erscheint ein
  ruhiges Material-3-Bottom-Sheet mit lokalem Lagerlogistik-Witz des Tages.
- Die Witze liegen statisch in `lib/core/data/lager_jokes.dart`; Auswahl ist
  deterministisch pro Kalendertag und robust gegen Uhrzeit-/Sommerzeit-Effekte.
- Bestehende Einträge zeigen beim Speichern von Änderungen nur eine kurze
  SnackBar-Bestätigung („Änderungen gespeichert."), damit der Flow nicht bei
  jedem Nachbearbeiten unterbrochen wird.

---

## Aktive Phase

**Phase 19: Release-QA auf echtem Android-Gerät** — APK installierbereit,
Checkliste vorbereitet; manueller Gerätetest steht aus (braucht echtes Gerät).

Phase 20 (Freundlichere UX #50–#57) ist der aktuelle UI-Stand.
Phase 22 (Daily-Check-in-Redesign) wurde am 2026-07-10 selektiv rückgängig gemacht.
Phase 21 (Agenten-Qualität: CI, PR-Template, Hygiene-Skript) bleibt bestehen.

### Release-QA-Status (eindeutig)

| Aspekt                                  | Status                                             |
| --------------------------------------- | -------------------------------------------------- |
| Code fertig                             | ja (Phase 0–20, +Phase 21 Infra)                   |
| Automatisierte Checks                   | bestanden (analyze 0, test grün, debug-APK baut)   |
| Debug-APK gebaut                        | ja                                                 |
| Release-APK gebaut/signiert             | ja (lokaler Upload-Keystore, v1/v2)                |
| Manuelle Android-QA                     | offen (Gerätetest nach QA_RELEASE_CHECKLIST)       |
| Bekannte manuelle Risiken               | Theme-Persistenz, Reminder unter Samsung, Backup-Sperre am Gerät |

Der offene Punkt ist **manuelles Testen**, kein Code-Mangel. Ein Agent darf
Release-QA nicht als erledigt markieren, solange der Gerätetest aussteht.

### Offene Agenten-/Produktfragen

- **#39 Import:** Produktentscheidung offen (Export ist implementiert). Erst
  nach Entscheidung bauen.
- **#37 Gerätetest:** braucht echtes Android-Gerät, nicht von einem Agenten erledigbar.

---

## Was fertig ist

Phasen 0–20 im Code abgeschlossen, plus UI/UX-Audit Phasen 1–3, plus
Phase 25 (Geführter Today-Check-in) und Phase 26 (UX-Quick-Wins und Native
Patterns — Sub-Phasen a/b/c/d).
Phase 21 (Agenten-Qualität: CI, PR-Template, Hygiene-Skript) bleibt bestehen.

Phase 22 (Daily-Check-in-Redesign) wurde am 2026-07-10 rückgängig gemacht.
Die App ist zurück auf dem UI-Stand von Phase 20.

Phase 20a (#54, Farbwelt weicher):

- Neue zentrale Farbquelle `lib/core/ui/day_status_colors.dart` (saved=primary, open=tertiary, absence=secondary, neutral=onSurfaceVariant)
- `ThemePreset.lagerTeal`-Surface aufgehellt (`0xFF0F1F1C` → `0xFF142822`); andere Presets unangetastet
- `week_screen.dart` `_DayStatus` delegiert Farben an den Helper; offene Tage nutzen Amber statt Rot
- `error`/`errorContainer` bleibt echten Fehlern vorbehalten (Ladefehler, Vorlagen-Warnung)
- DECISIONS.md: ADR zu zentralen Statusfarben; CODEMAP.md: neue Datei eingetragen
- `flutter analyze` — 0 Issues; theme/week/ui_layout-Tests grün; Goldens `today_empty`/`week_mixed`/`profile_overview`/`onboarding_welcome` regeneriert

Neu Phase 20b (#55, UX-Writing entschärft):

- Status-/Fehlertexte alltagstauglicher: „Noch nicht gespeichert"→„Noch offen", „Fehlt"→„Offen", „Fehlt: …"→„Noch offen: …", „Kein Eintrag – fehlt"→„Kein Eintrag – offen", Wochenbanner „… Tage offen"
- „Pflicht"-Badge → „Benötigt" (`today_screen.dart` Bereich + Tätigkeiten) + `app_ui.dart` Badge-Default
- Berichtskarten-Chip „Nicht gespeichert" → „Entwurf" (eindeutig gegenüber Status „Noch offen")
- DayStatusCard „Noch … auswählen" → „Wähle kurz: …"
- Echte Fehler-Texte bewusst unverändert (Permission-, Speicher-, Vorlagenfehler)
- Test-Assertions angepasst (`today_screen_test`, `week_screen_test`); Goldens `today_empty`/`week_mixed` regeneriert
- `flutter analyze` — 0 Issues; `flutter test` today/week — 40/40; ui_layout — 14/14

Neu Phase 20c (#50, Wochenübersicht weniger streng):

- Offene Werktage: ruhiges Icon `pending_outlined` statt `error_outline` (Farbe bleibt Amber aus 20a); Label „Offen"
- Wochentag-Banner-Message weicher: „Tippe auf einen offenen Tag, um ihn nachzutragen. Dauert nur kurz."
- `_summaryFor`: „Noch kein Tageseintrag" → „Noch kein Eintrag"
- Rot (`error`/`errorContainer`) nur noch bei echten Fehlern (Ladefehler, Vorlagen-Warnung)
- `flutter analyze` — 0 Issues; week_screen_test 13/13; Golden `week_mixed` regeneriert

Neu Phase 20d (#51, Heute-Screen freundlicher):

- Bereichs-Platzhalter weicher: „Wähle zuerst einen Bereich – dann erscheinen passende Tätigkeiten."
- Freundlichere Tageskarte/Ablauf bereits durch 20b-Texte erreicht (Status „Noch offen", „Wähle kurz: …", freundliche Section-Descriptions)
- `flutter analyze` — 0 Issues; today_screen_test 27/27; Golden `today_empty` regeneriert

Neu Phase 20e (#56, Empty States freundlicher):

- `AppEmptyState` (`app_ui.dart`): Icon in weichem Kreis-Container (`surfaceContainer`, 64×64) statt flachem 48-px-Icon — ruhiger und freundlicher
- Statuskarten (`AppMessage`) bereits durch 20a/20c beruhigt (kein Rot für offene Tage, ruhige container-Akzente)
- `flutter analyze` — 0 Issues; ui_layout 14/14; Goldens unverändert (kein Empty-State-Fehlerzustand in den Referenzen)

Neu Phase 20f (#52, Bereichsauswahl mit Unterzeile):

- `TrainingArea`-Enum: neuer `subtitle`-Getter („Annehmen & prüfen", „Einlagern & sortieren" … je Bereich)
- `AreaGrid`: FilterChip zeigt Label + kurze Unterzeile; Icons bleiben; selected-bewusste Subtitle-Farbe für Kontrast
- today_screen_test robust gemacht: neuer `scrollToActivities`-Helper nach Bereichs-Tap (höhere Chips verschoben sonst Tätigkeiten aus dem Viewport)
- `flutter analyze` — 0 Issues; today_screen_test 27/27; ui_layout 14/14; Golden `today_empty` regeneriert

Neu Phase 20g (#53, Vorlagen-Schnellzugriff):

- `TemplatesScreen`: optionaler `dailyEntryStorage`-Parameter; „Häufig genutzt"-Sektion (bis 6 Tätigkeiten, horizontale Chips) via `computeFrequentActivityIds` — nur bei Einträgen und ohne aktiven Such-/Kategorie-Filter
- `app.dart` übergibt `dailyEntryStorage` an `TemplatesScreen`
- FAB `.extended` („Eigene Tätigkeit") → kompakter Plus-FAB (Typ bleibt `FloatingActionButton`)
- Neuer Test „zeigt häufig genutzte Tätigkeiten aus gespeicherten Einträgen"; templates_screen_test 11/11; ui_layout 14/14; analyze 0 Issues

Neu Phase 20h (#57, Profil persönlicher):

- `ProfileHeader` (`lib/features/profile/widgets/profile_header.dart`): Avatar 28→24, Hintergrund `surfaceContainer`, Padding 16→12, freundliche Begrüßung „Hallo [Name],“, Tippen öffnet Bearbeitung (`profile_header` Key)
- `ProfileScreen`: redundanten „Ausbildungsprofil"-Abschnitt entfernt (Info steht im Header)
- Golden `profile_overview.png` & `ui_layout_test.dart` Key (`edit_profile` → `profile_header`) aktualisiert
- `flutter analyze` — 0 Issues; `flutter test` — alle Tests grün

Neu nach Profil/Reminder-Refactor (19.06.2026):

- `profile_screen.dart` entlastet (963 → 428 Zeilen), ohne sichtbare UI-/Key-Änderung
- Neue Reminder-Koordination: `lib/features/profile/profile_reminder_controller.dart`
- Neue Profil-Widgets: `profile_header.dart`, `profile_edit_screen.dart`, `profile_theme_section.dart`, `reminder_section.dart`
- Reminder-Controller kapselt Laden/Speichern, Permission-Status, Rollback und Edit-Regeln für Zeiten/Wochentage
- Race-Fix: Nach geladenen aktivierten Reminder-Settings wird der aktuelle Notification-Permission-Status erneut geprüft
- Neue Tests: `profile_reminder_controller_test.dart`
- `flutter analyze` — 0 Issues; `flutter test` — 244/244 bestanden; `flutter build apk --debug` — erfolgreich

Neu nach TodayScreen-Refactor (19.06.2026):

- `today_screen.dart` weiter entlastet (911 → 665 Zeilen), ohne sichtbare UI-/Key-Änderung
- Neue Logikdateien: `lib/features/today/today_entry_draft.dart`, `activity_picker_model.dart`
- Neues Widget `lib/features/today/widgets/activity_picker_section.dart`
- `activity_recommender.dart`: häufig-genutzt-Sortierung aus gespeicherten Einträgen als reine Funktion
- Neue Tests: `today_entry_draft_test.dart`, `activity_picker_model_test.dart`, `activity_recommender_test.dart`
- `flutter analyze` — 0 Issues; `flutter test` — 237/237 bestanden

Neu in Phase 16 (#40, #35, #49):

- `lib/core/report/daily_report_generator.dart`: `_detailText` kennt jetzt den Tagtyp — Betrieb und Berufsschule erhalten eigene Formulierungen für selbstständig, unterAnleitung, neuesGelernt, wiederholt, kontrolle
- Notiz-Präfix ohne `problemAufgetreten`: "Zusätzlich wurde notiert:" → "Notiz:" (kürzer, weniger bürokratisch)
- `_activityPattern` nutzt jetzt `(known.length - 1 + date.day) % 3` — gleiche Auswahl klingt an verschiedenen Tagen anders
- Berufsschule mit ≥ 3 Themen: drei datumsbasierte Varianten statt immer derselbe Satz
- Neues Widget `lib/features/today/widgets/report_card.dart`: zeigt generierten Bericht als Card mit Gespeichert-/Nicht-gespeichert-Chip und Kopier-Button
- `TodayScreen` zeigt die Berichtskarte, sobald `_canSave == true` und Tagtyp Betrieb oder Berufsschule
- `SaveBar`: `onPreview`-Parameter und Vorschau-Button entfernt; Bottom-Sheet-Preview durch Karte ersetzt
- 12 neue Generator-Tests (7 Berufsschule-Flags, 5 Datumsvarianten); 4 neue Widget-Tests (Berichtskarte); 2 alte Preview-Tests ersetzt

Neu in Phase 15 (#47):

- `today_screen.dart` (1 667 → 1 046 Zeilen; später 911 → 665 Zeilen) in kleinere Dateien zerlegt
- Neue Dateien: `day_status_card.dart`, `save_bar.dart`, `area_grid.dart`, `activity_section.dart`, `day_type_selector.dart`, `special_flags_note_section.dart`
- Weitere neue Dateien: `today_entry_draft.dart`, `activity_picker_model.dart`, `widgets/activity_picker_section.dart`
- `_specialFlagsExpanded` als lokaler Widget-State in `SpecialFlagsAndNoteSection` (war in `_TodayScreenState`)
- Alle 170 Tests unverändert grün; keine Verhaltens- oder Key-Änderung

Neu in Phase 14 (#43, #44, #42, #48, #38):

- `DATA_MODEL.md` und `UI_UX_SPEC.md` verifiziert und korrekt bestätigt
- `lib/core/constants.dart`: Kommentar zur kAppVersion-Strategie (Konstante + Test statt PackageInfo)
- `lib/core/storage/hive_daily_entry_storage.dart`: `Box` → `LazyBox`; per-Entry-FormatException-Handling in `loadAll()` und `loadByDate()`; Integrationstest mit `_CorruptedDailyEntryAdapter`
- `lib/core/storage/persisted_enum.dart`: `readPersistedEnum` wirft lesbare FormatException für unbekannte Enum-Strings
- `test/widget_test.dart`: Widget-Test für Profilbearbeitung mit Berufsänderung (Fachlagerist → Jahr 1–2)

Neu in UI/UX-Audit Phase 3:

- `today_screen.dart`: `_DayStatusCard` aus ListView extrahiert → bleibt beim Scrollen sichtbar
- `week_screen.dart`: `_WeekHeader` aus ListView extrahiert → bleibt beim Scrollen sichtbar
- `week_screen.dart`: `Semantics(label, value)` auf `LinearProgressIndicator` in `_WeekHeader`
- `ui_layout_test.dart`: 5 neue Accessibility-Guideline-Tests (WCAG-Kontrast für 3 Screens + helles Preset, Tap-Target)
- Golden-Referenzen (`today_empty.png`, `week_mixed.png`) nach Sticky-Header-Änderung aktualisiert

Neu im UI-Audit Phase 1 und Phase 2:

- `app_ui.dart`: `AppMessageTone.success` nutzt jetzt `secondaryContainer` statt `primaryContainer`
- `today_screen.dart`: Besonderheiten & Notiz hinter `ExpansionTile` (optional, auto-expandiert bei Sonstiges), Report-Vorschau als Bottom Sheet via SaveBar-Button, Selektionszähler direkt in SaveBar
- `week_screen.dart`: „Wochenzusammenfassung"-Button aus `_WeekHeader` nach AppBar verschoben
- Tests: `today_screen_test.dart` und `ui_layout_test.dart` angepasst, alle Golden-Referenzen aktualisiert

Neu in Phase 13:

- Sichtbarer Bootstrap-Fehler mit Retry statt stiller oder destruktiver Wiederherstellung
- Tageswechsel bei Resume; offene Heute-Eingaben bleiben dem bisherigen Datum zugeordnet
- Notification-Taps inklusive Kaltstart öffnen zuverlässig den Heute-Tab
- Deterministischer Reminder-Plan mit eindeutigen IDs und maximal 1 Uhrzeit
- Permission-Neuprüfung und Rollback bei Speicher-/Planungsfehlern
- SharedPreferences-Schreibfehler werden geprüft; Hive wird nach Komplettlöschung komprimiert
- Android-Backup und Gerätetransfer sind für alle lokalen Daten deaktiviert
- Application ID `com.daydaylx.berichtsheftmerker`; Release nutzt keinen Debug-Schlüssel
- Lokale Release-Signierung ist in dieser Arbeitskopie über ignorierte Dateien `android/key.properties` und `android/app/upload-keystore.jks` eingerichtet
- CI führt zusätzlich `flutter build apk --debug` aus

Weitere akzeptierte aktuelle Funktionen:

- Deterministischer lokaler Tagesberichtsvorschlag in Heute und Woche, inklusive Kopieren
- Neun lokal persistierte Farbthemes (acht dunkle, ein helles); `Lager Teal` ist das dunkle Standardpreset
- Theme-Auswahl im Profil über ein Farbkachel-Grid mit Live-Vorschau; Zurücksetzen über „Alle Daten löschen"
- Tätigkeitskatalog mit 132 stabilen IDs und 123 auswählbaren Lagerlogistik-Tätigkeiten inklusive EDV/Scanner, Qualität, Ordnung/5S und Unterweisung
- Heute-Screen mit Tätigkeitssuche, häufig genutzten Tätigkeiten, Untergruppen, Ausbildungsjahr-Empfehlungen und sichtbaren Auswahlchips
- Tagesbericht-Generator mit mehreren deterministischen Satzmustern für Betrieb und Berufsschule; Besonderheiten wie Kontrolle, Fehlerkorrektur, Probleme und Notizen werden eingebunden
- Fachlagerist/in ist auf Ausbildungsjahr 1–2 begrenzt; Fachkraft für Lagerlogistik erlaubt 1–3
- Eigene Tätigkeiten verhindern normalisierte Duplikate gegen Standard- und eigene Tätigkeiten
- Notification-Initialisierungsfehler werden im Profil-/Reminder-Bereich sichtbar; die „Eintrag fehlt"-SnackBar hat eine direkte Aktion
- Persistierte Enum-Strings werden über zentrale Parser mit lesbaren Fehlern gelesen
- `kAppVersion` wird per Test gegen `pubspec.yaml` abgesichert

---

## Letzte erfolgreiche Verifikation

Aktuell nach Neu-Build des Release-APK (2026-07-15):

```
bash scripts/check_repo_hygiene.sh  →  OK
flutter analyze          →  0 Issues
flutter test             →  251/251 bestanden
flutter build apk --debug  →  erfolgreich (Jul 15)
flutter build apk --release  →  erfolgreich (2026-07-15, 24.4 MB, signiert)
CI (Job flutter-checks)    →  Required-Check für main (Branch Protection)
```

Vorherige Geräteverifikation (Phase 13):

```
adb install -r app-release.apk auf Samsung SM-S931B  →  erfolgreich
```

Das zusammengeführte Release-Manifest bestätigt
`com.daydaylx.berichtsheftmerker`, `allowBackup=false` und die
Backup-/Transfer-Regeln. `apksigner verify` bestätigt v1/v2-Signatur mit dem
lokalen Release-Zertifikat (CN=Berichtsheft-Merker, SHA-256
0e26d264b2bb6dc27a67a1820fa72474f5a4cb4f861b8da77ad3c7819eaff1c9); der installierte Build meldet `apkSigningVersion=2`.

---

## Nächster Schritt

**Phase 19: Release-QA auf echtem Android-Gerät** — APK installieren und `docs/QA_RELEASE_CHECKLIST.md` Punkt für Punkt durcharbeiten.

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Issue #39 (Export/Import) ist bewusst offen und wartet auf eine
Produktentscheidung, bevor Code dafür entsteht.

Lokalen Release-Keystore sicher aufbewahren; spätere Release-Updates müssen mit
demselben Keystore signiert werden.
