import 'package:flutter/widgets.dart';
import 'package:berichtsheft_merker/core/enums/day_type.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> dismissJokeSheetIfPresent(WidgetTester tester) async {
  final closeFinder = find.byKey(const ValueKey('close_joke_sheet'));
  if (closeFinder.evaluate().isNotEmpty) {
    await tester.tap(closeFinder);
    await tester.pumpAndSettle();
  }
}

/// #Phase23: Wählt einen Abwesenheits- oder Sonstiges-Tagestyp über den
/// "Abwesend"-Chip und das zugehörige Bottom-Sheet.
///
/// Ersetzt das frühere direkte Tippen auf `day_type_frei` / `day_type_urlaub`
/// / `day_type_sonstiges`, da diese Typen seit der DayTypeRow nicht mehr als
/// eigene Chips existieren.
Future<void> selectAbsenceType(WidgetTester tester, DayType dayType) async {
  final chip = find.byKey(const ValueKey('day_type_absence_chip'));
  await tester.scrollUntilVisible(
    chip,
    -300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(chip);
  await tester.pumpAndSettle();
  await tester.tap(
    find.byKey(ValueKey('absence_option_${dayType.name}')),
  );
  await tester.pumpAndSettle();
}
