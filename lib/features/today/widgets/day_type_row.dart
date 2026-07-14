import 'package:flutter/material.dart';
import '../../../core/enums/day_type.dart';

// #Phase23: Reduced to 3 always-visible options; absence/sonstiges values
// are picked in a separate bottom sheet (see absence_sheet.dart) and shown
// on the third chip once chosen.
class DayTypeRow extends StatelessWidget {
  final DayType selectedDayType;
  final ValueChanged<DayType> onSelectBetrieb;
  final ValueChanged<DayType> onSelectBerufsschule;
  final VoidCallback onOpenAbsenceSheet;

  const DayTypeRow({
    super.key,
    required this.selectedDayType,
    required this.onSelectBetrieb,
    required this.onSelectBerufsschule,
    required this.onOpenAbsenceSheet,
  });

  bool get _isAbsenceOrOther =>
      selectedDayType.isAbsence || selectedDayType == DayType.sonstiges;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          key: const ValueKey('day_type_betrieb'),
          label: const Text('Betrieb'),
          selected: selectedDayType == DayType.betrieb,
          onSelected: (_) => onSelectBetrieb(DayType.betrieb),
        ),
        ChoiceChip(
          key: const ValueKey('day_type_berufsschule'),
          label: const Text('Berufsschule'),
          selected: selectedDayType == DayType.berufsschule,
          onSelected: (_) => onSelectBerufsschule(DayType.berufsschule),
        ),
        ChoiceChip(
          key: const ValueKey('day_type_absence_chip'),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_isAbsenceOrOther ? selectedDayType.label : 'Abwesend'),
              const SizedBox(width: 2),
              const Icon(Icons.expand_more, size: 18),
            ],
          ),
          selected: _isAbsenceOrOther,
          onSelected: (_) => onOpenAbsenceSheet(),
        ),
      ],
    );
  }
}
