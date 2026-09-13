import 'industry_profile.dart';
import 'occupation.dart';

/// Nicht persistierte Zusatzinformationen für Standardtätigkeiten.
///
/// DailyEntry speichert weiterhin nur stabile IDs. Die Metadaten steuern
/// Auswahl und Empfehlungen, ohne Hive-Schemata oder historische Einträge zu
/// verändern.
class ActivityCatalogMetadata {
  final int minimumTrainingYear;
  final int preferredTrainingYear;
  final Set<String> industryProfileKeys;
  final Set<String> wahlqualifikationKeys;
  final Set<int> schoolYears;

  const ActivityCatalogMetadata({
    this.minimumTrainingYear = 1,
    this.preferredTrainingYear = 0,
    this.industryProfileKeys = const {},
    this.wahlqualifikationKeys = const {},
    this.schoolYears = const {},
  });

  bool isAvailableForYear(int year) => minimumTrainingYear <= year;

  bool isSchoolTopicForYear(int year) =>
      schoolYears.isEmpty || schoolYears.contains(year);

  bool isForIndustry(IndustryProfile? industry) =>
      industry != null && industryProfileKeys.contains(industry.storageKey);

  bool matchesWahlqualifikation(
    Iterable<EinzelhandelWahlqualifikation> selected,
  ) {
    final selectedKeys = selected.map((value) => value.storageKey).toSet();
    return wahlqualifikationKeys.any(selectedKeys.contains);
  }
}

ActivityCatalogMetadata activityMetadataFor(String id) {
  if (id.startsWith('einzelhandel_schule_')) {
    return const ActivityCatalogMetadata(
      minimumTrainingYear: 3,
      preferredTrainingYear: 3,
      schoolYears: {3},
    );
  }

  if (id.startsWith('einzelhandel_moebel_')) {
    return ActivityCatalogMetadata(
      preferredTrainingYear: 3,
      industryProfileKeys: const {'moebel_einrichtung'},
      wahlqualifikationKeys: _moebelWahlqualifikationen(id),
    );
  }

  if (id.startsWith('einzelhandel_')) {
    return ActivityCatalogMetadata(
      minimumTrainingYear: 3,
      preferredTrainingYear: 3,
      wahlqualifikationKeys: _einzelhandelWahlqualifikationen(id),
    );
  }

  // Der bestehende Verkäuferkatalog ist die gemeinsame Basis für Jahr 1/2.
  if (id.startsWith('verkauf_')) {
    return const ActivityCatalogMetadata(
      schoolYears: {1, 2},
    );
  }
  return const ActivityCatalogMetadata();
}

Set<String> _einzelhandelWahlqualifikationen(String id) {
  if (id.startsWith('einzelhandel_beratung_')) {
    return const {'beratungKomplexeSituationen'};
  }
  if (id.startsWith('einzelhandel_beschaffung_')) {
    return const {'beschaffungWaren'};
  }
  if (id.startsWith('einzelhandel_bestand_')) {
    return const {'warenbestandssteuerung'};
  }
  if (id.startsWith('einzelhandel_steuerung_')) {
    return const {'kaufmaennischeSteuerungKontrolle'};
  }
  if (id.startsWith('einzelhandel_marketing_')) {
    return const {'marketingmassnahmen'};
  }
  if (id.startsWith('einzelhandel_online_')) {
    return const {'onlinehandel'};
  }
  if (id.startsWith('einzelhandel_personal_')) {
    return const {'mitarbeiterfuehrungEntwicklung'};
  }
  return const {};
}

Set<String> _moebelWahlqualifikationen(String id) {
  if (id.contains('_beratung_') ||
      id.contains('_material_') ||
      id.contains('_raumplanung_') ||
      id.contains('_kueche_')) {
    return const {'beratungKomplexeSituationen'};
  }
  if (id.contains('_auftrag_') || id.contains('_finanzierung_')) {
    return const {
      'beratungKomplexeSituationen',
      'beschaffungWaren',
    };
  }
  if (id.contains('_bestand_')) {
    return const {'warenbestandssteuerung'};
  }
  if (id.contains('_online_')) {
    return const {'onlinehandel'};
  }
  if (id.contains('_ausstellung_')) {
    return const {'marketingmassnahmen'};
  }
  return const {};
}
