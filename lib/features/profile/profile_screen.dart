import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/models/reminder_settings.dart';
import '../../core/profile_storage.dart';
import '../../core/services/notification_service.dart';
import '../../core/storage/reminder_storage.dart';
import '../../shared/widgets/profile_form.dart';

class ProfileScreen extends StatefulWidget {
  final Future<void> Function() onDataCleared;
  final NotificationScheduler? notificationScheduler;

  const ProfileScreen({
    super.key,
    required this.onDataCleared,
    this.notificationScheduler,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  StoredProfile? _profile;
  bool _loadFailed = false;
  ReminderSettings _reminderSettings = ReminderSettings.defaults;
  late final NotificationScheduler _scheduler;

  static const _weekdayLabels = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

  @override
  void initState() {
    super.initState();
    _scheduler =
        widget.notificationScheduler ?? const FlutterLocalNotificationScheduler();
    _loadProfile();
    _loadReminderSettings();
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

  Future<void> _loadReminderSettings() async {
    try {
      final settings = await ReminderStorage.load();
      if (mounted) setState(() => _reminderSettings = settings);
    } catch (_) {
      // keep defaults on error
    }
  }

  Future<void> _saveAndReschedule(ReminderSettings settings) async {
    await ReminderStorage.save(settings);
    await _scheduler.schedule(settings);
    if (mounted) setState(() => _reminderSettings = settings);
  }

  Future<void> _toggleReminder(bool value) async {
    await _saveAndReschedule(_reminderSettings.copyWith(enabled: value));
  }

  Future<void> _deleteTime(int index) async {
    final times = [..._reminderSettings.times]..removeAt(index);
    await _saveAndReschedule(_reminderSettings.copyWith(times: times));
  }

  Future<void> _addTime(TimeOfDay picked) async {
    final times = [
      ..._reminderSettings.times,
      ReminderTime(hour: picked.hour, minute: picked.minute),
    ];
    await _saveAndReschedule(_reminderSettings.copyWith(times: times));
  }

  Future<void> _toggleWeekday(int weekday) async {
    final current = List<int>.from(_reminderSettings.weekdays);
    if (current.contains(weekday)) {
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
      await widget.onDataCleared();
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Dein Profil konnte nicht geladen werden.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadProfile,
                icon: const Icon(Icons.refresh),
                label: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
      );
    }

    final profile = _profile;
    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        ProfileForm(
          initialName: profile.name,
          initialCompany: profile.company,
          initialOccupation: profile.occupation,
          initialTrainingYear: profile.trainingYear,
          submitLabel: 'Profil speichern',
          submitIcon: Icons.save_outlined,
          successMessage: 'Profil gespeichert.',
          onSubmit: _saveProfile,
        ),
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 16),
        _buildReminderSection(),
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.error,
            side: BorderSide(color: colorScheme.error),
            minimumSize: const Size.fromHeight(48),
          ),
          onPressed: _confirmAndDeleteAll,
          icon: const Icon(Icons.delete_forever_outlined),
          label: const Text('Alle Daten löschen'),
        ),
        const SizedBox(height: 32),
        Text(
          'Version $kAppVersion',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildReminderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Erinnerungen',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        SwitchListTile(
          key: const ValueKey('reminder_toggle'),
          title: const Text('Täglich erinnern'),
          value: _reminderSettings.enabled,
          onChanged: _toggleReminder,
          contentPadding: EdgeInsets.zero,
        ),
        if (_reminderSettings.enabled) ...[
          ..._reminderSettings.times.asMap().entries.map((entry) {
            final index = entry.key;
            final time = entry.value;
            return ListTile(
              key: ValueKey('reminder_time_$index'),
              contentPadding: EdgeInsets.zero,
              title: Text(time.toDisplayString()),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _deleteTime(index),
              ),
            );
          }),
          TextButton.icon(
            key: const ValueKey('reminder_add_time'),
            onPressed: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: const TimeOfDay(hour: 20, minute: 0),
              );
              if (picked != null) await _addTime(picked);
            },
            icon: const Icon(Icons.add),
            label: const Text('Zeit hinzufügen'),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(7, (i) {
              final weekday = i + 1;
              return FilterChip(
                key: ValueKey('reminder_weekday_$weekday'),
                label: Text(_weekdayLabels[i]),
                selected: _reminderSettings.weekdays.contains(weekday),
                onSelected: (_) => _toggleWeekday(weekday),
              );
            }),
          ),
        ],
      ],
    );
  }
}
