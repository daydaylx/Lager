import 'occupation.dart';

enum IndustryProfile {
  moebelEinrichtung,
}

extension IndustryProfileDetails on IndustryProfile {
  String get label => switch (this) {
        IndustryProfile.moebelEinrichtung => 'Möbel & Einrichtung',
      };

  String get storageKey => switch (this) {
        IndustryProfile.moebelEinrichtung => 'moebel_einrichtung',
      };

  bool supportsOccupation(TrainingOccupation occupation) =>
      occupation == TrainingOccupation.kaufmannEinzelhandel;

  static IndustryProfile? fromStorageKey(String key) => switch (key) {
        'moebel_einrichtung' => IndustryProfile.moebelEinrichtung,
        _ => null,
      };
}
