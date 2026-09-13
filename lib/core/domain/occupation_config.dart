import '../enums/activity_category.dart';
import '../enums/training_area.dart';
import 'industry_profile.dart';
import 'occupation.dart';

/// Berufsspezifische Konfiguration für Auswahl, Katalog und Empfehlungen.
/// Die gespeicherten Tagesdaten bleiben berufsunabhängig.
class OccupationConfig {
  final TrainingOccupation occupation;
  final List<TrainingArea> areas;
  final Map<TrainingArea, List<ActivityCategory>> categoriesByArea;
  final Set<ActivityCategory> activityCategories;
  final Set<String> activityIdPrefixes;
  final Set<String> excludedActivityIdPrefixes;
  final Set<String> quickAccessActivityIds;
  final Set<String> schoolTopicIds;
  final Map<Wahlqualifikation, List<String>> wahlqualifikationKeywords;
  final bool compactPicker;
  final Set<IndustryProfile> supportedIndustryProfiles;
  final Map<IndustryProfile, List<TrainingArea>> industryAreas;
  final Map<IndustryProfile, Map<TrainingArea, List<ActivityCategory>>>
      industryCategoriesByArea;

  const OccupationConfig({
    required this.occupation,
    required this.areas,
    required this.categoriesByArea,
    required this.activityCategories,
    required this.activityIdPrefixes,
    this.excludedActivityIdPrefixes = const {},
    this.quickAccessActivityIds = const {},
    this.schoolTopicIds = const {},
    this.wahlqualifikationKeywords = const {},
    this.compactPicker = false,
    this.supportedIndustryProfiles = const {},
    this.industryAreas = const {},
    this.industryCategoriesByArea = const {},
  });

  List<TrainingArea> areasFor(IndustryProfile? industry) {
    final result = [...areas];
    if (industry != null && supportedIndustryProfiles.contains(industry)) {
      result.addAll(industryAreas[industry] ?? const []);
    }
    return result.toSet().toList(growable: false);
  }

  List<ActivityCategory> categoriesForAreas(
    Set<TrainingArea> selectedAreas, {
    IndustryProfile? industry,
  }) {
    final result = <ActivityCategory>{};
    final branchCategories = industry == null
        ? const <TrainingArea, List<ActivityCategory>>{}
        : industryCategoriesByArea[industry] ??
            const <TrainingArea, List<ActivityCategory>>{};
    for (final area in selectedAreas) {
      result.addAll(categoriesByArea[area] ?? const []);
      result.addAll(branchCategories[area] ?? const []);
    }
    return result.toList(growable: false);
  }

  bool isActivityInOccupation(String id) =>
      activityIdPrefixes.any(id.startsWith) &&
      !excludedActivityIdPrefixes.any(id.startsWith);
}
