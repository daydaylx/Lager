# PROJECT_STATUS.md

Zuletzt aktualisiert: 2026-06-13

## Aktueller Stand

**Phasen 0–10 im Code abgeschlossen. Manueller Android-Gerätetest ist der nächste Schritt.**

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
  - `lib/main.dart` — öffnet beim Start Hive CE und liest das Ausbildungsprofil
  - `lib/app/app.dart` — MaterialApp + Onboarding-Gate + NavigationBar Shell (M3, IndexedStack)
  - `lib/app/theme.dart` — Material 3, ColorScheme.fromSeed grün-teal
  - `lib/app/router.dart` — Route-Konstanten
  - `lib/core/constants.dart` — Text-, SharedPreferences-, Berufs- und Ausbildungsjahr-Konstanten
  - `lib/core/profile_storage.dart` — zentraler SharedPreferences-Zugriff für das Ausbildungsprofil
  - `lib/core/enums/` — Tagtypen, Bereiche, Kategorien und Besonderheiten mit UI-Labels
  - `lib/core/models/` — `DailyEntry` und `ActivityTemplate`
  - `lib/core/data/default_activities.dart` — 87 vordefinierte Tätigkeiten mit stabilen IDs
  - `lib/core/storage/` — Speicher-Schnittstelle, Hive-CE-Adapter und In-Memory-Testspeicher
  - `lib/core/week_utils.dart` — ISO-Kalenderwoche und Wochenstart
  - `lib/features/onboarding/onboarding_screen.dart` — kompakter Erststart mit vollständigem Ausbildungsprofil
  - `lib/features/today/today_screen.dart` — persistenter Tageseintrag, eigene Vorlagen, Schutz vor Eingabeverlust
  - `lib/features/week/week_screen.dart` — Wochenwechsel, Tagesstatus und Zusammenfassung inklusive eigener Vorlagen
  - `lib/features/templates/templates_screen.dart` — Vorlagenverwaltung mit Aktiv-/Deaktivstatus
  - `lib/features/profile/profile_screen.dart` — Ausbildungsprofil, lokale Erinnerungen und Datenverwaltung
  - `lib/shared/widgets/placeholder_screen.dart` — wiederverwendbarer leerer Screen
- `lib/shared/widgets/profile_form.dart` — gemeinsame Profilmaske für Onboarding und Profil
- `shared_preferences` — speichert Name, Betrieb, Ausbildungsberuf, Ausbildungsjahr und Onboarding-Flag lokal
- `hive_ce` / `hive_ce_flutter` — speichert Tageseinträge und eigene Tätigkeiten dauerhaft
- `flutter_local_notifications` / `flutter_timezone` — lokale Erinnerungen in Gerätezeitzone
- `test/widget_test.dart` — Onboarding-, Profil- und Navigationstests
- `test/today_screen_test.dart` — Validierungs-, Speicher-, Bearbeitungs- und Tagtyp-Tests
- `test/default_activities_test.dart` — Katalogumfang und eindeutige IDs
- `test/hive_daily_entry_storage_test.dart` — echter Persistenztest über Box-Neuöffnung
- `test/week_utils_test.dart` — ISO-Kalenderwochen inklusive Jahreswechsel
- `test/week_screen_test.dart` — Wochenstatus, Navigation, Zusammenfassung und Fehlerbehandlung

## Ausgeführte Checks

| Check                                  | Ergebnis                              |
| -------------------------------------- | ------------------------------------- |
| `flutter create --platforms=android .` | Erfolgreich, android/ generiert       |
| `flutter pub get`                      | Erfolgreich, Abhängigkeiten aufgelöst |
| `flutter analyze`                      | 0 Issues                              |
| `flutter test`                         | 77/77 Tests bestanden                 |
| `flutter build apk --debug`            | Erfolgreich, Debug-APK 94.7 MB        |
| Start auf Android-Gerät oder Emulator  | Kein ADB-Gerät/Emulator verfügbar     |

Debug-APK: `build/app/outputs/flutter-apk/app-debug.apk`

Der erfolgreiche Build nutzt NDK 26.3.11579264. Die installierte NDK-27-Kopie
ist unvollständig; Plugins melden deshalb weiterhin eine abweichende
NDK-Empfehlung, der Debug-Build ist davon nicht blockiert.

## Bewusst noch nicht gebaut

- Vollständiges visuelles Redesign / eigenes Komponenten-Theme
- Favoriten und zuletzt verwendete Tätigkeiten
- Bearbeiten eigener Tätigkeitstitel
- PDF-Export (nicht geplant)
- Cloud/Backend (nicht geplant)

## Nächster Schritt

Manuellen Android-Gerätetest für Kernflow, große Systemschrift, Tastatur,
Zurück-Geste, Benachrichtigungsberechtigung und lokale Erinnerungszeit durchführen.
