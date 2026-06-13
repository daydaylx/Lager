import 'package:flutter/material.dart';
import '../../core/data/default_activities.dart';
import '../../core/enums/activity_category.dart';
import '../../core/models/activity_template.dart';
import '../../core/storage/activity_template_storage.dart';

class TemplatesScreen extends StatefulWidget {
  final ActivityTemplateStorage storage;

  const TemplatesScreen({super.key, required this.storage});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  final TextEditingController _addController = TextEditingController();

  ActivityCategory? _selectedCategory;
  List<ActivityTemplate> _customTemplates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustom();
  }

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  Future<void> _loadCustom() async {
    try {
      final templates = await widget.storage.loadCustom();
      if (mounted) {
        setState(() {
          _customTemplates = templates;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<ActivityTemplate> get _filteredDefaults {
    if (_selectedCategory == null) return defaultActivities;
    return defaultActivities
        .where((t) => t.category == _selectedCategory)
        .toList();
  }

  List<ActivityTemplate> get _filteredCustom {
    if (_selectedCategory == null) return _customTemplates;
    return _customTemplates
        .where((t) => t.category == _selectedCategory)
        .toList();
  }

  Future<void> _deleteCustom(String id) async {
    await widget.storage.delete(id);
    setState(() => _customTemplates.removeWhere((t) => t.id == id));
  }

  Future<void> _showAddDialog() async {
    _addController.clear();
    ActivityCategory selectedCategory =
        _selectedCategory ?? ActivityCategory.values.first;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Eigene Tätigkeit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _addController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Bezeichnung',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ActivityCategory>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategorie',
                  border: OutlineInputBorder(),
                ),
                items: ActivityCategory.values
                    .map(
                      (c) => DropdownMenuItem(value: c, child: Text(c.label)),
                    )
                    .toList(),
                onChanged: (c) {
                  if (c != null) setDialogState(() => selectedCategory = c);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () async {
                final title = _addController.text.trim();
                if (title.isEmpty) return;
                Navigator.of(ctx).pop();
                final template = ActivityTemplate(
                  id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                  title: title,
                  category: selectedCategory,
                  isCustom: true,
                );
                await widget.storage.save(template);
                if (mounted) {
                  setState(
                    () => _customTemplates = [..._customTemplates, template],
                  );
                }
              },
              child: const Text('Hinzufügen'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredDefaults = _filteredDefaults;
    final filteredCustom = _filteredCustom;
    final isEmpty = filteredDefaults.isEmpty && filteredCustom.isEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Vorlagen')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Eigene Tätigkeit'),
      ),
      body: Column(
        children: [
          _CategoryFilter(
            selected: _selectedCategory,
            onSelected: (c) => setState(() => _selectedCategory = c),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : isEmpty
                    ? Center(
                        child: Text(
                          'Keine Tätigkeiten in dieser Kategorie.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 88),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (filteredDefaults.isNotEmpty)
                              _SectionHeader(
                                'Vordefiniert (${filteredDefaults.length})',
                              ),
                            ...filteredDefaults.map(
                              (t) => ListTile(
                                title: Text(t.title),
                                dense: true,
                              ),
                            ),
                            if (filteredCustom.isNotEmpty)
                              _SectionHeader(
                                'Eigene (${filteredCustom.length})',
                              ),
                            ...filteredCustom.map(
                              (t) => ListTile(
                                title: Text(t.title),
                                dense: true,
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  tooltip: 'Löschen',
                                  onPressed: () => _deleteCustom(t.id),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  final ActivityCategory? selected;
  final void Function(ActivityCategory?) onSelected;

  const _CategoryFilter({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('Alle'),
              selected: selected == null,
              onSelected: (_) => onSelected(null),
            ),
          ),
          ...ActivityCategory.values.map(
            (c) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(c.label),
                selected: selected == c,
                onSelected: (_) => onSelected(selected == c ? null : c),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;

  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
