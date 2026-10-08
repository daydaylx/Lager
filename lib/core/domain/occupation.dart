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
          'Kaufmann/Kauffrau im Einzelhandel',
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

  bool get usesRetailCatalog =>
      this == TrainingOccupation.verkaeufer ||
      this == TrainingOccupation.kaufmannEinzelhandel;

  bool isValidYear(int year) => validYears.contains(year);
}

/// Die vier unverändert gespeicherten Grund-Wahlqualifikationen des Einzelhandels.
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

/// Vertiefungswahlqualifikationen des dreijährigen Berufs im Einzelhandel.
enum EinzelhandelVertiefungsqualifikation {
  beratungVonKundenInKomplexenSituationen,
  beschaffungVonWaren,
  warenbestandssteuerung,
  kaufmaennischeSteuerungUndKontrolle,
  marketingmassnahmen,
  onlinehandel,
  mitarbeiterfuehrungUndEntwicklung,
  vorbereitungUnternehmerischerSelbstaendigkeit,
}

extension EinzelhandelVertiefungsqualifikationDetails
    on EinzelhandelVertiefungsqualifikation {
  String get label => switch (this) {
        EinzelhandelVertiefungsqualifikation
              .beratungVonKundenInKomplexenSituationen =>
          'Beratung von Kunden in komplexen Situationen',
        EinzelhandelVertiefungsqualifikation.beschaffungVonWaren =>
          'Beschaffung von Waren',
        EinzelhandelVertiefungsqualifikation.warenbestandssteuerung =>
          'Warenbestandssteuerung',
        EinzelhandelVertiefungsqualifikation.kaufmaennischeSteuerungUndKontrolle =>
          'Kaufmännische Steuerung und Kontrolle',
        EinzelhandelVertiefungsqualifikation.marketingmassnahmen =>
          'Marketingmaßnahmen',
        EinzelhandelVertiefungsqualifikation.onlinehandel => 'Onlinehandel',
        EinzelhandelVertiefungsqualifikation.mitarbeiterfuehrungUndEntwicklung =>
          'Mitarbeiterführung und -entwicklung',
        EinzelhandelVertiefungsqualifikation
              .vorbereitungUnternehmerischerSelbstaendigkeit =>
          'Vorbereitung unternehmerischer Selbständigkeit',
      };

  String get storageKey => name;

  bool get countsTowardRequiredMinimum =>
      index < 3;

  static EinzelhandelVertiefungsqualifikation? fromStorageKey(String key) {
    for (final value in EinzelhandelVertiefungsqualifikation.values) {
      if (value.storageKey == key) return value;
    }
    return null;
  }

  static bool isValidSelection(Iterable<String> keys) {
    final parsed = keys
        .map(fromStorageKey)
        .toList(growable: false);
    final valid = parsed.whereType<EinzelhandelVertiefungsqualifikation>();
    return parsed.length == 3 &&
        valid.length == 3 &&
        valid.toSet().length == 3 &&
        valid.any((value) => value.countsTowardRequiredMinimum);
  }
}
