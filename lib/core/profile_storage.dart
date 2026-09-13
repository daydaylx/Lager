import 'dart:convert';

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
  List<String> wahlqualifikationen,
  String? industryProfile,
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
      wahlqualifikationen: _loadWahlqualifikationen(preferences),
      industryProfile: _loadIndustryProfile(preferences),
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
    if (occupation == TrainingOccupation.verkaeufer) {
      return WahlqualifikationDetails.fromStorageKey(
            profile.wahlqualifikation ?? '',
          ) !=
          null;
    }
    if (occupation == TrainingOccupation.kaufmannEinzelhandel) {
      return _hasValidEinzelhandelWahlqualifikationen(
        profile.wahlqualifikationen,
      );
    }
    return true;
  }

  static Future<void> save({
    String? name,
    String? company,
    required String occupation,
    required int trainingYear,
    String? wahlqualifikation,
    List<String> wahlqualifikationen = const [],
    String? industryProfile,
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
    if (occupationValue == TrainingOccupation.verkaeufer &&
        WahlqualifikationDetails.fromStorageKey(wahlqualifikation ?? '') ==
            null) {
      throw ArgumentError.value(
        wahlqualifikation,
        'wahlqualifikation',
        'Verkäufer/in benötigt eine Wahlqualifikation.',
      );
    }
    final normalizedEinzelhandelWahlqualifikationen =
        _normalizeEinzelhandelWahlqualifikationen(wahlqualifikationen);
    if (occupationValue == TrainingOccupation.kaufmannEinzelhandel &&
        !_hasValidEinzelhandelWahlqualifikationen(
          normalizedEinzelhandelWahlqualifikationen,
        )) {
      throw ArgumentError.value(
        wahlqualifikationen,
        'wahlqualifikationen',
        'Kaufmann/-frau im Einzelhandel benötigt drei passende Wahlqualifikationen, darunter eine der ersten drei.',
      );
    }
    final parsedIndustry = industryProfile == null
        ? null
        : IndustryProfileDetails.fromStorageKey(industryProfile);
    if (parsedIndustry != null &&
        (occupationValue == null ||
            !parsedIndustry.supportsOccupation(occupationValue))) {
      throw ArgumentError.value(
        industryProfile,
        'industryProfile',
        'Das Branchenprofil passt nicht zum Ausbildungsberuf.',
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

    if (occupationValue == TrainingOccupation.verkaeufer) {
      await _writeOptionalString(
        preferences,
        key: PreferenceKeys.wahlqualifikation,
        value: wahlqualifikation,
      );
      await _remove(preferences, PreferenceKeys.wahlqualifikationen);
      await _remove(preferences, PreferenceKeys.industryProfile);
    } else if (occupationValue == TrainingOccupation.kaufmannEinzelhandel) {
      await _remove(preferences, PreferenceKeys.wahlqualifikation);
      await _requireWrite(
        preferences.setString(
          PreferenceKeys.wahlqualifikationen,
          jsonEncode(normalizedEinzelhandelWahlqualifikationen),
        ),
      );
      await _writeOptionalString(
        preferences,
        key: PreferenceKeys.industryProfile,
        value: parsedIndustry?.storageKey,
      );
    } else {
      await _remove(preferences, PreferenceKeys.wahlqualifikation);
      await _remove(preferences, PreferenceKeys.wahlqualifikationen);
      await _remove(preferences, PreferenceKeys.industryProfile);
    }

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

  static List<String> _loadWahlqualifikationen(
    SharedPreferences preferences,
  ) {
    final raw = preferences.getString(PreferenceKeys.wahlqualifikationen);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return _normalizeEinzelhandelWahlqualifikationen(
        decoded.whereType<String>().toList(growable: false),
      );
    } catch (_) {
      return const [];
    }
  }

  static String? _loadIndustryProfile(SharedPreferences preferences) {
    final raw = preferences.getString(PreferenceKeys.industryProfile);
    if (raw == null) return null;
    return IndustryProfileDetails.fromStorageKey(raw)?.storageKey;
  }

  static List<String> _normalizeEinzelhandelWahlqualifikationen(
    Iterable<String> keys,
  ) {
    final valid = <String>{};
    for (final key in keys) {
      if (EinzelhandelWahlqualifikationDetails.fromStorageKey(key) != null) {
        valid.add(key);
      }
    }
    return valid.toList(growable: false)..sort();
  }

  static bool _hasValidEinzelhandelWahlqualifikationen(
    Iterable<String> keys,
  ) {
    final normalized = _normalizeEinzelhandelWahlqualifikationen(keys);
    if (normalized.length != 3) return false;
    const requiredGroup = {
      'beratungKomplexeSituationen',
      'beschaffungWaren',
      'warenbestandssteuerung',
    };
    return normalized.any(requiredGroup.contains);
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

  static Future<void> _remove(
    SharedPreferences preferences,
    String key,
  ) async {
    await _requireWrite(preferences.remove(key));
  }

  static Future<void> _requireWrite(Future<bool> operation) async {
    await requirePreferenceWrite(
      operation,
      message: 'Profildaten konnten nicht gespeichert werden.',
    );
  }
}
