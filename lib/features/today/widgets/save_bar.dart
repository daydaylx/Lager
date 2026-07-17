import 'package:flutter/material.dart';

/// Fortschrittsstatus für die drei Hauptpflichtfelder (#24b)
class EntryProgress {
  final bool hasDayType;
  final bool hasArea;
  final bool hasActivity;
  final bool needsArea;

  const EntryProgress({
    required this.hasDayType,
    required this.hasArea,
    required this.hasActivity,
    required this.needsArea,
  });

  bool get isComplete =>
      hasDayType && (!needsArea || hasArea) && hasActivity;

  int get completedSteps {
    var count = 0;
    if (hasDayType) count++;
    if (needsArea && hasArea) count++;
    if (hasActivity) count++;
    return count;
  }

  int get totalSteps => needsArea ? 3 : 2;
}

// #26: Lighter save bar with compact missing-items hint
// #24b: Progress dots for visual feedback
// #24d: Success animation after saving
class SaveBar extends StatefulWidget {
  final List<String> missingItems;
  final bool canSubmit;
  final bool isSaving;
  final bool isNewEntry;
  final bool isToday;
  final VoidCallback onSave;
  final int selectedActivityCount;
  final bool supportsActivities;
  final EntryProgress? progress;

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
    this.progress,
  });

  @override
  State<SaveBar> createState() => _SaveBarState();
}

class _SaveBarState extends State<SaveBar> {
  bool _showSuccess = false;
  bool _wasSaving = false;

  @override
  void didUpdateWidget(covariant SaveBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Detect when saving completes (was saving, now not saving)
    if (_wasSaving && !widget.isSaving && widget.canSubmit == false) {
      setState(() => _showSuccess = true);
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => _showSuccess = false);
      });
    }
    _wasSaving = widget.isSaving;
  }

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
            if (widget.progress != null) ...[
              _ProgressDots(progress: widget.progress!),
              const SizedBox(height: 8),
            ],
            if (widget.missingItems.isNotEmpty) ...[
              Text(
                'Noch offen: ${widget.missingItems.join(' · ')}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ] else if (widget.supportsActivities && widget.selectedActivityCount > 0) ...[
              Text(
                '${widget.selectedActivityCount} '
                '${widget.selectedActivityCount == 1 ? 'Tätigkeit' : 'Tätigkeiten'} gewählt',
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
                    onPressed: widget.canSubmit ? widget.onSave : null,
                    icon: widget.isSaving
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: _showSuccess
                                ? const Icon(Icons.check_circle, key: ValueKey('success'))
                                : Icon(
                                    widget.isNewEntry ? Icons.save_outlined : Icons.update,
                                    key: ValueKey(widget.isNewEntry ? 'save' : 'update'),
                                  ),
                          ),
                    label: Text(
                      _showSuccess
                          ? 'Gespeichert!'
                          : widget.isNewEntry
                              ? widget.isToday
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

class _ProgressDots extends StatelessWidget {
  final EntryProgress progress;

  const _ProgressDots({required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Dot(
          label: 'Tagtyp',
          filled: progress.hasDayType,
          color: theme.colorScheme.primary,
        ),
        if (progress.needsArea) ...[
          const SizedBox(width: 8),
          _Dot(
            label: 'Bereich',
            filled: progress.hasArea,
            color: theme.colorScheme.primary,
          ),
        ],
        const SizedBox(width: 8),
        _Dot(
          label: 'Tätigkeit',
          filled: progress.hasActivity,
          color: theme.colorScheme.primary,
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final String label;
  final bool filled;
  final Color color;

  const _Dot({
    required this.label,
    required this.filled,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? color : Colors.transparent,
            border: Border.all(
              color: color.withAlpha(filled ? 255 : 128),
              width: 2,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: filled
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: filled ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
