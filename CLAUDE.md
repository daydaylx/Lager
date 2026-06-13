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

- **Explore** — Codebase-Suche, nicht manuell grep/find
- **Plan** — Architekturentscheidungen

Sparsam einsetzen — kleine lokale Änderungen direkt erledigen.

---

## Kontext-Packs

Für aufgabenbezogene Dateilisten vor der Arbeit: `docs/AGENT_CONTEXT_PACKS.md`
