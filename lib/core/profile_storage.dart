import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'domain/domain.dart';
import 'storage/preferences_write.dart';

typedef StoredProfile = ({
  String? name,
  String? company,
  String? occupation,
  int? trainingYear,
  String? wahlqualifikation,
  List<String> vertiefungswahlqualifikationen,
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
      wahlqualifikation:
          preferences.getString(PreferenceKeys.wahlqualifikation),
      vertiefungswahlqualifikationen: preferences.getStringList(
            PreferenceKeys.vertiefungswahlqualifikationen,
          ) ??
          const <String>[],
      onboardingCompleted:
          preferences.getBool(PreferenceKeys.onboardingCompleted) ?? false,
    );
  }

  static bool isOnboardingComplete(StoredProfile profile) {
    final occupation = TrainingOccupationValues.parse(profile.occupation);
    if (!profile.onboardingCompleted ||
        occupation == null ||
        !TrainingYearValues.isValidForOccupation(
          profile.trainingYear,
          profile.occupation,
        )) {
      return false;
    }
    if (occupation.usesRetailCatalog &&
        WahlqualifikationDetails.fromStorageKey(
              profile.wahlqualifikation ?? '',
            ) ==
            null) {
      return false;
    }
    return occupation != TrainingOccupation.kaufmannEinzelhandel ||
        EinzelhandelVertiefungsqualifikationDetails.isValidSelection(
          profile.vertiefungswahlqualifikationen,
        );
  }

  static Future<void> save({
    String? name,
    String? company,
    required String occupation,
    required int trainingYear,
    String? wahlqualifikation,
    List<String> vertiefungswahlqualifikationen = const [],
    bool completeOnboarding = false,
  }) async {
    if (!TrainingYearValues.isValidForOccupation(trainingYear, occupation)) {
      throw ArgumentError.value(
        trainingYear,
        'trainingYear',
        'Ausbildungsjahr passt nicht zum Ausbildungsberuf.',
      );
    }
    final occupationValue = TrainingOccupationValues.parse(occupation);
    if (occupationValue == null) {
      throw ArgumentError.value(
        occupation,
        'occupation',
        'Unbekannter Ausbildungsberuf.',
      );
    }
    if (occupationValue.usesRetailCatalog &&
        WahlqualifikationDetails.fromStorageKey(wahlqualifikation ?? '') ==
            null) {
      throw ArgumentError.value(
        wahlqualifikation,
        'wahlqualifikation',
        'Einzelhandelsprofile benötigen eine Grund-Wahlqualifikation.',
      );
    }
    if (occupationValue == TrainingOccupation.kaufmannEinzelhandel &&
        !EinzelhandelVertiefungsqualifikationDetails.isValidSelection(
          vertiefungswahlqualifikationen,
        )) {
      throw ArgumentError.value(
        vertiefungswahlqualifikationen,
        'vertiefungswahlqualifikationen',
        'Kaufmann/Kauffrau benötigt drei gültige Vertiefungswahlqualifikationen, darunter mindestens eine aus den ersten drei.',
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
    await _writeOptionalString(
      preferences,
      key: PreferenceKeys.wahlqualifikation,
      value: occupationValue.usesRetailCatalog ? wahlqualifikation : null,
    );
    await _requireWrite(
      occupationValue == TrainingOccupation.kaufmannEinzelhandel
          ? preferences.setStringList(
              PreferenceKeys.vertiefungswahlqualifikationen,
              vertiefungswahlqualifikationen,
            )
          : preferences.remove(
              PreferenceKeys.vertiefungswahlqualifikationen,
            ),
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
