@AGENTS.md

# CLAUDE.md — Claude-Code-Ergänzungen

## Plan Mode (Pflicht vor Feature-Arbeit)

Vor jeder Feature-Implementierung:

1. Explore-Agent: relevante Dateien durchsuchen
2. Implementierungsplan schreiben
3. Erst nach User-Freigabe umsetzen

Keine Feature-Ausweitung ohne ausdrückliche Zustimmung.

---

## Subagenten

- **Explore** — bei breiten oder unklaren Codebase-Suchen
- **Plan** — Architekturentscheidungen

Sparsam einsetzen — kleine lokale Änderungen und gezielte Suchen direkt erledigen.

## Git-Sicherheit

Auch wenn lokale Tool-Berechtigungen Git-Befehle erlauben, gelten die Grenzen aus
`AGENTS.md`: ohne ausdrücklichen Auftrag nichts stagen, committen, pushen,
resetten oder auschecken.

---

## Kontext-Packs

Für aufgabenbezogene Dateilisten vor der Arbeit: `docs/AGENT_CONTEXT_PACKS.md`
