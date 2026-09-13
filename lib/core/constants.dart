import 'domain/domain.dart';

// Versionskonstante statt PackageInfo: kein zusätzliches Plugin, deterministisch
// in Tests, CI-Fehler bei Drift (test/version_consistency_test.dart).
const String kAppVersion = '1.0.0';

class AppStrings {
  static const String appName = 'Berichtsheft-Merker';
  static const String tabToday = 'Heute';
  static const String tabWeek = 'Woche';
  static const String tabTemplates = 'Vorlagen';
  static const String tabProfile = 'Profil';
}

class PreferenceKeys {
  static const String onboardingCompleted = 'onboarding_completed';
  static const String profileName = 'profile_name';
  static const String profileCompany = 'profile_company';
  static const String trainingOccupation = 'training_occupation';
  static const String trainingYear = 'training_year';
  static const String wahlqualifikation = 'wahlqualifikation';
  static const String wahlqualifikationen = 'wahlqualifikationen';
  static const String industryProfile = 'industry_profile';
  static const String reminderEnabled = 'reminder_enabled';
  static const String reminderTimes = 'reminder_times';
  static const String reminderWeekdays = 'reminder_weekdays';
  static const String reminderSettingsV2 = 'reminder_settings_v2';
  static const String defaultActivityOverrides = 'default_activity_overrides';
}

/// Kompatibilitäts-Layer: Liefert Storage-Keys für alle Berufe.
///
/// Neu: Delegiert an [TrainingOccupation] Enum.
class TrainingOccupationValues {
  static const String fachlagerist = 'fachlagerist';
  static const String fachkraftLagerlogistik = 'fachkraft_lagerlogistik';
  static const String verkaeufer = 'verkaeufer';
  static const String kaufmannEinzelhandel = 'kaufmann_einzelhandel';
  static const List<String> all = [
    fachlagerist,
    fachkraftLagerlogistik,
    verkaeufer,
    kaufmannEinzelhandel,
  ];

  /// Konvertiert Storage-Key in TrainingOccupation Enum.
  static TrainingOccupation? parse(String? key) {
    if (key == null) return null;
    return TrainingOccupationDetails.fromStorageKey(key);
  }
}

/// Lesbarer Ausbildungsberuf für einen gespeicherten occupation-String.
extension TrainingOccupationLabel on String? {
  String get occupationLabel {
    final occupation = TrainingOccupationValues.parse(this);
    if (occupation == null) return 'Ausbildung noch nicht ausgewählt';
    return occupation.label;
  }
}

/// Gültige Ausbildungsjahre pro Beruf.
///
/// Neu: Delegiert an [TrainingOccupation] Enum.
class TrainingYearValues {
  static const List<int> all = [1, 2, 3];

  static List<int> forOccupation(String? occupation) {
    final parsed = TrainingOccupationValues.parse(occupation);
    if (parsed == null) return all;
    return parsed.validYears;
  }

  static bool isValidForOccupation(int? year, String? occupation) {
    if (year == null) return false;
    final parsed = TrainingOccupationValues.parse(occupation);
    if (parsed == null) return all.contains(year);
    return parsed.isValidYear(year);
  }
}