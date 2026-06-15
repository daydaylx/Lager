# QA-Checkliste: Reminder auf Samsung/Android

Mindestens ein Test auf echtem Samsung-Gerät erforderlich.

---

## 1. Berechtigung (Issue #14)

- [ ] Reminder aktivieren → Android 13+: Permission-Dialog erscheint
- [ ] Permission erteilen → Reminder wird eingerichtet, kein Fehler
- [ ] Permission verweigern → Fehlermeldung mit "Bitte in den Einstellungen aktivieren" sichtbar
- [ ] "Benachrichtigungseinstellungen öffnen" → App-Einstellungen öffnen sich auf Notification-Seite
- [ ] Berechtigung nachträglich in Einstellungen sperren → Profil-Screen zeigt Warnung nach Rückkehr in die App
- [ ] Berechtigung nachträglich erlauben → Warnung verschwindet nach Rückkehr in die App

## 2. Notification-Channel (Issue #15)

- [ ] Channel "Tägliche Berichtsheft-Erinnerungen" in Einstellungen → Apps → Berichtsheft-Merker → Benachrichtigungen sichtbar
- [ ] Kanal-Wichtigkeit ist "Dringend" oder "Hoch" (nicht "Standard" oder "Lautlos")
- [ ] Notification erscheint mit Ton
- [ ] Notification erscheint mit Vibration

## 3. Notification-Inhalt und Tap (Issue #16)

- [ ] Titel: "Berichtsheft nicht vergessen"
- [ ] Text (primär): "Heute kurz Tätigkeiten eintragen – dauert nur 1 Minute."
- [ ] Notification als Banner im Sperrbildschirm sichtbar
- [ ] Notification im Benachrichtigungsfeld sichtbar
- [ ] Tap auf Notification → App öffnet sich auf Heute-Tab (Index 0)
- [ ] Tap bei laufender App im Hintergrund → Heute-Tab wird ausgewählt
- [ ] App vollständig beenden, dann Notification antippen → Kaltstart öffnet Heute-Tab

## 4. Zweite Erinnerung (Issue #17)

- [ ] 30 Minuten nach primärer Uhrzeit erscheint zweite Notification
- [ ] Text: "Falls dein Eintrag noch fehlt: jetzt kurz nachtragen."
- [ ] Zweite Erinnerung erscheint nur an konfigurierten Wochentagen
- [ ] Primärzeit 23:45 → zweite Erinnerung erscheint am Folgetag um 00:15

## 5. Wochencheck (Issue #17)

- [ ] Freitags um 19:00 erscheint Wochencheck-Notification
- [ ] Text: "Schau mal, ob diese Woche alle Tage eingetragen sind."
- [ ] Tap → App öffnet Heute-Tab

## 6. App-Start-Banner (Issue #19)

- [ ] Reminder aktiviert + Werktag + kein heutiger Eintrag → SnackBar beim Start sichtbar
- [ ] Text: "Heutiger Eintrag fehlt noch – jetzt kurz eintragen?"
- [ ] SnackBar verschwindet nach 5 Sekunden automatisch
- [ ] Kein SnackBar wenn Reminder deaktiviert
- [ ] Kein SnackBar am Wochenende

## 7. Wochenansicht offene Einträge (Issue #19)

- [ ] Aktuelle Woche mit fehlenden Einträgen → Banner "X Tage fehlen noch diese Woche"
- [ ] Text "Tippe auf einen offenen Tag, um ihn einzutragen."
- [ ] Vergangene Wochen → kein Banner
- [ ] Alle Tage eingetragen → kein Banner

## 8. Samsung-Hinweis (Issue #18)

- [ ] Profil-Screen → Erinnerungen → "Hinweis für Samsung-Geräte" sichtbar (zugeklappt)
- [ ] Antippen klappt Hinweis auf
- [ ] Text erwähnt Akku-Optimierung, Nicht stören, Benachrichtigungskategorien
- [ ] Einstellungspfade stimmen auf aktuellem Samsung-Gerät (One UI 6/7)

## 9. Samsung-spezifisches Verhalten

- [ ] Akku-Optimierung auf "Nicht eingeschränkt" → Notifications auch nach Stunden in Tiefsschlaf
- [ ] Nicht-Stören deaktiviert oder Ausnahme für App → Notification erscheint trotzdem
- [ ] Kanal-Kategorie in Einstellungen aktivierbar (falls Samsung sie deaktiviert hat)

## 10. Geräteneustart

- [ ] App nach Neustart → Reminder werden automatisch neu geplant (RECEIVE_BOOT_COMPLETED)
- [ ] Reminder erscheinen wieder zur konfigurierten Uhrzeit

## 11. Zeitzone und Tageswechsel

- [ ] Gerätezeitzone ändern, App öffnen und Reminder speichern → Hinweise folgen der neuen lokalen Uhrzeit
- [ ] App vor Mitternacht im Hintergrund lassen und danach öffnen → Heute-Screen zeigt den neuen Tag
- [ ] Offene Heute-Eingaben über Mitternacht → bleiben dem bisherigen Tag zugeordnet
- [ ] Wechsel zum neuen Tag mit offenen Eingaben → Bestätigung vor Verwerfen erscheint
- [ ] Aktuelle Wochenansicht über Wochenwechsel → wechselt zur neuen Woche
- [ ] Historisch ausgewählte Woche über Tageswechsel → bleibt ausgewählt

## 12. "Alle Daten löschen"

- [ ] Alle Daten löschen → keine weiteren Notifications bis Reminder neu aktiviert
- [ ] cancelAll() bricht primäre, zweite und Wochencheck-Notifications ab
- [ ] Nach Neustart sind Profil, Einträge, eigene Vorlagen, Reminder und Theme zurückgesetzt

## 13. Release und Datenschutz

- [ ] Installierte App verwendet Package `com.daydaylx.berichtsheftmerker`
- [ ] Debug-APK lässt sich installieren und starten
- [ ] Release-APK wird nur mit lokalem Release-Keystore signiert, nicht mit Debug-Key
- [ ] Android-Backup/Restore oder Gerätetransfer übernimmt keine App-Daten

## 14. Darstellung

- [ ] Standardtheme nach frischer Installation ist "Lager Teal"
- [ ] Jedes Farbtheme lässt sich auswählen und bleibt nach App-Neustart erhalten
- [ ] Helles Preset bleibt auf kleinem Display und mit großer Systemschrift lesbar
- [ ] "Alle Daten löschen" setzt das Farbtheme auf "Lager Teal" zurück

## Testumgebung

| Feld            | Wert |
| --------------- | ---- |
| Gerät           |      |
| Android-Version |      |
| One UI-Version  |      |
| Getestet am     |      |
| Tester          |      |
| APK             |      |
