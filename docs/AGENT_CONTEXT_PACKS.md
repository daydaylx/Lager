# AGENT_CONTEXT_PACKS.md — Aufgabenbezogene Dateilisten

Format: Aufgabe → Dateien lesen → Risiken → Mindestchecks

---

## Pack 1: Phase 6 — Vorlagenverwaltung (aktiv)

**Aufgabe:** `templates_screen.dart` implementieren — vordefinierte Tätigkeiten anzeigen,
filtern, eigene Tätigkeiten hinzufügen und löschen.

### Dateien lesen (in dieser Reihenfolge)

| Datei                                          | Warum                                                   |
| ---------------------------------------------- | ------------------------------------------------------- |
| `TASKS.md`                                     | Genaue Anforderungen Phase 6                            |
| `lib/features/templates/templates_screen.dart` | Aktueller Platzhalter — hier wird gebaut                |
| `lib/core/data/default_activities.dart`        | 87 Tätigkeiten mit stabilen IDs und Kategorien          |
| `lib/core/models/activity_template.dart`       | ActivityTemplate-Modell                                 |
| `lib/core/enums/activity_category.dart`        | ActivityCategory-Enum (10 Kategorien)                   |
| `lib/features/today/today_screen.dart`         | Wie Tätigkeiten heute gewählt werden (Pattern-Referenz) |
| `docs/UI_UX_SPEC.md`                           | Abschnitt "18. Vorlagen-Screen" (Zeile ~447)            |
| `docs/DATA_MODEL.md`                           | ActivityTemplate-Persistenz-Konzept                     |

### Risiken

- **Stabile IDs:** ActivityTemplate-IDs in `default_activities.dart` sind Fremdschlüssel in gespeicherten DailyEntry-Objekten. Nie ändern, nie löschen.
- **Keine neuen Packages:** Vorlagenverwaltung braucht kein neues Package. Nur vorhandene Hive CE / SharedPreferences nutzen.
- **setState reicht:** Kein State-Management-Framework einführen.
- **Kategorie-Filter als Chips:** Nicht als Dropdown — sieh UI_UX_SPEC.md.
- **Eigene Tätigkeiten:** Brauchen eigene stabile IDs (z. B. UUID-Format oder Timestamp-basiert). Nicht mit vordefinierten IDs kollidieren.

### Mindestchecks nach Änderung

```bash
/home/d/flutter/bin/flutter analyze    # muss 0 Issues zeigen
/home/d/flutter/bin/flutter test       # muss alle 28+ Tests bestehen
```

---

## Pack 2: Datenmodell-Änderung

**Aufgabe:** Enum oder Model ändern (z. B. neuer DayType, neues Feld in DailyEntry).

### Dateien lesen

| Datei                                            | Warum                                                       |
| ------------------------------------------------ | ----------------------------------------------------------- |
| `docs/DATA_MODEL.md`                             | Vollständige Referenz, Persistenz-Strategie                 |
| `lib/core/models/daily_entry.dart`               | Model-Definition                                            |
| `lib/core/storage/daily_entry_adapter.dart`      | Hive-CE-Adapter — muss bei Felderweiterung angepasst werden |
| `lib/core/storage/hive_daily_entry_storage.dart` | Produktiv-Impl.                                             |
| `test/hive_daily_entry_storage_test.dart`        | Persistenz-Tests                                            |
| `DECISIONS.md`                                   | Warum Hive CE statt SQLite (nicht erneut diskutieren)       |

### Risiken

- **Hive CE Adapter manuell:** Kein Codegenerator. Bei neuen Feldern `daily_entry_adapter.dart` anpassen.
- **Vorwärtskompatibilität:** Bestehende gespeicherte Daten müssen lesbar bleiben. Neue Felder optional (nullable) oder mit Default.
- **Enum-Namen als String gespeichert:** Enum-Werte werden als String-Name persistiert (nicht als Index). Umbenennungen brechen bestehende Daten.

### Mindestchecks

```bash
/home/d/flutter/bin/flutter analyze
/home/d/flutter/bin/flutter test      # besonders hive_daily_entry_storage_test.dart
```

---

## Pack 3: UI-Änderung (bestehender Screen)

**Aufgabe:** Einen bestehenden Screen anpassen (Layout, Widget, Text).

### Dateien lesen

| Datei                                            | Warum                                     |
| ------------------------------------------------ | ----------------------------------------- |
| `docs/UI_UX_SPEC.md`                             | Design-Vorgaben für den jeweiligen Screen |
| Ziel-Screen (z. B. `today_screen.dart`)          | Bestehendes Layout                        |
| `lib/app/theme.dart`                             | Farben, Theme-Tokens                      |
| Relevanter Test (z. B. `today_screen_test.dart`) | Was darf sich nicht ändern                |

### Risiken

- **Theme.of(context) nicht buildAppTheme()** — nie direkt aufrufen.
- **Große Touchflächen** — minimum 48×48dp, keine kleinen Buttons.
- **Bottom Navigation bleibt:** 4 Tabs, keine Änderung ohne expliziten Auftrag.
- **Keine Web-App-Elemente:** Kein AppBar mit Zurück-Button als Hauptnavigation.

### Mindestchecks

```bash
/home/d/flutter/bin/flutter analyze
```

Manueller Test auf Gerät/Emulator wenn Layout-kritisch.

---

## Pack 4: Phase abschließen

**Aufgabe:** Alle Aufgaben einer Phase sind erledigt, Dokumentation updaten.

### Dateien updaten

| Datei                    | Was ändern                                             |
| ------------------------ | ------------------------------------------------------ |
| `TASKS.md`               | Phase als ✅ markieren                                 |
| `PROJECT_STATUS.md`      | Neue Elemente in "Was existiert", Checks aktualisieren |
| `docs/CURRENT_STATUS.md` | Aktive Phase und nächsten Schritt updaten              |

### Mindestchecks

```bash
/home/d/flutter/bin/flutter analyze
/home/d/flutter/bin/flutter test
```
