enum SpecialFlag {
  selbststaendig,
  unterAnleitung,
  neuesGelernt,
  problemAufgetreten,
  kontrolle,
  fehlerKorrigiert,
  wiederholt,
}

extension SpecialFlagLabel on SpecialFlag {
  String get label {
    return switch (this) {
      SpecialFlag.selbststaendig => 'Selbstständig',
      SpecialFlag.unterAnleitung => 'Unter Anleitung',
      SpecialFlag.neuesGelernt => 'Neue Aufgabe gelernt',
      SpecialFlag.problemAufgetreten => 'Problem aufgetreten',
      SpecialFlag.kontrolle => 'Kontrolle durchgeführt',
      SpecialFlag.fehlerKorrigiert => 'Fehler korrigiert',
      SpecialFlag.wiederholt => 'Wiederholt / geübt',
    };
  }
}
