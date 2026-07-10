import 'package:flutter/material.dart';
import '../../../core/enums/activity_category.dart';

/// Ergebnis des „Eigene Tätigkeit hinzufügen"-Sheets.
class AddActivityResult {
  const AddActivityResult({
    required this.title,
    required this.category,
    required this.saveAsTemplate,
  });

  /// Bereinigte (getrimmte, Whitespace kollabiert) Bezeichnung.
  final String title;
  final ActivityCategory category;

  /// `true` = dauerhaft als eigene Vorlage speichern; `false` = nur heute.
  final bool saveAsTemplate;
}

/// Öffnet den Sheet zum direkten Hinzufügen einer eigenen Tätigkeit.
///
/// [existingTitles] sind alle bereits vorhandenen Bezeichnungen (Standard-,
/// eigene und heutige Tätigkeiten), gegen die Duplikate geprüft werden.
/// Liefert `null`, wenn der Nutzer abbricht.
Future<AddActivityResult?> showAddActivitySheet({
  required BuildContext context,
  required ActivityCategory initialCategory,
  required Set<String> existingTitles,
}) {
  return showModalBottomSheet<AddActivityResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => _AddActivitySheet(
      initialCategory: initialCategory,
      existingTitles: existingTitles,
    ),
  );
}

class _AddActivitySheet extends StatefulWidget {
  final ActivityCategory initialCategory;
  final Set<String> existingTitles;

  const _AddActivitySheet({
    required this.initialCategory,
    required this.existingTitles,
  });

  @override
  State<_AddActivitySheet> createState() => _AddActivitySheetState();
}

class _AddActivitySheetState extends State<_AddActivitySheet> {
  late final TextEditingController _titleController;
  late ActivityCategory _selectedCategory;
  bool _saveAsTemplate = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  static String _displayTitle(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String _normalize(String value) => _displayTitle(value).toLowerCase();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Eigene Tätigkeit hinzufügen',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Wähle sie gleich aus. Optional speicherst du sie für später.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 20),
            TextField(
              key: const ValueKey('add_activity_title_field'),
              controller: _titleController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Bezeichnung',
                errorText: _error,
              ),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ActivityCategory>(
              key: const ValueKey('add_activity_category_field'),
              value: _selectedCategory,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Kategorie'),
              items: ActivityCategory.values
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(
                        c.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (c) {
                if (c != null) setState(() => _selectedCategory = c);
              },
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              key: const ValueKey('add_activity_save_switch'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Für spätere Verwendung speichern'),
              subtitle: Text(
                _saveAsTemplate
                    ? 'Als eigene Vorlage angelegt.'
                    : 'Nur für diesen Tag.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              value: _saveAsTemplate,
              onChanged: (v) => setState(() => _saveAsTemplate = v),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const ValueKey('add_activity_submit'),
              onPressed: _submit,
              icon: const Icon(Icons.add),
              label: const Text('Hinzufügen'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Abbrechen'),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final title = _displayTitle(_titleController.text);
    if (title.isEmpty) {
      setState(() => _error = 'Gib eine Bezeichnung ein.');
      return;
    }
    final normalized = _normalize(title);
    final conflict = widget.existingTitles.firstWhere(
      (existing) => _normalize(existing) == normalized,
      orElse: () => '',
    );
    if (conflict.isNotEmpty) {
      setState(
          () => _error = 'Diese Tätigkeit existiert bereits: „$conflict".');
      return;
    }
    Navigator.of(context).pop(
      AddActivityResult(
        title: title,
        category: _selectedCategory,
        saveAsTemplate: _saveAsTemplate,
      ),
    );
  }
}
