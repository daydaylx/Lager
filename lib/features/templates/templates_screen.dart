import 'package:flutter/material.dart';
import '../../core/data/activity_subcategories.dart';
import '../../core/data/default_activities.dart';
import '../../core/enums/activity_category.dart';
import '../../core/models/activity_template.dart';
import '../../core/storage/default_activity_state_storage.dart';
import '../../core/storage/activity_template_storage.dart';
import '../../core/storage/daily_entry_storage.dart';
import '../../shared/widgets/app_ui.dart';
import '../today/activity_recommender.dart';

class TemplatesScreen extends StatefulWidget {
  final ActivityTemplateStorage storage;
  final DefaultActivityStateStorage defaultActivityStateStorage;
  final DailyEntryStorage? dailyEntryStorage;
  final VoidCallback? onTemplatesChanged;

  const TemplatesScreen({
    super.key,
    required this.storage,
    this.defaultActivityStateStorage = const DefaultActivityStateStorage(),
    this.dailyEntryStorage,
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
  Map<String, bool> _defaultOverrides = const {};
  List<ActivityTemplate> _frequentActivities = [];
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
      final overrides =
          await widget.defaultActivityStateStorage.loadOverrides();
      if (mounted) {
        setState(() {
          _customTemplates = templates;
          _defaultOverrides = overrides;
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
    await _loadFrequent();
  }

  /// „Häufig genutzt"-Schnellzugriff (#53): die am häufigsten verwendeten
  /// Tätigkeiten aus gespeicherten Einträgen. Optional — nur wenn ein
  /// [DailyEntryStorage] übergeben wurde und Einträge vorliegen.
  Future<void> _loadFrequent() async {
    final storage = widget.dailyEntryStorage;
    if (storage == null || !mounted) return;
    try {
      final entries = await storage.loadAll();
      final ids = computeFrequentActivityIds(entries);
      final byId = <String, ActivityTemplate>{
        for (final template in [...defaultActivities, ..._customTemplates])
          template.id: template,
      };
      final frequent = <ActivityTemplate>[];
      for (final id in ids) {
        final template = byId[id];
        if (template == null) continue;
        frequent.add(template);
        if (frequent.length == 6) break;
      }
      if (mounted) setState(() => _frequentActivities = frequent);
    } catch (_) {
      // Häufig-genutzt-Anzeige ist optional; bei Fehler einfach weglassen.
    }
  }

  bool _isDefaultActive(ActivityTemplate template) {
    return _defaultOverrides[template.id] ?? template.isActive;
  }

  List<ActivityTemplate> get _effectiveDefaults {
    return [
      for (final template in defaultActivities)
        _isDefaultActive(template) == template.isActive
            ? template
            : template.copyWith(isActive: _isDefaultActive(template)),
    ];
  }

  List<ActivityTemplate> get _filteredActiveDefaults {
    return _effectiveDefaults
        .where(
          (template) =>
              template.isActive &&
              (_selectedCategory == null ||
                  template.category == _selectedCategory) &&
              _matchesSearch(template),
        )
        .toList();
  }

  List<ActivityTemplate> get _filteredInactiveDefaults {
    return _effectiveDefaults
        .where(
          (template) =>
              !template.isActive &&
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

  Future<void> _toggleDefault(ActivityTemplate template) async {
    final currentlyActive = _isDefaultActive(template);
    try {
      await widget.defaultActivityStateStorage.setActive(
        template.id,
        !currentlyActive,
      );
      if (mounted) {
        setState(() {
          _defaultOverrides = {
            ..._defaultOverrides,
            template.id: !currentlyActive,
          };
        });
        widget.onTemplatesChanged?.call();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Die Tätigkeit konnte nicht geändert werden.'),
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
    final filteredActiveDefaults = _filteredActiveDefaults;
    final filteredInactiveDefaults = _filteredInactiveDefaults;
    final filteredCustom = _filteredCustom;
    final isEmpty = filteredActiveDefaults.isEmpty &&
        filteredInactiveDefaults.isEmpty &&
        filteredCustom.isEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Vorlagen')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSheet,
        tooltip: 'Eigene Tätigkeit hinzufügen',
        child: const Icon(Icons.add),
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
          if (_frequentActivities.isNotEmpty &&
              _searchQuery.isEmpty &&
              _selectedCategory == null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                'Häufig genutzt',
                key: const ValueKey('frequent_section'),
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _frequentActivities.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final template = _frequentActivities[index];
                  return Chip(
                    key: ValueKey('frequent_${template.id}'),
                    label: Text(template.title),
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
          ],
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
                            activeDefaults: filteredActiveDefaults,
                            inactiveDefaults: filteredInactiveDefaults,
                            custom: filteredCustom,
                            onToggleCustom: _toggleCustom,
                            onToggleDefault: _toggleDefault,
                          ),
          ),
        ],
      ),
    );
  }
}

class _TemplateList extends StatelessWidget {
  final List<ActivityTemplate> activeDefaults;
  final List<ActivityTemplate> inactiveDefaults;
  final List<ActivityTemplate> custom;
  final ValueChanged<ActivityTemplate> onToggleCustom;
  final ValueChanged<ActivityTemplate> onToggleDefault;

  const _TemplateList({
    required this.activeDefaults,
    required this.inactiveDefaults,
    required this.custom,
    required this.onToggleCustom,
    required this.onToggleDefault,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 88),
      children: [
        if (custom.isNotEmpty) ...[
          _SectionHeader('Eigene (${custom.length})'),
          ...custom.map(
            (template) => _TemplateRow(
              template: template,
              subtitleOverride: null,
              onToggle: () => onToggleCustom(template),
            ),
          ),
          const SizedBox(height: 8),
        ],
        _SectionHeader('Vordefiniert (${activeDefaults.length})'),
        if (activeDefaults.isEmpty)
          const _EmptyHint(
            'Keine aktiven Standardtätigkeiten in dieser Auswahl. '
            'Mehr weiter unten unter „Weitere Standardtätigkeiten".',
          )
        else
          ...activeDefaults.map(
            (template) => _TemplateRow(
              template: template,
              subtitleOverride: null,
              onToggle: () => onToggleDefault(template),
            ),
          ),
        if (inactiveDefaults.isNotEmpty) ...[
          const SizedBox(height: 8),
          _InactiveDefaultsSection(
            inactiveDefaults: inactiveDefaults,
            onToggleDefault: onToggleDefault,
          ),
        ],
      ],
    );
  }
}

class _InactiveDefaultsSection extends StatefulWidget {
  final List<ActivityTemplate> inactiveDefaults;
  final ValueChanged<ActivityTemplate> onToggleDefault;

  const _InactiveDefaultsSection({
    required this.inactiveDefaults,
    required this.onToggleDefault,
  });

  @override
  State<_InactiveDefaultsSection> createState() =>
      _InactiveDefaultsSectionState();
}

class _InactiveDefaultsSectionState extends State<_InactiveDefaultsSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: const ValueKey('inactive_defaults_section'),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      initiallyExpanded: _expanded,
      onExpansionChanged: (value) => setState(() => _expanded = value),
      title: Text(
        'Weitere Standardtätigkeiten (deaktiviert) · ${widget.inactiveDefaults.length}',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
      children: widget.inactiveDefaults
          .map(
            (template) => _TemplateRow(
              template: template,
              subtitleOverride: null,
              onToggle: () => widget.onToggleDefault(template),
            ),
          )
          .toList(),
    );
  }
}

class _TemplateRow extends StatelessWidget {
  final ActivityTemplate template;
  final String? subtitleOverride;
  final VoidCallback onToggle;

  const _TemplateRow({
    required this.template,
    required this.subtitleOverride,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final subcategory = activitySubcategory(template);
    final base = subcategory == null
        ? template.category.label
        : '${template.category.label} · $subcategory';
    final subtitle = subtitleOverride ??
        (template.isActive
            ? (template.isCustom ? '$base · Eigene' : base)
            : '$base · Deaktiviert');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          title: Text(template.title),
          subtitle: Text(subtitle),
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
            onPressed: onToggle,
          ),
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;

  const _EmptyHint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
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
