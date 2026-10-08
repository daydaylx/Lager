import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import 'lager_jokes.dart';

/// Wählt Witze zufällig ohne Wiederholung bis zum Ende eines vollständigen
/// Durchlaufs. Die verbleibenden Indizes bleiben über App-Neustarts erhalten.
class JokePicker {
  JokePicker({required SharedPreferences preferences, Random? random})
      : _preferences = preferences,
        _random = random ?? Random();

  static const _remainingKey = 'joke_picker_remaining_indices_v1';
  static const _lastIndexKey = 'joke_picker_last_index_v1';
  static const _listLengthKey = 'joke_picker_list_length_v1';

  final SharedPreferences _preferences;
  final Random _random;

  Future<String> nextJoke() async {
    final remaining = _readRemainingIndices();
    final indices = remaining.isEmpty ? _newCycle() : remaining;
    final selectedIndex = indices.removeLast();

    await _preferences.setStringList(
      _remainingKey,
      indices.map((index) => index.toString()).toList(growable: false),
    );
    await _preferences.setInt(_lastIndexKey, selectedIndex);
    await _preferences.setInt(_listLengthKey, kLagerJokes.length);

    return kLagerJokes[selectedIndex];
  }

  List<int> _readRemainingIndices() {
    if (_preferences.getInt(_listLengthKey) != kLagerJokes.length) {
      return <int>[];
    }

    final stored = _preferences.getStringList(_remainingKey);
    if (stored == null || stored.isEmpty) return <int>[];

    final indices = <int>[];
    for (final value in stored) {
      final index = int.tryParse(value);
      if (index == null || index < 0 || index >= kLagerJokes.length) {
        return <int>[];
      }
      indices.add(index);
    }
    if (indices.toSet().length != indices.length) return <int>[];
    return indices;
  }

  List<int> _newCycle() {
    final indices = List<int>.generate(kLagerJokes.length, (index) => index)
      ..shuffle(_random);
    final lastIndex = _preferences.getInt(_lastIndexKey);
    if (indices.length > 1 && indices.last == lastIndex) {
      final first = indices.first;
      indices[0] = indices.last;
      indices[indices.length - 1] = first;
    }
    return indices;
  }
}
