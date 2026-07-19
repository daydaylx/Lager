import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/enums/day_type.dart';
import '../../../core/enums/special_flag.dart';
import '../../../shared/widgets/app_ui.dart';

class SpecialFlagsAndNoteSection extends StatefulWidget {
  final DayType selectedDayType;
  final String? savedEntryId;
  final bool isExpanded;
  final ValueChanged<bool> onExpansionChanged;
  final Set<SpecialFlag> selectedSpecialFlags;
  final ValueChanged<SpecialFlag> onToggleSpecialFlag;
  final TextEditingController reportNoteController;
  final TextEditingController privateNoteController;

  const SpecialFlagsAndNoteSection({
    super.key,
    required this.selectedDayType,
    required this.savedEntryId,
    required this.isExpanded,
    required this.onExpansionChanged,
    required this.selectedSpecialFlags,
    required this.onToggleSpecialFlag,
    required this.reportNoteController,
    required this.privateNoteController,
  });

  @override
  State<SpecialFlagsAndNoteSection> createState() =>
      _SpecialFlagsAndNoteSectionState();
}

class _SpecialFlagsAndNoteSectionState
    extends State<SpecialFlagsAndNoteSection> {
  // #25: Compact collapsible special flags — expanded state is local UI only.
  bool _specialFlagsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: ValueKey(
        'optional_${widget.selectedDayType.name}_${widget.savedEntryId}',
      ),
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      maintainState: true,
      initiallyExpanded: widget.isExpanded,
      onExpansionChanged: widget.onExpansionChanged,
      title: Text(
        'Besonderheiten & Notizen',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
      subtitle: Text(
        'Optional',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
      children: [
        const SizedBox(height: 8),
        const AppSectionHeader(
          title: 'Besonderheiten',
          badge: 'Optional',
          badgeRequired: false,
          description: 'Was war heute besonders?',
        ),
        const SizedBox(height: 12),
        _buildSpecialFlags(),
        const SizedBox(height: 24),
        const AppSectionHeader(
          title: 'Notiz fürs Berichtsheft',
          badge: 'Optional',
          badgeRequired: false,
          description:
              'Öffentlich – erscheint im Berichtshefttext.',
        ),
        const SizedBox(height: 12),
        TextField(
          key: const ValueKey('daily_report_note_field'),
          controller: widget.reportNoteController,
          minLines: 2,
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Kurze Ergänzung fürs Berichtsheft …',
          ),
        ),
        const SizedBox(height: 24),
        _buildPrivateNote(context),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildPrivateNote(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lock_outline,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              'Private Notiz',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Nur lokal – bleibt in der App, nicht im Berichtsheft.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const ValueKey('daily_private_note_field'),
          controller: widget.privateNoteController,
          minLines: 2,
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest,
            hintText: 'Nur für dich – bleibt in der App …',
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialFlags() {
    const maxCollapsedUnselected = 3;
    const allFlags = SpecialFlag.values;
    final selectedFlags =
        allFlags.where(widget.selectedSpecialFlags.contains).toList();
    final unselectedFlags = allFlags
        .where((f) => !widget.selectedSpecialFlags.contains(f))
        .toList();

    final needsExpand = unselectedFlags.length > maxCollapsedUnselected;
    final showAll = _specialFlagsExpanded || !needsExpand;
    final visibleUnselected = showAll
        ? unselectedFlags
        : unselectedFlags.take(maxCollapsedUnselected).toList();
    final hiddenCount = unselectedFlags.length - maxCollapsedUnselected;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...selectedFlags.map(
          (flag) => FilterChip(
            key: ValueKey('special_${flag.name}'),
            label: Text(flag.label),
            selected: true,
            onSelected: (_) {
              HapticFeedback.selectionClick();
              widget.onToggleSpecialFlag(flag);
            },
          ),
        ),
        ...visibleUnselected.map(
          (flag) => FilterChip(
            key: ValueKey('special_${flag.name}'),
            label: Text(flag.label),
            selected: false,
            onSelected: (_) {
              HapticFeedback.selectionClick();
              widget.onToggleSpecialFlag(flag);
            },
          ),
        ),
        if (!showAll && hiddenCount > 0)
          ActionChip(
            label: Text('+$hiddenCount weitere'),
            onPressed: () => setState(() => _specialFlagsExpanded = true),
          ),
        if (showAll && needsExpand)
          ActionChip(
            label: const Text('Weniger'),
            onPressed: () => setState(() => _specialFlagsExpanded = false),
          ),
      ],
    );
  }
}
