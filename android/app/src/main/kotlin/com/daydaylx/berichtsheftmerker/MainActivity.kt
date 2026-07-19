package com.daydaylx.berichtsheftmerker

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Native Android Activity für die Berichtsheft-Merker-App.
 *
 * Zusätzliche Aufgaben neben dem Standard-Flutter-Setup (#UX-4 B3):
 * - Statische App-Shortcuts (res/xml/shortcuts.xml) werden über
 *   Intent-Daten mit dem Schema `berichtsheftmerker://shortcut/<id>` ausgelöst.
 * - Beim ersten Frame und bei `onNewIntent` wird die Shortcut-ID an Flutter
 *   über den Method-Channel `app_shortcuts` übermittelt. Flutter entscheidet
 *   dann selbst, was mit der ID passiert (z. B. auf den Heute-Tab springen).
 */
class MainActivity : FlutterActivity() {
    private val channelName = "com.daydaylx.berichtsheftmerker/app_shortcuts"
    private var pendingShortcut: String? = null
    private var channel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        channel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialShortcut" -> {
                    val value = pendingShortcut
                    pendingShortcut = null
                    result.success(value)
                }
                else -> result.notImplemented()
            }
        }
        intent?.let { handleShortcutIntent(it) }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleShortcutIntent(intent)
    }

    private fun handleShortcutIntent(intent: Intent) {
        val data = intent.data ?: return
        if (data.scheme != "berichtsheftmerker" || data.host != "shortcut") return
        val shortcutId = data.lastPathSegment ?: return
        pendingShortcut = shortcutId
        // Falls die Flutter-Seite bereits bereit ist, sofort liefern;
        // andernfalls wird sie über getInitialShortcut beim Start abgerufen.
        channel?.invokeMethod("onShortcut", shortcutId)
    }
}
