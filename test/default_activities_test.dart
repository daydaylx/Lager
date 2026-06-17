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

    expect(
      defaultActivities.map((activity) => activity.title),
      containsAll([
        'Wareneingang mit Scanner erfasst',
        'Lieferdaten im Warenwirtschaftssystem nachvollzogen',
        '5S-Regeln am Arbeitsplatz angewendet',
        'Unterweisung zur Arbeitssicherheit erhalten',
      ]),
    );
  });
}
