# PROJECT_STATUS.md

Zuletzt aktualisiert: 2026-10-08

## Aktueller Stand

**Phasen 0–20 im Code abgeschlossen. Der Reminder-Stack wurde am 2026-07-19 release-stabil überarbeitet. Phase 21 (Agenten-Qualität) Infrastruktur besteht. Phase 27 ergänzt eine optional deaktivierte OpenRouter-Berichtsnachbearbeitung mit lokalem Fallback; Modell-ID, Key und Budget sind bewusst nicht im Repository gesetzt. Die zusätzlich beauftragten Phasen 28–33 ergänzen Profil, Offline-Curriculum und Berufsschulablauf und wurden lokal mit Analyze, vollständiger Testsuite und Debug-APK-Build verifiziert. Phase 19 (Release-QA auf echtem Android-Gerät) und private Phase-27-Nachweise bleiben offen.**

### Release-QA-Status (eindeutig)

| Aspekt                          | Status                                           |
| ------------------------------- | ------------------------------------------------ |
| Code fertig                     | ja (Phase 0–20, +Phase 21 Infra)                  |
| Automatisierte Checks (lokal)   | Analyze 0 Issues, vollständige Testsuite bestanden, Debug-APK gebaut; CI nach Push ausstehend |
| Debug-APK gebaut                | ja — 99.0 MB (lokaler Build, 2026-10-08)         |
| Release-APK gebaut/signiert     | ja (v1/v2, lokaler Upload-Keystore)              |
| Manuelle Android-QA            | **teilweise** (Release-Update, Status, Testposting und Boot-Receiver geprüft) |
| Bekannte manuelle Risiken       | Theme-Persistenz, Reminder unter Samsung, Backup-Sperre am Gerät |

Offen bleiben die manuelle Release-QA auf einem Android-Gerät und die privaten Phase-27-Nachweise mit Modell/Key. Die lokale automatische Verifikation für Phasen 28–33 ist abgeschlossen.

Der Stand der zusätzlich beauftragten Phasen 28–33 ist noch nicht als
abgeschlossen verifiziert. Lernfeldnamen/Jahrgänge wurden mit den sächsischen
Lehrplanseiten geprüft; konkrete allgemeine Fächer ohne Quellenbeleg werden
nicht angeboten.

Neu in Phase 25: Der TodayScreen ist ein geführter Check-in (Tagtyp → Bereich
bei Betrieb → vollflächige Tätigkeitsauswahl → Prüfen & Speichern). Gespeicherte
Tage erscheinen als kompakte Übersicht mit gezielten Bearbeiten-Aktionen und
kopierbarem Bericht. `flutter analyze`, 248 Tests, Repo-Hygiene und Debug-APK-Build
waren nach dem Umbau erfolgreich.

---

## Was existiert

- Git-Repository mit aktiver Flutter-Implementierung
- `docs/` mit aktiver technischer Dokumentation und klar markierten historischen Konzeptunterlagen
- `README.md` mit Projektbeschreibung und Setup-Anleitung
- `AGENTS.md` als kanonische Agentenregel plus dünne Bridges für Claude, Codex,
  Gemini, OpenCode, Cursor und Copilot
- `pubspec.yaml` — Flutter-Projektdatei (berichtsheft_merker, SDK >=3.0.0)
- `pubspec.lock` — Abhängigkeiten aufgelöst
- `analysis_options.yaml`
- `android/` — vollständig generiert (Kotlin, Gradle, AndroidManifest)
- Flutter-Ordnerstruktur unter `lib/`:
  - `lib/main.dart` — startet den fehlertoleranten App-Bootstrap
  - `lib/app/bootstrap.dart` — öffnet lokale Speicher und bietet bei Fehlern Retry ohne Datenlöschung
  - `lib/app/app.dart` — MaterialApp + persistiertes ThemePreset + Onboarding-Gate + NavigationBar Shell
  - `lib/app/theme.dart` — neun Theme-Presets und explizites Material-3-Komponententheme
  - `lib/core/constants.dart` — Text-, SharedPreferences-, Berufs-, Versions- und Ausbildungsjahr-Konstanten
  - `lib/core/profile_storage.dart` — zentraler SharedPreferences-Zugriff für das Ausbildungsprofil
  - `lib/core/enums/` — Tagtypen, Bereiche, Kategorien und Besonderheiten mit UI-Labels
  - `lib/core/models/` — `DailyEntry`, `ActivityTemplate` und `ReminderSettings`
  - `lib/core/data/default_activities.dart` — 132 stabile IDs, 123 auswählbare und 38 standardmäßig aktive Tätigkeiten
  - `lib/core/data/activity_subcategories.dart` — fachliche Untergruppen für Tätigkeiten
  - `lib/core/storage/` — Hive-CE-Adapter, Profil-/Reminder-/Theme-Persistenz und In-Memory-Testspeicher
  - `lib/core/report/daily_report_generator.dart` — deterministische lokale Berichtsvorschläge als verbindlicher Fallback
  - `lib/core/ai/` — deaktivierbare Compile-Time-Konfiguration, Positivlisten-Payload, isolierter OpenRouter-Client, separater Cache, Hintergrundkoordinator und Bericht-Resolver
  - `lib/core/services/export_service.dart` — JSON-Export aller Daten via System-Share-Sheet
  - `lib/core/week_utils.dart` — ISO-Kalenderwoche und Wochenstart
- `lib/core/domain/curriculum_registry.dart` und `lib/core/school/` — statische DE-SN-Lernfelder, separate Schultage/Aufgaben/Leistungsnachweise und Snapshot-Koordination
- `lib/features/school/` — Berufsschul-Startscreen und vierstufiger Check-in
  - `lib/features/onboarding/onboarding_screen.dart` — zweistufiger kompakter Erststart
  - `lib/features/today/today_screen.dart` — persistenter Tageseintrag, Screen-State, Laden/Speichern, Tageswechsel und Berichtskarte
  - `lib/features/today/activity_picker_model.dart` — Tätigkeitsauswahl-Logik für Suche, häufig genutzt, Untergruppen, Ausbildungsjahr-Empfehlungen und historische IDs
  - `lib/features/today/today_entry_draft.dart` — DailyEntry-Entwurf für Validierung, Speichern und Berichtsvorschau
  - `lib/features/today/widgets/` — extrahierte UI-Bausteine: `DayStatusCard`, `SaveBar`, `AreaCarousel` (+ `AreaGrid`-Fallback), `DayTypeSelector`, `SpecialFlagsAndNoteSection`, `ActivitySection`, `ActivityPickerSection`, `ReportCard`
  - `lib/features/week/week_screen.dart` — Wochenliste, Tagesstatus, Zusammenfassung und kopierbare Berichte
  - `lib/features/week/widgets/week_dot_strip.dart` — Mo–So-Punkt-Leiste für Wochenfortschritt statt Prozentbalken
  - `lib/features/templates/templates_screen.dart` — Vorlagenverwaltung mit Suche und Bottom Sheet
  - `lib/features/profile/profile_screen.dart` — Profil-Orchestrierung, Datenverwaltung, Export/Delete und Section-Wiring
  - `lib/features/profile/profile_reminder_controller.dart` — Reminder laden/speichern, Berechtigung, Rollback und Edit-Regeln
  - `lib/features/profile/widgets/` — Profil-Header, Profil-Editor, Reminder-Section und Theme-Auswahl
- Phase 22 Daily-Check-in-Redesign: Heute-Sprache und Save-Flow entschärft, Bereichs-Carousel, weiche Progression, Wochen-Dot-Strip statt Prozent, leichtere Tageskarte/SaveBar/NavBar und wärmeres `lagerTeal`; alle Goldens aktualisiert
  - `lib/shared/widgets/app_ui.dart` — gemeinsame Abschnitts-, Status- und Empty-State-Bausteine
- `lib/shared/widgets/profile_form.dart` — gemeinsame Profilmaske für Onboarding und Profil
- `shared_preferences` — speichert Name, Betrieb, Ausbildungsberuf, Ausbildungsjahr, Wahlqualifikationen und Onboarding-Flag lokal
- `hive_ce` / `hive_ce_flutter` — speichert Tageseinträge, eigene Tätigkeiten und Schuldaten dauerhaft
- `flutter_local_notifications` / `flutter_timezone` — lokale Erinnerungen in Gerätezeitzone
- `http` / `crypto` — isolierter optionaler Report-Client und SHA-256-Fingerprint; ohne private Define-Datei keine Netzwerkverbindung
- `app_settings` — öffnet Android-Benachrichtigungseinstellungen direkt aus der App
- Android Application ID `com.daydaylx.berichtsheftmerker`
- Android-Cloud-Backup und Gerätetransfer für lokale Daten deaktiviert
- Release-Signierung über lokale, ignorierte `android/key.properties` und `android/app/upload-keystore.jks`
- `test/widget_test.dart` — Onboarding-, Profil- und Navigationstests
- `test/today_screen_test.dart` — Validierung, Suche, häufig genutzt, Untergruppen, Empfehlungen, Speicherung, Bearbeitung und Tagtypen
- `test/today_entry_draft_test.dart`, `test/activity_picker_model_test.dart`, `test/activity_recommender_test.dart` — ausgelagerte Today-Logik
- `test/default_activities_test.dart` — Katalogumfang, auswählbare Altvorlagen und eindeutige IDs
- `test/hive_daily_entry_storage_test.dart` — echter Persistenztest über Box-Neuöffnung
- `test/week_utils_test.dart` — ISO-Kalenderwochen inklusive Jahreswechsel
- `test/week_screen_test.dart` — Wochenstatus, Navigation, Zusammenfassung und Fehlerbehandlung
- `test/daily_report_generator_test.dart` — Berichtstexte je Tagtyp und Besonderheit
- `test/persistence_stability_test.dart` — stabile Enum-Namen, kontrollierte Parser und Tätigkeits-IDs
- `test/version_consistency_test.dart` — verhindert Drift zwischen `pubspec.yaml` und `kAppVersion`
- `test/notification_service_test.dart` — Reminder-Plan, stabile Tages-IDs, Laufzeitstatus und Tap-Payload
- `test/profile_reminder_controller_test.dart` — persistierte Nutzerabsicht, Planung, Fehler und Edit-Regeln
- `test/profile_reminder_screen_test.dart` — Profil-Screen Erinnerungs-UI
- `test/android_notification_config_test.dart` — Manifest, R8-Regeln und Notification-Icon
- `test/profile_theme_grid_test.dart` — Farbkachel-Grid der Theme-Auswahl
- `test/bootstrap_test.dart` — sichtbarer Bootstrap-Fehler und Retry
- `test/templates_screen_test.dart` — Vorlagenverwaltung (Suche, Hinzufügen, Deaktivieren)
- `test/ui_layout_test.dart` — kleine Displays, große Schrift, Tastatur, Touchflächen und Goldens
- `test/goldens/` — vier visuelle Referenzen zentraler UI-Zustände

## Ausgeführte Checks

| Check                                    | Ergebnis                                                   |
| ---------------------------------------- | ---------------------------------------------------------- |
| `flutter create --platforms=android .`   | Erfolgreich, android/ generiert                            |
| `flutter pub get`                        | Erfolgreich, Abhängigkeiten aufgelöst                      |
| `flutter analyze`                        | 0 Issues                                                   |
| `flutter test`                           | vollständige Testsuite bestanden; OpenRouter-Live-Smoke mangels privater Defines übersprungen |
| `flutter build apk --debug`              | Erfolgreich, Debug-APK 99,036,182 Bytes (2026-10-08)      |
| `flutter build apk --release`            | Erfolgreich signiert erzeugt, 24.5 MB (2026-07-19)         |
| Release-Signatur                         | `apksigner`: v1/v2 verifiziert, lokales Release-Zertifikat |
| Zusammengeführtes Release-Manifest       | Package-ID und Backup-Sperre bestätigt                     |
| Installation und Start auf Android-Gerät | Samsung SM-S931B: Release-Update erfolgreich; Package-Replaced-Receiver ohne Absturz |

Debug-APK: `build/app/outputs/flutter-apk/app-debug.apk`
Release-APK: `build/app/outputs/flutter-apk/app-release.apk`

Android ist auf NDK `27.0.12077973` gepinnt. Debug- und signierter
Release-Build wurden damit erfolgreich erzeugt.

## Bewusst noch nicht gebaut

- Favoriten
- Bearbeiten eigener Tätigkeitstitel
- Tätigkeiten vom Vortag übernehmen
- Lokaler Datenimport (Export ist implementiert; Import: Produktentscheidung offen)
- Direkte „nur heute“-Tätigkeit ohne Vorlage
- PDF-Export (nicht geplant)
- Cloud/Backend (nicht geplant)

## Nächster Schritt

Release-QA-Durchlauf (Phase 19) mit der installierten Release-APK nach
`docs/QA_RELEASE_CHECKLIST.md` durchführen:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Den lokalen Release-Keystore sicher aufbewahren, weil spätere Release-Updates
dieselbe Signatur benötigen.
