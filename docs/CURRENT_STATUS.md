# CURRENT_STATUS.md — Agent-Handoff

Stand: 2026-07-02 (Phase 22 Daily-Check-in-Redesign umgesetzt; Phase 19 Gerätetest bleibt offen)

---

## Aktive Phase

**Phase 19: Release-QA auf echtem Android-Gerät** — APK installierbereit,
Checkliste vorbereitet; manueller Gerätetest steht aus (braucht echtes Gerät).

Phase 20 (Freundlichere UX #50–#57) ist vollständig abgeschlossen und auf
GitHub geschlossen. Phase 22 (Daily-Check-in-Redesign) ist code- und testseitig
abgeschlossen; die finale manuelle Android-QA aus Phase 19 sollte gegen dieses
neue UI erneut laufen.

### Release-QA-Status (eindeutig)

| Aspekt                                  | Status                                             |
| --------------------------------------- | -------------------------------------------------- |
| Code fertig                             | ja (Phase 0–20)                                    |
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

Phasen 0–16 im Code abgeschlossen, plus UI/UX-Audit Phasen 1–3.

Neu Phase 22 (Daily-Check-in-Redesign):

- Heute-Sprache entschärft: Status „Erledigt", „Tag abschließen", keine
  „Benötigt"-Badges; `DayStatusCard` als Tageskarte mit dezentem Verlauf.
- Woche weniger alarmistisch: `WeekDotStrip` (Mo–So) statt Prozentbalken,
  Fortschritt „X / Y Tage erledigt", neutraler Banner „X Tage warten noch".
- Bereichsauswahl: `AreaCarousel` via `PageView` + ausgewählte Chips,
  Start auf Wareneingang; Multi-Select und Tätigkeitsfilter über alle Bereiche
  bleiben erhalten; sehr schmale Displays nutzen `AreaGrid` als Fallback.
- Weiche Progression: `AppSectionHeader` unterstützt `SectionEmphasis`;
  aktiver Schritt wird dekorativ markiert, kommende Schritte bleiben lesbar.
- Visual polish: leichtere SaveBar/NavigationBar, wärmeres `lagerTeal`, Karten
  mit subtiler Outline/Tint; keine neuen Dependencies.
- `flutter analyze` — 0 Issues; `flutter test` — 249/249; alle Goldens
  (`onboarding_welcome`, `today_empty`, `week_mixed`, `profile_overview`) aktualisiert.


Neu Phase 20a (#54, Farbwelt weicher):

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
- Deterministischer Reminder-Plan mit eindeutigen IDs, Mitternachtswechsel und maximal 7 Uhrzeiten
- Ehrliche Folgeerinnerung, Permission-Neuprüfung und Rollback bei Speicher-/Planungsfehlern
- SharedPreferences-Schreibfehler werden geprüft; Hive wird nach Komplettlöschung komprimiert
- Android-Backup und Gerätetransfer sind für alle lokalen Daten deaktiviert
- Application ID `com.daydaylx.berichtsheftmerker`; Release nutzt keinen Debug-Schlüssel
- Lokale Release-Signierung ist in dieser Arbeitskopie über ignorierte Dateien `android/key.properties` und `android/app/upload-keystore.jks` eingerichtet
- CI führt zusätzlich `flutter build apk --debug` aus

Weitere akzeptierte aktuelle Funktionen:

- Deterministischer lokaler Tagesberichtsvorschlag in Heute und Woche, inklusive Kopieren
- Neun lokal persistierte Farbthemes (acht dunkle, ein helles); `Lager Teal` ist das dunkle Standardpreset
- Theme-Auswahl im Profil über ein Farbkachel-Grid mit Live-Vorschau; Zurücksetzen über „Alle Daten löschen"
- Tätigkeitskatalog mit 132 vordefinierten Lagerlogistik-Tätigkeiten inklusive EDV/Scanner, Qualität, Ordnung/5S und Unterweisung
- Heute-Screen mit Tätigkeitssuche, häufig genutzten Tätigkeiten, Untergruppen, Ausbildungsjahr-Empfehlungen und sichtbaren Auswahlchips
- Tagesbericht-Generator mit mehreren deterministischen Satzmustern für Betrieb und Berufsschule; Besonderheiten wie Kontrolle, Fehlerkorrektur, Probleme und Notizen werden eingebunden
- Fachlagerist/in ist auf Ausbildungsjahr 1–2 begrenzt; Fachkraft für Lagerlogistik erlaubt 1–3
- Eigene Tätigkeiten verhindern normalisierte Duplikate gegen Standard- und eigene Tätigkeiten
- Notification-Initialisierungsfehler werden im Profil-/Reminder-Bereich sichtbar; die „Eintrag fehlt"-SnackBar hat eine direkte Aktion
- Persistierte Enum-Strings werden über zentrale Parser mit lesbaren Fehlern gelesen
- `kAppVersion` wird per Test gegen `pubspec.yaml` abgesichert

---

## Letzte erfolgreiche Verifikation

Aktuell nach Agenten-Qualität #58–#64 (01.07.2026):

```
bash scripts/check_repo_hygiene.sh  →  OK
flutter analyze          →  0 Issues
flutter test             →  249/249 bestanden
flutter build apk --debug  →  erfolgreich
flutter build apk --release  →  erfolgreich (18.06.2026)
CI (Job flutter-checks)    →  Required-Check für main (Branch Protection)
```

Vorherige Geräteverifikation (Phase 13):

```
adb install -r app-release.apk auf Samsung SM-S931B  →  erfolgreich
```

Das zusammengeführte Release-Manifest bestätigt
`com.daydaylx.berichtsheftmerker`, `allowBackup=false` und die
Backup-/Transfer-Regeln. `apksigner` bestätigt v1/v2-Signatur mit lokalem
Release-Zertifikat; der installierte Build meldet `apkSigningVersion=2`.

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
