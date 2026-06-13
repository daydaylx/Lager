# CLAUDE.md — Claude Code Regeln

Dieses Projekt wird mit **Claude Code** bearbeitet. Ergänzt `AGENTS.md` — immer beide lesen.

---

## Einstieg

```
1. AGENTS.md lesen
2. TASKS.md — aktuelle Phase prüfen
3. PROJECT_STATUS.md — was existiert bereits
4. docs/DATA_MODEL.md — Datenmodell-Überblick
```

Aktuelle Phase: **Phase 6 — Vorlagenverwaltung**

---

## Pflicht: Plan Mode vor Feature-Arbeit

Vor jeder Feature-Implementierung Plan Mode verwenden:

- Relevante Dateien mit Explore-Agent durchsuchen
- Implementierungsplan schreiben
- Erst nach Freigabe umsetzen

Keine Feature-Ausweitung ohne ausdrückliche Zustimmung des Users.

---

## Flutter-Pfad

Flutter ist **nicht** im System-PATH. Immer vollständigen Pfad verwenden:

```bash
/home/d/flutter/bin/flutter analyze       # 0 Issues = Pflicht nach jeder Dart-Änderung
/home/d/flutter/bin/flutter test
/home/d/flutter/bin/flutter pub get
/home/d/flutter/bin/flutter run
```

---

## Subagenten

- **Explore-Agent** für Codebase-Suche (nicht manuell grep/find)
- **Plan-Agent** für Architekturentscheidungen
- Subagenten sparsam einsetzen — kleine lokale Änderungen direkt erledigen

---

## Grenzen

- Nicht über die aktive Phase hinausbauen
- Kein State-Management-Framework ohne Bedarf (`setState` reicht)
- Keine neuen Pakete ohne konkreten Grund
- Kein PDF, kein Backend, kein Login — siehe `AGENTS.md`

---

## Nach jeder Änderung

1. `flutter analyze` — 0 Issues
2. `flutter test` wenn Features geändert wurden
3. `PROJECT_STATUS.md` + `TASKS.md` aktualisieren wenn Phase abgeschlossen

---

## Fokus

Flutter, Dart, Android, Material 3, lokale App. Kein Web, kein Backend.
