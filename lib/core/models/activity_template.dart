import '../enums/activity_category.dart';

class ActivityTemplate {
  final String id;
  final String title;
  final ActivityCategory category;
  final bool isCustom;

  const ActivityTemplate({
    required this.id,
    required this.title,
    required this.category,
    this.isCustom = false,
  });
}
