import 'package:flutter/material.dart';
import '../../core/data/default_activities.dart';
import '../../core/enums/activity_category.dart';
import '../../core/models/activity_template.dart';
import '../../core/storage/activity_template_storage.dart';

class TemplatesScreen extends StatefulWidget {
  final ActivityTemplateStorage storage;
  final VoidCallback? onTemplatesChanged;

  const TemplatesScreen({
    super.key,
    required this.storage,
    this.onTemplatesChanged,
  });

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  final TextEditingController _addController = TextEditingController();

  ActivityCategory? _selectedCategory;
  List<ActivityTemplate> _customTemplates = [];
  bool _isLoading = true;
  bool _loadFailed = false;

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
          _loadFailed = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadFailed = true;
        });
      }
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

  Future<void> _toggleCustom(ActivityTemplate template) async {
    final updated = template.copyWith(isActive: !template.isActive);
    try {
      await widget.storage.save(updated);
      if (mounted) {
        setState(() {
          _customTemplates = _customTemplates
              .map((item) => item.id == updated.id ? updated : item)
              .toList(growable: false);
        });
        widget.onTemplatesChanged?.call();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              template.isActive
                  ? 'Die Tätigkeit konnte nicht deaktiviert werden.'
                  : 'Die Tätigkeit konnte nicht aktiviert werden.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _showAddDialog() async {
    _addController.clear();
    ActivityCategory selectedCategory =
        _selectedCategory ?? ActivityCategory.values.first;
    String? titleError;

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
                decoration: InputDecoration(
                  labelText: 'Bezeichnung',
                  border: const OutlineInputBorder(),
                  errorText: titleError,
                ),
                onChanged: (_) {
                  if (titleError != null) {
                    setDialogState(() => titleError = null);
                  }
                },
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
                if (title.isEmpty) {
                  setDialogState(
                    () => titleError = 'Gib eine Bezeichnung ein.',
                  );
                  return;
                }
                Navigator.of(ctx).pop();
                final template = ActivityTemplate(
                  id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                  title: title,
                  category: selectedCategory,
                  isCustom: true,
                );
                try {
                  await widget.storage.save(template);
                  if (mounted) {
                    setState(
                      () => _customTemplates = [..._customTemplates, template],
                    );
                    widget.onTemplatesChanged?.call();
                  }
                } catch (_) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Die Tätigkeit konnte nicht gespeichert werden.'),
                      ),
                    );
                  }
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
                : _loadFailed
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline, size: 48),
                              const SizedBox(height: 16),
                              const Text(
                                'Eigene Tätigkeiten konnten nicht geladen werden.',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: _loadCustom,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Erneut versuchen'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.search_off_outlined,
                                  size: 48,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Keine Tätigkeiten in dieser Kategorie.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _TemplateList(
                            defaults: filteredDefaults,
                            custom: filteredCustom,
                            onToggleCustom: _toggleCustom,
                          ),
          ),
        ],
      ),
    );
  }
}

class _TemplateList extends StatelessWidget {
  final List<ActivityTemplate> defaults;
  final List<ActivityTemplate> custom;
  final ValueChanged<ActivityTemplate> onToggleCustom;

  const _TemplateList({
    required this.defaults,
    required this.custom,
    required this.onToggleCustom,
  });

  @override
  Widget build(BuildContext context) {
    final customLength = custom.isEmpty ? 0 : custom.length + 1;
    final defaultLength = defaults.isEmpty ? 0 : defaults.length + 1;

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: customLength + defaultLength,
      itemBuilder: (context, index) {
        if (custom.isNotEmpty) {
          if (index == 0) {
            return _SectionHeader('Eigene (${custom.length})');
          }
          if (index <= custom.length) {
            final template = custom[index - 1];
            return ListTile(
              title: Text(template.title),
              subtitle: Text(
                template.isActive
                    ? template.category.label
                    : '${template.category.label} · Deaktiviert',
              ),
              leading: Icon(
                template.isActive
                    ? Icons.check_circle_outline
                    : Icons.pause_circle_outline,
              ),
              trailing: IconButton(
                icon: Icon(
                  template.isActive
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                tooltip: template.isActive ? 'Deaktivieren' : 'Aktivieren',
                onPressed: () => onToggleCustom(template),
              ),
            );
          }
          index -= customLength;
        }

        if (index == 0) {
          return _SectionHeader('Vordefiniert (${defaults.length})');
        }
        final template = defaults[index - 1];
        return ListTile(
          title: Text(template.title),
          subtitle: Text(template.category.label),
          dense: true,
        );
      },
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
