import 'package:flutter/material.dart';
import '../../core/data/activity_subcategories.dart';
import '../../core/data/default_activities.dart';
import '../../core/enums/activity_category.dart';
import '../../core/models/activity_template.dart';
import '../../core/storage/activity_template_storage.dart';
import '../../shared/widgets/app_ui.dart';

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
  final TextEditingController _searchController = TextEditingController();

  ActivityCategory? _selectedCategory;
  String _searchQuery = '';
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
    _searchController.dispose();
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
    return defaultActivities
        .where(
          (template) =>
              (_selectedCategory == null ||
                  template.category == _selectedCategory) &&
              _matchesSearch(template),
        )
        .toList();
  }

  List<ActivityTemplate> get _filteredCustom {
    return _customTemplates
        .where(
          (template) =>
              (_selectedCategory == null ||
                  template.category == _selectedCategory) &&
              _matchesSearch(template),
        )
        .toList();
  }

  bool _matchesSearch(ActivityTemplate template) {
    final query = _searchQuery.trim().toLowerCase();
    return query.isEmpty ||
        template.title.toLowerCase().contains(query) ||
        template.category.label.toLowerCase().contains(query);
  }

  ActivityTemplate? _findDuplicate(String title) {
    final normalizedTitle = _normalizeActivityTitle(title);
    final all = [...defaultActivities, ..._customTemplates];
    final index = all.indexWhere(
      (template) => _normalizeActivityTitle(template.title) == normalizedTitle,
    );
    return index >= 0 ? all[index] : null;
  }

  String _displayTitle(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  String _normalizeActivityTitle(String value) {
    return _displayTitle(value).toLowerCase();
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

  Future<void> _showAddSheet() async {
    _addController.clear();
    ActivityCategory selectedCategory =
        _selectedCategory ?? ActivityCategory.values.first;
    String? titleError;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            20 + MediaQuery.viewInsetsOf(ctx).bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Eigene Tätigkeit',
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sie erscheint passend zur gewählten Kategorie im Tagesflow.',
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 20),
                TextField(
                  key: const ValueKey('template_title_field'),
                  controller: _addController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Bezeichnung',
                    errorText: titleError,
                  ),
                  onChanged: (_) {
                    if (titleError != null) {
                      setSheetState(() => titleError = null);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ActivityCategory>(
                  value: selectedCategory,
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
                    if (c != null) setSheetState(() => selectedCategory = c);
                  },
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () async {
                    final title = _displayTitle(_addController.text);
                    if (title.isEmpty) {
                      setSheetState(
                        () => titleError = 'Gib eine Bezeichnung ein.',
                      );
                      return;
                    }
                    final duplicate = _findDuplicate(title);
                    if (duplicate != null) {
                      setSheetState(
                        () => titleError =
                            'Diese Tätigkeit existiert bereits: „${duplicate.title}".',
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
                          () => _customTemplates = [
                            ..._customTemplates,
                            template
                          ],
                        );
                        widget.onTemplatesChanged?.call();
                      }
                    } catch (_) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Die Tätigkeit konnte nicht gespeichert werden.',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Hinzufügen'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Abbrechen'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredDefaults = _filteredDefaults;
    final filteredCustom = _filteredCustom;
    final isEmpty = filteredDefaults.isEmpty && filteredCustom.isEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Vorlagen')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        icon: const Icon(Icons.add),
        label: const Text('Eigene Tätigkeit'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: TextField(
              key: const ValueKey('template_search'),
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Tätigkeiten durchsuchen',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        tooltip: 'Suche leeren',
                        icon: const Icon(Icons.close),
                      ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          _CategoryFilter(
            selected: _selectedCategory,
            onSelected: (c) => setState(() => _selectedCategory = c),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _loadFailed
                    ? AppEmptyState(
                        icon: Icons.error_outline,
                        title: 'Vorlagen nicht verfügbar',
                        message:
                            'Eigene Tätigkeiten konnten nicht geladen werden.',
                        action: FilledButton.icon(
                          onPressed: _loadCustom,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Erneut versuchen'),
                        ),
                      )
                    : isEmpty
                        ? const AppEmptyState(
                            icon: Icons.search_off_outlined,
                            title: 'Keine Tätigkeiten gefunden',
                            message:
                                'Passe Suche oder Kategorie an, um weitere Tätigkeiten zu sehen.',
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
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              child: Material(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                child: ListTile(
                  title: Text(template.title),
                  subtitle: Text(
                    _templateSubtitle(template),
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
                ),
              ),
            );
          }
          index -= customLength;
        }

        if (index == 0) {
          return _SectionHeader('Vordefiniert (${defaults.length})');
        }
        final template = defaults[index - 1];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ListTile(
            title: Text(template.title),
            subtitle: Text(_templateSubtitle(template)),
            leading: const Icon(Icons.checklist_outlined, size: 20),
          ),
        );
      },
    );
  }

  String _templateSubtitle(ActivityTemplate template) {
    final subcategory = activitySubcategory(template);
    final base = subcategory == null
        ? template.category.label
        : '${template.category.label} · $subcategory';
    return template.isActive ? base : '$base · Deaktiviert';
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
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
