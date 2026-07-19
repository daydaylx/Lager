import 'package:berichtsheft_merker/core/enums/day_type.dart';
import 'package:berichtsheft_merker/features/today/today_flow_steps.dart';
import 'package:berichtsheft_merker/features/today/widgets/today_flow.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('todayFlowStepCounter', () {
    test('Betrieb zählt 1/4 für dayType', () {
      expect(
        todayFlowStepCounter(
          step: TodayFlowStep.dayType,
          dayType: DayType.betrieb,
        ),
        const TodayFlowStepCounter(current: 1, total: 4),
      );
    });

    test('Betrieb zählt 2/4 für area', () {
      expect(
        todayFlowStepCounter(
          step: TodayFlowStep.area,
          dayType: DayType.betrieb,
        ),
        const TodayFlowStepCounter(current: 2, total: 4),
      );
    });

    test('Betrieb zählt 3/4 für activities', () {
      expect(
        todayFlowStepCounter(
          step: TodayFlowStep.activities,
          dayType: DayType.betrieb,
        ),
        const TodayFlowStepCounter(current: 3, total: 4),
      );
    });

    test('Betrieb zählt 4/4 für review', () {
      expect(
        todayFlowStepCounter(
          step: TodayFlowStep.review,
          dayType: DayType.betrieb,
        ),
        const TodayFlowStepCounter(current: 4, total: 4),
      );
    });

    test('Berufsschule zählt 1/3 für dayType', () {
      expect(
        todayFlowStepCounter(
          step: TodayFlowStep.dayType,
          dayType: DayType.berufsschule,
        ),
        const TodayFlowStepCounter(current: 1, total: 3),
      );
    });

    test('Berufsschule zählt 2/3 für activities (überspringt area)', () {
      expect(
        todayFlowStepCounter(
          step: TodayFlowStep.activities,
          dayType: DayType.berufsschule,
        ),
        const TodayFlowStepCounter(current: 2, total: 3),
      );
    });

    test('Berufsschule zählt 3/3 für review', () {
      expect(
        todayFlowStepCounter(
          step: TodayFlowStep.review,
          dayType: DayType.berufsschule,
        ),
        const TodayFlowStepCounter(current: 3, total: 3),
      );
    });

    test('Abwesenheit (Urlaub) zählt 1/2 für dayType', () {
      expect(
        todayFlowStepCounter(
          step: TodayFlowStep.dayType,
          dayType: DayType.urlaub,
        ),
        const TodayFlowStepCounter(current: 1, total: 2),
      );
    });

    test('Abwesenheit (Krank) zählt 2/2 für review', () {
      expect(
        todayFlowStepCounter(
          step: TodayFlowStep.review,
          dayType: DayType.krank,
        ),
        const TodayFlowStepCounter(current: 2, total: 2),
      );
    });

    test('Sonstiges zählt 2/2 für review', () {
      expect(
        todayFlowStepCounter(
          step: TodayFlowStep.review,
          dayType: DayType.sonstiges,
        ),
        const TodayFlowStepCounter(current: 2, total: 2),
      );
    });

    test('dayType null fällt konservativ auf Betriebs-Max zurück', () {
      expect(
        todayFlowStepCounter(
          step: TodayFlowStep.dayType,
          dayType: null,
        ),
        const TodayFlowStepCounter(current: 1, total: 4),
      );
    });

    test('label rendert Schritt X von Y', () {
      const counter = TodayFlowStepCounter(current: 2, total: 4);
      expect(counter.label, 'Schritt 2 von 4');
    });
  });

  group('todayFlowStepContext', () {
    test('liefert Bereichs-Labels für Betrieb im Tätigkeitsschritt', () {
      expect(
        todayFlowStepContext(
          step: TodayFlowStep.activities,
          dayType: DayType.betrieb,
          selectedAreaLabels: const ['Wareneingang', 'Lager'],
        ),
        'Wareneingang, Lager',
      );
    });

    test('liefert "Berufsschule" für Berufsschule im Tätigkeitsschritt', () {
      expect(
        todayFlowStepContext(
          step: TodayFlowStep.activities,
          dayType: DayType.berufsschule,
          selectedAreaLabels: const [],
        ),
        'Berufsschule',
      );
    });

    test('liefert null außerhalb des Tätigkeitsschritts', () {
      expect(
        todayFlowStepContext(
          step: TodayFlowStep.dayType,
          dayType: DayType.betrieb,
          selectedAreaLabels: const ['Wareneingang'],
        ),
        isNull,
      );
      expect(
        todayFlowStepContext(
          step: TodayFlowStep.review,
          dayType: DayType.betrieb,
          selectedAreaLabels: const ['Wareneingang'],
        ),
        isNull,
      );
    });

    test('liefert null für Betrieb ohne ausgewählte Bereiche', () {
      expect(
        todayFlowStepContext(
          step: TodayFlowStep.activities,
          dayType: DayType.betrieb,
          selectedAreaLabels: const [],
        ),
        isNull,
      );
    });
  });
}
