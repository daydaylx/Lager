# PROJECT_STATUS.md

Zuletzt aktualisiert: 2026-06-12

## Aktueller Stand

**Phase 2 vollständig abgeschlossen. Phase 3 ist der nächste Schritt.**

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
  - `lib/main.dart` — liest beim Start das vollständige Ausbildungsprofil
  - `lib/app/app.dart` — MaterialApp + Onboarding-Gate + NavigationBar Shell (M3, IndexedStack)
  - `lib/app/theme.dart` — Material 3, ColorScheme.fromSeed grün-teal
  - `lib/app/router.dart` — Route-Konstanten
  - `lib/core/constants.dart` — Text-, SharedPreferences-, Berufs- und Ausbildungsjahr-Konstanten
  - `lib/core/profile_storage.dart` — zentraler SharedPreferences-Zugriff für das Ausbildungsprofil
  - `lib/features/onboarding/onboarding_screen.dart` — kompakter Erststart mit vollständigem Ausbildungsprofil
  - `lib/features/today/today_screen.dart` — Platzhalter "Heute"
  - `lib/features/week/week_screen.dart` — Platzhalter "Woche"
  - `lib/features/templates/templates_screen.dart` — Platzhalter "Vorlagen"
  - `lib/features/profile/profile_screen.dart` — Ausbildungsprofil anzeigen und bearbeiten
  - `lib/shared/widgets/placeholder_screen.dart` — wiederverwendbarer leerer Screen
- `lib/shared/widgets/profile_form.dart` — gemeinsame Profilmaske für Onboarding und Profil
- `shared_preferences` — speichert Name, Betrieb, Ausbildungsberuf, Ausbildungsjahr und Onboarding-Flag lokal
- `test/widget_test.dart` — Onboarding-, Persistenz- und Navigationstests

## Ausgeführte Checks

| Check                                  | Ergebnis                              |
| -------------------------------------- | ------------------------------------- |
| `flutter create --platforms=android .` | Erfolgreich, android/ generiert       |
| `flutter pub get`                      | Erfolgreich, Abhängigkeiten aufgelöst |
| `flutter analyze`                      | 0 Issues                              |
| `flutter test`                         | 6/6 Tests bestanden                   |
| `flutter build apk --debug`            | Auf Nutzerwunsch übersprungen         |
| Start auf Android-Gerät oder Emulator  | Auf Nutzerwunsch übersprungen         |

## Bewusst noch nicht gebaut

Alles aus Phase 3–8:

- Tageseintrag-Funktion
- Lokale Datenbank (Hive)
- Wochenübersicht
- Vorlagenverwaltung
- App-Version und lokale Datenlöschung im Profil
- PDF-Export (nicht geplant)
- Cloud/Backend (nicht geplant)

## Nächster Schritt

Phase 3 umsetzen: schnelle Tagesnotiz im Heute-Screen.
