import '../../core/enums/day_type.dart';
import 'widgets/today_flow.dart';

/// Reine Logik für die Schritt-Position im geführten Check-in-Flow (#UX-1 A1).
/// Wird sowohl vom Step-Header-Text als auch vom [AppStepIndicator] genutzt,
/// damit Anzeige und Logik synchron bleiben.
class TodayFlowStepCounter {
  final int current;
  final int total;

  const TodayFlowStepCounter({required this.current, required this.total});

  String get label => 'Schritt $current von $total';
}

/// Liefert (current, total) für den aktuellen Schritt in Abhängigkeit des
/// gewählten [dayType]. Für [dayType] `null` wird der größtmögliche Flow
/// (Betrieb) angenommen, damit bereits die Tagestyp-Auswahl einen korrekten
/// Höchstwert zeigt.
TodayFlowStepCounter todayFlowStepCounter({
  required TodayFlowStep step,
  required DayType? dayType,
}) {
  final effective = dayType ?? DayType.betrieb;
  switch (effective) {
    case DayType.betrieb:
      return switch (step) {
        TodayFlowStep.dayType => const TodayFlowStepCounter(current: 1, total: 4),
        TodayFlowStep.area => const TodayFlowStepCounter(current: 2, total: 4),
        TodayFlowStep.activities => const TodayFlowStepCounter(current: 3, total: 4),
        TodayFlowStep.review => const TodayFlowStepCounter(current: 4, total: 4),
        TodayFlowStep.saved => const TodayFlowStepCounter(current: 4, total: 4),
      };
    case DayType.berufsschule:
      return switch (step) {
        TodayFlowStep.dayType => const TodayFlowStepCounter(current: 1, total: 3),
        TodayFlowStep.activities => const TodayFlowStepCounter(current: 2, total: 3),
        TodayFlowStep.review => const TodayFlowStepCounter(current: 3, total: 3),
        TodayFlowStep.area => const TodayFlowStepCounter(current: 1, total: 3),
        TodayFlowStep.saved => const TodayFlowStepCounter(current: 3, total: 3),
      };
    case DayType.frei:
    case DayType.urlaub:
    case DayType.krank:
    case DayType.feiertag:
    case DayType.sonstiges:
      return switch (step) {
        TodayFlowStep.dayType => const TodayFlowStepCounter(current: 1, total: 2),
        TodayFlowStep.review => const TodayFlowStepCounter(current: 2, total: 2),
        TodayFlowStep.area => const TodayFlowStepCounter(current: 1, total: 2),
        TodayFlowStep.activities => const TodayFlowStepCounter(current: 1, total: 2),
        TodayFlowStep.saved => const TodayFlowStepCounter(current: 2, total: 2),
      };
  }
}

/// Kompakter Kontext-Text für den Tätigkeits-Picker-Header (#UX-1 A3).
/// `null` wenn kein sinnvoller Kontext vorhanden ist.
String? todayFlowStepContext({
  required TodayFlowStep step,
  required DayType? dayType,
  required Iterable<String> selectedAreaLabels,
}) {
  if (step != TodayFlowStep.activities) return null;
  if (dayType == DayType.berufsschule) return 'Berufsschule';
  if (selectedAreaLabels.isEmpty) return null;
  return selectedAreaLabels.join(', ');
}
