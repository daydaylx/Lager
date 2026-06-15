import 'package:berichtsheft_merker/core/storage/preferences_write.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fehlgeschlagener SharedPreferences-Schreibvorgang wird sichtbar', () {
    expect(
      requirePreferenceWrite(Future.value(false)),
      throwsA(isA<StateError>()),
    );
  });
}
