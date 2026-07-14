import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/constants.dart';
import '../../core/models/reminder_settings.dart';
import '../../core/profile_storage.dart';
import '../../core/services/export_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/storage/activity_template_storage.dart';
import '../../core/storage/daily_entry_storage.dart';
import '../../shared/widgets/app_ui.dart';
import '../../shared/widgets/profile_form.dart';
import 'profile_reminder_controller.dart';
import 'widgets/profile_edit_screen.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_theme_section.dart';
import 'widgets/reminder_section.dart';

class ProfileScreen extends StatefulWidget {
  final DailyEntryStorage dailyEntryStorage;
  final ActivityTemplateStorage templateStorage;
  final Future<void> Function() onDataCleared;
  final NotificationScheduler? notificationScheduler;
  final String? notificationInitializationError;
  final ProfileSubmitCallback? onProfileChanged;
  final ThemePreset themePreset;
  final Future<void> Function(ThemePreset)? onThemeChanged;

  const ProfileScreen({
    super.key,
    required this.dailyEntryStorage,
    required this.templateStorage,
    required this.onDataCleared,
    this.notificationScheduler,
    this.notificationInitializationError,
    this.onProfileChanged,
    this.themePreset = ThemePreset.lagerTeal,
    this.onThemeChanged,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver {
  StoredProfile? _profile;
  bool _loadFailed = false;
  ReminderSettings _reminderSettings = ReminderSettings.defaults;
  late final NotificationScheduler _scheduler;
  late final ProfileReminderController _reminderController;
  bool _isReminderSaving = false;
  bool _isDeleting = false;
  bool _isExporting = false;
  String? _reminderError;
  bool _notificationsBlockedBySystem = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduler = widget.notificationScheduler ??
        const FlutterLocalNotificationScheduler();
    _reminderController = ProfileReminderController(scheduler: _scheduler);
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
    final result = await _reminderController.checkPermission(
      settings: _reminderSettings,
      currentError: _reminderError,
    );
    if (result == null || !mounted) return;
    setState(() {
      _notificationsBlockedBySystem = result.notificationsBlockedBySystem;
      _reminderError = result.error;
    });
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
    await widget.onProfileChanged?.call(
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
        builder: (context) => ProfileEditScreen(
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
    final result = await _reminderController.load(
      notificationsBlockedBySystem: _notificationsBlockedBySystem,
    );
    if (!mounted) return;
    final loadedSettings = result.settings;
    setState(() {
      if (loadedSettings case final settings?) {
        _reminderSettings = settings;
      }
      _reminderError = result.error;
    });
    if (loadedSettings?.enabled ?? false) {
      await _checkNotificationPermission();
    }
  }

  Future<void> _saveAndReschedule(ReminderSettings settings) async {
    if (_isReminderSaving) return;
    final previous = _reminderSettings;
    setState(() {
      _isReminderSaving = true;
      _reminderError = null;
    });

    final result = await _reminderController.saveAndReschedule(
      previous: previous,
      next: settings,
    );
    if (!mounted) return;
    setState(() {
      _reminderSettings = result.settings;
      _isReminderSaving = false;
      _reminderError = result.error;
      if (result.notificationsBlockedBySystem case final blocked?) {
        _notificationsBlockedBySystem = blocked;
      }
    });
  }

  Future<void> _toggleReminder(bool value) async {
    await _applyReminderEdit(
      _reminderController.toggleEnabled(_reminderSettings, value),
    );
  }

  Future<void> _changeTime(TimeOfDay picked) async {
    await _applyReminderEdit(
      _reminderController.changeTime(
        _reminderSettings,
        ReminderTime(hour: picked.hour, minute: picked.minute),
      ),
    );
  }

  Future<void> _toggleWeekday(int weekday) async {
    await _applyReminderEdit(
      _reminderController.toggleWeekday(_reminderSettings, weekday),
    );
  }

  Future<void> _applyReminderEdit(ReminderSettingsEdit edit) async {
    if (edit.error case final error?) {
      setState(() => _reminderError = error);
      return;
    }
    if (edit.settings case final settings?) {
      await _saveAndReschedule(settings);
    }
  }

  Future<void> _exportData() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    try {
      await ExportService.share(
        widget.dailyEntryStorage,
        widget.templateStorage,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Export fehlgeschlagen. Bitte versuche es erneut.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
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
        ProfileHeader(
          key: const ValueKey('profile_header'),
          profile: profile,
          onTap: _openProfileEditor,
        ),
        const SizedBox(height: 24),
        ReminderSection(
          settings: _reminderSettings,
          error: _reminderError ?? widget.notificationInitializationError,
          isSaving: _isReminderSaving,
          isPermissionBlocked: _notificationsBlockedBySystem,
          onOpenSettings: _openNotificationSettings,
          onToggle: _toggleReminder,
          onChangeTime: _changeTime,
          onToggleWeekday: _toggleWeekday,
        ),
        const SizedBox(height: 24),
        ProfileThemeSection(
          current: widget.themePreset,
          onChanged: widget.onThemeChanged,
        ),
        const SizedBox(height: 24),
        AppSettingsSection(
          title: 'Daten & Datenschutz',
          description: 'Alle Inhalte bleiben lokal auf diesem Gerät.',
          children: [
            ListTile(
              key: const ValueKey('export_data'),
              leading: _isExporting
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_outlined),
              title: Text(
                _isExporting
                    ? 'Export wird vorbereitet …'
                    : 'Daten exportieren',
              ),
              subtitle: const Text(
                'Erstellt eine JSON-Datei mit allen Einträgen.',
              ),
              enabled: !_isExporting,
              onTap: _isExporting ? null : _exportData,
            ),
            const Divider(),
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
}
