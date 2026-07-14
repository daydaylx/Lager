import 'package:flutter/material.dart';
import '../../../core/ui/day_status_colors.dart';
import '../../../core/week_utils.dart';

enum TodayEntryStatus { open, unsavedChanges, saved, absence }

// #Phase23: Compact header replaces the large DayStatusCard — title, date
// and a status chip in one row instead of a padded full-width card. Reuses
// the central DayStatusColors helper (#54) so status colors stay consistent
// with WeekScreen instead of duplicating a local color mapping.
class TodayHeader extends StatelessWidget {
  final String title;
  final DateTime date;
  final TodayEntryStatus status;
  final List<String> missingItems;

  const TodayHeader({
    super.key,
    required this.title,
    required this.date,
    required this.status,
    required this.missingItems,
  });

  String get _statusLabel => switch (status) {
        TodayEntryStatus.open => 'Noch offen',
        TodayEntryStatus.unsavedChanges => 'Änderungen offen',
        TodayEntryStatus.saved => 'Gespeichert',
        TodayEntryStatus.absence => 'Abwesenheit',
      };

  DayStatusKind get _statusKind => switch (status) {
        TodayEntryStatus.saved => DayStatusKind.saved,
        TodayEntryStatus.unsavedChanges => DayStatusKind.open,
        TodayEntryStatus.absence => DayStatusKind.absence,
        TodayEntryStatus.open => DayStatusKind.neutral,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final statusKind = _statusKind;
    final fg = statusKind == DayStatusKind.neutral
        ? cs.onSurfaceVariant
        : statusKind.color(cs);
    final bg = statusKind.containerColor(cs);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                formatDayDate(date),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  _statusLabel,
                  key: const ValueKey('daily_entry_status'),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (status == TodayEntryStatus.open &&
                  missingItems.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Wähle kurz: ${missingItems.join(' und ')}',
                  textAlign: TextAlign.end,
                  softWrap: true,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
