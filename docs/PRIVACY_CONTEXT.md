# PRIVACY_CONTEXT.md — Lokale Datenhaltung

## Regel für Agenten

Diese App speichert ihre Primärdaten lokal und verwendet kein Backend,
Cloud-Sync oder Tracking. Ausschließlich die optional aktivierte
OpenRouter-Berichtsnachbearbeitung darf über ihre dokumentierte Servicegrenze
einen Netzwerkrequest ausführen. Ohne vollständige private
`--dart-define`-Konfiguration bleibt sie deaktiviert und die App funktioniert
vollständig lokal.

Jeder erlaubte Request erzwingt Zero Data Retention, lehnt Datensammlung ab und
wird nur an Endpunkte mit benötigten Structured Outputs geroutet. Übertragen
werden ausschließlich Tagtyp, sichtbare Bereichs- und Tätigkeitstitel,
fachliche Besonderheiten, `reportNote` und der lokale Berichtsentwurf. Niemals
übertragen werden `privateNote`, Profil, Betrieb, Entry-/Activity-IDs,
Zeitstempel, andere Einträge, Geräteinformationen oder Debugdaten.

---

## Was wo gespeichert wird

| Daten             | Speicherort           | Datei                                            |
| ----------------- | --------------------- | ------------------------------------------------ |
| Tageseinträge | Hive CE Box `entries` | `lib/core/storage/hive_daily_entry_storage.dart` |
| Eigene Tätigkeiten | Hive CE Box `custom_templates` | `lib/core/storage/hive_activity_template_storage.dart` |
| Schultage und private Schulnotizen | Hive CE Box `school_entries` | `lib/core/school/storage/hive_school_data_storage.dart` |
| Schulaufgaben | Hive CE Box `school_tasks` | `lib/core/school/storage/hive_school_data_storage.dart` |
| Leistungsnachweise | Hive CE Box `school_assessments` | `lib/core/school/storage/hive_school_data_storage.dart` |
| Ausbildungsprofil | SharedPreferences     | `lib/core/profile_storage.dart`                  |
| Onboarding-Flag   | SharedPreferences     | `lib/core/constants.dart` (Key)                  |
| Erinnerungseinstellungen | SharedPreferences | `lib/core/storage/reminder_storage.dart`       |
| Farbtheme | SharedPreferences | `lib/core/storage/theme_preset_storage.dart` |

---

## Was Agenten nicht einbauen dürfen

- HTTP-Requests außerhalb des klar abgegrenzten OpenRouter-Report-Clients sowie Dio oder sonstige Netzwerkpakete
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
Einstellungen, Tageseinträge, eigene Tätigkeiten und Schuldaten nicht durch
Android in die Cloud oder auf ein neues Gerät übertragen. Schuldaten werden
beim JSON-Export lokal auf ausdrückliche Nutzeraktion mit exportiert; private
Schulnotizen gelangen nicht in die optionale Berichtsnachbearbeitung.

„Alle Daten löschen“ leert SharedPreferences und die Datenboxen für
Tageseinträge, eigene Tätigkeiten, Schuldaten und optionale KI-Berichte. Die
Hive-Dateien werden danach komprimiert, damit gelöschte Inhalte nicht unnötig
in freien Dateibereichen verbleiben.

---

## Warum

Bewusste Entscheidung (siehe `DECISIONS.md`): Datenschutz, kein Account nötig,
keine Serverkosten, offline-tauglich. Nicht ändern ohne explizite Anforderung.
