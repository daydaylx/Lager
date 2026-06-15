import 'package:hive_ce_flutter/hive_flutter.dart';
import '../models/activity_template.dart';
import 'activity_template_adapter.dart';
import 'activity_template_storage.dart';

class HiveActivityTemplateStorage implements ActivityTemplateStorage {
  static const String boxName = 'custom_templates';

  final Box<ActivityTemplate> _box;

  const HiveActivityTemplateStorage._(this._box);

  static Future<HiveActivityTemplateStorage> open() async {
    await Hive.initFlutter();
    return _openBox();
  }

  static Future<HiveActivityTemplateStorage> openAtPath(String path) async {
    Hive.init(path);
    return _openBox();
  }

  static Future<HiveActivityTemplateStorage> _openBox() async {
    if (!Hive.isAdapterRegistered(ActivityTemplateAdapter.adapterTypeId)) {
      Hive.registerAdapter<ActivityTemplate>(const ActivityTemplateAdapter());
    }

    final box = await Hive.openBox<ActivityTemplate>(boxName);
    return HiveActivityTemplateStorage._(box);
  }

  @override
  Future<List<ActivityTemplate>> loadCustom() async {
    return _box.values.toList();
  }

  @override
  Future<void> save(ActivityTemplate template) async {
    await _box.put(template.id, template);
  }

  @override
  Future<void> clearAll() async {
    await _box.clear();
    await _box.compact();
  }
}
