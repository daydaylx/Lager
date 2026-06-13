import '../enums/activity_category.dart';

class ActivityTemplate {
  final String id;
  final String title;
  final ActivityCategory category;
  final bool isCustom;
  final bool isActive;

  const ActivityTemplate({
    required this.id,
    required this.title,
    required this.category,
    this.isCustom = false,
    this.isActive = true,
  });

  ActivityTemplate copyWith({
    String? title,
    ActivityCategory? category,
    bool? isActive,
  }) {
    return ActivityTemplate(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      isCustom: isCustom,
      isActive: isActive ?? this.isActive,
    );
  }
}
