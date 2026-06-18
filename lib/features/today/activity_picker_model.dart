import '../../core/data/default_activities.dart';
import '../../core/enums/activity_category.dart';
import '../../core/enums/day_type.dart';
import '../../core/enums/training_area.dart';
import '../../core/models/activity_template.dart';
import 'activity_recommender.dart';

class ActivityPickerGroup {
  final String title;
  final List<ActivityTemplate> activities;
  final bool markAsCustom;

  const ActivityPickerGroup({
    required this.title,
    required this.activities,
    this.markAsCustom = false,
  });
}

class ActivityPickerModel {
  final List<ActivityCategory> categories;
  final Map<String, ActivityTemplate> activitiesById;
  final List<ActivityTemplate> selectedActivities;
  final List<ActivityTemplate> frequentActivities;
  final List<ActivityTemplate> recommendedActivities;
  final List<ActivityPickerGroup> groups;
  final List<String> unavailableSelectedIds;
  final int visibleActivityCount;

  const ActivityPickerModel({
    required this.categories,
    required this.activitiesById,
    required this.selectedActivities,
    required this.frequentActivities,
    required this.recommendedActivities,
    required this.groups,
    required this.unavailableSelectedIds,
    required this.visibleActivityCount,
  });

  bool get hasVisibleActivities => visibleActivityCount > 0;

  factory ActivityPickerModel.build({
    required DayType dayType,
    required Set<TrainingArea> selectedAreas,
    required Set<String> selectedActivityIds,
    required List<ActivityTemplate> customTemplates,
    required List<String> frequentActivityIds,
    required String searchQuery,
    required int? trainingYear,
  }) {
    final categories = _categoriesFor(dayType, selectedAreas);
    final activitiesById = {
      for (final activity in defaultActivities) activity.id: activity,
      for (final activity in customTemplates) activity.id: activity,
    };
    final knownActivityIds = activitiesById.keys.toSet();
    final unavailableSelectedIds = selectedActivityIds
        .where((id) => !knownActivityIds.contains(id))
        .toList(growable: false);
    final selectedActivities = selectedActivityIds
        .map((id) => activitiesById[id])
        .whereType<ActivityTemplate>()
        .toList(growable: false);
    final hasSearch = searchQuery.trim().isNotEmpty;
    final frequentActivities = hasSearch
        ? const <ActivityTemplate>[]
        : computeFrequentActivities(
            categories,
            activitiesById,
            frequentActivityIds,
            selectedActivityIds,
          );
    final frequentIds = frequentActivities.map((a) => a.id).toSet();
    final recommendedActivities = !hasSearch && trainingYear != null
        ? computeRecommendedActivities(
            categories,
            activitiesById,
            selectedActivityIds,
            frequentIds,
            trainingYear,
          )
        : const <ActivityTemplate>[];
    final hiddenQuickAccessIds = {
      ...frequentIds,
      ...recommendedActivities.map((a) => a.id),
    };

    var visibleActivityCount =
        frequentActivities.length + recommendedActivities.length;
    final groups = <ActivityPickerGroup>[];
    for (final category in categories) {
      final defaults = _sortSelectedFirst(
        defaultActivities
            .where(
              (activity) =>
                  activity.category == category &&
                  _showInCategoryGroup(
                    activity,
                    hiddenQuickAccessIds,
                    searchQuery,
                    selectedActivityIds,
                  ) &&
                  _matchesActivitySearch(activity, searchQuery),
            )
            .toList(growable: false),
        selectedActivityIds,
      );
      final custom = _sortSelectedFirst(
        customTemplates
            .where(
              (activity) =>
                  activity.category == category &&
                  (activity.isActive ||
                      selectedActivityIds.contains(activity.id)) &&
                  _showInCategoryGroup(
                    activity,
                    hiddenQuickAccessIds,
                    searchQuery,
                    selectedActivityIds,
                  ) &&
                  _matchesActivitySearch(activity, searchQuery),
            )
            .toList(growable: false),
        selectedActivityIds,
      );
      visibleActivityCount += defaults.length + custom.length;
      if (defaults.isNotEmpty) {
        groups.add(
          ActivityPickerGroup(
            title: category.label,
            activities: defaults,
          ),
        );
      }
      if (custom.isNotEmpty) {
        groups.add(
          ActivityPickerGroup(
            title: 'Eigene Tätigkeiten',
            activities: custom,
            markAsCustom: true,
          ),
        );
      }
    }

    return ActivityPickerModel(
      categories: categories,
      activitiesById: activitiesById,
      selectedActivities: selectedActivities,
      frequentActivities: frequentActivities,
      recommendedActivities: recommendedActivities,
      groups: groups,
      unavailableSelectedIds: unavailableSelectedIds,
      visibleActivityCount: visibleActivityCount,
    );
  }

  static List<ActivityCategory> _categoriesFor(
    DayType dayType,
    Set<TrainingArea> selectedAreas,
  ) {
    return switch (dayType) {
      DayType.betrieb => <ActivityCategory>{
          ...selectedAreas.map((a) => a.activityCategory),
          ActivityCategory.sicherheit,
        }.toList(growable: false),
      DayType.berufsschule => [ActivityCategory.berufsschule],
      _ => <ActivityCategory>[],
    };
  }

  static bool _matchesActivitySearch(
    ActivityTemplate activity,
    String searchQuery,
  ) {
    final query = searchQuery.trim().toLowerCase();
    return query.isEmpty ||
        activity.title.toLowerCase().contains(query) ||
        activity.category.label.toLowerCase().contains(query);
  }

  static List<ActivityTemplate> _sortSelectedFirst(
    List<ActivityTemplate> activities,
    Set<String> selectedActivityIds,
  ) {
    final selected = activities
        .where((activity) => selectedActivityIds.contains(activity.id))
        .toList(growable: false);
    final unselected = activities
        .where((activity) => !selectedActivityIds.contains(activity.id))
        .toList(growable: false);
    return [...selected, ...unselected];
  }

  static bool _showInCategoryGroup(
    ActivityTemplate activity,
    Set<String> hiddenQuickAccessIds,
    String searchQuery,
    Set<String> selectedActivityIds,
  ) {
    if (searchQuery.trim().isNotEmpty) return true;
    return !hiddenQuickAccessIds.contains(activity.id) ||
        selectedActivityIds.contains(activity.id);
  }
}

Set<String> activityIdsForCategory(
  ActivityCategory category,
  List<ActivityTemplate> customTemplates,
) {
  return {
    ...defaultActivities
        .where((activity) => activity.category == category)
        .map((activity) => activity.id),
    ...customTemplates
        .where((activity) => activity.category == category)
        .map((activity) => activity.id),
  };
}
