import 'package:flutter/material.dart';

import '../../../core/enums/day_type.dart';
import '../../../core/enums/training_area.dart';
import '../../../shared/widgets/app_ui.dart';
import 'area_grid.dart';
import 'day_type_row.dart';
import 'save_bar.dart';
import 'today_header.dart';

/// Views of the local daily check-in. This is intentionally UI-only state; the
/// persisted DailyEntry contract remains unchanged.
enum TodayFlowStep { dayType, area, activities, review, saved }

class TodayCheckInPage extends StatelessWidget {
  final TodayFlowStep step;
  final String title;
  final DateTime date;
  final TodayEntryStatus status;
  final List<String> missingItems;
  final DayType? selectedDayType;
  final Set<TrainingArea> selectedAreas;
  final bool showDuplicateYesterday;
  final VoidCallback? onDuplicateYesterday;
  final ValueChanged<DayType> onSelectDayType;
  final VoidCallback onOpenAbsenceSheet;
  final ValueChanged<TrainingArea> onToggleArea;
  final VoidCallback onBack;
  final VoidCallback? onContinue;
  final String continueLabel;
  final bool canContinue;
  final Widget? reviewContent;
  final Widget? notice;
  final VoidCallback? onSave;
  final bool canSave;
  final bool isSaving;
  final bool isNewEntry;
  final bool isToday;
  final int selectedActivityCount;
  final bool supportsActivities;

  const TodayCheckInPage({
    super.key,
    required this.step,
    required this.title,
    required this.date,
    required this.status,
    required this.missingItems,
    required this.selectedDayType,
    required this.selectedAreas,
    required this.showDuplicateYesterday,
    required this.onDuplicateYesterday,
    required this.onSelectDayType,
    required this.onOpenAbsenceSheet,
    required this.onToggleArea,
    required this.onBack,
    required this.onContinue,
    required this.continueLabel,
    required this.canContinue,
    this.reviewContent,
    this.notice,
    required this.onSave,
    required this.canSave,
    required this.isSaving,
    required this.isNewEntry,
    required this.isToday,
    required this.selectedActivityCount,
    required this.supportsActivities,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                if (notice != null) ...[
                  notice!,
                  const SizedBox(height: 16),
                ],
                if (step == TodayFlowStep.dayType) ...[
                  TodayHeader(
                    title: title,
                    date: date,
                    status: status,
                    missingItems: missingItems,
                  ),
                  const SizedBox(height: 32),
                  const AppSectionHeader(
                    title: 'Wie war dein Tag?',
                    description: 'Wähle den passenden Tagtyp.',
                  ),
                  const SizedBox(height: 12),
                  DayTypeRow(
                    selectedDayType: selectedDayType,
                    onSelectBetrieb: onSelectDayType,
                    onSelectBerufsschule: onSelectDayType,
                    onOpenAbsenceSheet: onOpenAbsenceSheet,
                  ),
                  if (showDuplicateYesterday) ...[
                    const SizedBox(height: 24),
                    FilledButton.tonalIcon(
                      key: const ValueKey('duplicate_yesterday'),
                      onPressed: onDuplicateYesterday,
                      icon: const Icon(Icons.copy_outlined),
                      label: const Text('Wie gestern starten'),
                    ),
                  ],
                ] else if (step == TodayFlowStep.area) ...[
                  _StepHeader(
                    step: 'Schritt 2 von 4',
                    title: 'Wo hast du gearbeitet?',
                    onBack: onBack,
                  ),
                  const SizedBox(height: 20),
                  AreaGrid(
                    areas: TrainingArea.values,
                    selected: selectedAreas,
                    onToggle: onToggleArea,
                  ),
                ] else ...[
                  _StepHeader(
                    step: 'Prüfen & speichern',
                    title: 'Dein Tag auf einen Blick',
                    onBack: onBack,
                  ),
                  const SizedBox(height: 20),
                  if (reviewContent != null) reviewContent!,
                ],
              ],
            ),
          ),
          if (step == TodayFlowStep.review)
            SaveBar(
              missingItems: const [],
              canSubmit: canSave,
              isSaving: isSaving,
              isNewEntry: isNewEntry,
              isToday: isToday,
              onSave: onSave ?? () {},
              selectedActivityCount: selectedActivityCount,
              supportsActivities: supportsActivities,
              progress: supportsActivities
                  ? EntryProgress(
                      hasDayType: selectedDayType != null,
                      hasArea: selectedAreas.isNotEmpty,
                      hasActivity: selectedActivityCount > 0,
                      needsArea: selectedDayType == DayType.betrieb,
                    )
                  : null,
            )
          else
            TodayFlowActionBar(
              label: continueLabel,
              onPressed: canContinue ? onContinue : null,
            ),
        ],
      ),
    );
  }
}

class TodayActivityPickerPage extends StatelessWidget {
  final Widget picker;
  final int selectedCount;
  final VoidCallback onCancel;
  final VoidCallback? onConfirm;

  const TodayActivityPickerPage({
    super.key,
    required this.picker,
    required this.selectedCount,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
            child: Row(
              children: [
                IconButton(
                  key: const ValueKey('close_activity_picker'),
                  onPressed: onCancel,
                  tooltip: 'Auswahl verwerfen',
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tätigkeiten',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Text(
                  '$selectedCount gewählt',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [picker],
            ),
          ),
          TodayFlowActionBar(
            label: 'Auswahl übernehmen',
            onPressed: selectedCount > 0 ? onConfirm : null,
          ),
        ],
      ),
    );
  }
}

class TodaySavedOverview extends StatelessWidget {
  final String title;
  final DateTime date;
  final TodayEntryStatus status;
  final DayType dayType;
  final List<String> areas;
  final List<String> activities;
  final Widget? report;
  final VoidCallback onEditDayType;
  final VoidCallback onEditActivities;
  final VoidCallback onEditDetails;

  const TodaySavedOverview({
    super.key,
    required this.title,
    required this.date,
    required this.status,
    required this.dayType,
    required this.areas,
    required this.activities,
    required this.report,
    required this.onEditDayType,
    required this.onEditActivities,
    required this.onEditDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          TodayHeader(
            title: title,
            date: date,
            status: status,
            missingItems: const [],
          ),
          const SizedBox(height: 28),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.today_outlined),
                  title: const Text('Tagtyp'),
                  subtitle: Text(dayType.label),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: onEditDayType,
                ),
                if (dayType == DayType.betrieb ||
                    dayType == DayType.berufsschule)
                  const Divider(indent: 16, endIndent: 16),
                if (dayType == DayType.betrieb ||
                    dayType == DayType.berufsschule)
                  ListTile(
                    leading: const Icon(Icons.checklist_outlined),
                    title: const Text('Bereich & Tätigkeiten'),
                    subtitle: Text([
                      if (areas.isNotEmpty) areas.join(', '),
                      '${activities.length} ${activities.length == 1 ? 'Tätigkeit' : 'Tätigkeiten'}',
                    ].join(' · ')),
                    trailing: const Icon(Icons.edit_outlined),
                    onTap: onEditActivities,
                  ),
              ],
            ),
          ),
          if (activities.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Erfasst',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  activities.map((title) => Chip(label: Text(title))).toList(),
            ),
          ],
          const SizedBox(height: 24),
          OutlinedButton.icon(
            key: const ValueKey('edit_entry_details'),
            onPressed: onEditDetails,
            icon: const Icon(Icons.edit_note_outlined),
            label: const Text('Ergänzungen bearbeiten'),
          ),
          if (report != null) ...[
            const SizedBox(height: 24),
            report!,
          ],
        ],
      ),
    );
  }
}

class TodayReviewContent extends StatelessWidget {
  final DayType dayType;
  final List<String> areas;
  final List<String> activities;
  final Widget details;
  final Widget? report;

  const TodayReviewContent({
    super.key,
    required this.dayType,
    required this.areas,
    required this.activities,
    required this.details,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dayType.label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
                if (areas.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(areas.join(', ')),
                ],
                if (activities.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                      '${activities.length} ${activities.length == 1 ? 'Tätigkeit' : 'Tätigkeiten'} ausgewählt'),
                ],
              ],
            ),
          ),
        ),
        if (!dayType.isAbsence) ...[
          const SizedBox(height: 20),
          details,
        ],
        if (report != null) ...[
          const SizedBox(height: 20),
          report!,
        ],
      ],
    );
  }
}

class TodayFlowActionBar extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const TodayFlowActionBar({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainer,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: FilledButton(
          key: const ValueKey('today_flow_continue'),
          onPressed: onPressed,
          child: Text(label),
        ),
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  final String step;
  final String title;
  final VoidCallback onBack;

  const _StepHeader({
    required this.step,
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          key: const ValueKey('today_flow_back'),
          onPressed: onBack,
          tooltip: 'Zurück',
          icon: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(step,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  )),
              const SizedBox(height: 2),
              Text(title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}
