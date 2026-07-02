import 'package:flutter/material.dart';

class ReportCard extends StatelessWidget {
  final String report;
  final bool isSaved;
  final VoidCallback onCopy;

  const ReportCard({
    super.key,
    required this.report,
    required this.isSaved,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Vorschlag fürs Berichtsheft',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _StatusChip(isSaved: isSaved),
              ],
            ),
            const SizedBox(height: 12),
            SelectableText(
              report,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const ValueKey('copy_report_card'),
              onPressed: onCopy,
              icon: const Icon(Icons.copy_outlined),
              label: const Text('Bericht kopieren'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isSaved;

  const _StatusChip({required this.isSaved});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      label: Text(isSaved ? 'Erledigt' : 'Entwurf'),
      labelStyle: theme.textTheme.labelSmall?.copyWith(
        color: isSaved
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurfaceVariant,
      ),
      backgroundColor: isSaved
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHigh,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
