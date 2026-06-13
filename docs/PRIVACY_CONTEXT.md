# PRIVACY_CONTEXT.md — Lokale Datenhaltung

## Regel für Agenten

Diese App speichert **ausschließlich lokal**. Kein Netzwerkzugriff, kein Backend, keine Cloud.

---

## Was wo gespeichert wird

| Daten             | Speicherort           | Datei                                            |
| ----------------- | --------------------- | ------------------------------------------------ |
| Tageseinträge     | Hive CE Box `entries` | `lib/core/storage/hive_daily_entry_storage.dart` |
| Ausbildungsprofil | SharedPreferences     | `lib/core/profile_storage.dart`                  |
| Onboarding-Flag   | SharedPreferences     | `lib/core/constants.dart` (Key)                  |

---

## Was Agenten nicht einbauen dürfen

- HTTP-Requests, Dio, http-Package
- Firebase, Supabase, Amplify
- Cloud-Backup, iCloud, Google Drive Sync
- Analytics, Crashlytics, Sentry
- Login, OAuth, Auth-Flow
- Push-Notifications über FCM oder APNs

---

## Warum

Bewusste Entscheidung (siehe `DECISIONS.md`): Datenschutz, kein Account nötig,
keine Serverkosten, offline-tauglich. Nicht ändern ohne explizite Anforderung.
