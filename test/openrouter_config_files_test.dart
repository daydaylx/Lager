import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('OpenRouter bleibt ohne private Konfiguration und erhält Internetzugriff',
      () {
    final manifest = File('android/app/src/main/AndroidManifest.xml');
    final gitignore = File('.gitignore');
    final example = File('config/openrouter.example.json');

    expect(manifest.readAsStringSync(), contains('android.permission.INTERNET'));
    expect(gitignore.readAsStringSync(), contains('config/openrouter.private.json'));
    expect(example.existsSync(), isTrue);
    expect(example.readAsStringSync(), isNot(contains('sk-or-v1-')));
  });
}
