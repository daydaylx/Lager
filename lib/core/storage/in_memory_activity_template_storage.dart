import '../models/activity_template.dart';
import 'activity_template_storage.dart';

class InMemoryActivityTemplateStorage implements ActivityTemplateStorage {
  final Map<String, ActivityTemplate> _templates;

  InMemoryActivityTemplateStorage({
    Iterable<ActivityTemplate> initialTemplates = const [],
  }) : _templates = {
          for (final t in initialTemplates) t.id: t,
        };

  @override
  Future<List<ActivityTemplate>> loadCustom() async {
    return _templates.values.toList();
  }

  @override
  Future<void> save(ActivityTemplate template) async {
    _templates[template.id] = template;
  }

  @override
  Future<void> delete(String id) async {
    _templates.remove(id);
  }
}
