import 'package:flutter/material.dart';
import 'theme.dart';
import '../core/constants.dart';
import '../core/profile_storage.dart';
import '../core/services/notification_service.dart';
import '../core/storage/activity_template_storage.dart';
import '../core/storage/daily_entry_storage.dart';
import '../core/storage/reminder_storage.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/today/today_screen.dart';
import '../features/week/week_screen.dart';
import '../features/templates/templates_screen.dart';
import '../features/profile/profile_screen.dart';

class BerichtsheftApp extends StatefulWidget {
  final DailyEntryStorage dailyEntryStorage;
  final ActivityTemplateStorage templateStorage;
  final bool initialOnboardingCompleted;
  final String? initialName;
  final String? initialCompany;
  final String? initialOccupation;
  final int? initialTrainingYear;
  final NotificationScheduler? notificationScheduler;

  const BerichtsheftApp({
    super.key,
    required this.dailyEntryStorage,
    required this.templateStorage,
    required this.initialOnboardingCompleted,
    this.initialName,
    this.initialCompany,
    this.initialOccupation,
    this.initialTrainingYear,
    this.notificationScheduler,
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

  @override
  void initState() {
    super.initState();
    _onboardingCompleted = widget.initialOnboardingCompleted;
    _name = widget.initialName;
    _company = widget.initialCompany;
    _occupation = widget.initialOccupation;
    _trainingYear = widget.initialTrainingYear;
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

  Future<void> _resetAll() async {
    await _notificationScheduler.cancelAll();
    await widget.dailyEntryStorage.clearAll();
    await widget.templateStorage.clearAll();
    await ProfileStorage.clearAll();

    if (mounted) {
      setState(() {
        _onboardingCompleted = false;
        _name = null;
        _company = null;
        _occupation = null;
        _trainingYear = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: buildAppTheme(),
      darkTheme: buildDarkAppTheme(),
      themeMode: ThemeMode.dark,
      home: _onboardingCompleted
          ? MainShell(
              dailyEntryStorage: widget.dailyEntryStorage,
              templateStorage: widget.templateStorage,
              onDataCleared: _resetAll,
              notificationScheduler: _notificationScheduler,
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
  final Future<void> Function() onDataCleared;
  final NotificationScheduler notificationScheduler;

  const MainShell({
    super.key,
    required this.dailyEntryStorage,
    required this.templateStorage,
    required this.onDataCleared,
    required this.notificationScheduler,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  int _weekRefreshSignal = 0;
  int _templateRefreshSignal = 0;

  @override
  void initState() {
    super.initState();
    FlutterLocalNotificationScheduler.setOnTap(_handleNotificationTap);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkTodayEntry());
  }

  @override
  void dispose() {
    FlutterLocalNotificationScheduler.setOnTap(null);
    super.dispose();
  }

  void _handleNotificationTap(String? payload) {
    if (payload == 'today' && mounted) {
      setState(() => _currentIndex = 0);
    }
  }

  Future<void> _checkTodayEntry() async {
    if (!mounted) return;
    final now = DateTime.now();
    if (now.weekday > DateTime.friday) return;
    final today = DateTime(now.year, now.month, now.day);
    final entry = await widget.dailyEntryStorage.loadByDate(today);
    if (!mounted || entry != null) return;
    final settings = await ReminderStorage.load();
    if (!mounted || !settings.enabled) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Heutiger Eintrag fehlt noch – jetzt kurz eintragen?'),
        duration: Duration(seconds: 5),
      ),
    );
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
            templateRefreshSignal: _templateRefreshSignal,
            protectBackNavigation: _currentIndex == 0,
          ),
          WeekScreen(
            storage: widget.dailyEntryStorage,
            templateStorage: widget.templateStorage,
            refreshSignal: _weekRefreshSignal,
            templateRefreshSignal: _templateRefreshSignal,
          ),
          TemplatesScreen(
            storage: widget.templateStorage,
            onTemplatesChanged: () {
              setState(() => _templateRefreshSignal++);
            },
          ),
          ProfileScreen(
            onDataCleared: widget.onDataCleared,
            notificationScheduler: widget.notificationScheduler,
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
}
