# PROJECT_STATUS.md

Zuletzt aktualisiert: 2026-06-12

## Aktueller Stand

**Phase 0: Projektsetup vollständig abgeschlossen. Alle Checks grün.**

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
  - `lib/main.dart`
  - `lib/app/app.dart` — MaterialApp + NavigationBar Shell (M3, IndexedStack)
  - `lib/app/theme.dart` — Material 3, ColorScheme.fromSeed grün-teal
  - `lib/app/router.dart` — Route-Konstanten
  - `lib/core/constants.dart` — Textkonstanten
  - `lib/features/onboarding/onboarding_screen.dart` — Platzhalter
  - `lib/features/today/today_screen.dart` — Platzhalter "Heute"
  - `lib/features/week/week_screen.dart` — Platzhalter "Woche"
  - `lib/features/templates/templates_screen.dart` — Platzhalter "Vorlagen"
  - `lib/features/profile/profile_screen.dart` — Platzhalter "Profil"
  - `lib/shared/widgets/placeholder_screen.dart` — wiederverwendbarer leerer Screen
- `test/widget_test.dart` — Smoke-Test (bestanden)

## Ausgeführte Checks

| Check                                  | Ergebnis                              |
| -------------------------------------- | ------------------------------------- |
| `flutter create --platforms=android .` | Erfolgreich, android/ generiert       |
| `flutter pub get`                      | Erfolgreich, Abhängigkeiten aufgelöst |
| `flutter analyze`                      | 0 Issues                              |
| `flutter test`                         | 1/1 Tests bestanden                   |

## Bewusst noch nicht gebaut

Alles aus Phase 1–8:

- Onboarding-Logik (nur Platzhalter)
- Tageseintrag-Funktion
- Lokale Datenbank (Hive)
- Wochenübersicht
- Vorlagenverwaltung
- Profil-Bearbeitung
- PDF-Export (nicht geplant)
- Cloud/Backend (nicht geplant)

## Nächster Schritt

Phase 1 starten (siehe `TASKS.md`):

```bash
flutter run   # App auf Gerät/Emulator starten
```

Dann Onboarding-Logik implementieren (Phase 1 → Phase 2).
