# PROJECT_STATUS.md

Zuletzt aktualisiert: 2026-06-13

## Aktueller Stand

**Phase 5 vollständig abgeschlossen. Phase 6 ist der nächste Schritt.**

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
  - `lib/features/today/today_screen.dart` — persistenter Tageseintrag mit Lade- und Fehlerzuständen
  - `lib/features/week/week_screen.dart` — Wochenwechsel, Tagesstatus, Fortschritt und Wochenzusammenfassung
  - `lib/features/templates/templates_screen.dart` — Platzhalter "Vorlagen"
  - `lib/features/profile/profile_screen.dart` — Ausbildungsprofil anzeigen und bearbeiten
  - `lib/shared/widgets/placeholder_screen.dart` — wiederverwendbarer leerer Screen
- `lib/shared/widgets/profile_form.dart` — gemeinsame Profilmaske für Onboarding und Profil
- `shared_preferences` — speichert Name, Betrieb, Ausbildungsberuf, Ausbildungsjahr und Onboarding-Flag lokal
- `hive_ce` / `hive_ce_flutter` — speichert Tageseinträge dauerhaft in der Box `entries`
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
| `flutter test`                         | 28/28 Tests bestanden                 |
| `flutter build apk --debug`            | Auf Nutzerwunsch übersprungen         |
| Start auf Android-Gerät oder Emulator  | Auf Nutzerwunsch übersprungen         |

## Bewusst noch nicht gebaut

Alles aus Phase 6–8:

- Eigene Tätigkeiten und Vorlagenverwaltung
- App-Version und lokale Datenlöschung im Profil
- PDF-Export (nicht geplant)
- Cloud/Backend (nicht geplant)

## Nächster Schritt

Phase 6 umsetzen: Tätigkeitsvorlagen anzeigen und eigene Vorlagen verwalten.
