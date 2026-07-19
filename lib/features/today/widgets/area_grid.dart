import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/enums/training_area.dart';

// #23: 2-column area card grid using FilterChips with icons (multi-select)
// #52: jeder Bereich zeigt zusätzlich eine kurze Unterzeile (was dort gemacht wird).
class AreaGrid extends StatelessWidget {
  final List<TrainingArea> areas;
  final Set<TrainingArea> selected;
  final ValueChanged<TrainingArea> onToggle;

  const AreaGrid({
    super.key,
    required this.areas,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < areas.length; i += 2) {
      if (i > 0) rows.add(const SizedBox(height: 8));
      rows.add(Row(
        children: [
          Expanded(child: _areaChip(context, areas[i])),
          const SizedBox(width: 8),
          if (i + 1 < areas.length)
            Expanded(child: _areaChip(context, areas[i + 1]))
          else
            const Expanded(child: SizedBox.shrink()),
        ],
      ));
    }
    return Column(children: rows);
  }

  Widget _areaChip(BuildContext context, TrainingArea area) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = selected.contains(area);
    return FilterChip(
      key: ValueKey('area_${area.name}'),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(area.label),
          Text(
            area.subtitle,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isSelected
                  ? colorScheme.onSecondaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      avatar: Icon(area.icon, size: 18),
      showCheckmark: true,
      selected: isSelected,
      onSelected: (_) {
        HapticFeedback.selectionClick();
        onToggle(area);
      },
    );
  }
}
