import '../enums/activity_category.dart';
import '../enums/training_area.dart';
import 'occupation.dart';

/// Berufsspezifische Konfiguration für Auswahl, Katalog und Empfehlungen.
/// Die gespeicherten Tagesdaten bleiben berufsunabhängig.
class OccupationConfig {
  final TrainingOccupation occupation;
  final List<TrainingArea> areas;
  final Map<TrainingArea, List<ActivityCategory>> categoriesByArea;
  final Set<ActivityCategory> activityCategories;
  final String activityIdPrefix;
  final Set<String> quickAccessActivityIds;
  final Set<String> schoolTopicIds;
  final Map<Wahlqualifikation, List<String>> wahlqualifikationKeywords;

  const OccupationConfig({
    required this.occupation,
    required this.areas,
    required this.categoriesByArea,
    required this.activityCategories,
    required this.activityIdPrefix,
    this.quickAccessActivityIds = const {},
    this.schoolTopicIds = const {},
    this.wahlqualifikationKeywords = const {},
  });

  List<ActivityCategory> categoriesForAreas(Set<TrainingArea> selectedAreas) {
    final result = <ActivityCategory>{};
    for (final area in selectedAreas) {
      result.addAll(categoriesByArea[area] ?? const []);
    }
    return result.toList(growable: false);
  }

  bool isActivityInOccupation(String id) => activityIdPrefix.isEmpty
      ? !id.startsWith('verkauf_')
      : id.startsWith(activityIdPrefix);
}
