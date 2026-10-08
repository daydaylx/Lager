import 'package:flutter_test/flutter_test.dart';
import 'package:berichtsheft_merker/core/data/dark_jokes.dart';
import 'package:berichtsheft_merker/core/data/deine_mutter_jokes.dart';
import 'package:berichtsheft_merker/core/data/lager_jokes.dart';

void main() {
  group('kLagerJokes', () {
    test('enthält genau 700 Witze', () {
      expect(kLagerJokes.length, 700);
    });

    test('enthält je 200 neue Witze in beiden Zusatzkategorien', () {
      expect(kDarkJokes.length, 200);
      expect(kDeineMutterJokes.length, 200);
    });

    test('kein Eintrag ist leer', () {
      for (final joke in kLagerJokes) {
        expect(joke.trim(), isNotEmpty);
      }
    });

    test('enthält keine Duplikate', () {
      expect(kLagerJokes.toSet().length, kLagerJokes.length);
    });

    test('kein Eintrag hat führenden oder abschließenden Leerraum', () {
      for (final joke in kLagerJokes) {
        expect(joke, joke.trim(), reason: 'Leerraum am Rand: $joke');
      }
    });

    test('jeder Witz bleibt kurz genug für das Sheet', () {
      for (final joke in kLagerJokes) {
        expect(joke.length, lessThanOrEqualTo(160),
            reason: 'Zu lang (${joke.length} Zeichen): $joke');
      }
    });

    test('enthält keine dominierenden Lagerbegriffe', () {
      const warehouseTerms = [
        'lager',
        'palette',
        'scanner',
        'hubwagen',
        'stapler',
        'kommission',
        'wareneingang',
        'inventur',
        'pickliste',
        'retoure',
        'gabelstapler',
      ];

      for (final joke in kLagerJokes) {
        final normalized = joke.toLowerCase();
        for (final term in warehouseTerms) {
          expect(normalized, isNot(contains(term)),
              reason: 'Berufsspezifischer Begriff "$term": $joke');
        }
      }
    });
  });


}
