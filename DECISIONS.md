# DECISIONS.md — Architekturentscheidungen

## Technologie

**Flutter statt React Native oder Capacitor/Ionic**
Echte native App-Erfahrung auf Android. Kein Browser-Feel, kein WebView-Overhead. Flutter kompiliert zu nativem ARM-Code.

**Android-first, kein iOS**
Die Zielnutzerin verwendet Android. iOS-Support würde Aufwand ohne Mehrwert bedeuten (Apple-Developer-Account, andere Build-Umgebung).

**Dart — keine Alternative gewählt**
Flutter-Standardsprache. Keine externe Wahl nötig.

---

## Datenspeicherung

**Lokale Speicherung statt Cloud**
Private App für eine Person. Kein Account, kein Server, keine Datenschutzprobleme, kein Wartungsaufwand. Daten gehören der Nutzerin und bleiben auf dem Gerät.

**Hive CE als lokale Datenbank (seit Phase 4)**
Hive CE ist die aktiv gepflegte Fortführung der Hive-v2-API. Es bleibt leichtgewichtig und vermeidet SQL-Overhead für diese Datenmenge. Tageseinträge liegen in der Box `entries`; Adapter werden ohne Codegenerierung handgeschrieben.

**SharedPreferences für Einstellungen**
Profilname, Ausbildungsdaten, Onboarding-Flag — kleine Schlüssel-Wert-Paare passen in SharedPreferences, keine eigene DB-Tabelle nötig.

---

## Navigation und UI

**Bottom Navigation mit 4 Tabs**
Schneller Alltagseinsatz: Heute, Woche, Vorlagen, Profil. Alles mit einem Daumenclick erreichbar. Kein Hamburger-Menü, das erst aufgeklappt werden muss.

**Reduziertes Material 3 mit explizitem Komponenten-Theme**
Die App bleibt visuell nah an Android, verwendet aber feste Regeln für AppBars,
Navigation, Buttons, Eingaben, Chips, Karten, Dialoge und Statusflächen. Teal
ist das Standardpreset; weitere ruhige Farbpresets sind lokal wählbar. Custom
Fonts und neue UI-Pakete sind nicht nötig.

**Lokale Theme-Presets statt System-Dark-Mode**
Die Nutzerin wählt eines von neun Farbthemes im Profil. Das Preset wird lokal in
SharedPreferences gespeichert und zentral über `buildThemeForPreset()` auf die
gesamte App angewendet. Widgets lesen Farben weiterhin ausschließlich über
`Theme.of(context)`.

**Zentrale Statusfarben statt Rot für offene Tage (#54)**
Tages- und Wochenstatus nutzen eine zentrale Farbquelle
(`lib/core/ui/day_status_colors.dart`): gespeichert = `primary`, offen = `tertiary`
(ruhiger Amber-Akzent), Abwesenheit = `secondary`, neutral = `onSurfaceVariant`.
Rot (`error`/`errorContainer`) ist echten Fehlern (Ladefehler, Vorlagen-Warnung)
vorbehalten und wird nicht mehr für normale offene Werktage verwendet. So wirkt die
App weniger nach Kontrolle/Pflicht, ohne die Zustandsunterscheidbarkeit zu schwächen.

**IndexedStack für Tab-Persistence**
Scroll-Position und Screen-State bleiben beim Tab-Wechsel erhalten. Bessere UX als Navigator-Pop/Push für jeden Tab.

**Phase 22: Daily-Check-in statt Arbeitsformular** ❌ (rückgängig gemacht 2026-07-10)
Die UI-Experimente aus Phase 22 (AreaCarousel, WeekDotStrip, SectionEmphasis,
wärmeres lagerTeal) wurden selektiv revertiert. Der UI-Stand entspricht Phase 20.
Phase-21-Infrastruktur bleibt bestehen.

**Phase 25: Geführter Today-Check-in statt langem Scroll-Formular**
Der tägliche Kernflow führt abhängig vom Tagtyp durch Tagtyp, Bereich,
Tätigkeitsauswahl und Prüfung. Die umfangreiche Tätigkeitsliste läuft in einer
vollflächigen Ansicht mit explizitem Übernehmen; Abbrechen verwirft nur die noch
nicht übernommene Auswahl. Gespeicherte Tage zeigen eine kompakte Übersicht mit
gezieltem Bearbeiten. Das bleibt lokaler `setState`-UI-State und verändert weder
`DailyEntry` noch die Bottom Navigation.

---

## UX-Revisionen

**Phase 26: UX-Quick-Wins-Scope (2026-Q3) — additive Verbesserungen statt Flow-Redesign**

Die in `.agent/plans/current-plan.md` dokumentierte UX-Analyse identifizierte
etwa 15 Themen in zwei Clustern: Quick Wins (Inkonsistenzen wie
„Schritt 2 von 4" hardcodiert, fehlender Schritt-Indikator, Suchfeld-
Sichtbarkeit) und UX-Lücken (Pull-to-Refresh nur auf Woche,
„Eintrag fehlt"-SnackBar bei Abwesenheit, kürzere Wochenstatistik).
Statt einen erneuten Flow-Refactor (Phase 22 wurde 2026-07-10 rückgängig
gemacht) wurden die Themen als additive Sub-Phasen 26a/b/c umgesetzt:

- **26a** Flow-Orientierung: korrekte Schritt-Labels aus `TodayFlowStep` +
  Tagestyp (Betrieb 1/4, Berufsschule 1/3, Abwesenheit 1/2); neuer
  `AppStepIndicator` als reine UI-Komponente; Picker-Kontext im Header;
  konsistente `HapticFeedback.selectionClick()` auf AreaGrid, `ActivityRow`
  und SpecialFlag-Chips.
- **26b** UX-Patterns: Pull-to-Refresh auf Heute- und Vorlagen-Screen;
  Pop-Schutz-Differenzierung via `_hasStructuralChanges()` (reine
  Notiz-/Flag-Änderungen verwerfen ohne Bestätigungsdialog, strukturelle
  Änderungen lösen weiter den Dialog aus).
- **26c** Klarheit & Polish: „Eigene Tätigkeit" von
  `FilledButton.tonalIcon` auf kompakten `TextButton.icon`; präzisere
  Notiz-Beschriftungen; Wochenstatistik auf zwei Bestandteile gekürzt
  (Verteilung im Tooltip).

Bewusst zurückgestellt (separater Folge-Scope, eigene Produktentscheidung):

- **UX-4 B3** statische App-Shortcuts (Android-Kotlin)
- **UX-4 B5** `AnimatedSwitcher` zwischen Flow-Schritten (würde
  ListView-Refactor erfordern)
- **UX-4 B11** SaveBar-Sichtbarkeit bei geöffneter Tastatur
- **UX-3 A5** bedingte Suchfeld-Sichtbarkeit (subjektiv, niedrige Priorität)
- **UX-3 B8** Witz-Sheet-Re-Trigger im Profil
- **Stepper-Pattern, Draft-Persistenz bei App-Kill, First-Day-Erfahrung,
  Onboarding-Illustration, App-Icon-Badge** — alle ausdrücklich nicht im
  Scope dieses Plans, separate Phasen mit eigener Produktentscheidung.

Begründung Scope-Begrenzung: Phase 22 (Daily-Check-in-Redesign) hat
gezeigt, dass Flow-Refactors am tatsächlichen Nutzerbedarf vorbeigehen
können und teuer rückgängig zu machen sind. Additive Quick Wins greifen
konkret beobachtbare UX-Schmerzen auf, ohne den Phase-25-Flow zu gefährden.

Verifikation pro Sub-Phase: `flutter analyze` (0 Issues), `flutter test`
(vorherige Tests + neue Unit-/Widget-Tests grün), Goldens nur nach
Sichtprüfung der PNGs regeneriert, `scripts/check_repo_hygiene.sh` OK,
`flutter build apk --debug` erfolgreich. 274/274 Tests grün nach Phase 26c.

**Phase 26d — Native Patterns & Bewegung (UX-4 B3, B5, B11)**
ergänzt die Quick Wins um native Patterns:

- **B3 App-Shortcuts:** Long-Press auf das Android-App-Icon zeigt
  statische Shortcuts aus `res/xml/shortcuts.xml`. Der Intent-Schema ist
  `berichtsheftmerker://shortcut/<id>`, die Auswertung erfolgt in
  `MainActivity.kt` über den `MethodChannel`
  `com.daydaylx.berichtsheftmerker/app_shortcuts` an Flutter. Aktuell
  nur „Heute eintragen" (`open_today`); weitere Shortcuts folgen, sobald
  die Intent-Handhabung in Production verifiziert ist. Verhalten ist
  nur auf echtem Gerät verifizierbar — bleibt manuelle QA in Phase 19.
- **B5 Flow-Übergänge:** Schritt-Inhalt wird in ein eigenes `_StepBody`
  Widget mit stabilem Key extrahiert und mit `AnimatedSize` +
  `AnimatedSwitcher` (FadeTransition, 220 ms) animiert. Key enthält
  Step + DayType, damit State-Updates ohne Step-Wechsel keine
  Animation neu starten.
- **B11 SaveBar-Sichtbarkeit bei Tastatur:** bewusst kein Code-Eingriff.
  Der bestehende Test „Heute-Notiz und Speichern bleiben mit Tastatur
  erreichbar" (`test/ui_layout_test.dart`, 360×640 + 280 dp
  Tastatur-Inset) verifiziert das Verhalten bereits ab Phase 11.
  Eine zusätzliche `Scrollable.ensureVisible` wäre redundant und
  würde den bestehenden automatischen Flutter-Mechanismus doppeln.

Verifikation Phase 26d: `flutter analyze` 0 Issues, `flutter test`
280/280 grün (274 alt + 6 neue Tests für `AppShortcutService`),
`flutter build apk --debug` erfolgreich, `scripts/check_repo_hygiene.sh`
OK.

---

## State Management

**setState im MVP — kein Framework**
Die App ist klein. Ein Tageseintrag-Formular und eine Wochenübersicht brauchen keinen BLoC oder Riverpod. `setState` reicht; dies wurde nach Abschluss der persistenten Wochenübersicht in Phase 5 bestätigt.

---

## Features (Ausschlüsse)

**Kein PDF-Export in V1**
Die App ist eine Merkhilfe, kein offizielles Dokument. PDF-Generierung ist komplex und fehleranfällig. Nutzerin schreibt das Berichtsheft manuell — die App liefert nur das Gedächtnis.

**Onboarding mit genau zwei kompakten Schritten**
Eine kurze Einführung und danach das Ausbildungsprofil reichen. Keine
Tutorial-Slides, Berechtigungs-Dialoge oder langen Onboarding-Karussells.

**Lokale Erinnerungs-Notifications ohne Cloud**
Erinnerungen werden ausschließlich auf dem Android-Gerät geplant. Sie verwenden
die Gerätezeitzone, benötigen keine Push-Infrastruktur und werden beim Löschen
aller Daten abgebrochen.

**Android-Backup und Gerätetransfer deaktiviert**
Die App enthält private Ausbildungsnotizen und verspricht rein lokale
Datenhaltung. Android-Cloud-Backup und automatischer Gerätetransfer sind deshalb
für alle App-Daten deaktiviert.

**Eindeutige Application ID und keine Debug-Signatur für Releases**
Android-Builds verwenden `com.daydaylx.berichtsheftmerker`. Release-Artefakte
werden nur signiert, wenn lokal eine ignorierte `android/key.properties` mit
einem privaten Release-Keystore vorhanden ist; der Debug-Schlüssel ist für
Release-Builds ausgeschlossen.

**Eigene Tätigkeiten deaktivieren statt hart löschen**
Tageseinträge speichern Tätigkeit-IDs. Eigene Tätigkeiten bleiben deshalb mit
stabiler ID und Titel erhalten; deaktivierte Vorlagen verschwinden nur aus neuen
Auswahlen und bleiben für historische Einträge lesbar.

**Deterministischer Tagesbericht statt KI-Formulierung**
Der lokale `DailyReportGenerator` erzeugt aus Tagestyp, Bereich, Tätigkeiten und
ausgewählten Besonderheiten einen kopierbaren Berichtsvorschlag. Er verwendet
keine externe API, kein Sprachmodell und verändert keine gespeicherten Daten.

**Lokaler Speicher-Witz statt Gamification-System**
Nach dem ersten erfolgreichen Speichern eines neuen Tageseintrags zeigt die App
einen kurzen lokalen Lagerlogistik-Witz als ruhiges Material-3-Bottom-Sheet. Die
Auswahl ist deterministisch pro Kalendertag (`lib/core/data/lager_jokes.dart`),
benötigt keine Persistenz, keine neue Dependency, kein Backend und kein Punkte-,
Streak- oder Achievement-System. Spätere Änderungen an bestehenden Einträgen
nutzen nur eine kurze SnackBar-Bestätigung.

**Manueller JSON-Export via System-Share-Sheet**
Der Nutzer kann alle lokalen Daten (Tageseinträge, eigene Tätigkeiten, Profil)
als JSON-Datei exportieren und über das Android-Share-Sheet selbst sichern.
Direktes Schreiben in den öffentlichen Download-Ordner wurde verworfen: Auf
Android 10+ (Scoped Storage) erfordert das MediaStore-API oder
`MANAGE_EXTERNAL_STORAGE` — beides unverhältnismäßig für einen MVP-Export.
Das Share-Sheet ist erlaubnisfrei, funktioniert auf allen Android-Versionen und
lässt den Nutzer den Zielort selbst wählen.
