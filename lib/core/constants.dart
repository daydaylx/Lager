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
  static const String reminderEnabled = 'reminder_enabled';
  static const String reminderTimes = 'reminder_times';
  static const String reminderWeekdays = 'reminder_weekdays';
}

class TrainingOccupationValues {
  static const String fachlagerist = 'fachlagerist';
  static const String fachkraftLagerlogistik = 'fachkraft_lagerlogistik';

  static const List<String> all = [
    fachlagerist,
    fachkraftLagerlogistik,
  ];
}

class TrainingYearValues {
  static const List<int> all = [1, 2, 3];
}
