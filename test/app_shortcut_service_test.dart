import 'package:berichtsheft_merker/core/services/app_shortcut_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.daydaylx.berichtsheftmerker/app_shortcuts');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  group('parseAppShortcut', () {
    test('"open_today" wird zu openToday', () {
      expect(parseAppShortcut('open_today'), AppShortcutAction.openToday);
    });

    test('unbekannte ID wird zu unknown', () {
      expect(parseAppShortcut('foo_bar'), AppShortcutAction.unknown);
    });

    test('null wird zu unknown', () {
      expect(parseAppShortcut(null), AppShortcutAction.unknown);
    });
  });

  group('AppShortcutService.initialize', () {
    test('liefert openToday, wenn initialer Intent open_today liefert',
        () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'getInitialShortcut') return 'open_today';
        return null;
      });

      final service = AppShortcutService();
      AppShortcutAction? received;
      final initial = await service.initialize(
        onAction: (a) => received = a,
      );

      expect(initial, AppShortcutAction.openToday);
      expect(received, isNull,
          reason: 'onAction wird nicht für den initialen Wert aufgerufen');
    });

    test('liefert null, wenn Kanal nicht antwortet (Test/Non-Android)', () async {
      // Kein Mock-Handler gesetzt → MissingPluginException wird gefangen.
      final service = AppShortcutService();
      final initial = await service.initialize(onAction: (_) {});

      expect(initial, isNull);
    });

    test('Live-Aufruf von onShortcut ruft onAction mit openToday auf',
        () async {
      AppShortcutAction? received;
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'getInitialShortcut') return null;
        return null;
      });

      final service = AppShortcutService();
      await service.initialize(onAction: (a) => received = a);
      expect(received, isNull);

      // Simuliere nativen Live-Aufruf vom MainActivity.
      const codec = StandardMethodCodec();
      final message = codec.encodeMethodCall(const MethodCall('onShortcut', 'open_today'));
      await messenger.handlePlatformMessage(channel.name, message, (_) {});

      // Async-Verarbeitung abwarten
      await Future<void>.delayed(Duration.zero);
      expect(received, AppShortcutAction.openToday);
    });
  });
}
