/// Unterstützte Ausbildungsberufe.
///
/// Die Reihenfolge und Namen sind ein Persistenzvertrag für SharedPreferences.
enum TrainingOccupation {
  fachlagerist,
  fachkraftLagerlogistik,
  verkaeufer,
  kaufmannEinzelhandel,
}

extension TrainingOccupationDetails on TrainingOccupation {
  String get label => switch (this) {
        TrainingOccupation.fachlagerist => 'Fachlagerist/in',
        TrainingOccupation.fachkraftLagerlogistik =>
          'Fachkraft für Lagerlogistik',
        TrainingOccupation.verkaeufer => 'Verkäufer/in',
        TrainingOccupation.kaufmannEinzelhandel =>
          'Kaufmann/-frau im Einzelhandel',
      };

  String get storageKey => switch (this) {
        TrainingOccupation.fachlagerist => 'fachlagerist',
        TrainingOccupation.fachkraftLagerlogistik =>
          'fachkraft_lagerlogistik',
        TrainingOccupation.verkaeufer => 'verkaeufer',
        TrainingOccupation.kaufmannEinzelhandel => 'kaufmann_einzelhandel',
      };

  static TrainingOccupation? fromStorageKey(String key) => switch (key) {
        'fachlagerist' => TrainingOccupation.fachlagerist,
        'fachkraft_lagerlogistik' => TrainingOccupation.fachkraftLagerlogistik,
        'verkaeufer' => TrainingOccupation.verkaeufer,
        'kaufmann_einzelhandel' => TrainingOccupation.kaufmannEinzelhandel,
        _ => null,
      };

  List<int> get validYears => switch (this) {
        TrainingOccupation.fachlagerist => const [1, 2],
        TrainingOccupation.fachkraftLagerlogistik => const [1, 2, 3],
        TrainingOccupation.verkaeufer => const [1, 2],
        TrainingOccupation.kaufmannEinzelhandel => const [1, 2, 3],
      };

  bool isValidYear(int year) => validYears.contains(year);
}

/// Die acht Wahlqualifikationen des dreijährigen Einzelhandelsberufs.
enum EinzelhandelWahlqualifikation {
  beratungKomplexeSituationen,
  beschaffungWaren,
  warenbestandssteuerung,
  kaufmaennischeSteuerungKontrolle,
  marketingmassnahmen,
  onlinehandel,
  mitarbeiterfuehrungEntwicklung,
  vorbereitungUnternehmerischeSelbstaendigkeit,
}

extension EinzelhandelWahlqualifikationDetails
    on EinzelhandelWahlqualifikation {
  String get label => switch (this) {
        EinzelhandelWahlqualifikation.beratungKomplexeSituationen =>
          'Beratung von Kunden in komplexen Situationen',
        EinzelhandelWahlqualifikation.beschaffungWaren => 'Beschaffung von Waren',
        EinzelhandelWahlqualifikation.warenbestandssteuerung =>
          'Warenbestandssteuerung',
        EinzelhandelWahlqualifikation.kaufmaennischeSteuerungKontrolle =>
          'Kaufmännische Steuerung und Kontrolle',
        EinzelhandelWahlqualifikation.marketingmassnahmen =>
          'Marketingmaßnahmen',
        EinzelhandelWahlqualifikation.onlinehandel => 'Onlinehandel',
        EinzelhandelWahlqualifikation.mitarbeiterfuehrungEntwicklung =>
          'Mitarbeiterführung und -entwicklung',
        EinzelhandelWahlqualifikation.vorbereitungUnternehmerischeSelbstaendigkeit =>
          'Vorbereitung unternehmerischer Selbstständigkeit',
      };

  String get storageKey => name;

  static EinzelhandelWahlqualifikation? fromStorageKey(String key) {
    for (final value in EinzelhandelWahlqualifikation.values) {
      if (value.storageKey == key) return value;
    }
    return null;
  }
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
