import 'package:flutter/material.dart';
import '../../../core/ui/day_status_colors.dart';

/// Status eines Wochentags in der Punkt-Leiste.
enum WeekDotStatus {
  /// Erledigt: Es existiert ein Eintrag.
  done,

  /// Fällig (Werktag bis einschließlich heute), aber noch kein Eintrag.
  open,

  /// Nicht fällig: Wochenende oder liegt in der Zukunft.
  idle,
}

/// Ein Datenpunkt der [WeekDotStrip] (ein Wochentag).
class WeekDot {
  final String weekday;
  final WeekDotStatus status;
  final bool isToday;

  const WeekDot({
    required this.weekday,
    required this.status,
    this.isToday = false,
  });
}

/// Kompakte Mo–So-Punkt-Leiste für den Wochen-Header (Phase 22b).
///
/// Ersetzt den bisherigen Prozentbalken durch eine ruhige, at-a-glance
/// Übersicht: gefüllter Punkt = erledigt, Ring = offen, kleiner blasser Punkt =
/// nicht fällig (Wochenende/Zukunft). Der heutige Tag ist durch einen feinen
/// Rahmen hervorgehoben. Die Bedienung bleibt bei der tappbaren Tagesliste
/// darunter — die Dots sind rein visuell.
class WeekDotStrip extends StatelessWidget {
  final List<WeekDot> dots;

  const WeekDotStrip({super.key, required this.dots});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _semanticsLabel(),
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [for (final dot in dots) _Dot(dot: dot)],
      ),
    );
  }

  String _semanticsLabel() {
    final done = dots.where((d) => d.status == WeekDotStatus.done).length;
    final open = dots.where((d) => d.status == WeekDotStatus.open).length;
    final due = done + open;
    return '$done von $due ${due == 1 ? 'Tag' : 'Tagen'} erledigt, '
        '$open ${open == 1 ? 'Tag wartet' : 'Tage warten'} noch.';
  }
}

class _Dot extends StatelessWidget {
  final WeekDot dot;

  const _Dot({required this.dot});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final color = switch (dot.status) {
      WeekDotStatus.done => DayStatusKind.saved.color(cs),
      WeekDotStatus.open => DayStatusKind.open.color(cs),
      WeekDotStatus.idle => cs.onSurfaceVariant.withValues(alpha: 0.38),
    };

    final mark = switch (dot.status) {
      WeekDotStatus.done => _circle(size: 12, color: color, filled: true),
      WeekDotStatus.open => _circle(size: 12, color: color, filled: false),
      WeekDotStatus.idle => _circle(size: 6, color: color, filled: true),
    };

    final markArea = dot.isToday
        ? Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: DayStatusKind.saved.color(cs).withValues(alpha: 0.7),
                width: 1.5,
              ),
            ),
            child: mark,
          )
        : SizedBox(width: 18, height: 18, child: Center(child: mark));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        markArea,
        const SizedBox(height: 4),
        Text(
          dot.weekday,
          style: theme.textTheme.labelSmall?.copyWith(
            color: dot.isToday ? cs.primary : cs.onSurfaceVariant,
            fontWeight: dot.isToday ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _circle({required double size, required Color color, required bool filled}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? color : null,
        border: filled ? null : Border.all(color: color, width: 2),
      ),
    );
  }
}
