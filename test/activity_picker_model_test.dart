import 'package:berichtsheft_merker/core/domain/domain.dart';
import 'package:berichtsheft_merker/core/enums/activity_category.dart';
import 'package:berichtsheft_merker/core/enums/day_type.dart';
import 'package:berichtsheft_merker/core/enums/training_area.dart';
import 'package:berichtsheft_merker/core/models/activity_template.dart';
import 'package:berichtsheft_merker/core/models/adhoc_activity.dart';
import 'package:berichtsheft_merker/features/today/activity_picker_model.dart';
import 'package:flutter_test/flutter_test.dart';

ActivityPickerModel _model({
  DayType dayType = DayType.betrieb,
  Set<TrainingArea> areas = const {TrainingArea.wareneingang},
  Set<String> selectedIds = const {},
  List<ActivityTemplate> customTemplates = const [],
  List<String> frequentIds = const [],
  String search = '',
  int? trainingYear,
  Map<String, bool> defaultOverrides = const {},
  List<AdhocActivity> adhocActivities = const [],
  TrainingOccupation occupation = TrainingOccupation.fachkraftLagerlogistik,
  String? wahlqualifikation,
}) {
  return ActivityPickerModel.build(
    dayType: dayType,
    selectedAreas: areas,
    selectedActivityIds: selectedIds,
    customTemplates: customTemplates,
    frequentActivityIds: frequentIds,
    searchQuery: search,
    trainingYear: trainingYear,
    defaultOverrides: defaultOverrides,
    adhocActivities: adhocActivities,
    occupation: occupation,
    wahlqualifikation: wahlqualifikation,
  );
}

List<String> _groupActivityIds(ActivityPickerModel model) {
  return model.groups
      .expand((group) => group.activities)
      .map((activity) => activity.id)
      .toList(growable: false);
}

void main() {
  group('ActivityPickerModel', () {
    test('Betrieb nutzt gewählte Bereichskategorie plus Sicherheit', () {
      final model = _model();

      expect(
        model.categories,
        [ActivityCategory.wareneingang, ActivityCategory.sicherheit],
      );
      expect(model.hasVisibleActivities, isTrue);
      expect(_groupActivityIds(model), contains('wareneingang_01'));
    });

    test('Berufsschule nutzt nur Berufsschul-Kategorie', () {
      final model = _model(
        dayType: DayType.berufsschule,
        areas: const {},
      );

      expect(model.categories, [ActivityCategory.berufsschule]);
      expect(_groupActivityIds(model), contains('berufsschule_01'));
      expect(_groupActivityIds(model), isNot(contains('wareneingang_01')));
    });

    test('Verkäufer nutzt nur den Verkäuferkatalog', () {
      final model = _model(
        occupation: TrainingOccupation.verkaeufer,
        areas: const {TrainingArea.verkaufsflaeche},
        trainingYear: 1,
        wahlqualifikation: Wahlqualifikation.beratungVonKunden.storageKey,
      );
      final ids = _groupActivityIds(model);

      expect(model.categories, [
        ActivityCategory.verkaufsflaeche,
        ActivityCategory.allgemein,
      ]);
      expect(
        model.recommendationContext,
        'Wahlqualifikation: Beratung von Kunden',
      );
      expect(ids, contains('verkauf_flaeche_01'));
      expect(ids, isNot(contains('wareneingang_01')));
    });

    test('alle Verkäufer-Wahlqualifikationen werden als Kontext angezeigt', () {
      for (final wahlqualifikation in Wahlqualifikation.values) {
        final model = _model(
          occupation: TrainingOccupation.verkaeufer,
          areas: const {TrainingArea.verkaufsflaeche},
          trainingYear: 1,
          wahlqualifikation: wahlqualifikation.storageKey,
        );

        expect(
          model.recommendationContext,
          'Wahlqualifikation: ${wahlqualifikation.label}',
        );
      }
    });

    test('Verkäufer-Berufsschulthemen werden nach Jahr gefiltert', () {
      final firstYearModel = _model(
        occupation: TrainingOccupation.verkaeufer,
        dayType: DayType.berufsschule,
        areas: const {},
        trainingYear: 1,
      );
      final secondYearModel = _model(
        occupation: TrainingOccupation.verkaeufer,
        dayType: DayType.berufsschule,
        areas: const {},
        trainingYear: 2,
      );
      final firstYear = {
        ..._groupActivityIds(firstYearModel),
        ...firstYearModel.recommendedActivities.map((a) => a.id),
      };
      final secondYear = {
        ..._groupActivityIds(secondYearModel),
        ...secondYearModel.recommendedActivities.map((a) => a.id),
      };

      expect(firstYear, contains('verkauf_schule_01'));
      expect(firstYear, contains('verkauf_schule_08'));
      expect(firstYear, isNot(contains('verkauf_schule_09')));
      expect(secondYear, contains('verkauf_schule_09'));
      expect(secondYear, contains('verkauf_schule_20'));
      expect(secondYear, isNot(contains('verkauf_schule_08')));
    });

    test('historische Custom-ID bleibt beim Berufswechsel auflösbar', () {
      final model = _model(
        occupation: TrainingOccupation.verkaeufer,
        areas: const {TrainingArea.verkaufsflaeche},
        selectedIds: const {'custom_old_1'},
        customTemplates: const [
          ActivityTemplate(
            id: 'custom_old_1',
            title: 'Historische Lagertätigkeit',
            category: ActivityCategory.wareneingang,
            isCustom: true,
          ),
        ],
      );

      expect(model.unavailableSelectedIds, isEmpty);
      expect(model.selectedActivities.single.id, 'custom_old_1');
      expect(_groupActivityIds(model), isNot(contains('custom_old_1')));
    });

    test('Suche filtert aktuelle Kategorien nach Titel und Kategorie', () {
      final model = _model(search: 'Scanner');
      final ids = _groupActivityIds(model);

      expect(ids, contains('wareneingang_11'));
      expect(ids, isNot(contains('wareneingang_01')));
      expect(model.frequentActivities, isEmpty);
      expect(model.recommendedActivities, isEmpty);
    });

    test('häufige Tätigkeiten werden oben gezeigt und aus Gruppen ausgeblendet',
        () {
      final model = _model(
        frequentIds: const ['wareneingang_11', 'wareneingang_01'],
      );

      expect(
        model.frequentActivities.map((activity) => activity.id),
        ['wareneingang_11', 'wareneingang_01'],
      );
      expect(_groupActivityIds(model), isNot(contains('wareneingang_11')));
      expect(_groupActivityIds(model), isNot(contains('wareneingang_01')));
    });

    test('ausgewählte Quick-Access-Tätigkeit bleibt in der Gruppe sichtbar',
        () {
      final model = _model(
        selectedIds: {'wareneingang_11'},
        frequentIds: const ['wareneingang_11'],
      );

      expect(model.frequentActivities, isEmpty);
      expect(_groupActivityIds(model).first, 'wareneingang_11');
      expect(model.selectedActivities.map((activity) => activity.id), [
        'wareneingang_11',
      ]);
    });

    test('Custom-Templates: aktiv sichtbar, deaktiviert nur bei Auswahl', () {
      final model = _model(
        selectedIds: {'custom_inactive_selected', 'missing_old_id'},
        customTemplates: const [
          ActivityTemplate(
            id: 'custom_active',
            title: 'Eigene Warenprüfung',
            category: ActivityCategory.wareneingang,
            isCustom: true,
          ),
          ActivityTemplate(
            id: 'custom_inactive_hidden',
            title: 'Veraltete Prüfung',
            category: ActivityCategory.wareneingang,
            isCustom: true,
            isActive: false,
          ),
          ActivityTemplate(
            id: 'custom_inactive_selected',
            title: 'Historische Prüfung',
            category: ActivityCategory.wareneingang,
            isCustom: true,
            isActive: false,
          ),
        ],
      );
      final ids = _groupActivityIds(model);

      expect(ids, contains('custom_active'));
      expect(ids, contains('custom_inactive_selected'));
      expect(ids, isNot(contains('custom_inactive_hidden')));
      expect(model.unavailableSelectedIds, ['missing_old_id']);
    });

    test('aussortierte Altvorlage kann nicht reaktiviert werden', () {
      final model = _model(
        areas: const {TrainingArea.transport},
        defaultOverrides: const {'transport_07': true},
      );

      expect(model.activitiesById['transport_07']?.isActive, isFalse);
      expect(_groupActivityIds(model), isNot(contains('transport_07')));
      expect(
        model.recommendedActivities.map((activity) => activity.id),
        isNot(contains('transport_07')),
      );
    });

    test('aussortierte Altvorlage bleibt in historischem Eintrag lesbar', () {
      final model = _model(
        areas: const {TrainingArea.transport},
        selectedIds: const {'transport_07'},
      );

      expect(model.unavailableSelectedIds, isEmpty);
      expect(model.selectedActivities.single.id, 'transport_07');
      expect(_groupActivityIds(model), contains('transport_07'));
    });

    test('activityIdsForCategory enthält Standard- und Custom-IDs', () {
      final ids = activityIdsForCategory(
        ActivityCategory.wareneingang,
        const [
          ActivityTemplate(
            id: 'custom_1',
            title: 'Eigene Warenprüfung',
            category: ActivityCategory.wareneingang,
            isCustom: true,
          ),
          ActivityTemplate(
            id: 'custom_other',
            title: 'Eigene Verpackung',
            category: ActivityCategory.verpackung,
            isCustom: true,
          ),
        ],
      );

      expect(ids, contains('wareneingang_01'));
      expect(ids, contains('custom_1'));
      expect(ids, isNot(contains('custom_other')));
    });
  });
}
