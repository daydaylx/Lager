import 'package:flutter_test/flutter_test.dart';
import 'package:berichtsheft_merker/core/domain/curriculum_registry.dart';
import 'package:berichtsheft_merker/core/domain/curriculum_unit.dart';
import 'package:berichtsheft_merker/core/domain/occupation.dart';

void main() {
  group('CurriculumRegistry', () {
    test('liefert eindeutige, jahrgangsgefilterte Units für alle Berufe', () {
      final units = CurriculumRegistry.allUnits;
      expect(units.map((unit) => unit.id).toSet().length, units.length);

      for (final occupation in TrainingOccupation.values) {
        for (final year in occupation.validYears) {
          final pack = CurriculumRegistry.packFor(
            region: CurriculumRegistry.saxonyRegion,
            occupation: occupation,
            trainingYear: year,
          );
          expect(pack.units, isNotEmpty);
          expect(
            pack.units.every(
              (unit) =>
                  unit.occupation == occupation && unit.trainingYear == year,
            ),
            isTrue,
          );
          expect(pack.learningFields, isNotEmpty);
          // Official sources provide no named general subjects per year.
          expect(pack.generalSubjects, isEmpty);
        }
      }
    });

    test('Unit-Typen unterstützen allgemeine und eigene Fächer', () {
      expect(CurriculumUnitType.generalSubject.label, 'Fach');
      expect(CurriculumUnitType.custom.label, 'Eigenes Fach');
    });

    test('Lagerberufe besitzen getrennte Lernfeld-Zuordnungen', () {
      final fachlagerist = CurriculumRegistry.packFor(
        region: CurriculumRegistry.saxonyRegion,
        occupation: TrainingOccupation.fachlagerist,
        trainingYear: 2,
      );
      final fachkraft = CurriculumRegistry.packFor(
        region: CurriculumRegistry.saxonyRegion,
        occupation: TrainingOccupation.fachkraftLagerlogistik,
        trainingYear: 2,
      );

      expect(fachlagerist.learningFields, hasLength(4));
      expect(fachkraft.learningFields, hasLength(3));
      expect(
        fachlagerist.learningFields
            .singleWhere((unit) => unit.displayCode == 'LF 7')
            .title,
        'Güter verladen',
      );
      expect(
        fachkraft.learningFields
            .singleWhere((unit) => unit.displayCode == 'LF 7')
            .title,
        'Touren planen',
      );
      expect(
        fachlagerist.learningFields.last.title,
        'Güter versenden',
      );
      expect(fachkraft.learningFields.last.title, 'Touren planen');
      final fachkraftYear3 = CurriculumRegistry.packFor(
        region: CurriculumRegistry.saxonyRegion,
        occupation: TrainingOccupation.fachkraftLagerlogistik,
        trainingYear: 3,
      );
      expect(fachkraftYear3.learningFields, hasLength(5));
      expect(
        fachkraftYear3.learningFields.map((unit) => unit.title),
        isNot(contains('Touren planen')),
      );
      expect(
        CurriculumRegistry.packFor(
          region: CurriculumRegistry.saxonyRegion,
          occupation: TrainingOccupation.fachlagerist,
          trainingYear: 3,
        ).units,
        isEmpty,
      );
    });

    test('Verkäufer und Kaufmann unterscheiden sich im dritten Jahr', () {
      final sellerYear2 = CurriculumRegistry.packFor(
        region: CurriculumRegistry.saxonyRegion,
        occupation: TrainingOccupation.verkaeufer,
        trainingYear: 2,
      );
      final kaufmannYear3 = CurriculumRegistry.packFor(
        region: CurriculumRegistry.saxonyRegion,
        occupation: TrainingOccupation.kaufmannEinzelhandel,
        trainingYear: 3,
      );

      expect(sellerYear2.learningFields, hasLength(5));
      expect(kaufmannYear3.learningFields, hasLength(4));
      expect(
        kaufmannYear3.learningFields.map((unit) => unit.displayCode),
        ['LF 11', 'LF 12', 'LF 13', 'LF 14'],
      );
      expect(
        kaufmannYear3.units.every((unit) => unit.trainingYear == 3),
        isTrue,
      );
    });

    test('unbekannte Region liefert keine erfundenen Curriculumdaten', () {
      final pack = CurriculumRegistry.packFor(
        region: 'DE-XX',
        occupation: TrainingOccupation.fachlagerist,
        trainingYear: 1,
      );
      expect(pack.units, isEmpty);
    });
  });
}
