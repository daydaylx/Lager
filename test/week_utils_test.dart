import 'package:flutter_test/flutter_test.dart';
import 'package:berichtsheft_merker/core/week_utils.dart';

void main() {
  test('Wochenstart ist immer Montag', () {
    expect(startOfWeek(DateTime(2026, 6, 8)), DateTime(2026, 6, 8));
    expect(startOfWeek(DateTime(2026, 6, 14)), DateTime(2026, 6, 8));
  });

  test('ISO-Kalenderwoche berücksichtigt Jahresgrenzen', () {
    expect(isoWeekNumber(DateTime(2021, 1, 1)), 53);
    expect(isoWeekYear(DateTime(2021, 1, 1)), 2020);

    expect(isoWeekNumber(DateTime(2024, 12, 30)), 1);
    expect(isoWeekYear(DateTime(2024, 12, 30)), 2025);
  });
}
