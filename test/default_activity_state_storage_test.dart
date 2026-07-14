import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:berichtsheft_merker/core/storage/default_activity_state_storage.dart';

void main() {
  const storage = DefaultActivityStateStorage();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loadOverrides gibt leere veränderliche Map zurück', () async {
    final overrides = await storage.loadOverrides();
    expect(overrides, isEmpty);
    // Muss veränderlich sein, damit setActive Einträge hinzufügen kann.
    expect(() => overrides['id'] = true, returnsNormally);
  });

  test('setActive speichert Override', () async {
    await storage.setActive('activity_1', false);
    await storage.setActive('activity_2', true);

    final overrides = await storage.loadOverrides();
    expect(overrides, {'activity_1': false, 'activity_2': true});
  });

  test('setActive überschreibt bestehenden Wert', () async {
    await storage.setActive('activity_1', false);
    await storage.setActive('activity_1', true);

    final overrides = await storage.loadOverrides();
    expect(overrides, {'activity_1': true});
  });

  test('clearAll entfernt alle Overrides', () async {
    await storage.setActive('activity_1', false);
    await storage.clearAll();

    final overrides = await storage.loadOverrides();
    expect(overrides, isEmpty);
  });

  test('ungültiger JSON wird ignoriert', () async {
    SharedPreferences.setMockInitialValues({
      'default_activity_overrides': 'not-json',
    });

    final overrides = await storage.loadOverrides();
    expect(overrides, isEmpty);
  });
}
