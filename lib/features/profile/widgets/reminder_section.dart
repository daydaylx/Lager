import 'package:flutter/material.dart';

import '../../../core/models/reminder_settings.dart';
import '../../../core/services/notification_service.dart';
import '../../../shared/widgets/app_ui.dart';

class ReminderSection extends StatelessWidget {
  static const _weekdayLabels = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

  final ReminderSettings settings;
  final ReminderRuntimeStatus status;
  final String? error;
  final bool isSaving;
  final bool isTesting;
  final VoidCallback? onOpenSettings;
  final VoidCallback onRequestPermissions;
  final VoidCallback onRepair;
  final VoidCallback onTest;
  final ValueChanged<bool> onToggle;
  final ValueChanged<TimeOfDay> onChangeTime;
  final ValueChanged<int> onToggleWeekday;

  const ReminderSection({
    super.key,
    required this.settings,
    required this.status,
    required this.error,
    required this.isSaving,
    required this.isTesting,
    required this.onOpenSettings,
    required this.onRequestPermissions,
    required this.onRepair,
    required this.onTest,
    required this.onToggle,
    required this.onChangeTime,
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
        if (settings.enabled) ...[
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: _ReminderStatusMessage(
              status: status,
              isSaving: isSaving,
              onOpenSettings: onOpenSettings,
              onRequestPermissions: onRequestPermissions,
              onRepair: onRepair,
            ),
          ),
        ],
        if (error case final msg?) ...[
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: AppMessage(
              icon: Icons.error_outline,
              title: msg,
              tone: AppMessageTone.error,
            ),
          ),
        ],
        if (settings.enabled) ...[
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Uhrzeit',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          ListTile(
            key: const ValueKey('reminder_time'),
            leading: const Icon(Icons.schedule_outlined),
            title: Text(settings.time.toDisplayString()),
            trailing: const Icon(Icons.edit_outlined),
            enabled: !isSaving,
            onTap: isSaving
                ? null
                : () async {
                    final time = settings.time;
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: time.hour,
                        minute: time.minute,
                      ),
                    );
                    if (picked != null) onChangeTime(picked);
                  },
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
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: OutlinedButton.icon(
              key: const ValueKey('reminder_test'),
              onPressed: isSaving || isTesting || status.isPermissionBlocked
                  ? null
                  : onTest,
              icon: isTesting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.notifications_active_outlined),
              label: Text(
                isTesting ? 'Test wird vorbereitet …' : 'Testbenachrichtigung',
              ),
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

class _ReminderStatusMessage extends StatelessWidget {
  final ReminderRuntimeStatus status;
  final bool isSaving;
  final VoidCallback? onOpenSettings;
  final VoidCallback onRequestPermissions;
  final VoidCallback onRepair;

  const _ReminderStatusMessage({
    required this.status,
    required this.isSaving,
    required this.onOpenSettings,
    required this.onRequestPermissions,
    required this.onRepair,
  });

  @override
  Widget build(BuildContext context) {
    final planned =
        '${status.pendingCount} von ${status.expectedCount} Tagen geplant';
    return switch (status.state) {
      ReminderRuntimeState.disabled => const AppMessage(
          icon: Icons.notifications_off_outlined,
          title: 'Erinnerung ist aus',
        ),
      ReminderRuntimeState.readyExact => AppMessage(
          key: const ValueKey('reminder_status_exact'),
          icon: Icons.check_circle_outline,
          title: 'Bereit – minutengenau',
          message: planned,
          tone: AppMessageTone.success,
        ),
      ReminderRuntimeState.readyApproximate => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppMessage(
              key: const ValueKey('reminder_status_approximate'),
              icon: Icons.schedule_outlined,
              title: 'Aktiv – Uhrzeit kann abweichen',
              message: '$planned. Android darf die Erinnerung später anzeigen.',
              tone: AppMessageTone.warning,
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              key: const ValueKey('reminder_request_exact'),
              onPressed: isSaving ? null : onRequestPermissions,
              icon: const Icon(Icons.alarm_on_outlined),
              label: const Text('Minutengenaue Alarme erlauben'),
            ),
          ],
        ),
      ReminderRuntimeState.blocked => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppMessage(
              key: const ValueKey('reminder_status_blocked'),
              icon: Icons.notifications_off_outlined,
              title: 'Benachrichtigungen sind blockiert',
              message: planned,
              tone: AppMessageTone.error,
            ),
            if (onOpenSettings != null) ...[
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: onOpenSettings,
                icon: const Icon(Icons.settings_outlined),
                label: const Text('Benachrichtigungseinstellungen öffnen'),
              ),
            ],
          ],
        ),
      ReminderRuntimeState.error => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppMessage(
              key: const ValueKey('reminder_status_error'),
              icon: Icons.sync_problem_outlined,
              title: 'Planung unvollständig',
              message: planned,
              tone: AppMessageTone.error,
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              key: const ValueKey('reminder_repair'),
              onPressed: isSaving ? null : onRepair,
              icon: const Icon(Icons.refresh),
              label: const Text('Neu planen'),
            ),
          ],
        ),
    };
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
