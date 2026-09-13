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
  // Verkäufer-Kategorien: nur an das Enum anhängen, da Namen persistiert werden.
  verkaufsflaeche,
  kundenberatung,
  kasse,
  warenpraesentation,
  wareneingangVerkauf,
  lagerBestand,
  reklamationService,
  werbungVerkaufsfoerderung,
  preis,
  allgemein,
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
      ActivityCategory.sicherheit => 'Ordnung / Qualität / Unterweisung',
      ActivityCategory.verkaufsflaeche => 'Verkaufsfläche',
      ActivityCategory.kundenberatung => 'Kundenberatung & Verkauf',
      ActivityCategory.kasse => 'Kasse & Zahlungsverkehr',
      ActivityCategory.warenpraesentation => 'Warenpräsentation',
      ActivityCategory.wareneingangVerkauf => 'Warenannahme',
      ActivityCategory.lagerBestand => 'Lager & Warenbestand',
      ActivityCategory.reklamationService => 'Reklamation & Service',
      ActivityCategory.werbungVerkaufsfoerderung =>
        'Werbung & Verkaufsförderung',
      ActivityCategory.preis => 'Preiskalkulation & Preisauszeichnung',
      ActivityCategory.allgemein => 'Sicherheit & betriebliche Organisation',
    };
  }
}
