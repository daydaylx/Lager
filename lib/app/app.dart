import 'package:flutter/material.dart';
import 'theme.dart';
import '../core/constants.dart';
import '../core/profile_storage.dart';
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
  final NotificationScheduler? notificationScheduler;
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
    this.notificationScheduler,
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
  late final NotificationScheduler _notificationScheduler;
  late ThemePreset _themePreset;

  @override
  void initState() {
    super.initState();
    _onboardingCompleted = widget.initialOnboardingCompleted;
    _name = widget.initialName;
    _company = widget.initialCompany;
    _occupation = widget.initialOccupation;
    _trainingYear = widget.initialTrainingYear;
    _themePreset = widget.initialThemePreset;
    _notificationScheduler = widget.notificationScheduler ??
        const FlutterLocalNotificationScheduler();
  }

  Future<void> _completeOnboarding({
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
      completeOnboarding: true,
    );

    if (mounted) {
      setState(() {
        _onboardingCompleted = true;
        _name = name;
        _company = company;
        _occupation = occupation;
        _trainingYear = trainingYear;
      });
    }
  }

  Future<void> _profileChanged({
    String? name,
    String? company,
    required String occupation,
    required int trainingYear,
  }) async {
    if (!mounted) return;
    setState(() {
      _name = name;
      _company = company;
      _occupation = occupation;
      _trainingYear = trainingYear;
    });
  }

  Future<void> _resetAll() async {
    await _notificationScheduler.cancelAll();
    await widget.dailyEntryStorage.clearAll();
    await widget.templateStorage.clearAll();
    await const DefaultActivityStateStorage().clearAll();
    await ProfileStorage.clearAll();

    if (mounted) {
      setState(() {
        _onboardingCompleted = false;
        _name = null;
        _company = null;
        _occupation = null;
        _trainingYear = null;
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
              trainingYear: _trainingYear,
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
  final ProfileSubmitCallback? onProfileChanged;
  final ThemePreset themePreset;
  final Future<void> Function(ThemePreset) onThemeChanged;
  final AppClock clock;

  const MainShell({
    super.key,
    required this.dailyEntryStorage,
    required this.templateStorage,
    this.defaultActivityStateStorage = const DefaultActivityStateStorage(),
    required this.onDataCleared,
    required this.notificationScheduler,
    this.trainingYear,
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
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentDate = _normalizedDate(widget.clock());
    _initializeNotifications();
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
    }
  }

  Future<void> _initializeNotifications() async {
    try {
      final initialPayload =
          await widget.notificationScheduler.initialize(_handleNotificationTap);
      _handleNotificationTap(initialPayload);
    } catch (_) {
      if (mounted) {
        setState(() {
          _notificationInitializationError =
              'Reminder konnten nicht initialisiert werden. Prüfe App-Berechtigungen oder starte die App neu.';
        });
      }
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
          ),
          WeekScreen(
            storage: widget.dailyEntryStorage,
            templateStorage: widget.templateStorage,
            defaultActivityStateStorage: widget.defaultActivityStateStorage,
            refreshSignal: _weekRefreshSignal,
            templateRefreshSignal: _templateRefreshSignal,
            currentDate: _currentDate,
            onNavigateToToday: () => setState(() => _currentIndex = 0),
          ),
          TemplatesScreen(
            storage: widget.templateStorage,
            defaultActivityStateStorage: widget.defaultActivityStateStorage,
            dailyEntryStorage: widget.dailyEntryStorage,
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
