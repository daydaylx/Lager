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

**Hive als lokale Datenbank (ab Phase 4)**
Leichtgewichtig, Flutter-native, kein SQL-Overhead für diese Datenmenge. SQLite wäre auch möglich, aber Hive ist einfacher für einfache Datenstrukturen. Entscheidung kann in Phase 4 revidiert werden.

**SharedPreferences für Einstellungen**
Profilname, Ausbildungsdaten, Onboarding-Flag — kleine Schlüssel-Wert-Paare passen in SharedPreferences, keine eigene DB-Tabelle nötig.

---

## Navigation und UI

**Bottom Navigation mit 4 Tabs**
Schneller Alltagseinsatz: Heute, Woche, Vorlagen, Profil. Alles mit einem Daumenclick erreichbar. Kein Hamburger-Menü, das erst aufgeklappt werden muss.

**Material 3**
Modernes, freundliches Android-Look & Feel ohne Custom-Theme-Aufwand. Wärme und Lesbarkeit out of the box.

**IndexedStack für Tab-Persistence**
Scroll-Position und Screen-State bleiben beim Tab-Wechsel erhalten. Bessere UX als Navigator-Pop/Push für jeden Tab.

---

## State Management

**setState im MVP — kein Framework**
Die App ist klein. Ein Tageseintrag-Formular und eine Wochenübersicht brauchen keinen BLoC oder Riverpod. setState reicht. Entscheidung wird in Phase 4–5 neu bewertet wenn Datenbankzugriffe komplexer werden.

---

## Features (Ausschlüsse)

**Kein PDF-Export in V1**
Die App ist eine Merkhilfe, kein offizielles Dokument. PDF-Generierung ist komplex und fehleranfällig. Nutzerin schreibt das Berichtsheft manuell — die App liefert nur das Gedächtnis.

**Kein Onboarding-Wizard mit vielen Schritten**
Einfache Profil-Eingabe beim ersten Start reicht. Keine Tutorial-Slides, keine Berechtigungs-Dialoge, kein Onboarding-Karussel.

**Keine Erinnerungs-Notifications in V1**
Nützlich, aber nicht kritisch für MVP. Kann in Phase 8 oder danach ergänzt werden.
