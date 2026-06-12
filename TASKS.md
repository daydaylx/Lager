# TASKS.md — Projektphasen und Aufgaben

## Aktuelle Phase

**Phase 0: Projektsetup** — abgeschlossen am 2026-06-12

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
- [ ] `flutter pub get` — ausstehend (Flutter SDK nicht installiert)
- [ ] `flutter analyze` — ausstehend (Flutter SDK nicht installiert)

---

## Phase 1: App-Grundgerüst — NÄCHSTE PHASE

Voraussetzung: Flutter SDK installiert, `flutter pub get` erfolgreich.

- [ ] Flutter SDK installieren (siehe README)
- [ ] `flutter pub get` ausführen
- [ ] `flutter analyze` — 0 Fehler
- [ ] App startet auf Android-Emulator oder Gerät
- [ ] Bottom Navigation funktioniert (4 Tabs)
- [ ] Alle Platzhalter-Screens erreichbar
- [ ] Onboarding-Flow: einfacher erster Start (Name, Ausbildungsberuf)
- [ ] Onboarding wird nur beim ersten Start gezeigt (SharedPreferences-Flag)

---

## Phase 2: Onboarding

- [ ] Screen: Name eingeben
- [ ] Screen: Ausbildungsberuf wählen (Fachlagerist/in oder Fachkraft für Lagerlogistik)
- [ ] Screen: Ausbildungsjahr wählen (1, 2, 3)
- [ ] Daten lokal speichern (SharedPreferences)
- [ ] Weiterleitung zum Heute-Screen nach Abschluss

---

## Phase 3: Heute-Screen

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

- [ ] Profilname und Ausbildungsdaten bearbeiten
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
