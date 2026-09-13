/// Unterstützte Ausbildungsberufe.
///
/// Die Reihenfolge und Namen sind ein Persistenzvertrag für SharedPreferences.
enum TrainingOccupation {
  fachlagerist,
  fachkraftLagerlogistik,
  verkaeufer,
}

extension TrainingOccupationDetails on TrainingOccupation {
  String get label => switch (this) {
        TrainingOccupation.fachlagerist => 'Fachlagerist/in',
        TrainingOccupation.fachkraftLagerlogistik =>
          'Fachkraft für Lagerlogistik',
        TrainingOccupation.verkaeufer => 'Verkäufer/in',
      };

  String get storageKey => switch (this) {
        TrainingOccupation.fachlagerist => 'fachlagerist',
        TrainingOccupation.fachkraftLagerlogistik =>
          'fachkraft_lagerlogistik',
        TrainingOccupation.verkaeufer => 'verkaeufer',
      };

  static TrainingOccupation? fromStorageKey(String key) => switch (key) {
        'fachlagerist' => TrainingOccupation.fachlagerist,
        'fachkraft_lagerlogistik' => TrainingOccupation.fachkraftLagerlogistik,
        'verkaeufer' => TrainingOccupation.verkaeufer,
        _ => null,
      };

  List<int> get validYears => switch (this) {
        TrainingOccupation.fachlagerist => const [1, 2],
        TrainingOccupation.fachkraftLagerlogistik => const [1, 2, 3],
        TrainingOccupation.verkaeufer => const [1, 2],
      };

  bool isValidYear(int year) => validYears.contains(year);
}

/// Die vier im Verkäuferprofil auswählbaren Wahlqualifikationen.
enum Wahlqualifikation {
  sicherstellungWarenpraesenz,
  beratungVonKunden,
  kassensystemdatenKundenservice,
  werbungVerkaufsfoerderung,
}

extension WahlqualifikationDetails on Wahlqualifikation {
  String get label => switch (this) {
        Wahlqualifikation.sicherstellungWarenpraesenz =>
          'Sicherstellung der Warenpräsenz',
        Wahlqualifikation.beratungVonKunden => 'Beratung von Kunden',
        Wahlqualifikation.kassensystemdatenKundenservice =>
          'Kassensystemdaten und Kundenservice',
        Wahlqualifikation.werbungVerkaufsfoerderung =>
          'Werbung und Verkaufsförderung',
      };

  String get storageKey => name;

  static Wahlqualifikation? fromStorageKey(String key) {
    for (final value in Wahlqualifikation.values) {
      if (value.storageKey == key) return value;
    }
    return null;
  }
}
