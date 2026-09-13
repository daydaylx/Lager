import '../../core/data/default_activities.dart';
import '../../core/domain/domain.dart';
import '../../core/enums/activity_category.dart';
import '../../core/enums/day_type.dart';
import '../../core/enums/training_area.dart';
import '../../core/models/activity_template.dart';
import '../../core/models/adhoc_activity.dart';
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
  final String? recommendationContext;
  final List<ActivityPickerGroup> groups;
  final List<String> unavailableSelectedIds;
  final int visibleActivityCount;

  const ActivityPickerModel({
    required this.categories,
    required this.activitiesById,
    required this.selectedActivities,
    required this.frequentActivities,
    required this.recommendedActivities,
    this.recommendationContext,
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
    required Map<String, bool> defaultOverrides,
    required List<AdhocActivity> adhocActivities,
    TrainingOccupation occupation = TrainingOccupation.fachkraftLagerlogistik,
    String? wahlqualifikation,
  }) {
    final occupationConfig = OccupationRegistry.configFor(occupation);
    final categories = _categoriesFor(dayType, selectedAreas, occupationConfig);
    final effectiveDefaults = [
      for (final activity in defaultActivities)
        _applyOverride(activity, defaultOverrides),
    ];
    final availableDefaults = effectiveDefaults.where((activity) {
      if (!occupationConfig.isActivityInOccupation(activity.id)) return false;
      if (activity.category == ActivityCategory.berufsschule &&
          occupation == TrainingOccupation.verkaeufer) {
        return occupationConfig.schoolTopicIds.contains(activity.id) &&
            _sellerSchoolTopicForYear(activity.id, trainingYear);
      }
      return occupationConfig.activityCategories.contains(activity.category);
    }).map((activity) {
      if (occupation == TrainingOccupation.verkaeufer &&
          activity.category == ActivityCategory.berufsschule) {
        // Berufsschulthemen werden nach Jahr angeboten; ihr Katalogstatus
        // beschreibt nicht, ob sie im betrieblichen Quick-Access erscheinen.
        return activity.copyWith(isActive: true);
      }
      return activity;
    }).toList(growable: false);
    final adhocTemplates = [
      for (final adhoc in adhocActivities)
        ActivityTemplate(
          id: adhoc.id,
          title: adhoc.title,
          category: categories.isNotEmpty
              ? categories.first
              : ActivityCategory.sicherheit,
          isCustom: true,
          isActive: true,
        ),
    ];
    final activitiesById = {
      for (final activity in effectiveDefaults) activity.id: activity,
      for (final activity in customTemplates) activity.id: activity,
      for (final activity in adhocTemplates) activity.id: activity,
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
    final pickerActivitiesById = {
      for (final activity in availableDefaults) activity.id: activity,
      for (final activity in customTemplates)
        if (occupationConfig.isActivityInOccupation(activity.id))
          activity.id: activity,
      for (final activity in adhocTemplates) activity.id: activity,
    };
    final frequentActivities = hasSearch
        ? const <ActivityTemplate>[]
        : computeFrequentActivities(
            categories,
            pickerActivitiesById,
            frequentActivityIds,
            selectedActivityIds,
          );
    final frequentIds = frequentActivities.map((a) => a.id).toSet();
    final selectedWahlqualifikation = wahlqualifikation == null
        ? null
        : WahlqualifikationDetails.fromStorageKey(wahlqualifikation);
    final preferredKeywords = selectedWahlqualifikation == null
        ? const <String>[]
        : (occupationConfig
                .wahlqualifikationKeywords[selectedWahlqualifikation] ??
            const <String>[]);
    final recommendedActivities = !hasSearch && trainingYear != null
        ? computeRecommendedActivities(
            categories,
            pickerActivitiesById,
            selectedActivityIds,
            frequentIds,
            trainingYear,
            preferredKeywords: preferredKeywords,
          )
        : const <ActivityTemplate>[];
    final recommendationContext = occupation == TrainingOccupation.verkaeufer &&
            selectedWahlqualifikation != null
        ? 'Wahlqualifikation: ${selectedWahlqualifikation.label}'
        : trainingYear == null
            ? null
            : '$trainingYear. Ausbildungsjahr';
    final hiddenQuickAccessIds = {
      ...frequentIds,
      ...recommendedActivities.map((a) => a.id),
    };

    var visibleActivityCount =
        frequentActivities.length + recommendedActivities.length;
    final groups = <ActivityPickerGroup>[];

    // Einmalige Tätigkeiten dieses Tages in einer eigenen Gruppe zeigen.
    final visibleAdhoc = _sortSelectedFirst(
      adhocTemplates
          .where((activity) => _matchesActivitySearch(activity, searchQuery))
          .toList(growable: false),
      selectedActivityIds,
    );
    visibleActivityCount += visibleAdhoc.length;
    if (visibleAdhoc.isNotEmpty) {
      groups.add(
        ActivityPickerGroup(
          title: 'Nur heute hinzugefügt',
          activities: visibleAdhoc,
          markAsCustom: true,
        ),
      );
    }

    for (final category in categories) {
      final defaults = _sortSelectedFirst(
        availableDefaults
            .where(
              (activity) =>
                  activity.category == category &&
                  _isDefaultVisible(
                    activity,
                    occupation,
                    occupationConfig,
                    defaultOverrides,
                    selectedActivityIds,
                  ) &&
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
                  occupationConfig.isActivityInOccupation(activity.id) &&
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
      recommendationContext: recommendationContext,
      groups: groups,
      unavailableSelectedIds: unavailableSelectedIds,
      visibleActivityCount: visibleActivityCount,
    );
  }

  static ActivityTemplate _applyOverride(
    ActivityTemplate activity,
    Map<String, bool> overrides,
  ) {
    if (!isSelectableDefaultActivity(activity)) {
      return activity.isActive ? activity.copyWith(isActive: false) : activity;
    }
    final override = overrides[activity.id];
    if (override == null || override == activity.isActive) return activity;
    return activity.copyWith(isActive: override);
  }

  static bool _isDefaultVisible(
    ActivityTemplate activity,
    TrainingOccupation occupation,
    OccupationConfig config,
    Map<String, bool> overrides,
    Set<String> selectedIds,
  ) {
    if (selectedIds.contains(activity.id)) return true;
    if (!activity.isActive) return false;
    if (occupation != TrainingOccupation.verkaeufer) return true;
    // Berufsschulthemen werden fachlich über das Ausbildungsjahr begrenzt,
    // nicht über den betrieblichen Quick-Access-Katalog.
    if (activity.category == ActivityCategory.berufsschule) return true;
    return config.quickAccessActivityIds.contains(activity.id) ||
        overrides[activity.id] == true;
  }

  static List<ActivityCategory> _categoriesFor(
    DayType dayType,
    Set<TrainingArea> selectedAreas,
    OccupationConfig config,
  ) {
    return switch (dayType) {
      DayType.betrieb => <ActivityCategory>{
          ...config.categoriesForAreas(selectedAreas),
          if (config.occupation == TrainingOccupation.verkaeufer)
            ActivityCategory.allgemein,
          if (config.occupation != TrainingOccupation.verkaeufer)
            ActivityCategory.sicherheit,
        }.toList(growable: false),
      DayType.berufsschule => [ActivityCategory.berufsschule],
      _ => <ActivityCategory>[],
    };
  }

  static bool _sellerSchoolTopicForYear(String id, int? year) {
    if (year == null) return true;
    final number = int.tryParse(id.split('_').last);
    if (number == null) return true;
    return year == 1 ? number <= 8 : number >= 9;
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
