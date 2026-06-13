import '../enums/activity_category.dart';

class ActivityTemplate {
  final String id;
  final String title;
  final ActivityCategory category;

  const ActivityTemplate({
    required this.id,
    required this.title,
    required this.category,
  });
}
