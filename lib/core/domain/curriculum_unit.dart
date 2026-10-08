import 'occupation.dart';

enum CurriculumUnitType {
  learningField,
  generalSubject,
  elective,
  custom,
}

extension CurriculumUnitTypeLabel on CurriculumUnitType {
  String get label => switch (this) {
        CurriculumUnitType.learningField => 'Lernfeld',
        CurriculumUnitType.generalSubject => 'Fach',
        CurriculumUnitType.elective => 'Wahlbereich',
        CurriculumUnitType.custom => 'Eigenes Fach',
      };
}

/// Eine statische Lerneinheit aus dem regionalen Berufsschul-Curriculum.
class CurriculumUnit {
  final String id;
  final TrainingOccupation occupation;
  final String region;
  final int trainingYear;
  final CurriculumUnitType unitType;
  final String displayCode;
  final String title;
  final List<String> keywords;

  const CurriculumUnit({
    required this.id,
    required this.occupation,
    required this.region,
    required this.trainingYear,
    required this.unitType,
    required this.displayCode,
    required this.title,
    this.keywords = const [],
  });

  String get displayTitle => displayCode.isEmpty ? title : '$displayCode · $title';
}

/// Die für einen Ausbildungsberuf, ein Bundesland und ein Jahr sichtbaren
/// Lerneinheiten. Die Registry enthält nur statische, offline verfügbare Daten.
class CurriculumPack {
  final TrainingOccupation occupation;
  final String region;
  final int trainingYear;
  final List<CurriculumUnit> units;

  const CurriculumPack({
    required this.occupation,
    required this.region,
    required this.trainingYear,
    required this.units,
  });

  List<CurriculumUnit> get learningFields => units
      .where((unit) => unit.unitType == CurriculumUnitType.learningField)
      .toList(growable: false);

  List<CurriculumUnit> get generalSubjects => units
      .where((unit) => unit.unitType == CurriculumUnitType.generalSubject)
      .toList(growable: false);
}
