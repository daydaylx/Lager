import 'package:flutter/material.dart';
import '../core/ai/ai_report_cache.dart';
import '../core/ai/hive_ai_report_cache.dart';
import '../core/ai/openrouter_config.dart';
import '../core/profile_storage.dart';
import '../core/services/notification_service.dart';
import '../core/storage/activity_template_storage.dart';
import '../core/storage/daily_entry_storage.dart';
import '../core/storage/default_activity_state_storage.dart';
import '../core/storage/hive_activity_template_storage.dart';
import '../core/storage/hive_daily_entry_storage.dart';
import '../core/storage/theme_preset_storage.dart';
import '../core/school/storage/hive_school_data_storage.dart';
import '../core/school/storage/in_memory_school_data_storage.dart';
import '../core/school/storage/school_data_storage.dart';
import '../shared/widgets/app_ui.dart';
import 'app.dart';
import 'theme.dart';

class BootstrapData {
  final DailyEntryStorage dailyEntryStorage;
  final ActivityTemplateStorage templateStorage;
  final SchoolDataStorage schoolDataStorage;
  final DefaultActivityStateStorage defaultActivityStateStorage;
  final StoredProfile profile;
  final ThemePreset themePreset;
  final AiReportCache aiReportCache;
  final OpenRouterConfig openRouterConfig;

  const BootstrapData({
    required this.dailyEntryStorage,
    required this.templateStorage,
    required this.defaultActivityStateStorage,
    this.schoolDataStorage = const UnavailableSchoolDataStorage(
      'Der Schulbereich wurde nicht initialisiert.',
    ),
    required this.profile,
    required this.themePreset,
    this.aiReportCache = const DisabledAiReportCache(),
    this.openRouterConfig = OpenRouterConfig.disabled,
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
  SchoolDataStorage schoolDataStorage;
  try {
    schoolDataStorage = await HiveSchoolDataStorage.open();
  } catch (_) {
    schoolDataStorage = const UnavailableSchoolDataStorage(
      'Die lokalen Schuldaten konnten nicht geöffnet werden.',
    );
  }
  final profile = await ProfileStorage.load();
  final themePreset = await ThemePresetStorage.load();
  AiReportCache aiReportCache = const DisabledAiReportCache();
  try {
    aiReportCache = await HiveAiReportCache.open();
  } catch (_) {
    // The optional report cache must never block local bootstrap.
  }
  return BootstrapData(
    dailyEntryStorage: dailyEntryStorage,
    templateStorage: templateStorage,
    defaultActivityStateStorage: const DefaultActivityStateStorage(),
    schoolDataStorage: schoolDataStorage,
    profile: profile,
    themePreset: themePreset,
    aiReportCache: aiReportCache,
    openRouterConfig: const OpenRouterConfig.fromEnvironment(),
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
        schoolDataStorage: data.schoolDataStorage,
        defaultActivityStateStorage: data.defaultActivityStateStorage,
        initialOnboardingCompleted:
            ProfileStorage.isOnboardingComplete(profile),
        initialName: profile.name,
        initialCompany: profile.company,
        initialOccupation: profile.occupation,
        initialTrainingYear: profile.trainingYear,
        initialWahlqualifikation: profile.wahlqualifikation,
        initialVertiefungswahlqualifikationen:
            profile.vertiefungswahlqualifikationen,
        initialThemePreset: data.themePreset,
        aiReportCache: data.aiReportCache,
        openRouterConfig: data.openRouterConfig,
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
