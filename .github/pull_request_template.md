<!-- Pflichtinhalt für jede Änderung. Kurz halten, aber vollständig ausfüllen. -->

## Summary

<!-- 1–3 Sätze: Was ändert dieser PR und warum? -->

## Changed areas

<!-- z. B. today_screen, Hive-Storage, Android-Manifest, Doku. -->

## Validation

- [ ] `flutter analyze` — 0 Issues
- [ ] `flutter test` — alle bestanden
- [ ] `flutter build apk --debug` — erfolgreich (bei Storage/Android/Release-Bezug)
- [ ] Manueller Android-Test, falls relevant (siehe `docs/QA_*_CHECKLIST.md`)

## Documentation Freshness Check

- [ ] README geprüft
- [ ] AGENTS / Context Packs geprüft
- [ ] TASKS / CURRENT_STATUS geprüft
- [ ] keine Doku-Änderung nötig / Doku aktualisiert

## Risk Check

- [ ] Storage / Persistenz betroffen? (Enum-Namen, Adapter, Activity-IDs stabil)
- [ ] Android-Permissions / Backup / Signing betroffen?
- [ ] UI / UX / Theme betroffen? (Goldens, Touchflächen)
- [ ] Release / Signing betroffen? (Keystore, Debug-Key)

## Referenzen

<!-- Issue-Nummern, z. B. Closes #58. Bei Code-freien Issues weglassen. -->
