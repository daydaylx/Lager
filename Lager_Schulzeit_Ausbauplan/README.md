# Lager – Ausbauplan für Berufsschule, Lernen und Prüfung

Basis: `daydaylx/Lager`, Branch `main`, geplant auf Stand `9b8aae521bd2e36f23d42d7e267c2f3cb14535d2`.

## Ziel

Den bestehenden Berichtsheft-Merker schrittweise zu einem schlanken Ausbildungsbegleiter erweitern, ohne den stabilen Tages-/Wochen-/Berichtsheft-Kern unnötig umzubauen.

Die drei Produktdomänen bleiben getrennt:

1. **Ausbildungstag** – Betrieb und Berufsschule dokumentieren.
2. **Schule** – Lernfelder/Fächer, Unterricht, Aufgaben und Klassenarbeiten verwalten.
3. **Prüfung** – Wissen gezielt wiederholen und später IHK-Prüfungsbereiche abbilden.

## Wichtigste Architekturregel

`DailyEntry` darf **nicht** zum Universalmodell für Schul- und Lerndaten werden.

Neue Schuldaten werden in einer eigenen Domäne mit separater Persistenz angelegt und nur über definierte Schnittstellen mit dem Berichtsheft verbunden.

## Empfohlene Releases

- **1.1 Schulbasis:** Phasen 28–33
- **1.2 Organisation:** Phasen 34–35
- **1.3 Lernen:** Phasen 36–37
- **1.4 Fachlernen:** Phase 38
- **1.5 Prüfung:** Phase 39
- **2.x optional:** Phasen 40–41

## Reihenfolge

Die Phasen 28–33 bilden den ersten zusammenhängenden Entwicklungsblock. Danach sollte reale Nutzung in der Berufsschule getestet werden, bevor Lernkarten, Fachrechnen oder KI ergänzt werden.

## Dateien

- `00_ZIEL_UND_NICHTZIELE.md` – Produktgrenzen
- `01_ROADMAP.md` – Gesamtfahrplan
- `architektur/` – Zielarchitektur, Datenmodell und Migration
- `phasen/` – detaillierte Phasen 28–41
- `tests/` – Abnahme-, Integrations- und Regressionstests
- `agent/` – direkt nutzbarer Arbeitsauftrag für Phase 28–33
- `research/` – fachliche Quellen und Annahmen
