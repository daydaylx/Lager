import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/constants.dart';
import '../../core/models/reminder_settings.dart';
import '../../core/profile_storage.dart';
import '../../core/services/notification_service.dart';
import '../../core/storage/reminder_storage.dart';
import '../../shared/widgets/app_ui.dart';
import '../../shared/widgets/profile_form.dart';

class ProfileScreen extends StatefulWidget {
  final Future<void> Function() onDataCleared;
  final NotificationScheduler? notificationScheduler;
  final ThemePreset themePreset;
  final Future<void> Function(ThemePreset)? onThemeChanged;

  const ProfileScreen({
    super.key,
    required this.onDataCleared,
    this.notificationScheduler,
    this.themePreset = ThemePreset.lagerTeal,
    this.onThemeChanged,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver {
  static const _permissionError =
      'Benachrichtigungen sind nicht erlaubt. Bitte in den Einstellungen aktivieren.';

  StoredProfile? _profile;
  bool _loadFailed = false;
  ReminderSettings _reminderSettings = ReminderSettings.defaults;
  late final NotificationScheduler _scheduler;
  bool _isReminderSaving = false;
  bool _isDeleting = false;
  String? _reminderError;
  bool _notificationsBlockedBySystem = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduler = widget.notificationScheduler ??
        const FlutterLocalNotificationScheduler();
    _loadProfile();
    _loadReminderSettings();
    _checkNotificationPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkNotificationPermission();
    }
  }

  Future<void> _checkNotificationPermission() async {
    try {
      final enabled = await _scheduler.areNotificationsEnabled();
      if (mounted) {
        setState(() {
          _notificationsBlockedBySystem = !enabled;
          if (enabled && _reminderError == _permissionError) {
            _reminderError = null;
          } else if (!enabled && _reminderSettings.enabled) {
            _reminderError = _permissionError;
          }
        });
      }
    } catch (_) {
      // Silently skip if the plugin is not available (e.g. in tests).
    }
  }

  Future<void> _openNotificationSettings() async {
    await AppSettings.openAppSettings(type: AppSettingsType.notification);
  }

  Future<void> _loadProfile() async {
    setState(() => _loadFailed = false);
    try {
      final profile = await ProfileStorage.load();
      if (mounted) setState(() => _profile = profile);
    } catch (_) {
      if (mounted) setState(() => _loadFailed = true);
    }
  }

  Future<void> _saveProfile({
    String? name,
    String? company,
    required String occupation,
    required int trainingYear,
  }) async {
    await ProfileStorage.save(
      name: name,
      company: company,
      occupation: occupation,
      trainingYear: trainingYear,
    );
  }

  Future<void> _openProfileEditor() async {
    final profile = _profile;
    if (profile == null) return;
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => _ProfileEditScreen(
          profile: profile,
          onSave: _saveProfile,
        ),
      ),
    );
    if (saved == true && mounted) {
      await _loadProfile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil gespeichert.')),
        );
      }
    }
  }

  Future<void> _loadReminderSettings() async {
    try {
      final settings = await ReminderStorage.load();
      if (mounted) {
        setState(() {
          _reminderSettings = settings;
          if (settings.enabled && _notificationsBlockedBySystem) {
            _reminderError = _permissionError;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _reminderError =
              'Erinnerungseinstellungen konnten nicht geladen werden.';
        });
      }
    }
  }

  Future<void> _saveAndReschedule(ReminderSettings settings) async {
    if (_isReminderSaving) return;
    final previous = _reminderSettings;
    final normalized = settings.normalized();
    setState(() {
      _isReminderSaving = true;
      _reminderError = null;
    });

    try {
      final result = await _scheduler.schedule(normalized);
      if (result == NotificationScheduleResult.permissionDenied) {
        await _restoreSchedule(previous);
        if (mounted) {
          setState(() {
            _isReminderSaving = false;
            _notificationsBlockedBySystem = true;
            _reminderError = _permissionError;
          });
        }
        return;
      }
      await ReminderStorage.save(normalized);
      if (mounted) {
        setState(() {
          _reminderSettings = normalized;
          _isReminderSaving = false;
          _notificationsBlockedBySystem = false;
        });
      }
    } catch (_) {
      await _restoreReminderState(previous);
      if (mounted) {
        setState(() {
          _isReminderSaving = false;
          _reminderError =
              'Die Erinnerung konnte nicht gespeichert werden. Bitte versuche es erneut.';
        });
      }
    }
  }

  Future<void> _restoreSchedule(ReminderSettings previous) async {
    try {
      await _scheduler.schedule(previous);
    } catch (_) {
      // The visible save error covers both the initial and rollback failures.
    }
  }

  Future<void> _restoreReminderState(ReminderSettings previous) async {
    await _restoreSchedule(previous);
    try {
      await ReminderStorage.save(previous);
    } catch (_) {
      // The visible save error covers native and persisted rollback failures.
    }
  }

  Future<void> _toggleReminder(bool value) async {
    await _saveAndReschedule(_reminderSettings.copyWith(enabled: value));
  }

  Future<void> _deleteTime(int index) async {
    if (_reminderSettings.times.length <= 1) return;
    final times = [..._reminderSettings.times]..removeAt(index);
    await _saveAndReschedule(_reminderSettings.copyWith(times: times));
  }

  Future<void> _addTime(TimeOfDay picked) async {
    final newTime = ReminderTime(hour: picked.hour, minute: picked.minute);
    if (_reminderSettings.times.contains(newTime)) {
      setState(() => _reminderError = 'Diese Uhrzeit ist bereits eingetragen.');
      return;
    }
    if (_reminderSettings.times.length >= ReminderSettings.maxTimes) {
      setState(() {
        _reminderError =
            'Es können höchstens ${ReminderSettings.maxTimes} Uhrzeiten gespeichert werden.';
      });
      return;
    }
    final times = [
      ..._reminderSettings.times,
      newTime,
    ]..sort((a, b) => a.hour == b.hour
        ? a.minute.compareTo(b.minute)
        : a.hour.compareTo(b.hour));
    await _saveAndReschedule(_reminderSettings.copyWith(times: times));
  }

  Future<void> _toggleWeekday(int weekday) async {
    final current = List<int>.from(_reminderSettings.weekdays);
    if (current.contains(weekday)) {
      if (current.length <= 1) return;
      current.remove(weekday);
    } else {
      current.add(weekday);
      current.sort();
    }
    await _saveAndReschedule(_reminderSettings.copyWith(weekdays: current));
  }

  Future<void> _confirmAndDeleteAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alle Daten löschen?'),
        content: const Text(
          'Alle Tageseinträge, eigene Vorlagen und Profildaten werden '
          'unwiderruflich gelöscht. Das Onboarding startet neu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Alle Daten löschen'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isDeleting = true);
      try {
        await widget.onDataCleared();
      } catch (_) {
        if (mounted) {
          setState(() => _isDeleting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Die Daten konnten nicht vollständig gelöscht werden. Bitte versuche es erneut.',
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loadFailed) {
      return AppEmptyState(
        icon: Icons.error_outline,
        title: 'Profil nicht verfügbar',
        message: 'Dein Profil konnte nicht geladen werden.',
        action: FilledButton.icon(
          onPressed: _loadProfile,
          icon: const Icon(Icons.refresh),
          label: const Text('Erneut versuchen'),
        ),
      );
    }

    final profile = _profile;
    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        _ProfileHeader(profile: profile),
        const SizedBox(height: 24),
        AppSettingsSection(
          title: 'Ausbildungsprofil',
          description: 'Diese Angaben helfen dir bei der täglichen Einordnung.',
          children: [
            ListTile(
              key: const ValueKey('edit_profile'),
              leading: const Icon(Icons.badge_outlined),
              title: Text(_occupationLabel(profile.occupation)),
              subtitle: Text(
                '${profile.trainingYear ?? '–'}. Ausbildungsjahr'
                '${profile.company == null ? '' : ' · ${profile.company}'}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _openProfileEditor,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _ReminderSection(
          settings: _reminderSettings,
          error: _reminderError,
          isSaving: _isReminderSaving,
          isPermissionBlocked: _notificationsBlockedBySystem,
          onOpenSettings: _openNotificationSettings,
          onToggle: _toggleReminder,
          onAddTime: _addTime,
          onDeleteTime: _deleteTime,
          onToggleWeekday: _toggleWeekday,
        ),
        const SizedBox(height: 24),
        _ThemeSection(
          current: widget.themePreset,
          onChanged: widget.onThemeChanged,
        ),
        const SizedBox(height: 24),
        AppSettingsSection(
          title: 'Daten & Datenschutz',
          description: 'Alle Inhalte bleiben lokal auf diesem Gerät.',
          children: [
            ListTile(
              key: const ValueKey('delete_all_data'),
              leading: _isDeleting
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline),
              title: Text(
                _isDeleting
                    ? 'Daten werden gelöscht ...'
                    : 'Alle Daten löschen',
              ),
              subtitle: const Text('Entfernt Profil, Einträge und Vorlagen.'),
              textColor: Theme.of(context).colorScheme.error,
              iconColor: Theme.of(context).colorScheme.error,
              enabled: !_isDeleting,
              onTap: _isDeleting ? null : _confirmAndDeleteAll,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Version $kAppVersion',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  String _occupationLabel(String? occupation) {
    return switch (occupation) {
      TrainingOccupationValues.fachlagerist => 'Fachlagerist/in',
      TrainingOccupationValues.fachkraftLagerlogistik =>
        'Fachkraft für Lagerlogistik',
      _ => 'Ausbildung noch nicht ausgewählt',
    };
  }
}

class _ReminderSection extends StatelessWidget {
  static const _weekdayLabels = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

  final ReminderSettings settings;
  final String? error;
  final bool isSaving;
  final bool isPermissionBlocked;
  final VoidCallback? onOpenSettings;
  final ValueChanged<bool> onToggle;
  final ValueChanged<TimeOfDay> onAddTime;
  final ValueChanged<int> onDeleteTime;
  final ValueChanged<int> onToggleWeekday;

  const _ReminderSection({
    required this.settings,
    required this.error,
    required this.isSaving,
    required this.isPermissionBlocked,
    required this.onOpenSettings,
    required this.onToggle,
    required this.onAddTime,
    required this.onDeleteTime,
    required this.onToggleWeekday,
  });

  @override
  Widget build(BuildContext context) {
    return AppSettingsSection(
      title: 'Erinnerungen',
      description: 'Ein kurzer Hinweis an ausgewählten Tagen.',
      children: [
        SwitchListTile(
          key: const ValueKey('reminder_toggle'),
          title: const Text('An ausgewählten Tagen erinnern'),
          subtitle: Text(settings.enabled ? 'Aktiv' : 'Aus'),
          value: settings.enabled,
          onChanged: isSaving ? null : onToggle,
          secondary: isSaving
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
        ),
        if (error case final msg?) ...[
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppMessage(
                  icon: Icons.error_outline,
                  title: msg,
                  tone: AppMessageTone.error,
                ),
                if (isPermissionBlocked && onOpenSettings != null) ...[
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: onOpenSettings,
                    icon: const Icon(Icons.settings_outlined),
                    label: const Text('Benachrichtigungseinstellungen öffnen'),
                  ),
                ],
              ],
            ),
          ),
        ],
        if (settings.enabled) ...[
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Uhrzeiten',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          ...settings.times.asMap().entries.map((entry) {
            final index = entry.key;
            final time = entry.value;
            return ListTile(
              key: ValueKey('reminder_time_$index'),
              leading: const Icon(Icons.schedule_outlined),
              title: Text(time.toDisplayString()),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: settings.times.length <= 1
                    ? 'Mindestens eine Uhrzeit ist erforderlich'
                    : 'Uhrzeit entfernen',
                onPressed: isSaving || settings.times.length <= 1
                    ? null
                    : () => onDeleteTime(index),
              ),
            );
          }),
          TextButton.icon(
            key: const ValueKey('reminder_add_time'),
            onPressed: isSaving
                ? null
                : () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 20, minute: 0),
                    );
                    if (picked != null) onAddTime(picked);
                  },
            icon: const Icon(Icons.add),
            label: const Text('Zeit hinzufügen'),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Tage',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(7, (i) {
                final weekday = i + 1;
                return FilterChip(
                  key: ValueKey('reminder_weekday_$weekday'),
                  label: Text(_weekdayLabels[i]),
                  selected: settings.weekdays.contains(weekday),
                  onSelected: isSaving ||
                          (settings.weekdays.length <= 1 &&
                              settings.weekdays.contains(weekday))
                      ? null
                      : (_) => onToggleWeekday(weekday),
                );
              }),
            ),
          ),
        ],
        const Divider(),
        const ExpansionTile(
          key: ValueKey('samsung_hint'),
          leading: Icon(Icons.info_outline),
          title: Text('Hinweis für Samsung-Geräte'),
          tilePadding: EdgeInsets.symmetric(horizontal: 16),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Auf Samsung-Geräten können Benachrichtigungen '
                    'zusätzlich blockiert werden:',
                  ),
                  SizedBox(height: 12),
                  _SamsungHintStep(
                    icon: Icons.battery_saver_outlined,
                    text: 'Einstellungen → Apps → Berichtsheft-Merker '
                        '→ Akku → „Nicht eingeschränkt" wählen',
                  ),
                  SizedBox(height: 8),
                  _SamsungHintStep(
                    icon: Icons.do_not_disturb_on_outlined,
                    text: 'Einstellungen → Benachrichtigungen → Nicht '
                        'stören → prüfen, ob die App blockiert wird',
                  ),
                  SizedBox(height: 8),
                  _SamsungHintStep(
                    icon: Icons.notifications_active_outlined,
                    text: 'Einstellungen → Apps → Berichtsheft-Merker '
                        '→ Benachrichtigungen → Kategorie '
                        '„Tägliche Berichtsheft-Erinnerungen" aktivieren',
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ThemeSection extends StatelessWidget {
  final ThemePreset current;
  final Future<void> Function(ThemePreset)? onChanged;

  const _ThemeSection({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return AppSettingsSection(
      title: 'Darstellung',
      description: 'Farbtheme der App.',
      children: [
        ListTile(
          key: const ValueKey('theme_selector'),
          leading: const Icon(Icons.palette_outlined),
          title: const Text('Farbtheme'),
          subtitle: Text(current.label),
          trailing: const Icon(Icons.chevron_right),
          onTap: onChanged == null
              ? null
              : () => _openSelector(context),
        ),
      ],
    );
  }

  Future<void> _openSelector(BuildContext context) async {
    await showDialog<ThemePreset>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Farbtheme wählen'),
        children: ThemePreset.values.map((preset) {
          return RadioListTile<ThemePreset>(
            key: ValueKey('theme_${preset.name}'),
            title: Text(preset.label),
            value: preset,
            groupValue: current,
            onChanged: (value) async {
              if (value != null) {
                try {
                  await onChanged!(value);
                  if (context.mounted) Navigator.of(context).pop();
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Das Farbtheme konnte nicht gespeichert werden.',
                        ),
                      ),
                    );
                  }
                }
              }
            },
          );
        }).toList(),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final StoredProfile profile;

  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = profile.name?.trim();
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              child: const Icon(Icons.person_outline, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name == null || name.isEmpty ? 'Dein Profil' : name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Ausbildung und App-Einstellungen',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SamsungHintStep extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SamsungHintStep({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: theme.textTheme.bodySmall),
        ),
      ],
    );
  }
}

class _ProfileEditScreen extends StatelessWidget {
  final StoredProfile profile;
  final ProfileSubmitCallback onSave;

  const _ProfileEditScreen({
    required this.profile,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil bearbeiten')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          ProfileForm(
            initialName: profile.name,
            initialCompany: profile.company,
            initialOccupation: profile.occupation,
            initialTrainingYear: profile.trainingYear,
            submitLabel: 'Profil speichern',
            submitIcon: Icons.save_outlined,
            onSubmit: ({
              name,
              company,
              required occupation,
              required trainingYear,
            }) async {
              await onSave(
                name: name,
                company: company,
                occupation: occupation,
                trainingYear: trainingYear,
              );
              if (context.mounted) {
                Navigator.of(context).pop(true);
              }
            },
          ),
        ],
      ),
    );
  }
}
