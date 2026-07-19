import 'package:flutter/material.dart';
import '../../../shared/widgets/app_ui.dart';
import '../activity_picker_model.dart';
import 'activity_section.dart';

class ActivityPickerSection extends StatelessWidget {
  final ActivityPickerModel model;
  final bool templatesLoadFailed;
  final VoidCallback onRetryTemplates;
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<String> onToggleActivity;
  final VoidCallback onAddActivity;
  final int? trainingYear;

  const ActivityPickerSection({
    super.key,
    required this.model,
    required this.templatesLoadFailed,
    required this.onRetryTemplates,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onToggleActivity,
    required this.onAddActivity,
    required this.trainingYear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (templatesLoadFailed) ...[
          TemplateLoadWarning(onRetry: onRetryTemplates),
          const SizedBox(height: 16),
        ],
        if (model.selectedActivities.isNotEmpty) ...[
          SelectedActivitiesBar(
            activities: model.selectedActivities,
            onRemove: onToggleActivity,
          ),
          const SizedBox(height: 16),
        ],
        TextField(
          key: const ValueKey('activity_search'),
          controller: searchController,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Tätigkeiten suchen',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: searchQuery.isEmpty
                ? null
                : IconButton(
                    key: const ValueKey('clear_activity_search'),
                    onPressed: onClearSearch,
                    tooltip: 'Suche leeren',
                    icon: const Icon(Icons.close),
                  ),
          ),
          onChanged: onSearchChanged,
        ),
        const SizedBox(height: 8),
        // Eigene-Tätigkeit-Aktion (#UX-3 A4): weniger prominent, damit die
        // Auswahl-Listen nicht visuell überfrachtet werden. Bei leerem
        // Suchergebnis bleibt sie sichtbar.
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            key: const ValueKey('add_activity_button'),
            onPressed: onAddActivity,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Eigene Tätigkeit hinzufügen'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (model.frequentActivities.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ActivityGroup(
              title: 'Häufig genutzt',
              activities: model.frequentActivities,
              selectedActivityIds: model.selectedActivities
                  .map((activity) => activity.id)
                  .toSet(),
              onToggle: onToggleActivity,
            ),
          ),
        if (model.recommendedActivities.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ActivityGroup(
              title: 'Passend zum $trainingYear. Ausbildungsjahr',
              activities: model.recommendedActivities,
              selectedActivityIds: model.selectedActivities
                  .map((activity) => activity.id)
                  .toSet(),
              onToggle: onToggleActivity,
            ),
          ),
        if (!model.hasVisibleActivities)
          const AppMessage(
            icon: Icons.search_off_outlined,
            title: 'Keine passenden Tätigkeiten gefunden',
            message: 'Passe die Suche an oder wähle einen anderen Bereich.',
          ),
        ...model.groups.map(
          (group) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ActivityGroup(
              title: group.title,
              activities: group.activities,
              selectedActivityIds: model.selectedActivities
                  .map((activity) => activity.id)
                  .toSet(),
              onToggle: onToggleActivity,
              markAsCustom: group.markAsCustom,
            ),
          ),
        ),
        if (model.unavailableSelectedIds.isNotEmpty)
          UnavailableActivities(
            ids: model.unavailableSelectedIds,
            onRemove: onToggleActivity,
          ),
      ],
    );
  }
}
