import 'package:flutter_test/flutter_test.dart';
import 'package:berichtsheft_merker/core/data/lager_jokes.dart';

void main() {
  group('kLagerJokes', () {
    test('enthält genau 300 Witze', () {
      expect(kLagerJokes.length, 300);
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

  group('jokeForDate', () {
    test('gibt für dasselbe Datum immer denselben Witz zurück', () {
      final date = DateTime(2026, 7, 11);
      final first = jokeForDate(date);
      final second = jokeForDate(date);
      expect(first, equals(second));
    });

    test('verschiedene Tage geben verschiedene Witze', () {
      final joke1 = jokeForDate(DateTime(2026, 1, 1));
      final joke2 = jokeForDate(DateTime(2026, 1, 2));
      expect(joke1, isNot(equals(joke2)));
    });

    test('beginnt am Jahresanfang mit dem ersten Witz', () {
      expect(jokeForDate(DateTime(2026, 1, 1)), kLagerJokes.first);
      expect(jokeForDate(DateTime(2026, 1, 2)), kLagerJokes[1]);
    });

    test('nutzt Kalendertage unabhängig von Uhrzeit', () {
      final startOfDay = jokeForDate(DateTime(2026, 7, 11));
      expect(jokeForDate(DateTime(2026, 7, 11, 23, 59)), startOfDay);
      expect(jokeForDate(DateTime.utc(2026, 7, 11, 23, 59)), startOfDay);
    });

    test('bleibt um Sommerzeit-Tage fortlaufend', () {
      final jokes = {
        jokeForDate(DateTime(2026, 3, 28)),
        jokeForDate(DateTime(2026, 3, 29)),
        jokeForDate(DateTime(2026, 3, 30)),
      };
      expect(jokes, hasLength(3));
    });

    test('bleibt im gültigen Bereich bei Jahresende (Tag 366)', () {
      // 31.12.2024 ist Tag 366 (Schaltjahr)
      final joke = jokeForDate(DateTime(2024, 12, 31));
      expect(kLagerJokes, contains(joke));
    });

    test('bleibt im gültigen Bereich bei Jahresanfang (Tag 1)', () {
      final joke = jokeForDate(DateTime(2026, 1, 1));
      expect(kLagerJokes, contains(joke));
    });

    test('gibt einen String zurück', () {
      final joke = jokeForDate(DateTime(2026, 7, 11));
      expect(joke, isA<String>());
      expect(joke.trim(), isNotEmpty);
    });
  });
}
