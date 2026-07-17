import 'package:berichtsheft_merker/app/theme.dart';
import 'package:berichtsheft_merker/core/constants.dart';
import 'package:berichtsheft_merker/core/enums/day_type.dart';
import 'package:berichtsheft_merker/core/enums/training_area.dart';
import 'package:berichtsheft_merker/core/models/daily_entry.dart';
import 'package:berichtsheft_merker/core/storage/in_memory_activity_template_storage.dart';
import 'package:berichtsheft_merker/core/storage/in_memory_daily_entry_storage.dart';
import 'package:berichtsheft_merker/features/onboarding/onboarding_screen.dart';
import 'package:berichtsheft_merker/features/profile/profile_screen.dart';
import 'package:berichtsheft_merker/features/templates/templates_screen.dart';
import 'package:berichtsheft_merker/features/today/today_screen.dart';
import 'package:berichtsheft_merker/features/week/week_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'test_helpers.dart';

const _phoneSize = Size(400, 800);
final _fixedToday = DateTime(2026, 6, 10);

Widget _themed(Widget child, {double textScale = 1}) {
  return MaterialApp(
    theme: buildThemeForPreset(ThemePreset.lagerTeal),
    builder: (context, child) {
      final mediaQuery = MediaQuery.of(context);
      return MediaQuery(
        data: mediaQuery.copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      );
    },
    home: child,
  );
}

Widget _themedLight(Widget child) {
  return MaterialApp(
    theme: buildThemeForPreset(ThemePreset.hell),
    home: child,
  );
}

Future<void> _setSize(WidgetTester tester, Size size) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

DailyEntry _entry(
  DateTime date, {
  DayType dayType = DayType.betrieb,
}) {
  return DailyEntry(
    id: DailyEntry.idForDate(date),
    date: date,
    dayType: dayType,
    areas: dayType == DayType.betrieb
        ? const [TrainingArea.wareneingang]
        : const [],
    selectedActivities:
        dayType == DayType.betrieb ? const ['wareneingang_01'] : const [],
    specialFlags: const [],
    reportNote: null,
    createdAt: date,
    updatedAt: date,
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('mobile layout', () {
    testWidgets(
        'Onboarding bleibt auf kleinem Display mit großer Schrift nutzbar',
        (tester) async {
      await _setSize(tester, const Size(360, 640));
      await tester.pumpWidget(
        _themed(
          OnboardingScreen(
            onComplete: ({
              name,
              company,
              required occupation,
              required trainingYear,
            }) async {},
          ),
          textScale: 1.5,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('onboarding_continue')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Heute-Checkliste und Speichern haben große Touchflächen',
        (tester) async {
      await _setSize(tester, const Size(360, 640));
      await tester.pumpWidget(
        _themed(
          TodayScreen(
            storage: InMemoryDailyEntryStorage(),
            templateStorage: InMemoryActivityTemplateStorage(),
            currentDate: _fixedToday,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('day_type_betrieb')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('area_wareneingang')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('today_flow_continue')));
      await tester.pumpAndSettle();

      final activity = find.byKey(const ValueKey('activity_wareneingang_01'));
      await tester.scrollUntilVisible(
        activity,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(tester.getSize(activity).height, greaterThanOrEqualTo(48));
      expect(
        tester.getSize(find.byKey(const ValueKey('today_flow_continue'))).height,
        greaterThanOrEqualTo(48),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('Vorlagen-Bottom-Sheet bleibt mit Tastatur bedienbar',
        (tester) async {
      await _setSize(tester, const Size(360, 640));
      await tester.pumpWidget(
        _themed(
          TemplatesScreen(storage: InMemoryActivityTemplateStorage()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();

      expect(
          find.byKey(const ValueKey('template_title_field')), findsOneWidget);
      expect(find.text('Hinzufügen'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Heute-Notiz und Speichern bleiben mit Tastatur erreichbar',
        (tester) async {
      await _setSize(tester, const Size(360, 640));
      await tester.pumpWidget(
        _themed(
          TodayScreen(
            storage: InMemoryDailyEntryStorage(),
            templateStorage: InMemoryActivityTemplateStorage(),
            currentDate: _fixedToday,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await selectAbsenceType(tester, DayType.sonstiges);
      // After selecting sonstiges the optional section auto-expands;
      // scroll to the note field which is now in the expanded tile
      final note = find.byKey(const ValueKey('daily_report_note_field'));
      await tester.scrollUntilVisible(
        note,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.showKeyboard(note);
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('save_daily_entry')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Profilübersicht bleibt mit großer Schrift scrollbar',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.trainingOccupation:
            TrainingOccupationValues.fachkraftLagerlogistik,
        PreferenceKeys.trainingYear: 2,
      });
      await _setSize(tester, const Size(360, 640));
      await tester.pumpWidget(
        _themed(
          ProfileScreen(
            dailyEntryStorage: InMemoryDailyEntryStorage(),
            templateStorage: InMemoryActivityTemplateStorage(),
            onDataCleared: () async {},
          ),
          textScale: 1.5,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('profile_header')), findsOneWidget);
      expect(find.byType(Scrollable), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  group('goldens', () {
    testWidgets('Onboarding welcome', (tester) async {
      await _setSize(tester, _phoneSize);
      await tester.pumpWidget(
        _themed(
          OnboardingScreen(
            onComplete: ({
              name,
              company,
              required occupation,
              required trainingYear,
            }) async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/onboarding_welcome.png'),
      );
    });

    testWidgets('Heute empty', (tester) async {
      await _setSize(tester, _phoneSize);
      await tester.pumpWidget(
        _themed(
          TodayScreen(
            storage: InMemoryDailyEntryStorage(),
            templateStorage: InMemoryActivityTemplateStorage(),
            currentDate: _fixedToday,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/today_empty.png'),
      );
    });

    testWidgets('Woche mixed states', (tester) async {
      await _setSize(tester, _phoneSize);
      final monday = DateTime(2026, 6, 8);
      await tester.pumpWidget(
        _themed(
          WeekScreen(
            storage: InMemoryDailyEntryStorage(
              initialEntries: [
                _entry(monday),
                _entry(
                  monday.add(const Duration(days: 1)),
                  dayType: DayType.urlaub,
                ),
              ],
            ),
            templateStorage: InMemoryActivityTemplateStorage(),
            initialDate: _fixedToday,
            currentDate: _fixedToday,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/week_mixed.png'),
      );
    });

    testWidgets('Profil overview', (tester) async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.profileName: 'Lara Lager',
        PreferenceKeys.profileCompany: 'Musterlager GmbH',
        PreferenceKeys.trainingOccupation:
            TrainingOccupationValues.fachkraftLagerlogistik,
        PreferenceKeys.trainingYear: 2,
      });
      await _setSize(tester, _phoneSize);
      await tester.pumpWidget(
        _themed(ProfileScreen(
          dailyEntryStorage: InMemoryDailyEntryStorage(),
          templateStorage: InMemoryActivityTemplateStorage(),
          onDataCleared: () async {},
        )),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/profile_overview.png'),
      );
    });
  });

  group('accessibility guidelines', () {
    testWidgets('Heute-Screen erfüllt Text-Kontrastrichtlinie', (tester) async {
      final handle = tester.ensureSemantics();
      await _setSize(tester, _phoneSize);
      await tester.pumpWidget(
        _themed(
          TodayScreen(
            storage: InMemoryDailyEntryStorage(),
            templateStorage: InMemoryActivityTemplateStorage(),
            currentDate: _fixedToday,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });

    testWidgets('Woche-Screen erfüllt Text-Kontrastrichtlinie', (tester) async {
      final handle = tester.ensureSemantics();
      await _setSize(tester, _phoneSize);
      await tester.pumpWidget(
        _themed(
          WeekScreen(
            storage: InMemoryDailyEntryStorage(),
            templateStorage: InMemoryActivityTemplateStorage(),
            currentDate: _fixedToday,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });

    testWidgets('Profil-Screen erfüllt Text-Kontrastrichtlinie',
        (tester) async {
      final handle = tester.ensureSemantics();
      await _setSize(tester, _phoneSize);
      await tester.pumpWidget(
        _themed(ProfileScreen(
          dailyEntryStorage: InMemoryDailyEntryStorage(),
          templateStorage: InMemoryActivityTemplateStorage(),
          onDataCleared: () async {},
        )),
      );
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });

    testWidgets('Heute-Screen (helles Preset) erfüllt Text-Kontrastrichtlinie',
        (tester) async {
      final handle = tester.ensureSemantics();
      await _setSize(tester, _phoneSize);
      await tester.pumpWidget(
        _themedLight(
          TodayScreen(
            storage: InMemoryDailyEntryStorage(),
            templateStorage: InMemoryActivityTemplateStorage(),
            currentDate: _fixedToday,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });

    testWidgets('Heute-Screen erfüllt Tap-Target-Richtlinie', (tester) async {
      final handle = tester.ensureSemantics();
      await _setSize(tester, _phoneSize);
      await tester.pumpWidget(
        _themed(
          TodayScreen(
            storage: InMemoryDailyEntryStorage(),
            templateStorage: InMemoryActivityTemplateStorage(),
            currentDate: _fixedToday,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });
  });
}
