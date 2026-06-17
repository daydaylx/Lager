import 'package:flutter/material.dart';
import '../../../core/enums/training_area.dart';

// #23: 2-column area card grid using FilterChips with icons (multi-select)
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
          Expanded(child: _areaChip(areas[i])),
          const SizedBox(width: 8),
          if (i + 1 < areas.length)
            Expanded(child: _areaChip(areas[i + 1]))
          else
            const Expanded(child: SizedBox.shrink()),
        ],
      ));
    }
    return Column(children: rows);
  }

  Widget _areaChip(TrainingArea area) {
    return FilterChip(
      key: ValueKey('area_${area.name}'),
      label: Text(area.label),
      avatar: Icon(area.icon, size: 16),
      showCheckmark: true,
      selected: selected.contains(area),
      onSelected: (_) => onToggle(area),
    );
  }
}
