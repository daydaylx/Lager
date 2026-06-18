import 'data/default_activities.dart';
import 'models/activity_template.dart';

Map<String, String> buildActivityTitlesMap(
  Iterable<ActivityTemplate> customTemplates,
) => {
      for (final a in defaultActivities) a.id: a.title,
      for (final a in customTemplates) a.id: a.title,
    };
