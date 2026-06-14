# CURRENT_STATUS.md — Agent-Handoff

Stand: 2026-06-14

---

## Aktive Phase

**Phase 12: Reminder-Stack + UI-Redesign-Iterationen** — Issues #14–#28 im Code abgeschlossen

---

## Was fertig ist

Phasen 0–12 im Code abgeschlossen:

- Flutter-Projektsetup, Android-Konfiguration
- Onboarding (Profil mit Name, Beruf, Jahr, Betrieb)
- Heute-Screen (Standard- und eigene Tätigkeiten, Hive-Persistenz, Schutz vor Eingabeverlust)
- Wochenübersicht (kompakte Tagesliste, Zusammenfassung mit eigenen Tätigkeitstiteln)
- Profil anzeigen und bearbeiten
- Vorlagenverwaltung (vordefiniert + eigene, deaktivieren/reaktivieren)
- App-Version anzeigen, Alle Daten löschen (mit Bestätigung)
- App-Icon (teal, Berichtsheft-Metapher) in allen mipmap-Dichten
- Splash Screen (einfarbig #2E7D6B)
- App-Label: "Berichtsheft-Merker"
- TemplatesScreen: lazy Liste, Validierung, Aktivstatus und Screen-Synchronisierung
- ProfileScreen: Fehler-Icon konsistent ergänzt
- Release-APK gebaut (22.4 MB, debug-signing)
- Erinnerungen: Gerätezeitzone, Permission-/Fehlerstatus, Rollback, Android-Receiver
- Alle Daten löschen bricht geplante Erinnerungen ab
- Reminder-Stack Phase 2: Permission-Feedback, Notification-Channel, bessere Copy,
  Eskalationslogik, Samsung-Hinweis, Wochenbanner, QA-Checkliste

### Neu seit 2026-06-14 (Issues #21–#28)

- **#21** `_DayStatusCard`: farbiger Status-Badge, Missing-Hint im Header, kein dekorativer Icon
- **#22** Pflicht/Optional-Badges auf Section-Headern (Bereich, Tätigkeiten = Pflicht; Besonderheiten, Notiz = Optional)
- **#23** Bereichsauswahl als 2-spaltiges `_AreaGrid` mit Icons (kein reines Chip-Wrap)
- **#24** Aktivere Leertext-Meldung im Tätigkeiten-Bereich
- **#25** Besonderheiten kollabierbar (3 ungewählte sichtbar + "+N weitere"-Chip)
- **#26** SaveBar zeigt kompaktes "Fehlt: Bereich · Tätigkeit" statt langem Hinweistext
- **#27** Kontrast verbessert: Nav-Labels, Disabled-Button-Text, Input-Hint im Dark Theme
- **#28** 5 Farbthemen (`ThemePreset`: Lager Teal, Nacht Grün, Warm Sand, Blau Grau, Hell),
  persistiert via `ThemePresetStorage`, wählbar im Profil-Screen

---

## Letzte erfolgreiche Verifikation

```
flutter analyze  →  0 Issues
flutter test     →  130/130 bestanden
flutter test --update-goldens  →  Golden-Referenzen aktualisiert
```

GitHub Actions CI unter `.github/workflows/flutter-ci.yml` eingerichtet.

---

## Nächster Schritt

Manuelle Tests auf echtem Android-Gerät (APK neu bauen):

- Heute-Screen: Header-Badge, 2-spaltige Bereichsauswahl, kollabierbare Besonderheiten
- SaveBar "Fehlt: …" sichtbar und korrekt
- Profil → Darstellung → Theme wählen → sofort sichtbar + nach Neustart erhalten
- Dark Theme: Kontrast von Nav-Labels, Disabled-Button, Placeholder prüfen
- Permission-Dialog erscheint, Notifications funktionieren (Reminder-Tests)
