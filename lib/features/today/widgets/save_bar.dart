import 'package:flutter/material.dart';

// #26: Lighter save bar with compact missing-items hint
class SaveBar extends StatelessWidget {
  final List<String> missingItems;
  final bool canSubmit;
  final bool isSaving;
  final bool isNewEntry;
  final bool isToday;
  final VoidCallback onSave;
  final int selectedActivityCount;
  final bool supportsActivities;

  const SaveBar({
    super.key,
    required this.missingItems,
    required this.canSubmit,
    required this.isSaving,
    required this.isNewEntry,
    required this.isToday,
    required this.onSave,
    required this.selectedActivityCount,
    required this.supportsActivities,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainer,
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (missingItems.isNotEmpty) ...[
              Text(
                'Fehlt: ${missingItems.join(' · ')}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ] else if (supportsActivities && selectedActivityCount > 0) ...[
              Text(
                '$selectedActivityCount '
                '${selectedActivityCount == 1 ? 'Tätigkeit' : 'Tätigkeiten'} gewählt',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    key: const ValueKey('save_daily_entry'),
                    onPressed: canSubmit ? onSave : null,
                    icon: isSaving
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(isNewEntry ? Icons.save_outlined : Icons.update),
                    label: Text(
                      isNewEntry
                          ? isToday
                              ? 'Heute speichern'
                              : 'Tag speichern'
                          : 'Änderungen speichern',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
