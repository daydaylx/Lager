import 'occupation.dart';
import 'curriculum_unit.dart';

/// Offline-Curricula für das Start-Bundesland Sachsen (`DE-SN`).
///
/// Lernfelder folgen den sächsischen Lehrplänen. Die Quellen nennen den
/// berufsübergreifenden Bereich, aber keine konkreten Fächer mit
/// Jahrgangszuordnung; solche Einheiten werden deshalb nicht erfunden.
/// Quellen: Sächsische Lehrpläne /795 und /434 sowie KMK-Rahmenlehrpläne
/// Fachlagerist, Fachkraft Lagerlogistik und Einzelhandel (Stand 2016).
class CurriculumRegistry {
  static const String saxonyRegion = 'DE-SN';

  static const Map<int, String> _fachlageristFields = {
    1: 'Güter annehmen und kontrollieren',
    2: 'Güter lagern',
    3: 'Güter bearbeiten',
    4: 'Güter im Betrieb transportieren',
    5: 'Güter kommissionieren',
    6: 'Güter verpacken',
    7: 'Güter verladen',
    8: 'Güter versenden',
  };

  static const Map<int, String> _fachkraftFields = {
    1: 'Güter annehmen und kontrollieren',
    2: 'Güter lagern',
    3: 'Güter bearbeiten',
    4: 'Güter im Betrieb transportieren',
    5: 'Güter kommissionieren',
    6: 'Güter verpacken',
    7: 'Touren planen',
    8: 'Güter verladen',
    9: 'Güter versenden',
    10: 'Logistische Prozesse optimieren',
    11: 'Güter beschaffen',
    12: 'Kennzahlen ermitteln und auswerten',
  };

  static const Map<int, String> _retailFields = {
    1: 'Das Einzelhandelsunternehmen repräsentieren',
    2: 'Verkaufsgespräche kundenorientiert führen',
    3: 'Kunden im Servicebereich Kasse betreuen',
    4: 'Waren präsentieren',
    5: 'Werben und den Verkauf fördern',
    6: 'Waren beschaffen',
    7: 'Waren annehmen, lagern und pflegen',
    8: 'Geschäftsprozesse erfassen und kontrollieren',
    9: 'Preispolitische Maßnahmen vorbereiten und durchführen',
    10: 'Besondere Verkaufssituationen bewältigen',
    11: 'Geschäftsprozesse erfolgsorientiert steuern',
    12: 'Mit Marketingkonzepten Kunden gewinnen und binden',
    13: 'Personaleinsatz planen und Mitarbeiter führen',
    14: 'Ein Einzelhandelsunternehmen leiten und entwickeln',
  };

  static final List<CurriculumUnit> _units = _buildUnits();

  static List<CurriculumUnit> get allUnits =>
      List<CurriculumUnit>.unmodifiable(_units);

  static CurriculumPack packFor({
    required String region,
    required TrainingOccupation occupation,
    required int trainingYear,
  }) {
    final units = region == saxonyRegion && occupation.isValidYear(trainingYear)
        ? _units
            .where(
              (unit) =>
                  unit.region == region &&
                  unit.occupation == occupation &&
                  unit.trainingYear == trainingYear,
            )
            .toList(growable: false)
        : const <CurriculumUnit>[];
    return CurriculumPack(
      occupation: occupation,
      region: region,
      trainingYear: trainingYear,
      units: units,
    );
  }

  static CurriculumUnit? unitById(String id) {
    for (final unit in _units) {
      if (unit.id == id) return unit;
    }
    return null;
  }

  static List<CurriculumUnit> _buildUnits() {
    final units = <CurriculumUnit>[];
    for (final occupation in TrainingOccupation.values) {
      final fields = switch (occupation) {
        TrainingOccupation.fachlagerist => _fachlageristFields,
        TrainingOccupation.fachkraftLagerlogistik => _fachkraftFields,
        TrainingOccupation.verkaeufer ||
        TrainingOccupation.kaufmannEinzelhandel => _retailFields,
      };
      for (final field in fields.entries) {
        if (occupation == TrainingOccupation.verkaeufer && field.key > 10) {
          continue;
        }
        final year = switch (occupation) {
          TrainingOccupation.fachlagerist => field.key <= 4 ? 1 : 2,
          TrainingOccupation.fachkraftLagerlogistik =>
            field.key <= 4 ? 1 : field.key <= 7 ? 2 : 3,
          TrainingOccupation.verkaeufer => field.key <= 5 ? 1 : 2,
          TrainingOccupation.kaufmannEinzelhandel =>
            field.key <= 5 ? 1 : field.key <= 10 ? 2 : 3,
        };
        if (!occupation.isValidYear(year)) continue;
        units.add(
          CurriculumUnit(
            id: 'de_sn_${occupation.storageKey}_lf${field.key.toString().padLeft(2, '0')}',
            occupation: occupation,
            region: saxonyRegion,
            trainingYear: year,
            unitType: CurriculumUnitType.learningField,
            displayCode: 'LF ${field.key}',
            title: field.value,
          ),
        );
      }

    }
    return List<CurriculumUnit>.unmodifiable(units);
  }
}
