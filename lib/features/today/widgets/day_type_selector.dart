import 'package:flutter/material.dart';
import '../../../core/enums/day_type.dart';

class DayTypeSelector extends StatelessWidget {
  final DayType selectedDayType;
  final ValueChanged<DayType> onSelect;

  const DayTypeSelector({
    super.key,
    required this.selectedDayType,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: DayType.values.map((dayType) {
        return ChoiceChip(
          key: ValueKey('day_type_${dayType.name}'),
          label: Text(dayType.label),
          selected: selectedDayType == dayType,
          onSelected: (_) => onSelect(dayType),
        );
      }).toList(),
    );
  }
}
