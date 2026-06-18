import '../../core/enums/activity_category.dart';
import '../../core/models/activity_template.dart';

List<ActivityTemplate> computeRecommendedActivities(
  List<ActivityCategory> categories,
  Map<String, ActivityTemplate> activitiesById,
  Set<String> selectedIds,
  Set<String> excludedIds,
  int trainingYear,
) {
  final categorySet = categories.toSet();
  final candidates = activitiesById.values.indexed.where((entry) {
    final activity = entry.$2;
    return categorySet.contains(activity.category) &&
        activity.isActive &&
        !selectedIds.contains(activity.id) &&
        !excludedIds.contains(activity.id) &&
        trainingYearPriority(activity, trainingYear) == 0;
  }).toList(growable: false);

  candidates.sort((a, b) {
    final priorityA = trainingYearPriority(a.$2, trainingYear);
    final priorityB = trainingYearPriority(b.$2, trainingYear);
    if (priorityA != priorityB) return priorityA.compareTo(priorityB);
    return a.$1.compareTo(b.$1);
  });

  return candidates.take(4).map((entry) => entry.$2).toList(growable: false);
}

int trainingYearPriority(ActivityTemplate activity, int trainingYear) {
  final title = activity.title.toLowerCase();
  final category = activity.category;

  return switch (trainingYear) {
    1 => matchesAny(title, const [
          'angenommen',
          'geprüft',
          'beachtet',
          'vorbereitet',
          'aufgeräumt',
          'unter anleitung',
          'arbeitsanweisung',
          'grundlagen',
          'sicherheits',
        ])
          ? 0
          : category == ActivityCategory.sicherheit
              ? 0
              : 1,
    2 => matchesAny(title, const [
          'scanner',
          'system',
          'bestand',
          'kommissionier',
          'versand',
          'lagerplatz',
          'pick',
          'retoure',
        ])
          ? 0
          : 1,
    _ => matchesAny(title, const [
          'kennzahl',
          'inventur',
          'differenz',
          'system',
          'qualität',
          'abweichung',
          'prozess',
          'kontrolle',
        ])
          ? 0
          : category == ActivityCategory.inventur
              ? 0
              : 1,
  };
}

bool matchesAny(String value, List<String> needles) {
  return needles.any(value.contains);
}
