import 'package:flutter_test/flutter_test.dart';
import 'package:berichtsheft_merker/app/app.dart';

void main() {
  testWidgets('App startet ohne Absturz', (WidgetTester tester) async {
    await tester.pumpWidget(const BerichtsheftApp());
    expect(find.byType(BerichtsheftApp), findsOneWidget);
  });
}
