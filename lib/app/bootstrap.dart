import 'package:flutter/material.dart';
import '../core/profile_storage.dart';
import '../core/services/notification_service.dart';
import '../core/storage/activity_template_storage.dart';
import '../core/storage/daily_entry_storage.dart';
import '../core/storage/hive_activity_template_storage.dart';
import '../core/storage/hive_daily_entry_storage.dart';
import '../core/storage/theme_preset_storage.dart';
import '../shared/widgets/app_ui.dart';
import 'app.dart';
import 'theme.dart';

class BootstrapData {
  final DailyEntryStorage dailyEntryStorage;
  final ActivityTemplateStorage templateStorage;
  final StoredProfile profile;
  final ThemePreset themePreset;

  const BootstrapData({
    required this.dailyEntryStorage,
    required this.templateStorage,
    required this.profile,
    required this.themePreset,
  });
}

typedef BootstrapLoader = Future<BootstrapData> Function();

class AppBootstrap extends StatefulWidget {
  final BootstrapLoader loader;
  final NotificationScheduler? notificationScheduler;
  final AppClock clock;

  const AppBootstrap({
    super.key,
    this.loader = loadBootstrapData,
    this.notificationScheduler,
    this.clock = DateTime.now,
  });

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

Future<BootstrapData> loadBootstrapData() async {
  final dailyEntryStorage = await HiveDailyEntryStorage.open();
  final templateStorage = await HiveActivityTemplateStorage.open();
  final profile = await ProfileStorage.load();
  final themePreset = await ThemePresetStorage.load();
  return BootstrapData(
    dailyEntryStorage: dailyEntryStorage,
    templateStorage: templateStorage,
    profile: profile,
    themePreset: themePreset,
  );
}

class _AppBootstrapState extends State<AppBootstrap> {
  BootstrapData? _data;
  Object? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await widget.loader();
      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    if (data != null) {
      final profile = data.profile;
      return BerichtsheftApp(
        dailyEntryStorage: data.dailyEntryStorage,
        templateStorage: data.templateStorage,
        initialOnboardingCompleted:
            ProfileStorage.isOnboardingComplete(profile),
        initialName: profile.name,
        initialCompany: profile.company,
        initialOccupation: profile.occupation,
        initialTrainingYear: profile.trainingYear,
        initialThemePreset: data.themePreset,
        notificationScheduler: widget.notificationScheduler,
        clock: widget.clock,
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildThemeForPreset(ThemePreset.lagerTeal),
      home: Scaffold(
        appBar: AppBar(title: const Text('Berichtsheft-Merker')),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : AppEmptyState(
                icon: Icons.error_outline,
                title: 'App-Daten nicht verfügbar',
                message:
                    'Die lokalen Daten konnten nicht geöffnet werden. Deine Daten wurden nicht verändert.',
                action: FilledButton.icon(
                  key: const ValueKey('retry_bootstrap'),
                  onPressed: _error == null ? null : _load,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Erneut versuchen'),
                ),
              ),
      ),
    );
  }
}
