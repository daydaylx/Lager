import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:berichtsheft_merker/core/constants.dart';

void main() {
  test('kAppVersion stimmt mit pubspec.yaml überein', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final versionMatch =
        RegExp(r'^version:\s*([^\s]+)', multiLine: true).firstMatch(pubspec);

    expect(versionMatch, isNotNull);
    final pubspecVersion = versionMatch!.group(1)!.split('+').first;

    expect(kAppVersion, pubspecVersion);
  });
}
