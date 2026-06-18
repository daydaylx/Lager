# CURRENT_STATUS.md — Agent-Handoff

Stand: 2026-06-18 (Phase 17+18 aufgeräumt; #41-Fehlermeldung verbessert; Phase 19 QA-Vorbereitung läuft)

---

## Aktive Phase

**Phase 19: Release-QA auf echtem Android-Gerät** — APK gebaut (18.06.2026), Checkliste bereit

---

## Was fertig ist

Phasen 0–16 im Code abgeschlossen, plus UI/UX-Audit Phasen 1–3.

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

- `today_screen.dart` (1 667 → 1 046 Zeilen) in `lib/features/today/widgets/` zerlegt
- Neue Dateien: `day_status_card.dart`, `save_bar.dart`, `area_grid.dart`, `activity_section.dart`, `day_type_selector.dart`, `special_flags_note_section.dart`
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
- Fünf lokal persistierte Farbthemes; `Lager Teal` ist das dunkle Standardpreset
- Theme-Auswahl im Profil und Zurücksetzen über „Alle Daten löschen"
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

Aktuell nach Phase 19 QA-Vorbereitung (18.06.2026):

```
flutter analyze          →  0 Issues
flutter test             →  184/184 bestanden
flutter build apk --release  →  erfolgreich (18.06.2026)
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

**Phase 19 Release-QA:** APK auf echtem Gerät installieren und `docs/QA_RELEASE_CHECKLIST.md` Punkt für Punkt durcharbeiten.

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Issue #39 (Export/Import) ist bewusst offen — eigene Produktentscheidung erforderlich, bevor Code dafür entsteht.

Lokalen Release-Keystore sicher aufbewahren; spätere Release-Updates müssen mit demselben Keystore signiert werden.
