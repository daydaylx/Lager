import 'models/adhoc_activity.dart';
import 'models/daily_entry.dart';
import 'data/default_activities.dart';
import 'models/activity_template.dart';

Map<String, String> buildActivityTitlesMap(
  Iterable<ActivityTemplate> customTemplates,
) =>
    {
      for (final a in defaultActivities) a.id: a.title,
      for (final a in customTemplates) a.id: a.title,
    };

/// Liefert die Titel-Map zum Auflösen der Tätigkeiten eines konkreten Eintrags.
///
/// Neben den Standard- und eigenen Tätigkeiten werden auch die einmaligen
/// ([AdhocActivity]) Tätigkeiten dieses Eintrags aufgenommen, damit sie im
/// generierten Bericht und in der Wochenzusammenfassung namentlich erscheinen.
Map<String, String> activityTitlesForEntry(
  DailyEntry entry,
  Iterable<ActivityTemplate> customTemplates,
) {
  return {
    ...buildActivityTitlesMap(customTemplates),
    for (final a in entry.adhocActivities) a.id: a.title,
  };
}
