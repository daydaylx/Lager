import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'storage/preferences_write.dart';

typedef StoredProfile = ({
  String? name,
  String? company,
  String? occupation,
  int? trainingYear,
  bool onboardingCompleted,
});

class ProfileStorage {
  static Future<StoredProfile> load() async {
    final preferences = await SharedPreferences.getInstance();
    return (
      name: preferences.getString(PreferenceKeys.profileName),
      company: preferences.getString(PreferenceKeys.profileCompany),
      occupation: preferences.getString(PreferenceKeys.trainingOccupation),
      trainingYear: preferences.getInt(PreferenceKeys.trainingYear),
      onboardingCompleted:
          preferences.getBool(PreferenceKeys.onboardingCompleted) ?? false,
    );
  }

  static bool isOnboardingComplete(StoredProfile profile) {
    return profile.onboardingCompleted &&
        TrainingOccupationValues.all.contains(profile.occupation) &&
        TrainingYearValues.isValidForOccupation(
          profile.trainingYear,
          profile.occupation,
        );
  }

  static Future<void> save({
    String? name,
    String? company,
    required String occupation,
    required int trainingYear,
    bool completeOnboarding = false,
  }) async {
    if (!TrainingYearValues.isValidForOccupation(trainingYear, occupation)) {
      throw ArgumentError.value(
        trainingYear,
        'trainingYear',
        'Ausbildungsjahr passt nicht zum Ausbildungsberuf.',
      );
    }
    final preferences = await SharedPreferences.getInstance();

    await _writeOptionalString(
      preferences,
      key: PreferenceKeys.profileName,
      value: name,
    );
    await _writeOptionalString(
      preferences,
      key: PreferenceKeys.profileCompany,
      value: company,
    );
    await _requireWrite(
      preferences.setString(PreferenceKeys.trainingOccupation, occupation),
    );
    await _requireWrite(
      preferences.setInt(PreferenceKeys.trainingYear, trainingYear),
    );

    if (completeOnboarding) {
      await _requireWrite(
        preferences.setBool(PreferenceKeys.onboardingCompleted, true),
      );
    }
  }

  static Future<void> clearAll() async {
    final preferences = await SharedPreferences.getInstance();
    await requirePreferenceWrite(
      preferences.clear(),
      message: 'Lokale Einstellungen konnten nicht gelöscht werden.',
    );
  }

  static Future<void> _writeOptionalString(
    SharedPreferences preferences, {
    required String key,
    required String? value,
  }) async {
    await _requireWrite(
      value == null
          ? preferences.remove(key)
          : preferences.setString(key, value),
    );
  }

  static Future<void> _requireWrite(Future<bool> operation) async {
    await requirePreferenceWrite(
      operation,
      message: 'Profildaten konnten nicht gespeichert werden.',
    );
  }
}
