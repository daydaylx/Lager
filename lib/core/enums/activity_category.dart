enum ActivityCategory {
  wareneingang,
  einlagerung,
  transport,
  kommissionierung,
  verpackung,
  versand,
  inventur,
  retouren,
  berufsschule,
  sicherheit,
}

extension ActivityCategoryLabel on ActivityCategory {
  String get label {
    return switch (this) {
      ActivityCategory.wareneingang => 'Wareneingang',
      ActivityCategory.einlagerung => 'Einlagerung / Lagerung',
      ActivityCategory.transport => 'Innerbetrieblicher Transport',
      ActivityCategory.kommissionierung => 'Kommissionierung',
      ActivityCategory.verpackung => 'Verpackung',
      ActivityCategory.versand => 'Versand / Verladung',
      ActivityCategory.inventur => 'Bestandskontrolle / Inventur',
      ActivityCategory.retouren => 'Retouren / Reklamation',
      ActivityCategory.berufsschule => 'Berufsschule',
      ActivityCategory.sicherheit => 'Sicherheit / Ordnung / Qualität',
    };
  }
}
