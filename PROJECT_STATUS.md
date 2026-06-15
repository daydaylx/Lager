# PROJECT_STATUS.md

Zuletzt aktualisiert: 2026-06-15

## Aktueller Stand

**Phasen 0–13 im Code abgeschlossen. Manueller Android-Gerätetest und lokale Release-Signierung sind offen.**

---

## Was existiert

- Git-Repository mit initialem Commit
- `docs/` mit den vier Planungsdokumenten (aus ZIP entpackt)
- `README.md` mit Projektbeschreibung und Setup-Anleitung
- `AGENTS.md`, `CLAUDE.md`, `TASKS.md`, `DECISIONS.md` — Agentendateien vollständig
- `pubspec.yaml` — Flutter-Projektdatei (berichtsheft_merker, SDK >=3.0.0)
- `pubspec.lock` — Abhängigkeiten aufgelöst
- `analysis_options.yaml`
- `android/` — vollständig generiert (Kotlin, Gradle, AndroidManifest)
- Flutter-Ordnerstruktur unter `lib/`:
  - `lib/main.dart` — startet den fehlertoleranten App-Bootstrap
  - `lib/app/bootstrap.dart` — öffnet lokale Speicher und bietet bei Fehlern Retry ohne Datenlöschung
  - `lib/app/app.dart` — MaterialApp + Onboarding-Gate + NavigationBar Shell (M3, IndexedStack)
  - `lib/app/theme.dart` — explizites reduziertes Material-3-Komponententheme
  - `lib/app/router.dart` — Route-Konstanten
  - `lib/core/constants.dart` — Text-, SharedPreferences-, Berufs- und Ausbildungsjahr-Konstanten
  - `lib/core/profile_storage.dart` — zentraler SharedPreferences-Zugriff für das Ausbildungsprofil
  - `lib/core/enums/` — Tagtypen, Bereiche, Kategorien und Besonderheiten mit UI-Labels
  - `lib/core/models/` — `DailyEntry` und `ActivityTemplate`
  - `lib/core/data/default_activities.dart` — 87 vordefinierte Tätigkeiten mit stabilen IDs
  - `lib/core/storage/` — Speicher-Schnittstellen, Hive-CE-Adapter, SharedPreferences-Prüfung und In-Memory-Testspeicher
  - `lib/core/week_utils.dart` — ISO-Kalenderwoche und Wochenstart
  - `lib/features/onboarding/onboarding_screen.dart` — zweistufiger kompakter Erststart
  - `lib/features/today/today_screen.dart` — persistenter Tageseintrag mit kompakter Tätigkeits-Checkliste
  - `lib/features/week/week_screen.dart` — kompakte Wochenliste, Tagesstatus und Zusammenfassung
  - `lib/features/templates/templates_screen.dart` — Vorlagenverwaltung mit Suche und Bottom Sheet
  - `lib/features/profile/profile_screen.dart` — Profilübersicht, Bearbeitung, Erinnerungen und Datenverwaltung
  - `lib/shared/widgets/app_ui.dart` — gemeinsame Abschnitts-, Status- und Empty-State-Bausteine
  - `lib/shared/widgets/placeholder_screen.dart` — wiederverwendbarer leerer Screen
- `lib/shared/widgets/profile_form.dart` — gemeinsame Profilmaske für Onboarding und Profil
- `shared_preferences` — speichert Name, Betrieb, Ausbildungsberuf, Ausbildungsjahr und Onboarding-Flag lokal
- `hive_ce` / `hive_ce_flutter` — speichert Tageseinträge und eigene Tätigkeiten dauerhaft
- `flutter_local_notifications` / `flutter_timezone` — lokale Erinnerungen in Gerätezeitzone
- `app_settings` — öffnet Android-Benachrichtigungseinstellungen direkt aus der App
- Android Application ID `com.daydaylx.berichtsheftmerker`
- Android-Cloud-Backup und Gerätetransfer für lokale Daten deaktiviert
- Release-Signierung optional über lokale, ignorierte `android/key.properties`
- `test/widget_test.dart` — Onboarding-, Profil- und Navigationstests
- `test/today_screen_test.dart` — Validierungs-, Speicher-, Bearbeitungs- und Tagtyp-Tests
- `test/default_activities_test.dart` — Katalogumfang und eindeutige IDs
- `test/hive_daily_entry_storage_test.dart` — echter Persistenztest über Box-Neuöffnung
- `test/week_utils_test.dart` — ISO-Kalenderwochen inklusive Jahreswechsel
- `test/week_screen_test.dart` — Wochenstatus, Navigation, Zusammenfassung und Fehlerbehandlung
- `test/ui_layout_test.dart` — kleine Displays, große Schrift, Tastatur, Touchflächen und Goldens
- `test/goldens/` — vier visuelle Referenzen zentraler UI-Zustände

## Ausgeführte Checks

| Check                                  | Ergebnis                              |
| -------------------------------------- | ------------------------------------- |
| `flutter create --platforms=android .` | Erfolgreich, android/ generiert       |
| `flutter pub get`                      | Erfolgreich, Abhängigkeiten aufgelöst |
| `flutter analyze`                      | 0 Issues                              |
| `flutter test`                         | 145/145 Tests bestanden               |
| `flutter build apk --debug`            | Erfolgreich, Debug-APK 91 MB           |
| `flutter build apk --release`          | Erfolgreich erzeugt, bewusst unsigniert |
| Release-Signatur ohne lokalen Keystore | `apksigner`: keine Signatur vorhanden  |
| Zusammengeführtes Release-Manifest     | Package-ID und Backup-Sperre bestätigt |
| Start auf Android-Gerät oder Emulator  | Kein ADB-Gerät/Emulator verfügbar     |

Debug-APK: `build/app/outputs/flutter-apk/app-debug.apk`

Android ist auf NDK `27.0.12077973` gepinnt. Debug- und unsignierter
Release-Build wurden damit erfolgreich erzeugt.

## Bewusst noch nicht gebaut

- Favoriten und zuletzt verwendete Tätigkeiten
- Bearbeiten eigener Tätigkeitstitel
- PDF-Export (nicht geplant)
- Cloud/Backend (nicht geplant)

## Nächster Schritt

Manuellen Android-Gerätetest über `docs/QA_REMINDER_CHECKLIST.md` durchführen
und lokalen Release-Keystore für einen signierten Release-Build konfigurieren.
