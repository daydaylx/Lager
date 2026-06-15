# PRIVACY_CONTEXT.md — Lokale Datenhaltung

## Regel für Agenten

Diese App speichert **ausschließlich lokal**. Kein Netzwerkzugriff, kein Backend, keine Cloud.

---

## Was wo gespeichert wird

| Daten             | Speicherort           | Datei                                            |
| ----------------- | --------------------- | ------------------------------------------------ |
| Tageseinträge     | Hive CE Box `entries` | `lib/core/storage/hive_daily_entry_storage.dart` |
| Eigene Tätigkeiten | Hive CE Box `custom_templates` | `lib/core/storage/hive_activity_template_storage.dart` |
| Ausbildungsprofil | SharedPreferences     | `lib/core/profile_storage.dart`                  |
| Onboarding-Flag   | SharedPreferences     | `lib/core/constants.dart` (Key)                  |
| Erinnerungseinstellungen | SharedPreferences | `lib/core/storage/reminder_storage.dart`       |

---

## Was Agenten nicht einbauen dürfen

- HTTP-Requests, Dio, http-Package
- Firebase, Supabase, Amplify
- Cloud-Backup, iCloud, Google Drive Sync
- Analytics, Crashlytics, Sentry
- Login, OAuth, Auth-Flow
- Push-Notifications über FCM oder APNs

Lokale Android-Benachrichtigungen sind erlaubt. Sie werden ausschließlich auf
dem Gerät geplant, verwenden die Gerätezeitzone und benötigen keinen Netzwerkzugriff.

Android-Cloud-Backup und Gerätetransfer sind in
`android/app/src/main/AndroidManifest.xml` sowie den XML-Regeln unter
`android/app/src/main/res/xml/` deaktiviert. Dadurch werden Profil,
Einstellungen, Tageseinträge und eigene Tätigkeiten nicht durch Android in die
Cloud oder auf ein neues Gerät übertragen.

„Alle Daten löschen“ leert SharedPreferences und beide Hive-Boxen. Die
Hive-Dateien werden danach komprimiert, damit gelöschte Inhalte nicht unnötig
in freien Dateibereichen verbleiben.

---

## Warum

Bewusste Entscheidung (siehe `DECISIONS.md`): Datenschutz, kein Account nötig,
keine Serverkosten, offline-tauglich. Nicht ändern ohne explizite Anforderung.
