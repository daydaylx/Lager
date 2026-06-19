import 'package:flutter/material.dart';
import '../../../core/week_utils.dart';

class DayStatusCard extends StatelessWidget {
  final DateTime date;
  final String statusLabel;
  final bool isSaved;
  final bool hasUnsavedChanges;
  final List<String> missingItems;

  const DayStatusCard({
    super.key,
    required this.date,
    required this.statusLabel,
    required this.isSaved,
    required this.hasUnsavedChanges,
    required this.missingItems,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final ({Color bg, Color fg}) badge;
    if (isSaved && !hasUnsavedChanges) {
      badge = (bg: cs.primaryContainer, fg: cs.onPrimaryContainer);
    } else if (hasUnsavedChanges) {
      badge = (bg: cs.tertiaryContainer, fg: cs.onTertiaryContainer);
    } else {
      badge = (bg: cs.surfaceContainer, fg: cs.onSurfaceVariant);
    }

    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatDayDate(date),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badge.bg,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    statusLabel,
                    key: const ValueKey('daily_entry_status'),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: badge.fg,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (missingItems.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Wähle kurz: ${missingItems.join(' und ')}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
