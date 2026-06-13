import 'package:flutter_test/flutter_test.dart';
import 'package:berichtsheft_merker/core/data/default_activities.dart';
import 'package:berichtsheft_merker/core/enums/activity_category.dart';

void main() {
  test('Standard-Tätigkeitskatalog enthält eindeutige IDs', () {
    final ids = defaultActivities.map((activity) => activity.id).toSet();

    expect(defaultActivities, hasLength(87));
    expect(ids, hasLength(defaultActivities.length));
    for (final category in ActivityCategory.values) {
      expect(
        defaultActivities.any((activity) => activity.category == category),
        isTrue,
        reason: 'Für ${category.name} fehlt mindestens eine Tätigkeit.',
      );
    }
  });
}
