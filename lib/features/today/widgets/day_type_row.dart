import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/enums/day_type.dart';

// #Phase23: Reduced to 3 always-visible options; absence/sonstiges values
// are picked in a separate bottom sheet (see absence_sheet.dart) and shown
// on the third chip once chosen.
class DayTypeRow extends StatelessWidget {
  final DayType? selectedDayType;
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
      selectedDayType?.isAbsence == true ||
      selectedDayType == DayType.sonstiges;

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
          onSelected: (_) {
            HapticFeedback.lightImpact();
            onSelectBetrieb(DayType.betrieb);
          },
        ),
        ChoiceChip(
          key: const ValueKey('day_type_berufsschule'),
          label: const Text('Berufsschule'),
          selected: selectedDayType == DayType.berufsschule,
          onSelected: (_) {
            HapticFeedback.lightImpact();
            onSelectBerufsschule(DayType.berufsschule);
          },
        ),
        // Abwesend-Chip öffnet ein Auswahlmenü (kein sofortiger Tagesstatus).
        // Tooltip + unfold_more-Icon (#UX-1 A10) machen die Menü-Semantik klar.
        Tooltip(
          key: const ValueKey('day_type_absence_tooltip'),
          message: _isAbsenceOrOther
              ? 'Abwesenheit ändern'
              : 'Abwesenheit oder Sonstiges wählen',
          child: ChoiceChip(
            key: const ValueKey('day_type_absence_chip'),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_isAbsenceOrOther ? selectedDayType!.label : 'Abwesend'),
                const SizedBox(width: 4),
                const Icon(Icons.unfold_more, size: 18),
              ],
            ),
            selected: _isAbsenceOrOther,
            onSelected: (_) {
              HapticFeedback.lightImpact();
              onOpenAbsenceSheet();
            },
          ),
        ),
      ],
    );
  }
}
