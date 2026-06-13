import '../models/activity_template.dart';

abstract class ActivityTemplateStorage {
  Future<List<ActivityTemplate>> loadCustom();
  Future<void> save(ActivityTemplate template);
  Future<void> delete(String id);

  Future<void> clearAll();
}
