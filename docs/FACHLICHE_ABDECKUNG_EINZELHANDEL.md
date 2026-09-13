# Fachliche Abdeckung: Einzelhandel

## Unterstütztes Profil

`Kaufmann/-frau im Einzelhandel` ist ein eigenständiger dreijähriger
Ausbildungsberuf. Das Profil speichert Ausbildungsjahr 1–3, genau drei gültige
Wahlqualifikationen aus den acht offiziellen Optionen und optional das
Branchenprofil `Möbel & Einrichtung`.

`Verkäufer/in` bleibt davon getrennt ein zweijähriger Beruf mit den bisherigen
vier Wahlqualifikationen. Bestehende Lagerprofile, Hive-TypeIDs, Storage-Keys,
Verkäufer-IDs und Lager-IDs bleiben unverändert.

## Katalog und Filter

- Gemeinsame Einzelhandelsgrundlagen verwenden die bestehenden `verkauf_*`-IDs.
- Neue kaufmännische und schulische IDs liegen unter `einzelhandel_*`.
- Möbel-/Einrichtungsinhalte liegen unter `einzelhandel_moebel_*` und werden nur
  bei ausgewähltem Branchenprofil angeboten.
- Kaufmännische Inhalte werden nach Ausbildungsjahr und Wahlqualifikation
  empfohlen; die Metadaten sind nicht Teil des Hive-Schemas.
- Berufsschulthemen bleiben im Picker als Berufsschule gekennzeichnet.
- Eigene und historische Tätigkeiten bleiben bei Berufswechseln auflösbar.

## Möbel & Einrichtung

Der Branchenbereich deckt beobachtbare Ausbildungsaufgaben ab: Möbel- und
Materialberatung, Raum- und Küchenplanung, Auftrag und Vertragsabwicklung,
Finanzierungs-/Zahlungsthemen, Lieferung, Montage, Reklamation, Ausstellung,
Bestand und Onlinehandel. Es werden keine internen Höffner-Systeme oder
betriebsinternen Abläufe behauptet.

## Ausgabe und Datenfluss

Profiländerungen werden von Onboarding, Profilbearbeitung und Bootstrap bis in
Today-/Vorlagenpicker weitergereicht. Berichte formulieren Kaufmann-Tätigkeiten
als Einzelhandels-/Abteilungskontext; der JSON-Export enthält zusätzlich
`wahlqualifikationen` und `industryProfile`. Private Notizen bleiben wie bisher
außerhalb des generierten Berichts und des Exports vertraulicher KI-Daten.

## Abdeckung durch Tests

- Profilvalidierung und rückwärtskompatibler SharedPreferences-Roundtrip:
  `test/profile_storage_test.dart`
- Jahr-, Branchen- und Katalogfilter sowie Empfehlungen:
  `test/activity_picker_model_test.dart`
- Kataloggröße, eindeutige IDs und persistente Enum-/ID-Verträge:
  `test/default_activities_test.dart`, `test/persistence_stability_test.dart`
- Kaufmann-Bericht und Export:
  `test/daily_report_generator_test.dart`, `test/export_service_test.dart`
