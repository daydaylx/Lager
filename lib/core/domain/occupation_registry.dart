import '../enums/activity_category.dart';
import '../enums/training_area.dart';
import 'occupation.dart';
import 'occupation_config.dart';

/// Zentrale, einfache Registry der berufsspezifischen App-Konfiguration.
class OccupationRegistry {
  static const Map<TrainingOccupation, OccupationConfig> _configs = {
    TrainingOccupation.fachlagerist: _lagerConfig,
    TrainingOccupation.fachkraftLagerlogistik: _lagerConfig,
    TrainingOccupation.verkaeufer: _verkaeuferConfig,
  };

  static List<TrainingOccupation> get allOccupations =>
      TrainingOccupation.values;

  static OccupationConfig configFor(TrainingOccupation occupation) =>
      _configs[occupation] ?? _lagerConfig;

  static const OccupationConfig _lagerConfig = OccupationConfig(
    occupation: TrainingOccupation.fachkraftLagerlogistik,
    areas: [
      TrainingArea.wareneingang,
      TrainingArea.lager,
      TrainingArea.transport,
      TrainingArea.kommissionierung,
      TrainingArea.verpackung,
      TrainingArea.versand,
      TrainingArea.inventur,
      TrainingArea.retouren,
    ],
    categoriesByArea: {
      TrainingArea.wareneingang: [ActivityCategory.wareneingang],
      TrainingArea.lager: [ActivityCategory.einlagerung],
      TrainingArea.transport: [ActivityCategory.transport],
      TrainingArea.kommissionierung: [ActivityCategory.kommissionierung],
      TrainingArea.verpackung: [ActivityCategory.verpackung],
      TrainingArea.versand: [ActivityCategory.versand],
      TrainingArea.inventur: [ActivityCategory.inventur],
      TrainingArea.retouren: [ActivityCategory.retouren],
    },
    activityCategories: {
      ActivityCategory.wareneingang,
      ActivityCategory.einlagerung,
      ActivityCategory.transport,
      ActivityCategory.kommissionierung,
      ActivityCategory.verpackung,
      ActivityCategory.versand,
      ActivityCategory.inventur,
      ActivityCategory.retouren,
      ActivityCategory.berufsschule,
      ActivityCategory.sicherheit,
    },
    activityIdPrefix: '',
  );

  static const OccupationConfig _verkaeuferConfig = OccupationConfig(
    occupation: TrainingOccupation.verkaeufer,
    areas: [
      TrainingArea.verkaufsflaeche,
      TrainingArea.kundenberatung,
      TrainingArea.kasse,
      TrainingArea.warenpraesentation,
      TrainingArea.wareneingangVerkauf,
      TrainingArea.lagerBestand,
      TrainingArea.reklamationService,
      TrainingArea.werbungVerkaufsfoerderung,
    ],
    categoriesByArea: {
      TrainingArea.verkaufsflaeche: [ActivityCategory.verkaufsflaeche],
      TrainingArea.kundenberatung: [ActivityCategory.kundenberatung],
      TrainingArea.kasse: [ActivityCategory.kasse, ActivityCategory.preis],
      TrainingArea.warenpraesentation: [
        ActivityCategory.warenpraesentation,
        ActivityCategory.werbungVerkaufsfoerderung,
      ],
      TrainingArea.wareneingangVerkauf: [ActivityCategory.wareneingangVerkauf],
      TrainingArea.lagerBestand: [ActivityCategory.lagerBestand],
      TrainingArea.reklamationService: [ActivityCategory.reklamationService],
      TrainingArea.werbungVerkaufsfoerderung: [
        ActivityCategory.werbungVerkaufsfoerderung,
      ],
    },
    activityCategories: {
      ActivityCategory.verkaufsflaeche,
      ActivityCategory.kundenberatung,
      ActivityCategory.kasse,
      ActivityCategory.warenpraesentation,
      ActivityCategory.wareneingangVerkauf,
      ActivityCategory.lagerBestand,
      ActivityCategory.reklamationService,
      ActivityCategory.werbungVerkaufsfoerderung,
      ActivityCategory.preis,
      ActivityCategory.allgemein,
      ActivityCategory.berufsschule,
    },
    activityIdPrefix: 'verkauf_',
    // 38 häufige Tätigkeiten bleiben im Tagespicker kompakt sichtbar.
    quickAccessActivityIds: {
      'verkauf_beratung_01',
      'verkauf_beratung_02',
      'verkauf_beratung_03',
      'verkauf_beratung_04',
      'verkauf_beratung_05',
      'verkauf_beratung_06',
      'verkauf_beratung_07',
      'verkauf_beratung_08',
      'verkauf_beratung_09',
      'verkauf_beratung_10',
      'verkauf_kasse_01',
      'verkauf_kasse_02',
      'verkauf_kasse_03',
      'verkauf_kasse_04',
      'verkauf_kasse_05',
      'verkauf_kasse_06',
      'verkauf_kasse_07',
      'verkauf_kasse_08',
      'verkauf_flaeche_01',
      'verkauf_flaeche_02',
      'verkauf_flaeche_03',
      'verkauf_flaeche_04',
      'verkauf_flaeche_05',
      'verkauf_flaeche_06',
      'verkauf_flaeche_07',
      'verkauf_praesentation_01',
      'verkauf_praesentation_02',
      'verkauf_praesentation_03',
      'verkauf_praesentation_04',
      'verkauf_praesentation_05',
      'verkauf_wareneingang_01',
      'verkauf_wareneingang_02',
      'verkauf_wareneingang_03',
      'verkauf_bestand_01',
      'verkauf_bestand_02',
      'verkauf_service_01',
      'verkauf_service_02',
      'verkauf_werbung_01',
    },
    schoolTopicIds: {
      'verkauf_schule_01',
      'verkauf_schule_02',
      'verkauf_schule_03',
      'verkauf_schule_04',
      'verkauf_schule_05',
      'verkauf_schule_06',
      'verkauf_schule_07',
      'verkauf_schule_08',
      'verkauf_schule_09',
      'verkauf_schule_10',
      'verkauf_schule_11',
      'verkauf_schule_12',
      'verkauf_schule_13',
      'verkauf_schule_14',
      'verkauf_schule_15',
      'verkauf_schule_16',
      'verkauf_schule_17',
      'verkauf_schule_18',
      'verkauf_schule_19',
      'verkauf_schule_20',
    },
    wahlqualifikationKeywords: {
      Wahlqualifikation.sicherstellungWarenpraesenz: [
        'bestand',
        'lieferung',
        'wareneingang',
        'warenwirtschaft',
        'inventur',
        'verfügbarkeit',
      ],
      Wahlqualifikation.beratungVonKunden: [
        'kunden',
        'produkte',
        'beratung',
        'verkaufsgespräch',
        'reklamation',
      ],
      Wahlqualifikation.kassensystemdatenKundenservice: [
        'kasse',
        'kassier',
        'kassen',
        'gutschein',
        'stornierung',
      ],
      Wahlqualifikation.werbungVerkaufsfoerderung: [
        'werbung',
        'aktion',
        'präsent',
        'verkaufsförder',
        'aktionsfläche',
      ],
    },
  );
}
