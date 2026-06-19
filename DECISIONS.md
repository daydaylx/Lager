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
Die Nutzerin wählt eines von fünf Farbthemes im Profil. Das Preset wird lokal in
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

**Manueller JSON-Export via System-Share-Sheet**
Der Nutzer kann alle lokalen Daten (Tageseinträge, eigene Tätigkeiten, Profil)
als JSON-Datei exportieren und über das Android-Share-Sheet selbst sichern.
Direktes Schreiben in den öffentlichen Download-Ordner wurde verworfen: Auf
Android 10+ (Scoped Storage) erfordert das MediaStore-API oder
`MANAGE_EXTERNAL_STORAGE` — beides unverhältnismäßig für einen MVP-Export.
Das Share-Sheet ist erlaubnisfrei, funktioniert auf allen Android-Versionen und
lässt den Nutzer den Zielort selbst wählen.
