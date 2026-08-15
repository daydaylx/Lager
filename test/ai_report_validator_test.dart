import 'package:berichtsheft_merker/core/ai/ai_report_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const validator = AiReportValidator();

  test('akzeptiert einen strukturierten sachlichen Bericht', () {
    expect(
      validator.validate(
        '{"report":"Ich habe den Wareneingang geprüft. Danach habe ich die Waren eingelagert."}',
      ),
      'Ich habe den Wareneingang geprüft. Danach habe ich die Waren eingelagert.',
    );
  });

  test('lehnt Zusatzfelder, Markdown und unpassende Antworten ab', () {
    expect(
      validator.validate('{"report":"Ich habe gearbeitet. Danach war alles erledigt.","extra":true}'),
      isNull,
    );
    expect(
      validator.validate('{"report":"# Bericht\nIch habe gearbeitet. Danach war alles erledigt."}'),
      isNull,
    );
    expect(
      validator.validate('{"report":"Als KI kann ich das nicht. Bitte frage anders."}'),
      isNull,
    );
  });
}
