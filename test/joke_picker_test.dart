import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:berichtsheft_merker/core/data/joke_picker.dart';
import 'package:berichtsheft_merker/core/data/lager_jokes.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('zeigt alle 700 Witze einmal, bevor ein neuer Durchlauf beginnt',
      () async {
    final preferences = await SharedPreferences.getInstance();
    final picker = JokePicker(preferences: preferences, random: Random(17));
    final shown = <String>[];

    for (var index = 0; index < kLagerJokes.length; index++) {
      shown.add(await picker.nextJoke());
    }

    expect(shown.toSet(), hasLength(kLagerJokes.length));
    expect(shown.toSet(), containsAll(kLagerJokes));
    expect(await picker.nextJoke(), isNot(shown.last));
  });

  test('setzt den nicht verbrauchten Zufallszyklus nach Picker-Neustart fort',
      () async {
    final preferences = await SharedPreferences.getInstance();
    final firstPicker =
        JokePicker(preferences: preferences, random: Random(23));
    final firstJoke = await firstPicker.nextJoke();

    final restartedPicker =
        JokePicker(preferences: preferences, random: Random(29));
    final secondJoke = await restartedPicker.nextJoke();

    expect(secondJoke, isNot(firstJoke));
  });
}
