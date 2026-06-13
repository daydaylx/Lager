import '../models/activity_template.dart';

abstract class ActivityTemplateStorage {
  Future<List<ActivityTemplate>> loadCustom();
  Future<void> save(ActivityTemplate template);

  Future<void> clearAll();
}
