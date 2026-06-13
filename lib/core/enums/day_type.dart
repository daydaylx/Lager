enum DayType {
  betrieb,
  berufsschule,
  frei,
  urlaub,
  krank,
  feiertag,
  sonstiges,
}

extension DayTypeLabel on DayType {
  String get label {
    return switch (this) {
      DayType.betrieb => 'Betrieb',
      DayType.berufsschule => 'Berufsschule',
      DayType.frei => 'Frei',
      DayType.urlaub => 'Urlaub',
      DayType.krank => 'Krank',
      DayType.feiertag => 'Feiertag',
      DayType.sonstiges => 'Sonstiges',
    };
  }

  bool get supportsActivities {
    return this == DayType.betrieb || this == DayType.berufsschule;
  }

  bool get isAbsence {
    return this == DayType.frei ||
        this == DayType.urlaub ||
        this == DayType.krank ||
        this == DayType.feiertag;
  }
}
