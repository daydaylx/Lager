import 'package:flutter/material.dart';
import 'theme.dart';
import '../core/ai/ai_report_cache.dart';
import '../core/ai/openrouter_config.dart';
import '../core/ai/openrouter_report_enhancer.dart';
import '../core/ai/report_enhancement_coordinator.dart';
import '../core/ai/resolved_report.dart';
import '../core/constants.dart';
import '../core/profile_storage.dart';
import '../core/services/app_shortcut_service.dart';
import '../core/services/notification_service.dart';
import '../core/storage/activity_template_storage.dart';
import '../core/storage/daily_entry_storage.dart';
import '../core/storage/default_activity_state_storage.dart';
import '../core/storage/reminder_storage.dart';
import '../core/storage/theme_preset_storage.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/today/today_screen.dart';
import '../features/week/week_screen.dart';
import '../features/templates/templates_screen.dart';
import '../features/profile/profile_screen.dart';
import '../shared/widgets/profile_form.dart';

typedef AppClock = DateTime Function();

class BerichtsheftApp extends StatefulWidget {
  final DailyEntryStorage dailyEntryStorage;
  final ActivityTemplateStorage templateStorage;
  final DefaultActivityStateStorage defaultActivityStateStorage;
  final bool initialOnboardingCompleted;
  final String? initialName;
  final String? initialCompany;
  final String? initialOccupation;
  final int? initialTrainingYear;
  final String? initialWahlqualifikation;
  final NotificationScheduler? notificationScheduler;
  final AiReportCache aiReportCache;
  final OpenRouterConfig openRouterConfig;
  final ThemePreset initialThemePreset;
  final AppClock clock;

  const BerichtsheftApp({
    super.key,
    required this.dailyEntryStorage,
    required this.templateStorage,
    this.defaultActivityStateStorage = const DefaultActivityStateStorage(),
    required this.initialOnboardingCompleted,
    this.initialName,
    this.initialCompany,
    this.initialOccupation,
    this.initialTrainingYear,
    this.initialWahlqualifikation,
    this.notificationScheduler,
    this.aiReportCache = const DisabledAiReportCache(),
    this.openRouterConfig = OpenRouterConfig.disabled,
    this.initialThemePreset = ThemePreset.lagerTeal,
    this.clock = DateTime.now,
  });

  @override
  State<BerichtsheftApp> createState() => _BerichtsheftAppState();
}

class _BerichtsheftAppState extends State<BerichtsheftApp> {
  late bool _onboardingCompleted;
  String? _name;
  String? _company;
  String? _occupation;
  int? _trainingYear;
  String? _wahlqualifikation;
  late final NotificationScheduler _notificationScheduler;
  late final AppShortcutService _appShortcutService;
  late final ReportEnhancementCoordinator _reportCoordinator;
  late final ResolvedReportResolver _reportResolver;
  late ThemePreset _themePreset;

  @override
  void initState() {
    super.initState();
    _onboardingCompleted = widget.initialOnboardingCompleted;
    _name = widget.initialName;
    _company = widget.initialCompany;
    _occupation = widget.initialOccupation;
    _trainingYear = widget.initialTrainingYear;
    _wahlqualifikation = widget.initialWahlqualifikation;
    _themePreset = widget.initialThemePreset;
    _notificationScheduler =
        widget.notificationScheduler ?? FlutterLocalNotificationScheduler();
    _appShortcutService = AppShortcutService();
    _reportCoordinator = ReportEnhancementCoordinator(
      entryStorage: widget.dailyEntryStorage,
      templateStorage: widget.templateStorage,
      cache: widget.aiReportCache,
      enhancer: OpenRouterReportEnhancer(config: widget.openRouterConfig),
      config: widget.openRouterConfig,
    );
    _reportResolver = ResolvedReportResolver(
      cache: widget.aiReportCache,
      templateStorage: widget.templateStorage,
      config: widget.openRouterConfig,
    );
  }

  @override
  void dispose() {
    _reportCoordinator.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding({
    String? name,
    String? company,
    required String occupation,
    required int trainingYear,
    String? wahlqualifikation,
  }) async {
    await ProfileStorage.save(
      name: name,
      company: company,
      occupation: occupation,
      trainingYear: trainingYear,
      wahlqualifikation: wahlqualifikation,
      completeOnboarding: true,
    );

    if (mounted) {
      setState(() {
        _onboardingCompleted = true;
        _name = name;
        _company = company;
        _occupation = occupation;
        _trainingYear = trainingYear;
        _wahlqualifikation = wahlqualifikation;
      });
    }
  }

  Future<void> _profileChanged({
    String? name,
    String? company,
    required String occupation,
    required int trainingYear,
    String? wahlqualifikation,
  }) async {
    if (!mounted) return;
    setState(() {
      _name = name;
      _company = company;
      _occupation = occupation;
      _trainingYear = trainingYear;
      _wahlqualifikation = wahlqualifikation;
    });
  }

  Future<void> _resetAll() async {
    await _notificationScheduler.cancelAll();
    await widget.dailyEntryStorage.clearAll();
    await widget.templateStorage.clearAll();
    await const DefaultActivityStateStorage().clearAll();
    try {
      await _reportCoordinator.clearAll();
    } catch (_) {
      // The optional cache cannot block deletion of primary local data.
    }
    await ProfileStorage.clearAll();

    if (mounted) {
      setState(() {
        _onboardingCompleted = false;
        _name = null;
        _company = null;
        _occupation = null;
        _trainingYear = null;
        _wahlqualifikation = null;
        _themePreset = ThemePreset.lagerTeal;
      });
    }
  }

  Future<void> _onThemeChanged(ThemePreset preset) async {
    await ThemePresetStorage.save(preset);
    if (mounted) setState(() => _themePreset = preset);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: buildThemeForPreset(_themePreset),
      themeMode: ThemeMode.light, // preset controls brightness
      home: _onboardingCompleted
          ? MainShell(
              dailyEntryStorage: widget.dailyEntryStorage,
              templateStorage: widget.templateStorage,
              defaultActivityStateStorage: widget.defaultActivityStateStorage,
              onDataCleared: _resetAll,
              notificationScheduler: _notificationScheduler,
              appShortcutService: _appShortcutService,
              reportCoordinator: _reportCoordinator,
              reportResolver: _reportResolver,
              aiReportCache: widget.aiReportCache,
              trainingYear: _trainingYear,
              occupation: _occupation,
              wahlqualifikation: _wahlqualifikation,
              onProfileChanged: _profileChanged,
              themePreset: _themePreset,
              onThemeChanged: _onThemeChanged,
              clock: widget.clock,
            )
          : OnboardingScreen(
              initialName: _name,
              initialCompany: _company,
              initialOccupation: _occupation,
              initialTrainingYear: _trainingYear,
              onComplete: _completeOnboarding,
            ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainShell extends StatefulWidget {
  final DailyEntryStorage dailyEntryStorage;
  final ActivityTemplateStorage templateStorage;
  final DefaultActivityStateStorage defaultActivityStateStorage;
  final Future<void> Function() onDataCleared;
  final NotificationScheduler notificationScheduler;
  final int? trainingYear;
  final String? occupation;
  final String? wahlqualifikation;
  final ProfileSubmitCallback? onProfileChanged;
  final ThemePreset themePreset;
  final Future<void> Function(ThemePreset) onThemeChanged;
  final AppClock clock;
  final AppShortcutService appShortcutService;
  final ReportEnhancementCoordinator? reportCoordinator;
  final ResolvedReportResolver? reportResolver;
  final AiReportCache aiReportCache;

  const MainShell({
    super.key,
    required this.dailyEntryStorage,
    required this.templateStorage,
    this.defaultActivityStateStorage = const DefaultActivityStateStorage(),
    required this.onDataCleared,
    required this.notificationScheduler,
    required this.appShortcutService,
    this.reportCoordinator,
    this.reportResolver,
    this.aiReportCache = const DisabledAiReportCache(),
    this.trainingYear,
    this.occupation,
    this.wahlqualifikation,
    this.onProfileChanged,
    required this.themePreset,
    required this.onThemeChanged,
    this.clock = DateTime.now,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  int _currentIndex = 0;
  int _weekRefreshSignal = 0;
  int _templateRefreshSignal = 0;
  String? _notificationInitializationError;
  bool _isReconcilingNotifications = false;
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentDate = _normalizedDate(widget.clock());
    _initializeNotifications();
    _initializeAppShortcuts();
    widget.reportCoordinator?.resumePending();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkTodayEntry());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.notificationScheduler.clearOnTap();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshCurrentDate();
      _checkTodayEntry();
      _reconcileNotifications();
    }
  }

  Future<void> _initializeAppShortcuts() async {
    final initial = await widget.appShortcutService.initialize(
      onAction: _handleShortcutAction,
    );
    if (initial != null) {
      _handleShortcutAction(initial);
    }
  }

  void _handleShortcutAction(AppShortcutAction action) {
    if (!mounted) return;
    switch (action) {
      case AppShortcutAction.openToday:
        setState(() => _currentIndex = 0);
        break;
      case AppShortcutAction.unknown:
        break;
    }
  }

  Future<void> _initializeNotifications() async {
    try {
      final initialPayload =
          await widget.notificationScheduler.initialize(_handleNotificationTap);
      _handleNotificationTap(initialPayload);
      await _reconcileNotifications();
    } catch (_) {
      if (mounted) {
        setState(() {
          _notificationInitializationError =
              'Reminder konnten nicht initialisiert werden. Prüfe App-Berechtigungen oder starte die App neu.';
        });
      }
    }
  }

  Future<void> _reconcileNotifications() async {
    if (_isReconcilingNotifications) return;
    _isReconcilingNotifications = true;
    try {
      final settings = await ReminderStorage.load();
      await widget.notificationScheduler.schedule(settings);
      if (mounted && _notificationInitializationError != null) {
        setState(() => _notificationInitializationError = null);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _notificationInitializationError =
              'Android konnte die Erinnerungsplanung noch nicht reparieren. Öffne das Profil und tippe auf „Neu planen“.';
        });
      }
    } finally {
      _isReconcilingNotifications = false;
    }
  }

  void _handleNotificationTap(String? payload) {
    if (payload == 'today' && mounted) {
      setState(() => _currentIndex = 0);
    }
  }

  Future<void> _checkTodayEntry() async {
    if (!mounted) return;
    final now = widget.clock();
    if (now.weekday > DateTime.friday) return;
    try {
      final today = _normalizedDate(now);
      final entry = await widget.dailyEntryStorage.loadByDate(today);
      if (!mounted || entry != null) return;
      final settings = await ReminderStorage.load();
      if (!mounted || !settings.enabled) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Heutiger Eintrag fehlt noch – jetzt kurz eintragen?',
          ),
          action: SnackBarAction(
            label: 'Eintragen',
            onPressed: _openTodayFromMissingEntrySnackBar,
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (_) {
      // The relevant screen provides retry actions for local storage failures.
    }
  }

  void _openTodayFromMissingEntrySnackBar() {
    if (!mounted || _currentIndex == 0) return;
    setState(() => _currentIndex = 0);
  }

  void _refreshCurrentDate() {
    final nextDate = _normalizedDate(widget.clock());
    if (nextDate == _currentDate || !mounted) return;
    setState(() {
      _currentDate = nextDate;
      _weekRefreshSignal++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          TodayScreen(
            storage: widget.dailyEntryStorage,
            templateStorage: widget.templateStorage,
            defaultActivityStateStorage: widget.defaultActivityStateStorage,
            templateRefreshSignal: _templateRefreshSignal,
            protectBackNavigation: _currentIndex == 0,
            currentDate: _currentDate,
            trainingYear: widget.trainingYear,
            occupation: widget.occupation,
            wahlqualifikation: widget.wahlqualifikation,
            reportCoordinator: widget.reportCoordinator,
            reportResolver: widget.reportResolver,
          ),
          WeekScreen(
            storage: widget.dailyEntryStorage,
            templateStorage: widget.templateStorage,
            defaultActivityStateStorage: widget.defaultActivityStateStorage,
            refreshSignal: _weekRefreshSignal,
            templateRefreshSignal: _templateRefreshSignal,
            currentDate: _currentDate,
            onNavigateToToday: () => setState(() => _currentIndex = 0),
            reportCoordinator: widget.reportCoordinator,
            reportResolver: widget.reportResolver,
          ),
          TemplatesScreen(
            storage: widget.templateStorage,
            defaultActivityStateStorage: widget.defaultActivityStateStorage,
            dailyEntryStorage: widget.dailyEntryStorage,
            occupation: widget.occupation,
            onTemplatesChanged: () {
              setState(() => _templateRefreshSignal++);
            },
          ),
          ProfileScreen(
            dailyEntryStorage: widget.dailyEntryStorage,
            templateStorage: widget.templateStorage,
            onDataCleared: widget.onDataCleared,
            notificationScheduler: widget.notificationScheduler,
            notificationInitializationError: _notificationInitializationError,
            onProfileChanged: widget.onProfileChanged,
            themePreset: widget.themePreset,
            onThemeChanged: widget.onThemeChanged,
            aiReportCache: widget.aiReportCache,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
            if (index == 1) {
              _weekRefreshSignal++;
            }
          });
        },
        destinations: const [
          NavigationDestination(
            key: ValueKey('tab_today'),
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: AppStrings.tabToday,
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_view_week_outlined),
            selectedIcon: Icon(Icons.calendar_view_week),
            label: AppStrings.tabWeek,
          ),
          NavigationDestination(
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books),
            label: AppStrings.tabTemplates,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: AppStrings.tabProfile,
          ),
        ],
      ),
    );
  }

  static DateTime _normalizedDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
