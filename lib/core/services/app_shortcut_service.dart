import 'package:flutter/services.dart';

/// Bekannte App-Shortcut-IDs (#UX-4 B3). Werden vom Android-Intent
/// (`berichtsheftmerker://shortcut/<id>`) ausgelöst und hier zu semantischen
/// Aktionen aufgelöst.
enum AppShortcutAction {
  openToday,
  unknown,
}

AppShortcutAction parseAppShortcut(String? id) {
  switch (id) {
    case 'open_today':
      return AppShortcutAction.openToday;
    default:
      return AppShortcutAction.unknown;
  }
}

/// Bridge zum nativen Android-Code (`MainActivity.kt`) für statische
/// App-Shortcuts. Auf Nicht-Android-Plattformen oder in Tests liefert
/// `initialize` einen No-Op-Channel, der nie aufruft.
class AppShortcutService {
  static const _channelName = 'com.daydaylx.berichtsheftmerker/app_shortcuts';

  final MethodChannel _channel;
  void Function(AppShortcutAction action)? _onAction;

  AppShortcutService({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(_channelName);

  /// Initialisiert den Service. Liefert die Action, mit der die App
  /// gestartet wurde (oder null, wenn kein Shortcut beteiligt war). Nach
  /// der Initialisierung werden Live-Aufrufe (App läuft bereits, Shortcut
  /// wird später getippt) über [onAction] an den Listener gemeldet.
  Future<AppShortcutAction?> initialize({
    required void Function(AppShortcutAction action) onAction,
  }) async {
    _onAction = onAction;
    _channel.setMethodCallHandler(_handleMethodCall);
    try {
      final initial = await _channel.invokeMethod<String?>('getInitialShortcut');
      return parseAppShortcut(initial);
    } on MissingPluginException {
      // Testumgebung oder Nicht-Android: kein Kanal verfügbar.
      return null;
    } on PlatformException {
      return null;
    }
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onShortcut') {
      final id = call.arguments as String?;
      final action = parseAppShortcut(id);
      _onAction?.call(action);
    }
    return null;
  }
}
