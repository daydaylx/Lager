import 'package:flutter/material.dart';
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
  final TextEditingController noteController;

  const SpecialFlagsAndNoteSection({
    super.key,
    required this.selectedDayType,
    required this.savedEntryId,
    required this.isExpanded,
    required this.onExpansionChanged,
    required this.selectedSpecialFlags,
    required this.onToggleSpecialFlag,
    required this.noteController,
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
        'Besonderheiten & Notiz',
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
          title: 'Notiz',
          badge: 'Optional',
          badgeRequired: false,
          description: 'Kurze Ergänzung, falls etwas Besonderes war.',
        ),
        const SizedBox(height: 12),
        TextField(
          key: const ValueKey('daily_note_field'),
          controller: widget.noteController,
          minLines: 2,
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Kurze Notiz, falls etwas Besonderes war ...',
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSpecialFlags() {
    const maxCollapsedUnselected = 3;
    const allFlags = SpecialFlag.values;
    final selectedFlags =
        allFlags.where(widget.selectedSpecialFlags.contains).toList();
    final unselectedFlags =
        allFlags.where((f) => !widget.selectedSpecialFlags.contains(f)).toList();

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
            onSelected: (_) => widget.onToggleSpecialFlag(flag),
          ),
        ),
        ...visibleUnselected.map(
          (flag) => FilterChip(
            key: ValueKey('special_${flag.name}'),
            label: Text(flag.label),
            selected: false,
            onSelected: (_) => widget.onToggleSpecialFlag(flag),
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
