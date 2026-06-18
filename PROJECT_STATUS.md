# PROJECT_STATUS.md

Zuletzt aktualisiert: 2026-06-18

## Aktueller Stand

**Phasen 0–18 im Code abgeschlossen. Phase 19 (Release-QA) läuft: APK gebaut, Checkliste bereit, manueller Gerätetest auf Samsung SM-S931B steht aus.**

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
  - `lib/app/theme.dart` — fünf Theme-Presets und explizites Material-3-Komponententheme
  - `lib/core/constants.dart` — Text-, SharedPreferences-, Berufs-, Versions- und Ausbildungsjahr-Konstanten
  - `lib/core/profile_storage.dart` — zentraler SharedPreferences-Zugriff für das Ausbildungsprofil
  - `lib/core/enums/` — Tagtypen, Bereiche, Kategorien und Besonderheiten mit UI-Labels
  - `lib/core/models/` — `DailyEntry` und `ActivityTemplate`
  - `lib/core/data/default_activities.dart` — 132 vordefinierte Tätigkeiten mit stabilen IDs
  - `lib/core/data/activity_subcategories.dart` — fachliche Untergruppen für Tätigkeiten
  - `lib/core/storage/` — Hive-CE-Adapter, Profil-/Reminder-/Theme-Persistenz und In-Memory-Testspeicher
  - `lib/core/report/daily_report_generator.dart` — deterministische lokale Berichtsvorschläge ohne KI
  - `lib/core/services/export_service.dart` — JSON-Export aller Daten via System-Share-Sheet
  - `lib/core/week_utils.dart` — ISO-Kalenderwoche und Wochenstart
  - `lib/features/onboarding/onboarding_screen.dart` — zweistufiger kompakter Erststart
  - `lib/features/today/today_screen.dart` — persistenter Tageseintrag mit Suche, häufig genutzt, Untergruppen, Ausbildungsjahr-Empfehlungen und Berichtskarte
  - `lib/features/today/widgets/` — extrahierte UI-Bausteine: `DayStatusCard`, `SaveBar`, `AreaGrid`, `DayTypeSelector`, `SpecialFlagsAndNoteSection`, `ActivitySection`, `ReportCard`
  - `lib/features/week/week_screen.dart` — Wochenliste, Tagesstatus, Zusammenfassung und kopierbare Berichte
  - `lib/features/templates/templates_screen.dart` — Vorlagenverwaltung mit Suche und Bottom Sheet
  - `lib/features/profile/profile_screen.dart` — Profil, Erinnerungen, Theme-Auswahl und Datenverwaltung
  - `lib/shared/widgets/app_ui.dart` — gemeinsame Abschnitts-, Status- und Empty-State-Bausteine
- `lib/shared/widgets/profile_form.dart` — gemeinsame Profilmaske für Onboarding und Profil
- `shared_preferences` — speichert Name, Betrieb, Ausbildungsberuf, Ausbildungsjahr und Onboarding-Flag lokal
- `hive_ce` / `hive_ce_flutter` — speichert Tageseinträge und eigene Tätigkeiten dauerhaft
- `flutter_local_notifications` / `flutter_timezone` — lokale Erinnerungen in Gerätezeitzone
- `app_settings` — öffnet Android-Benachrichtigungseinstellungen direkt aus der App
- Android Application ID `com.daydaylx.berichtsheftmerker`
- Android-Cloud-Backup und Gerätetransfer für lokale Daten deaktiviert
- Release-Signierung über lokale, ignorierte `android/key.properties` und `android/app/upload-keystore.jks`
- `test/widget_test.dart` — Onboarding-, Profil- und Navigationstests
- `test/today_screen_test.dart` — Validierung, Suche, häufig genutzt, Untergruppen, Empfehlungen, Speicherung, Bearbeitung und Tagtypen
- `test/default_activities_test.dart` — Katalogumfang und eindeutige IDs
- `test/hive_daily_entry_storage_test.dart` — echter Persistenztest über Box-Neuöffnung
- `test/week_utils_test.dart` — ISO-Kalenderwochen inklusive Jahreswechsel
- `test/week_screen_test.dart` — Wochenstatus, Navigation, Zusammenfassung und Fehlerbehandlung
- `test/daily_report_generator_test.dart` — Berichtstexte je Tagtyp und Besonderheit
- `test/persistence_stability_test.dart` — stabile Enum-Namen, kontrollierte Parser und Tätigkeits-IDs
- `test/version_consistency_test.dart` — verhindert Drift zwischen `pubspec.yaml` und `kAppVersion`
- `test/notification_service_test.dart` — Reminder-Plan, IDs und Tap-Payload
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
| `flutter test`                           | 184/184 Tests bestanden                                    |
| `flutter build apk --debug`              | Erfolgreich, Debug-APK 91 MB                               |
| `flutter build apk --release`            | Erfolgreich signiert erzeugt, 24.1 MB                      |
| Release-Signatur                         | `apksigner`: v1/v2 verifiziert, lokales Release-Zertifikat |
| Zusammengeführtes Release-Manifest       | Package-ID und Backup-Sperre bestätigt                     |
| Installation und Start auf Android-Gerät | Samsung SM-S931B: installiert und gestartet                |

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
