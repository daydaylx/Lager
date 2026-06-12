# TASKS.md — Projektphasen und Aufgaben

## Aktuelle Phase

**Phase 3: Heute-Screen** — NÄCHSTE PHASE

---

## Phase 0: Projektsetup ✅

- [x] ZIP-Dokumente nach `docs/` entpackt
- [x] `README.md` erstellt
- [x] `AGENTS.md` erstellt
- [x] `CLAUDE.md` erstellt
- [x] `TASKS.md` erstellt
- [x] `PROJECT_STATUS.md` erstellt
- [x] `DECISIONS.md` erstellt
- [x] Flutter-Projektstruktur (`pubspec.yaml`, `lib/`, `test/`) angelegt
- [x] Platzhalter-Screens für alle 4 Tabs erstellt
- [x] Bottom Navigation Shell eingerichtet
- [x] `flutter pub get`
- [x] `flutter analyze` — 0 Issues

---

## Phase 1: App-Grundgerüst ✅

Voraussetzung: Flutter SDK installiert, `flutter pub get` erfolgreich.

- [x] Flutter SDK installieren (siehe README)
- [x] `flutter pub get` ausführen
- [x] `flutter analyze` — 0 Fehler
- [x] App-Start strukturell durch Widget-Tests geprüft; manuelle Android-Prüfung auf Nutzerwunsch übersprungen
- [x] Bottom Navigation funktioniert (4 Tabs)
- [x] Alle Platzhalter-Screens erreichbar
- [x] Onboarding-Flow: einfacher erster Start (optionaler Name, Ausbildungsberuf)
- [x] Onboarding wird nur beim ersten Start gezeigt (SharedPreferences-Flag)

---

## Phase 2: Onboarding erweitern ✅

- [x] Name optional eingeben (bereits in Phase 1)
- [x] Ausbildungsberuf wählen (bereits in Phase 1)
- [x] Screen: Ausbildungsjahr wählen (1, 2, 3)
- [x] Optionalen Betrieb erfassen
- [x] Bestehende Profildaten ergänzen und bearbeiten
- [x] Erweiterte Profildaten lokal speichern (SharedPreferences)
- [x] Weiterleitung zum Heute-Screen nach Abschluss

---

## Phase 3: Heute-Screen — NÄCHSTE PHASE

- [ ] Tageseintrag erstellen (Datum, Tagtyp, Bereich, Tätigkeiten, Notizen)
- [ ] Tagtypen: Betrieb, Berufsschule, Frei, Urlaub, Krank, Feiertag, Sonstiges
- [ ] Tätigkeitsliste aus Vorlagen wählen
- [ ] Freie Notiz hinzufügen
- [ ] Eintrag speichern (noch ohne persistente DB — in Arbeitsspeicher)
- [ ] Bestehenden Eintrag für heute anzeigen wenn vorhanden

---

## Phase 4: Lokale Speicherung

- [ ] Hive als lokale Datenbank einrichten
- [ ] DailyEntry-Modell mit Hive-Adapter
- [ ] Alle bisher temporär gespeicherten Daten auf Hive umstellen
- [ ] Daten überleben App-Neustart

---

## Phase 5: Wochenübersicht

- [ ] 7-Tage-Kacheln für aktuelle Woche
- [ ] Kachelstatus: eingetragen / fehlt / Frei/Urlaub/Krank
- [ ] Wochenzusammenfassung als lesbare Liste
- [ ] Navigation zum Tageseintrag aus Wochenansicht

---

## Phase 6: Vorlagenverwaltung

- [ ] Vordefinierte Tätigkeiten pro Kategorie anzeigen
- [ ] Eigene Tätigkeit hinzufügen
- [ ] Eigene Tätigkeit löschen
- [ ] Kategorie-Filter

---

## Phase 7: Profil-Screen

- [x] Profilname und Ausbildungsdaten bearbeiten (bereits in Phase 2)
- [ ] App-Version anzeigen
- [ ] Alle Daten löschen (mit Bestätigung)

---

## Phase 8: Polishing und Android-Build

- [ ] App-Icon erstellen
- [ ] Splash Screen
- [ ] Android APK bauen: `flutter build apk`
- [ ] Manuelle Tests auf echtem Android-Gerät
- [ ] Ladezeiten und Performance prüfen
- [ ] Leere Zustände (Empty States) überall vorhanden
- [ ] Fehlermeldungen verständlich
