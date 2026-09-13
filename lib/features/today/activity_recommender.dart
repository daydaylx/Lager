import '../../core/domain/activity_catalog_metadata.dart';
import '../../core/domain/industry_profile.dart';
import '../../core/domain/occupation.dart';
import '../../core/enums/activity_category.dart';
import '../../core/enums/day_type.dart';
import '../../core/models/activity_template.dart';
import '../../core/models/daily_entry.dart';

List<ActivityTemplate> computeRecommendedActivities(
  List<ActivityCategory> categories,
  Map<String, ActivityTemplate> activitiesById,
  Set<String> selectedIds,
  Set<String> excludedIds,
  int trainingYear, {
  List<String> preferredKeywords = const [],
  IndustryProfile? industryProfile,
  List<EinzelhandelWahlqualifikation> einzelhandelWahlqualifikationen =
      const [],
}) {
  final categorySet = categories.toSet();
  final candidates = activitiesById.values.indexed.where((entry) {
    final activity = entry.$2;
    final metadata = activityMetadataFor(activity.id);
    final industryMatches = metadata.industryProfileKeys.isEmpty ||
        metadata.isForIndustry(industryProfile);
    return categorySet.contains(activity.category) &&
        activity.isActive &&
        !selectedIds.contains(activity.id) &&
        !excludedIds.contains(activity.id) &&
        metadata.isAvailableForYear(trainingYear) &&
        industryMatches &&
        (trainingYearPriority(activity, trainingYear) == 0 ||
            matchesAny(activity.title.toLowerCase(), preferredKeywords) ||
            metadata.preferredTrainingYear == trainingYear ||
            metadata.matchesWahlqualifikation(
              einzelhandelWahlqualifikationen,
            ));
  }).toList(growable: false);

  candidates.sort((a, b) {
    final priorityA = _combinedPriority(
      a.$2,
      trainingYear,
      preferredKeywords,
      industryProfile,
      einzelhandelWahlqualifikationen,
    );
    final priorityB = _combinedPriority(
      b.$2,
      trainingYear,
      preferredKeywords,
      industryProfile,
      einzelhandelWahlqualifikationen,
    );
    if (priorityA != priorityB) return priorityA.compareTo(priorityB);
    return a.$1.compareTo(b.$1);
  });

  return candidates.take(4).map((entry) => entry.$2).toList(growable: false);
}

int _combinedPriority(
  ActivityTemplate activity,
  int trainingYear,
  List<String> preferredKeywords,
  IndustryProfile? industryProfile,
  List<EinzelhandelWahlqualifikation> einzelhandelWahlqualifikationen,
) {
  final metadata = activityMetadataFor(activity.id);
  var priority = trainingYearPriority(activity, trainingYear) + 1;
  if (metadata.preferredTrainingYear == trainingYear) priority--;
  if (metadata.isForIndustry(industryProfile)) priority -= 2;
  if (metadata.matchesWahlqualifikation(einzelhandelWahlqualifikationen)) {
    priority -= 2;
  }
  if (matchesAny(activity.title.toLowerCase(), preferredKeywords)) priority -= 2;
  return priority < 0 ? 0 : priority;
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

List<String> computeFrequentActivityIds(List<DailyEntry> entries) {
  final counts = <String, int>{};
  final lastUsed = <String, DateTime>{};
  for (final entry in entries) {
    if (!entry.dayType.supportsActivities) continue;
    for (final id in entry.selectedActivities) {
      counts[id] = (counts[id] ?? 0) + 1;
      final previous = lastUsed[id];
      if (previous == null || entry.date.isAfter(previous)) {
        lastUsed[id] = entry.date;
      }
    }
  }
  final ids = counts.keys.toList(growable: false)
    ..sort((a, b) {
      final countCompare = counts[b]!.compareTo(counts[a]!);
      if (countCompare != 0) return countCompare;
      final dateCompare = lastUsed[b]!.compareTo(lastUsed[a]!);
      if (dateCompare != 0) return dateCompare;
      return a.compareTo(b);
    });
  return ids;
}

List<ActivityTemplate> computeFrequentActivities(
  List<ActivityCategory> categories,
  Map<String, ActivityTemplate> activitiesById,
  List<String> frequentActivityIds,
  Set<String> selectedIds,
) {
  final categorySet = categories.toSet();
  final frequent = <ActivityTemplate>[];
  for (final id in frequentActivityIds) {
    final activity = activitiesById[id];
    if (activity == null || !categorySet.contains(activity.category)) {
      continue;
    }
    if (selectedIds.contains(activity.id)) {
      continue;
    }
    if (!activity.isActive && !selectedIds.contains(activity.id)) {
      continue;
    }
    if (frequent.any((item) => item.id == activity.id)) {
      continue;
    }
    frequent.add(activity);
    if (frequent.length == 6) break;
  }
  return frequent;
}
