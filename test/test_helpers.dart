import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> dismissJokeSheetIfPresent(WidgetTester tester) async {
  final closeFinder = find.byKey(const ValueKey('close_joke_sheet'));
  if (closeFinder.evaluate().isNotEmpty) {
    await tester.tap(closeFinder);
    await tester.pumpAndSettle();
  }
}
