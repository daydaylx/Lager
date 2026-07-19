import '../enums/activity_category.dart';
import '../models/activity_template.dart';

/// Vollständiger Standardkatalog der Lagerlogistik-Tätigkeiten.
///
/// Bewusst werden **keine** IDs entfernt oder umbenannt: gespeicherte
/// Tageseinträge referenzieren diese IDs als Strings, und alte Berichte müssen
/// auflösbar bleiben. Nicht mehr sinnvolle Einträge bleiben deshalb hier als
/// historische Referenz erhalten, werden aber über [retiredDefaultActivityIds]
/// aus neuer Auswahl und Vorlagenverwaltung ausgeblendet.
///
/// Werksvorgabe: 38 der auswählbaren Einträge sind im Tagesformular direkt
/// aktiv. Weitere fachlich passende Einträge können im Vorlagen-Screen
/// aktiviert werden. Passive Pflichtaussagen und Angaben, die bereits über
/// Besonderheiten abgedeckt sind, gehören nicht zur auswählbaren Liste.
const List<ActivityTemplate> defaultActivities = [
  // --- Wareneingang (aktiv: 01, 05, 06, 11) ---
  ActivityTemplate(
    id: 'wareneingang_01',
    title: 'Lieferung angenommen und geprüft',
    category: ActivityCategory.wareneingang,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'wareneingang_02',
    title: 'Lieferung anhand des Lieferscheins geprüft',
    category: ActivityCategory.wareneingang,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'wareneingang_03',
    title: 'Liefermenge kontrolliert',
    category: ActivityCategory.wareneingang,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'wareneingang_04',
    title: 'Artikelnummern mit Lieferpapieren abgeglichen',
    category: ActivityCategory.wareneingang,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'wareneingang_05',
    title: 'Verpackung auf Schäden geprüft',
    category: ActivityCategory.wareneingang,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'wareneingang_06',
    title: 'Auffällige oder beschädigte Ware gemeldet',
    category: ActivityCategory.wareneingang,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'wareneingang_07',
    title: 'Ware ausgepackt',
    category: ActivityCategory.wareneingang,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'wareneingang_08',
    title: 'Ware sortiert',
    category: ActivityCategory.wareneingang,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'wareneingang_09',
    title: 'Wareneingang dokumentiert',
    category: ActivityCategory.wareneingang,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'wareneingang_10',
    title: 'Ware für die Einlagerung vorbereitet',
    category: ActivityCategory.wareneingang,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'wareneingang_11',
    title: 'Wareneingang im System oder mit Scanner erfasst',
    category: ActivityCategory.wareneingang,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'wareneingang_12',
    title: 'Lieferdaten im Warenwirtschaftssystem geprüft',
    category: ActivityCategory.wareneingang,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'wareneingang_13',
    title: 'Chargen- oder Seriennummern abgeglichen',
    category: ActivityCategory.wareneingang,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'wareneingang_14',
    title: 'Begleitpapiere sortiert und weitergegeben',
    category: ActivityCategory.wareneingang,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'wareneingang_15',
    title: 'Lieferabweichung dokumentiert und gemeldet',
    category: ActivityCategory.wareneingang,
    isActive: false,
  ),

  // --- Einlagerung (aktiv: 01, 04, 07, 08) ---
  ActivityTemplate(
    id: 'einlagerung_01',
    title: 'Ware eingelagert und einsortiert',
    category: ActivityCategory.einlagerung,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'einlagerung_02',
    title: 'Geeigneten Lagerplatz ermittelt',
    category: ActivityCategory.einlagerung,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'einlagerung_03',
    title: 'Ware nach Lagerordnung einsortiert',
    category: ActivityCategory.einlagerung,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'einlagerung_04',
    title: 'Lagerbestand geprüft',
    category: ActivityCategory.einlagerung,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'einlagerung_05',
    title: 'Ware umgelagert',
    category: ActivityCategory.einlagerung,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'einlagerung_06',
    title: 'Lagerplatz beschriftet',
    category: ActivityCategory.einlagerung,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'einlagerung_07',
    title: 'Mindesthaltbarkeitsdaten und FIFO-Reihenfolge kontrolliert',
    category: ActivityCategory.einlagerung,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'einlagerung_08',
    title: 'Lagerbereich gereinigt und geordnet',
    category: ActivityCategory.einlagerung,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'einlagerung_09',
    title: 'Lagerfläche vorbereitet',
    category: ActivityCategory.einlagerung,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'einlagerung_10',
    title: 'Ware gegen Beschädigung gesichert',
    category: ActivityCategory.einlagerung,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'einlagerung_11',
    title: 'Lagerplatz im System geprüft',
    category: ActivityCategory.einlagerung,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'einlagerung_12',
    title: 'Einlagerung mit Scanner bestätigt',
    category: ActivityCategory.einlagerung,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'einlagerung_13',
    title: 'Ware nach FIFO-Prinzip einsortiert',
    category: ActivityCategory.einlagerung,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'einlagerung_14',
    title: 'Regalfach und Artikelnummer abgeglichen',
    category: ActivityCategory.einlagerung,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'einlagerung_15',
    title: 'Bestandsabweichung an zuständige Person weitergegeben',
    category: ActivityCategory.einlagerung,
    isActive: false,
  ),

  // --- Transport (aktiv: 01, 03, 08) ---
  ActivityTemplate(
    id: 'transport_01',
    title: 'Ware mit Hubwagen oder Rollwagen transportiert',
    category: ActivityCategory.transport,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'transport_02',
    title: 'Ware mit Rollwagen transportiert',
    category: ActivityCategory.transport,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'transport_03',
    title: 'Ware zum Lagerplatz oder zur Versandzone gebracht',
    category: ActivityCategory.transport,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'transport_04',
    title: 'Ware zur Versandzone gebracht',
    category: ActivityCategory.transport,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'transport_05',
    title: 'Transportwege kontrolliert und Hindernisse entfernt',
    category: ActivityCategory.transport,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'transport_06',
    title: 'Fördermittel vor dem Einsatz geprüft',
    category: ActivityCategory.transport,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'transport_07',
    title: 'Sicherheitsvorgaben beim Transport beachtet',
    category: ActivityCategory.transport,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'transport_08',
    title: 'Ware auf Ladungsträger umgesetzt und gesichert',
    category: ActivityCategory.transport,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'transport_09',
    title: 'Transportauftrag mit Scanner bearbeitet',
    category: ActivityCategory.transport,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'transport_10',
    title: 'Ladehilfsmittel bereitgestellt',
    category: ActivityCategory.transport,
    isActive: false,
  ),

  // --- Kommissionierung (aktiv: 01, 02, 04, 08) ---
  ActivityTemplate(
    id: 'kommissionierung_01',
    title: 'Kundenauftrag kommissioniert',
    category: ActivityCategory.kommissionierung,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'kommissionierung_02',
    title: 'Artikel nach Pickliste zusammengestellt',
    category: ActivityCategory.kommissionierung,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'kommissionierung_03',
    title: 'Ware aus dem Lager entnommen',
    category: ActivityCategory.kommissionierung,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'kommissionierung_04',
    title: 'Artikel gescannt und Menge kontrolliert',
    category: ActivityCategory.kommissionierung,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'kommissionierung_05',
    title: 'Menge kontrolliert',
    category: ActivityCategory.kommissionierung,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'kommissionierung_06',
    title: 'Fehlbestand festgestellt und gemeldet',
    category: ActivityCategory.kommissionierung,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'kommissionierung_07',
    title: 'Kommissionierten Auftrag bereitgestellt',
    category: ActivityCategory.kommissionierung,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'kommissionierung_08',
    title: 'Auftrag auf Vollständigkeit geprüft',
    category: ActivityCategory.kommissionierung,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'kommissionierung_09',
    title: 'Kommissionierauftrag im System bearbeitet',
    category: ActivityCategory.kommissionierung,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'kommissionierung_10',
    title: 'Entnahme mit Scanner bestätigt',
    category: ActivityCategory.kommissionierung,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'kommissionierung_11',
    title: 'Artikel nach Lagerplatzreihenfolge entnommen',
    category: ActivityCategory.kommissionierung,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'kommissionierung_12',
    title: 'Ersatzartikel nach Rücksprache bereitgestellt',
    category: ActivityCategory.kommissionierung,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'kommissionierung_13',
    title: 'Kommissionierfehler gemeldet und korrigiert',
    category: ActivityCategory.kommissionierung,
    isActive: false,
  ),

  // --- Verpackung (aktiv: 01, 05, 10) ---
  ActivityTemplate(
    id: 'verpackung_01',
    title: 'Ware transportsicher verpackt',
    category: ActivityCategory.verpackung,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'verpackung_02',
    title: 'Passende Verpackung ausgewählt',
    category: ActivityCategory.verpackung,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'verpackung_03',
    title: 'Paket mit Füllmaterial gepolstert',
    category: ActivityCategory.verpackung,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'verpackung_04',
    title: 'Paket verschlossen',
    category: ActivityCategory.verpackung,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'verpackung_05',
    title: 'Versandlabel angebracht',
    category: ActivityCategory.verpackung,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'verpackung_06',
    title: 'Ware für den Versand vorbereitet',
    category: ActivityCategory.verpackung,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'verpackung_07',
    title: 'Ladeeinheit zusammengestellt',
    category: ActivityCategory.verpackung,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'verpackung_08',
    title: 'Verpackungsmaterial aufgefüllt',
    category: ActivityCategory.verpackung,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'verpackung_09',
    title: 'Ware auf Transportschäden geprüft',
    category: ActivityCategory.verpackung,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'verpackung_10',
    title: 'Packliste mit Ware abgeglichen',
    category: ActivityCategory.verpackung,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'verpackung_11',
    title: 'Sendung im System fertiggemeldet',
    category: ActivityCategory.verpackung,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'verpackung_12',
    title: 'Füllmaterial passend eingesetzt',
    category: ActivityCategory.verpackung,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'verpackung_13',
    title: 'Gefahr- und Hinweissymbole an Ware oder Sendung geprüft',
    category: ActivityCategory.verpackung,
    isActive: false,
  ),

  // --- Versand (aktiv: 01, 05, 06, 07) ---
  ActivityTemplate(
    id: 'versand_01',
    title: 'Sendung für den Versand vorbereitet',
    category: ActivityCategory.versand,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'versand_02',
    title: 'Versandpapiere geprüft',
    category: ActivityCategory.versand,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'versand_03',
    title: 'Lieferschein beigelegt',
    category: ActivityCategory.versand,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'versand_04',
    title: 'Paket beschriftet',
    category: ActivityCategory.versand,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'versand_05',
    title: 'Ware zur Verladung bereitgestellt',
    category: ActivityCategory.versand,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'versand_06',
    title: 'Lkw-Beladung unterstützt',
    category: ActivityCategory.versand,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'versand_07',
    title: 'Ladung für den Transport gesichert',
    category: ActivityCategory.versand,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'versand_08',
    title: 'Ware auf Palette gestapelt',
    category: ActivityCategory.versand,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'versand_09',
    title: 'Palette foliert',
    category: ActivityCategory.versand,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'versand_10',
    title: 'Versandbereich aufgeräumt',
    category: ActivityCategory.versand,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'versand_11',
    title: 'Sendungsdaten im System geprüft',
    category: ActivityCategory.versand,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'versand_12',
    title: 'Verladung nach Tourenliste unterstützt',
    category: ActivityCategory.versand,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'versand_13',
    title: 'Packstücke nach Versandart sortiert',
    category: ActivityCategory.versand,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'versand_14',
    title: 'Palette für den Transport gesichert',
    category: ActivityCategory.versand,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'versand_15',
    title: 'Abholung der Ware vorbereitet',
    category: ActivityCategory.versand,
    isActive: false,
  ),

  // --- Inventur (aktiv: 01, 02, 09) ---
  ActivityTemplate(
    id: 'inventur_01',
    title: 'Lagerbestand gezählt',
    category: ActivityCategory.inventur,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'inventur_02',
    title: 'Bestand mit System abgeglichen',
    category: ActivityCategory.inventur,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'inventur_03',
    title: 'Fehlmengen gemeldet',
    category: ActivityCategory.inventur,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'inventur_04',
    title: 'Zählarbeiten bei der Inventur durchgeführt',
    category: ActivityCategory.inventur,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'inventur_05',
    title: 'Artikel gezählt',
    category: ActivityCategory.inventur,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'inventur_06',
    title: 'Bestandsabweichung dokumentiert',
    category: ActivityCategory.inventur,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'inventur_07',
    title: 'Lagerkennzahlen besprochen',
    category: ActivityCategory.inventur,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'inventur_08',
    title: 'Zählbereich vorbereitet',
    category: ActivityCategory.inventur,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'inventur_09',
    title: 'Artikel mit Scanner gezählt',
    category: ActivityCategory.inventur,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'inventur_10',
    title: 'Bestand unter Anleitung im System geprüft',
    category: ActivityCategory.inventur,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'inventur_11',
    title: 'Kontrollzählung durchgeführt',
    category: ActivityCategory.inventur,
    isActive: false,
  ),

  // --- Retouren (aktiv: 01, 04, 05) ---
  ActivityTemplate(
    id: 'retouren_01',
    title: 'Retoure angenommen und geprüft',
    category: ActivityCategory.retouren,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'retouren_02',
    title: 'Retournierte Ware auf Zustand und Vollständigkeit geprüft',
    category: ActivityCategory.retouren,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'retouren_03',
    title: 'Beschädigte Ware aussortiert',
    category: ActivityCategory.retouren,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'retouren_04',
    title: 'Reklamation dokumentiert',
    category: ActivityCategory.retouren,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'retouren_05',
    title: 'Retournierte Ware wieder eingelagert oder aussortiert',
    category: ActivityCategory.retouren,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'retouren_06',
    title: 'Nicht verwendbare Ware gekennzeichnet',
    category: ActivityCategory.retouren,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'retouren_07',
    title: 'Retourengrund aufgenommen',
    category: ActivityCategory.retouren,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'retouren_08',
    title: 'Retoure mit Scanner erfasst',
    category: ActivityCategory.retouren,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'retouren_09',
    title: 'Retoure zur weiteren Prüfung bereitgestellt',
    category: ActivityCategory.retouren,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'retouren_10',
    title: 'Rücksendung nach Vorgabe sortiert',
    category: ActivityCategory.retouren,
    isActive: false,
  ),

  // --- Berufsschule (aktiv: 01, 02, 09, 10, 12) ---
  ActivityTemplate(
    id: 'berufsschule_01',
    title: 'Fachinhalte zur Lagerlogistik bearbeitet',
    category: ActivityCategory.berufsschule,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'berufsschule_02',
    title: 'Aufgaben zu einem Lernfeld bearbeitet',
    category: ActivityCategory.berufsschule,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'berufsschule_03',
    title: 'Aufgaben im Bereich Lagerlogistik bearbeitet',
    category: ActivityCategory.berufsschule,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'berufsschule_04',
    title: 'Warenannahme theoretisch behandelt',
    category: ActivityCategory.berufsschule,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'berufsschule_05',
    title: 'Lagerarten besprochen',
    category: ActivityCategory.berufsschule,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'berufsschule_06',
    title: 'Kommissionierung besprochen',
    category: ActivityCategory.berufsschule,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'berufsschule_07',
    title: 'Verpackung und Versand behandelt',
    category: ActivityCategory.berufsschule,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'berufsschule_08',
    title: 'Arbeitssicherheit behandelt',
    category: ActivityCategory.berufsschule,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'berufsschule_09',
    title: 'Wirtschafts- und Sozialkunde bearbeitet',
    category: ActivityCategory.berufsschule,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'berufsschule_10',
    title: 'Klassenarbeit geschrieben',
    category: ActivityCategory.berufsschule,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'berufsschule_11',
    title: 'Unterrichtsinhalte wiederholt',
    category: ActivityCategory.berufsschule,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'berufsschule_12',
    title: 'Warenwirtschaft und Lagerkennzahlen behandelt',
    category: ActivityCategory.berufsschule,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'berufsschule_13',
    title: 'Rechte und Pflichten in der Ausbildung erarbeitet',
    category: ActivityCategory.berufsschule,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'berufsschule_14',
    title: 'Ladungssicherung theoretisch bearbeitet',
    category: ActivityCategory.berufsschule,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'berufsschule_15',
    title: 'Qualitätssicherung im Lager besprochen',
    category: ActivityCategory.berufsschule,
    isActive: false,
  ),

  // --- Ordnung / Qualität / Unterweisung (aktiv: 03, 06, 11, 13, 14) ---
  ActivityTemplate(
    id: 'sicherheit_01',
    title: 'Persönliche Schutzausrüstung getragen',
    category: ActivityCategory.sicherheit,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'sicherheit_02',
    title: 'Sicherheitsvorschriften beachtet',
    category: ActivityCategory.sicherheit,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'sicherheit_03',
    title: 'Arbeitsbereich gereinigt und geordnet',
    category: ActivityCategory.sicherheit,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'sicherheit_04',
    title: 'Verkehrswege freigehalten',
    category: ActivityCategory.sicherheit,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'sicherheit_05',
    title: 'Verpackungsabfälle getrennt und entsorgt',
    category: ActivityCategory.sicherheit,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'sicherheit_06',
    title: 'Ware auf Qualitätsmängel geprüft',
    category: ActivityCategory.sicherheit,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'sicherheit_07',
    title: 'Arbeitsanweisung beachtet',
    category: ActivityCategory.sicherheit,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'sicherheit_08',
    title: 'Unter Anleitung gearbeitet',
    category: ActivityCategory.sicherheit,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'sicherheit_09',
    title: 'Selbstständig gearbeitet',
    category: ActivityCategory.sicherheit,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'sicherheit_10',
    title: 'Neue Aufgabe gelernt',
    category: ActivityCategory.sicherheit,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'sicherheit_11',
    title: 'Arbeitsbereich nach 5S geprüft und geordnet',
    category: ActivityCategory.sicherheit,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'sicherheit_12',
    title: 'Arbeitsplatz nach Vorgabe geordnet',
    category: ActivityCategory.sicherheit,
    isActive: false,
  ),
  ActivityTemplate(
    id: 'sicherheit_13',
    title: 'Qualitätsmangel festgestellt und gemeldet',
    category: ActivityCategory.sicherheit,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'sicherheit_14',
    title: 'An einer Arbeitsschutzunterweisung teilgenommen',
    category: ActivityCategory.sicherheit,
    isActive: true,
  ),
  ActivityTemplate(
    id: 'sicherheit_15',
    title: 'Prüfpunkte aus Arbeitsanweisung nachvollzogen',
    category: ActivityCategory.sicherheit,
    isActive: false,
  ),
];

/// Historische Katalogeinträge, die keine eigenständige, berichtsfähige
/// Tätigkeit beschreiben. Die IDs und Originaltitel bleiben zur Auflösung alter
/// Tageseinträge erhalten, sind für neue Einträge aber nicht mehr auswählbar.
const Set<String> retiredDefaultActivityIds = {
  'transport_07',
  'sicherheit_01',
  'sicherheit_02',
  'sicherheit_04',
  'sicherheit_07',
  'sicherheit_08',
  'sicherheit_09',
  'sicherheit_10',
  'sicherheit_12',
};

bool isSelectableDefaultActivity(ActivityTemplate activity) =>
    !retiredDefaultActivityIds.contains(activity.id);

final List<ActivityTemplate> selectableDefaultActivities =
    List.unmodifiable(defaultActivities.where(isSelectableDefaultActivity));
