import 'package:flutter/material.dart';
import 'theme.dart';
import '../core/constants.dart';
import '../core/profile_storage.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/today/today_screen.dart';
import '../features/week/week_screen.dart';
import '../features/templates/templates_screen.dart';
import '../features/profile/profile_screen.dart';

class BerichtsheftApp extends StatefulWidget {
  final bool initialOnboardingCompleted;
  final String? initialName;
  final String? initialCompany;
  final String? initialOccupation;
  final int? initialTrainingYear;

  const BerichtsheftApp({
    super.key,
    required this.initialOnboardingCompleted,
    this.initialName,
    this.initialCompany,
    this.initialOccupation,
    this.initialTrainingYear,
  });

  @override
  State<BerichtsheftApp> createState() => _BerichtsheftAppState();
}

class _BerichtsheftAppState extends State<BerichtsheftApp> {
  late bool _onboardingCompleted;

  @override
  void initState() {
    super.initState();
    _onboardingCompleted = widget.initialOnboardingCompleted;
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
      setState(() => _onboardingCompleted = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: buildAppTheme(),
      home: _onboardingCompleted
          ? const MainShell()
          : OnboardingScreen(
              initialName: widget.initialName,
              initialCompany: widget.initialCompany,
              initialOccupation: widget.initialOccupation,
              initialTrainingYear: widget.initialTrainingYear,
              onComplete: _completeOnboarding,
            ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    TodayScreen(),
    WeekScreen(),
    TemplatesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
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
