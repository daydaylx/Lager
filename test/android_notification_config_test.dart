import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final manifest = File('android/app/src/main/AndroidManifest.xml');
  final buildConfig = File('android/app/build.gradle.kts');
  final proguardRules = File('android/app/proguard-rules.pro');
  final notificationIcon =
      File('android/app/src/main/res/drawable/ic_stat_notification.xml');
  final resourceKeep = File('android/app/src/main/res/raw/keep.xml');

  group('Android-Erinnerungskonfiguration', () {
    test('deklariert Exaktalarm-Berechtigung und Plugin-Receiver', () {
      final content = manifest.readAsStringSync();

      expect(
        content,
        contains('android.permission.SCHEDULE_EXACT_ALARM'),
      );
      expect(content, contains('ScheduledNotificationReceiver'));
      expect(content, contains('ScheduledNotificationBootReceiver'));
    });

    test('Release-Build verwendet die Gson-TypeToken-Schutzregeln', () {
      final buildContent = buildConfig.readAsStringSync();
      final rulesContent = proguardRules.readAsStringSync();

      expect(buildContent, contains('proguard-rules.pro'));
      expect(rulesContent, contains('-keepattributes Signature'));
      expect(rulesContent, contains('com.google.gson.reflect.TypeToken'));
      expect(
          rulesContent, contains('extends com.google.gson.reflect.TypeToken'));
    });

    test('monochromes Notification-Icon bleibt im Release erhalten', () {
      expect(notificationIcon.existsSync(), isTrue);
      expect(notificationIcon.readAsStringSync(), contains('<vector'));
      expect(notificationIcon.readAsStringSync(), contains('M12,2.5'));
      expect(
        resourceKeep.readAsStringSync(),
        contains('@drawable/ic_stat_notification'),
      );
    });
  });
}
