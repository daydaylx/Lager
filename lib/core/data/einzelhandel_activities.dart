import '../enums/activity_category.dart';
import '../models/activity_template.dart';

ActivityTemplate einzelhandelActivity({
  required String id,
  required String title,
  required ActivityCategory category,
  bool isActive = false,
}) => ActivityTemplate(
      id: id,
      title: title,
      category: category,
      isActive: isActive,
    );

/// Berufsspezifische Tätigkeiten für Kaufleute im Einzelhandel.
///
/// Die gemeinsamen Grundlagen bleiben im bestehenden `verkauf_*`-Namespace.
/// Dieser Katalog enthält vor allem zusätzliche kaufmännische Inhalte und die
/// erweiterten Berufsschulthemen des dritten Ausbildungsjahres.
final List<ActivityTemplate> einzelhandelActivities = [
  // Komplexe Beratung
  einzelhandelActivity(id: 'einzelhandel_beratung_01', title: 'Komplexen Kundenbedarf analysiert', category: ActivityCategory.kundenberatung, isActive: true),
  einzelhandelActivity(id: 'einzelhandel_beratung_02', title: 'Mehrere Produktlösungen miteinander verglichen', category: ActivityCategory.kundenberatung, isActive: true),
  einzelhandelActivity(id: 'einzelhandel_beratung_03', title: 'Kunden bei einer höherwertigen Kaufentscheidung beraten', category: ActivityCategory.kundenberatung, isActive: true),
  einzelhandelActivity(id: 'einzelhandel_beratung_04', title: 'Preis-, Qualitäts- und Nutzungsanforderungen abgewogen', category: ActivityCategory.kundenberatung),
  einzelhandelActivity(id: 'einzelhandel_beratung_05', title: 'Eine alternative Produktlösung vorgeschlagen', category: ActivityCategory.kundenberatung, isActive: true),
  einzelhandelActivity(id: 'einzelhandel_beratung_06', title: 'Einwände eines Kunden bearbeitet', category: ActivityCategory.kundenberatung),
  einzelhandelActivity(id: 'einzelhandel_beratung_07', title: 'Eine individuelle Kundenlösung erarbeitet', category: ActivityCategory.kundenberatung),
  einzelhandelActivity(id: 'einzelhandel_beratung_08', title: 'Eine Beratung mit einer Fachabteilung abgestimmt', category: ActivityCategory.kundenberatung),
  einzelhandelActivity(id: 'einzelhandel_beratung_09', title: 'Liefer-, Montage- und Produktanforderungen gemeinsam berücksichtigt', category: ActivityCategory.kundenberatung),
  einzelhandelActivity(id: 'einzelhandel_beratung_10', title: 'Eine komplexe Kundenanfrage dokumentiert', category: ActivityCategory.kundenberatung),

  // Kaufmännische Steuerung und Kontrolle
  einzelhandelActivity(id: 'einzelhandel_steuerung_01', title: 'Betriebliche Kennzahlen ausgewertet', category: ActivityCategory.kaufmaennischeSteuerung, isActive: true),
  einzelhandelActivity(id: 'einzelhandel_steuerung_02', title: 'Die Umsatzentwicklung betrachtet', category: ActivityCategory.kaufmaennischeSteuerung, isActive: true),
  einzelhandelActivity(id: 'einzelhandel_steuerung_03', title: 'Verkaufszahlen ausgewertet', category: ActivityCategory.kaufmaennischeSteuerung, isActive: true),
  einzelhandelActivity(id: 'einzelhandel_steuerung_04', title: 'Soll- und Ist-Werte verglichen', category: ActivityCategory.kaufmaennischeSteuerung),
  einzelhandelActivity(id: 'einzelhandel_steuerung_05', title: 'Warenbewegungen ausgewertet', category: ActivityCategory.kaufmaennischeSteuerung),
  einzelhandelActivity(id: 'einzelhandel_steuerung_06', title: 'Inventurergebnisse ausgewertet', category: ActivityCategory.kaufmaennischeSteuerung),
  einzelhandelActivity(id: 'einzelhandel_steuerung_07', title: 'Bestandsabweichungen analysiert', category: ActivityCategory.kaufmaennischeSteuerung),
  einzelhandelActivity(id: 'einzelhandel_steuerung_08', title: 'Die Wirtschaftlichkeit einer Maßnahme betrachtet', category: ActivityCategory.kaufmaennischeSteuerung),
  einzelhandelActivity(id: 'einzelhandel_steuerung_09', title: 'Auswirkungen einer Preisänderung nachvollzogen', category: ActivityCategory.kaufmaennischeSteuerung),
  einzelhandelActivity(id: 'einzelhandel_steuerung_10', title: 'Eine Kalkulation nachvollzogen', category: ActivityCategory.kaufmaennischeSteuerung),
  einzelhandelActivity(id: 'einzelhandel_steuerung_11', title: 'Umsatz- oder Absatzdaten verglichen', category: ActivityCategory.kaufmaennischeSteuerung),
  einzelhandelActivity(id: 'einzelhandel_steuerung_12', title: 'Einen Soll-Ist-Vergleich besprochen', category: ActivityCategory.kaufmaennischeSteuerung),

  // Beschaffung und Warenbestandssteuerung
  einzelhandelActivity(id: 'einzelhandel_beschaffung_01', title: 'Warenbedarf anhand von Bestandsdaten nachvollzogen', category: ActivityCategory.beschaffung, isActive: true),
  einzelhandelActivity(id: 'einzelhandel_beschaffung_02', title: 'Eine Warenbestellung vorbereitet', category: ActivityCategory.beschaffung),
  einzelhandelActivity(id: 'einzelhandel_beschaffung_03', title: 'Liefer- und Zahlungsbedingungen geprüft', category: ActivityCategory.beschaffung),
  einzelhandelActivity(id: 'einzelhandel_beschaffung_04', title: 'Einen Sortimentsvorschlag besprochen', category: ActivityCategory.beschaffung),
  einzelhandelActivity(id: 'einzelhandel_beschaffung_05', title: 'Eine Bestellung im Warenwirtschaftssystem nachvollzogen', category: ActivityCategory.beschaffung),
  einzelhandelActivity(id: 'einzelhandel_bestand_01', title: 'Bestandsstatistiken ausgewertet', category: ActivityCategory.warenbestandssteuerung, isActive: true),
  einzelhandelActivity(id: 'einzelhandel_bestand_02', title: 'Bestands- und Umsatzkennziffern verglichen', category: ActivityCategory.warenbestandssteuerung),
  einzelhandelActivity(id: 'einzelhandel_bestand_03', title: 'Eine Bestandsabweichung nachvollzogen', category: ActivityCategory.warenbestandssteuerung),
  einzelhandelActivity(id: 'einzelhandel_bestand_04', title: 'Warenverfügbarkeit anhand von Systemdaten geprüft', category: ActivityCategory.warenbestandssteuerung, isActive: true),
  einzelhandelActivity(id: 'einzelhandel_bestand_05', title: 'Reservierte Ware geprüft', category: ActivityCategory.warenbestandssteuerung),
  einzelhandelActivity(id: 'einzelhandel_bestand_06', title: 'Eine Warenbewegung artikelbezogen nachvollzogen', category: ActivityCategory.warenbestandssteuerung),
  einzelhandelActivity(id: 'einzelhandel_bestand_07', title: 'Bestandsdaten auf Plausibilität geprüft', category: ActivityCategory.warenbestandssteuerung),
  einzelhandelActivity(id: 'einzelhandel_bestand_08', title: 'Eine Inventurdifferenz besprochen', category: ActivityCategory.warenbestandssteuerung),

  // Marketing, Onlinehandel und Organisation
  einzelhandelActivity(id: 'einzelhandel_marketing_01', title: 'Eine Verkaufsaktion vorbereitet', category: ActivityCategory.werbungVerkaufsfoerderung, isActive: true),
  einzelhandelActivity(id: 'einzelhandel_marketing_02', title: 'Werbemittel im Markt eingesetzt', category: ActivityCategory.werbungVerkaufsfoerderung),
  einzelhandelActivity(id: 'einzelhandel_marketing_03', title: 'Die Wirkung einer Verkaufsaktion betrachtet', category: ActivityCategory.werbungVerkaufsfoerderung, isActive: true),
  einzelhandelActivity(id: 'einzelhandel_marketing_04', title: 'Eine Kundenbindungsmaßnahme unterstützt', category: ActivityCategory.werbungVerkaufsfoerderung),
  einzelhandelActivity(id: 'einzelhandel_marketing_05', title: 'Eine saisonale Verkaufsfläche vorbereitet', category: ActivityCategory.werbungVerkaufsfoerderung),
  einzelhandelActivity(id: 'einzelhandel_marketing_06', title: 'Eine Verbesserung der Warenpräsentation besprochen', category: ActivityCategory.werbungVerkaufsfoerderung),
  einzelhandelActivity(id: 'einzelhandel_online_01', title: 'Die Online-Verfügbarkeit eines Artikels geprüft', category: ActivityCategory.onlinehandel, isActive: true),
  einzelhandelActivity(id: 'einzelhandel_online_02', title: 'Online- und Filialangebot verglichen', category: ActivityCategory.onlinehandel),
  einzelhandelActivity(id: 'einzelhandel_online_03', title: 'Kunden bei einem Onlineangebot unterstützt', category: ActivityCategory.onlinehandel),
  einzelhandelActivity(id: 'einzelhandel_online_04', title: 'Produktinformationen im Onlineangebot kontrolliert', category: ActivityCategory.onlinehandel),
  einzelhandelActivity(id: 'einzelhandel_online_05', title: 'Kunden über verschiedene Bestellwege informiert', category: ActivityCategory.onlinehandel),
  einzelhandelActivity(id: 'einzelhandel_online_06', title: 'Einen digitalen Kundenkontakt bearbeitet', category: ActivityCategory.onlinehandel),
  einzelhandelActivity(id: 'einzelhandel_personal_01', title: 'Arbeitsaufgaben im Team abgestimmt', category: ActivityCategory.personalOrganisation, isActive: true),
  einzelhandelActivity(id: 'einzelhandel_personal_02', title: 'Eine Aufgabenverteilung nachvollzogen', category: ActivityCategory.personalOrganisation),
  einzelhandelActivity(id: 'einzelhandel_personal_03', title: 'Neue Auszubildende bei einer Aufgabe unterstützt', category: ActivityCategory.personalOrganisation),
  einzelhandelActivity(id: 'einzelhandel_personal_04', title: 'Eine betriebliche Anweisung erklärt', category: ActivityCategory.personalOrganisation),
  einzelhandelActivity(id: 'einzelhandel_personal_05', title: 'Die Informationsweitergabe im Team unterstützt', category: ActivityCategory.personalOrganisation),
  einzelhandelActivity(id: 'einzelhandel_personal_06', title: 'Den Personaleinsatz im Verkaufsbereich beobachtet', category: ActivityCategory.personalOrganisation),
  einzelhandelActivity(id: 'einzelhandel_personal_07', title: 'Die Schichtplanung nachvollzogen', category: ActivityCategory.personalOrganisation),
  einzelhandelActivity(id: 'einzelhandel_personal_08', title: 'Ein Feedbackgespräch begleitet', category: ActivityCategory.personalOrganisation),

  // Berufsschule: Lernfelder 11–14 des dritten Ausbildungsjahres
  einzelhandelActivity(id: 'einzelhandel_schule_01', title: 'Kennzahlen und Statistiken im Einzelhandel bearbeitet', category: ActivityCategory.berufsschule),
  einzelhandelActivity(id: 'einzelhandel_schule_02', title: 'Umsatz, Absatz und Kosten betrachtet', category: ActivityCategory.berufsschule),
  einzelhandelActivity(id: 'einzelhandel_schule_03', title: 'Wirtschaftlichkeit und Rentabilität bearbeitet', category: ActivityCategory.berufsschule),
  einzelhandelActivity(id: 'einzelhandel_schule_04', title: 'Deckungsbeitrag und Nachkalkulation behandelt', category: ActivityCategory.berufsschule),
  einzelhandelActivity(id: 'einzelhandel_schule_05', title: 'Warenwirtschaftliche Analysen durchgeführt', category: ActivityCategory.berufsschule),
  einzelhandelActivity(id: 'einzelhandel_schule_06', title: 'Marketinginstrumente und Zielgruppen bearbeitet', category: ActivityCategory.berufsschule),
  einzelhandelActivity(id: 'einzelhandel_schule_07', title: 'Kundenbindung und CRM behandelt', category: ActivityCategory.berufsschule),
  einzelhandelActivity(id: 'einzelhandel_schule_08', title: 'Onlinehandel und Omnichannel bearbeitet', category: ActivityCategory.berufsschule),
  einzelhandelActivity(id: 'einzelhandel_schule_09', title: 'Marketingmaßnahmen bewertet', category: ActivityCategory.berufsschule),
  einzelhandelActivity(id: 'einzelhandel_schule_10', title: 'Personalbedarf und Personaleinsatz behandelt', category: ActivityCategory.berufsschule),
  einzelhandelActivity(id: 'einzelhandel_schule_11', title: 'Arbeitsrecht und Kommunikation bearbeitet', category: ActivityCategory.berufsschule),
  einzelhandelActivity(id: 'einzelhandel_schule_12', title: 'Mitarbeiterführung und Personalentwicklung behandelt', category: ActivityCategory.berufsschule),
  einzelhandelActivity(id: 'einzelhandel_schule_13', title: 'Unternehmensziele und Standortfaktoren bearbeitet', category: ActivityCategory.berufsschule),
  einzelhandelActivity(id: 'einzelhandel_schule_14', title: 'Rechtsformen und Unternehmensentwicklung behandelt', category: ActivityCategory.berufsschule),
  einzelhandelActivity(id: 'einzelhandel_schule_15', title: 'Finanzierung und Investitionen bearbeitet', category: ActivityCategory.berufsschule),
  einzelhandelActivity(id: 'einzelhandel_schule_16', title: 'Nachhaltigkeit im Einzelhandel behandelt', category: ActivityCategory.berufsschule),
];
