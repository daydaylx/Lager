// Schutz gegen versehentliches Aktivieren von Android-Cloud-Backup und
// Gerätetransfer. Alle App-Daten bleiben lokal (siehe PRIVACY_CONTEXT.md).
// Ein Agent darf diese Assertionen nicht lockern, ohne dass eine explizite
// Produktentscheidung in DECISIONS.md vorliegt.
//
// Ergänzt scripts/check_repo_hygiene.sh (der dortige allowBackup-Check ist ein
// schneller Frühindikator; hier wird das Regelwerk vollständig geprüft).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final manifest = File('android/app/src/main/AndroidManifest.xml');
  final extractionRules =
      File('android/app/src/main/res/xml/data_extraction_rules.xml');
  final backupRules = File('android/app/src/main/res/xml/backup_rules.xml');

  group('Android-Backup und Gerätetransfer sind deaktiviert', () {
    test('allowBackup ist false', () {
      final content = manifest.readAsStringSync();
      expect(
        content,
        contains('android:allowBackup="false"'),
        reason:
            'allowBackup muss false bleiben, sonst werden lokale Daten gesichert.',
      );
      expect(
        content,
        isNot(contains('android:allowBackup="true"')),
      );
    });

    test('dataExtractionRules schließen für cloud-backup alles aus', () {
      final content = extractionRules.readAsStringSync();
      expect(content, contains('<cloud-backup>'));
      final cloudSection = content
          .split('<cloud-backup>')
          .last
          .split(
            '</cloud-backup>',
          )
          .first;
      // Die Root- und Datenbereiche müssen ausgeschlossen sein.
      expect(
        cloudSection,
        contains('<exclude domain="root" path="."/>'),
      );
      expect(
        cloudSection,
        contains('<exclude domain="file" path="."/>'),
      );
      expect(
        cloudSection,
        contains('<exclude domain="database" path="."/>'),
      );
      expect(
        cloudSection,
        contains('<exclude domain="sharedpref" path="."/>'),
      );
    });

    test('dataExtractionRules schließen für device-transfer alles aus', () {
      final content = extractionRules.readAsStringSync();
      expect(content, contains('<device-transfer>'));
      final transferSection = content
          .split('<device-transfer>')
          .last
          .split(
            '</device-transfer>',
          )
          .first;
      expect(
        transferSection,
        contains('<exclude domain="root" path="."/>'),
      );
      expect(
        transferSection,
        contains('<exclude domain="sharedpref" path="."/>'),
      );
    });

    test('fullBackupContent schließt alle Bereiche aus', () {
      final content = backupRules.readAsStringSync();
      expect(content, contains('<exclude domain="root" path="."/>'));
      expect(content, contains('<exclude domain="file" path="."/>'));
      expect(content, contains('<exclude domain="database" path="."/>'));
      expect(content, contains('<exclude domain="sharedpref" path="."/>'));
      expect(content, contains('<exclude domain="external" path="."/>'));
    });
  });
}
