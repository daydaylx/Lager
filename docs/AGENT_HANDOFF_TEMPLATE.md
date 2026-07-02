# AGENT_HANDOFF_TEMPLATE.md — Einheitliche Agenten-Übergabe

Knapp halten, aber vollständig ausfüllen. Ein Agent kann diese Vorlage direkt in
den PR- oder Abschlusskommentar übernehmen. Sie ersetzt nicht das
`.github/pull_request_template.md`, sondern ergänzt den Agenten-Handoff.

---

## Aufgabe

<!-- Issue-Nummer / Phasenbezug und was fachlich das Ziel war. -->

## Geänderte Dateien

<!-- Pfade, gruppiert nach lib/ test/ docs/ android/ config. -->

## Fachliche Entscheidung

<!-- Kurz: welche Option und warum. Verweis auf DECISIONS.md bei ADR-Reife. -->

## Tests / Checks

<!-- Tatsächlich ausgeführt, z. B.:
- flutter analyze → 0 Issues
- flutter test → N/N
- flutter build apk --debug → erfolgreich -->

## Nicht gemacht

<!-- Bewusst ausgelassene Punkte und warum. -->

## Risiken

<!-- Persistenz, Android, UI/Theme, Release — nur was wirklich relevant ist. -->

## Documentation Freshness Check

| Area                                   | Docs affected? | Action               |
| -------------------------------------- | -------------: | -------------------- |
| README / setup                         |         yes/no | updated / not needed |
| Agent context                          |         yes/no | updated / not needed |
| Validation matrix                      |         yes/no | updated / not needed |
| UI / data / security / deployment docs |         yes/no | updated / not needed |

Result:

- `No documentation update needed`
- oder `Documentation updated`
- oder `Documentation update still required`

## Nächster sinnvoller Schritt

<!-- Konketer Folgeauftrag oder offener manueller Test. -->
