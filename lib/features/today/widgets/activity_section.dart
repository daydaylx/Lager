import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/data/activity_subcategories.dart';
import '../../../core/models/activity_template.dart';
import '../../../shared/widgets/app_ui.dart';

class SelectedActivitiesBar extends StatelessWidget {
  final List<ActivityTemplate> activities;
  final ValueChanged<String> onRemove;

  const SelectedActivitiesBar({
    super.key,
    required this.activities,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ausgewählt',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: activities
                .map(
                  (activity) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InputChip(
                      key: ValueKey('selected_activity_${activity.id}'),
                      label: Text(activity.title),
                      onDeleted: () => onRemove(activity.id),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ],
    );
  }
}

class ActivityGroup extends StatelessWidget {
  final String title;
  final List<ActivityTemplate> activities;
  final Set<String> selectedActivityIds;
  final ValueChanged<String> onToggle;
  final bool markAsCustom;

  const ActivityGroup({
    super.key,
    required this.title,
    required this.activities,
    required this.selectedActivityIds,
    required this.onToggle,
    this.markAsCustom = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = <Widget>[];
    String? previousSubcategory;

    for (final entry in activities.indexed) {
      final index = entry.$1;
      final activity = entry.$2;
      final subcategory = activitySubcategory(activity);
      if (subcategory != null && subcategory != previousSubcategory) {
        rows.add(ActivitySubcategoryHeader(subcategory));
        previousSubcategory = subcategory;
      }
      rows.add(
        ActivityRow(
          activity: activity,
          isLast: index == activities.length - 1,
          isSelected: selectedActivityIds.contains(activity.id),
          markAsCustom: markAsCustom,
          onToggle: onToggle,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(title: title),
        const SizedBox(height: 8),
        Material(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: Column(children: rows),
        ),
      ],
    );
  }
}

class ActivitySubcategoryHeader extends StatelessWidget {
  final String title;

  const ActivitySubcategoryHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class ActivityRow extends StatelessWidget {
  final ActivityTemplate activity;
  final bool isLast;
  final bool isSelected;
  final bool markAsCustom;
  final ValueChanged<String> onToggle;

  const ActivityRow({
    super.key,
    required this.activity,
    required this.isLast,
    required this.isSelected,
    required this.markAsCustom,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = activity.isActive || isSelected;
    return Column(
      children: [
        InkWell(
          key: ValueKey('activity_${activity.id}'),
          onTap: enabled
              ? () {
                  HapticFeedback.selectionClick();
                  onToggle(activity.id);
                }
              : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
              child: Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: enabled
                        ? (_) {
                            HapticFeedback.selectionClick();
                            onToggle(activity.id);
                          }
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: !activity.isActive && !isSelected
                                ? theme.colorScheme.onSurface
                                    .withValues(alpha: 0.45)
                                : null,
                          ),
                        ),
                        if (!activity.isActive) ...[
                          const SizedBox(height: 2),
                          Text(
                            markAsCustom
                                ? 'Eigene Tätigkeit · Deaktiviert'
                                : 'Deaktiviert',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ] else if (markAsCustom) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Eigene Tätigkeit',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isLast) const Divider(indent: 56),
      ],
    );
  }
}

class TemplateLoadWarning extends StatelessWidget {
  final VoidCallback onRetry;

  const TemplateLoadWarning({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return AppMessage(
      icon: Icons.warning_amber_outlined,
      title: 'Eigene Tätigkeiten konnten nicht geladen werden.',
      message: 'Vordefinierte Tätigkeiten bleiben verfügbar.',
      tone: AppMessageTone.error,
      action: IconButton(
        onPressed: onRetry,
        tooltip: 'Erneut versuchen',
        icon: const Icon(Icons.refresh),
      ),
    );
  }
}

class SelectionCount extends StatelessWidget {
  final int count;

  const SelectionCount({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: count == 0
            ? theme.colorScheme.surfaceContainer
            : theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count gewählt',
        style: theme.textTheme.labelMedium?.copyWith(
          color: count == 0
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class UnavailableActivities extends StatelessWidget {
  final List<String> ids;
  final ValueChanged<String> onRemove;

  const UnavailableActivities({
    super.key,
    required this.ids,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nicht mehr verfügbare Tätigkeiten',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Diese Auswahl stammt aus einem älteren Eintrag. '
          'Du kannst sie entfernen oder unverändert speichern.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ids.indexed
              .map(
                (e) => InputChip(
                  label: Text('Nicht verfügbar (${e.$1 + 1})'),
                  onDeleted: () => onRemove(e.$2),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}
