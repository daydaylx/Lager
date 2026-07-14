import 'package:flutter/material.dart';
import '../../../core/enums/day_type.dart';

const _absenceOptions = [
  DayType.frei,
  DayType.urlaub,
  DayType.krank,
  DayType.feiertag,
  DayType.sonstiges,
];

const _absenceIcons = {
  DayType.frei: Icons.free_breakfast_outlined,
  DayType.urlaub: Icons.beach_access_outlined,
  DayType.krank: Icons.sick_outlined,
  DayType.feiertag: Icons.event_outlined,
  DayType.sonstiges: Icons.edit_note_outlined,
};

/// Öffnet die Auswahl für Abwesenheit oder Sonstiges. Liefert `null`, wenn
/// der Nutzer ohne Auswahl abbricht.
Future<DayType?> showAbsenceSheet({
  required BuildContext context,
  required DayType? currentSelection,
}) {
  return showModalBottomSheet<DayType>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (ctx) => _AbsenceSheet(currentSelection: currentSelection),
  );
}

class _AbsenceSheet extends StatelessWidget {
  final DayType? currentSelection;

  const _AbsenceSheet({required this.currentSelection});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Abwesenheit oder Sonstiges',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Wähle eine Option',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            ..._absenceOptions.map(
              (dayType) => ListTile(
                key: ValueKey('absence_option_${dayType.name}'),
                contentPadding: EdgeInsets.zero,
                leading: Icon(_absenceIcons[dayType]),
                title: Text(dayType.label),
                trailing: currentSelection == dayType
                    ? Icon(Icons.check, color: theme.colorScheme.primary)
                    : null,
                onTap: () => Navigator.of(context).pop(dayType),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
