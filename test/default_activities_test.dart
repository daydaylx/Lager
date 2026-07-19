import 'package:flutter_test/flutter_test.dart';
import 'package:berichtsheft_merker/core/data/default_activities.dart';
import 'package:berichtsheft_merker/core/enums/activity_category.dart';

void main() {
  test('Standard-Tätigkeitskatalog enthält eindeutige IDs', () {
    final ids = defaultActivities.map((activity) => activity.id).toSet();

    expect(defaultActivities, hasLength(132));
    expect(ids, hasLength(defaultActivities.length));
    for (final category in ActivityCategory.values) {
      expect(
        defaultActivities.any((activity) => activity.category == category),
        isTrue,
        reason: 'Für ${category.name} fehlt mindestens eine Tätigkeit.',
      );
    }

    // Historische IDs bleiben erhalten; fachlich ungeeignete Altvorlagen sind
    // weder im Vorlagen-Screen noch für neue Einträge auswählbar.
    expect(selectableDefaultActivities, hasLength(123));
    expect(
      selectableDefaultActivities.where((activity) => activity.isActive).length,
      38,
    );
    expect(
      defaultActivities
          .where((activity) => retiredDefaultActivityIds.contains(activity.id))
          .every((activity) => !activity.isActive),
      isTrue,
    );
    expect(
      selectableDefaultActivities.map((activity) => activity.id),
      isNot(contains('sicherheit_01')),
    );
    expect(
      selectableDefaultActivities.map((activity) => activity.id),
      isNot(contains('transport_07')),
    );

    expect(
      selectableDefaultActivities.map((activity) => activity.title),
      containsAll([
        'Lieferung angenommen und geprüft',
        'Lieferdaten im Warenwirtschaftssystem geprüft',
        'Arbeitsbereich nach 5S geprüft und geordnet',
        'An einer Arbeitsschutzunterweisung teilgenommen',
        'Ladung für den Transport gesichert',
      ]),
    );
    final selectableTitles =
        selectableDefaultActivities.map((activity) => activity.title);
    expect(selectableTitles,
        isNot(contains('Persönliche Schutzausrüstung getragen')));
    expect(
        selectableTitles, isNot(contains('Sicherheitsvorschriften beachtet')));
    expect(selectableTitles, isNot(contains('Selbstständig gearbeitet')));
  });
}
