import 'package:flutter/material.dart';
import '../../../core/enums/training_area.dart';
import 'area_grid.dart';

/// Snap-Carousel zur Bereichsauswahl (Phase 22c).
///
/// Interaktion (Plan 4.6): Wischen = blättern (keine Auswahländerung), Tippen
/// auf die **zentrierte** Karte = Bereich ein-/ausschalten, ausgewählte
/// Bereiche erscheinen darunter als Chips (Tap entfernt). Das Carousel startet
/// **zentriert auf dem ersten Bereich (wareneingang)**, damit der häufigste
/// Fall sofort wählbar ist und bestehende Tap-Tests ohne Paging greifen.
///
/// Visuelle Hierarchie ohne Text-Abdunklung (sonst WCAG-Kontrast gefährdet,
/// Plan-Risiko 3): die zentrierte Karte bekommt Primär-Outline + Primär-Icon,
/// Nachbarn sind flacher. Auf sehr schmalen Displays (< 300 dp) fällt das
/// Widget auf das bewährte 2-spaltige Grid ([AreaGrid]) zurück.
class AreaCarousel extends StatefulWidget {
  final List<TrainingArea> areas;
  final Set<TrainingArea> selected;
  final ValueChanged<TrainingArea> onToggle;

  const AreaCarousel({
    super.key,
    required this.areas,
    required this.selected,
    required this.onToggle,
  });

  @override
  State<AreaCarousel> createState() => _AreaCarouselState();
}

class _AreaCarouselState extends State<AreaCarousel> {
  static const double _viewportFraction = 0.72;
  static const double _fallbackWidth = 300;

  late final PageController _controller;
  int _focused = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage: 0,
      viewportFraction: _viewportFraction,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _centerOn(TrainingArea area) {
    final index = widget.areas.indexOf(area);
    if (index >= 0 && index != _focused && _controller.hasClients) {
      _controller.animateToPage(
        index,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _fallbackWidth) {
          return AreaGrid(
            areas: widget.areas,
            selected: widget.selected,
            onToggle: widget.onToggle,
          );
        }
        final orderedSelected = widget.areas
            .where(widget.selected.contains)
            .toList(growable: false);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 156,
              child: PageView.builder(
                key: const ValueKey('area_carousel'),
                controller: _controller,
                itemCount: widget.areas.length,
                onPageChanged: (index) => setState(() => _focused = index),
                itemBuilder: (context, index) {
                  final area = widget.areas[index];
                  final isSelected = widget.selected.contains(area);
                  final isCentered = index == _focused;
                  return _AreaCard(
                    key: ValueKey('area_${area.name}'),
                    area: area,
                    selected: isSelected,
                    centered: isCentered,
                    onTap: isCentered ? () => widget.onToggle(area) : null,
                  );
                },
              ),
            ),
            if (orderedSelected.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final area in orderedSelected)
                    InputChip(
                      key: ValueKey('area_chip_${area.name}'),
                      avatar: Icon(area.icon, size: 16),
                      label: Text(area.label),
                      selected: true,
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        widget.onToggle(area);
                        _centerOn(area);
                      },
                      onSelected: (_) {
                        widget.onToggle(area);
                        _centerOn(area);
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

class _AreaCard extends StatelessWidget {
  final TrainingArea area;
  final bool selected;
  final bool centered;
  final VoidCallback? onTap;

  const _AreaCard({
    super.key,
    required this.area,
    required this.selected,
    required this.centered,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final Color background;
    final Color foreground;
    final Color subtitleColor;
    final Color iconColor;
    BoxBorder? border;

    if (selected) {
      background = cs.primaryContainer;
      foreground = cs.onPrimaryContainer;
      subtitleColor = cs.onPrimaryContainer;
      iconColor = cs.onPrimaryContainer;
      border = Border.all(color: cs.primary, width: 2);
    } else if (centered) {
      background = cs.surfaceContainerLow;
      foreground = cs.onSurface;
      subtitleColor = cs.onSurfaceVariant;
      iconColor = cs.primary;
      border = Border.all(
        color: cs.primary.withValues(alpha: 0.5),
        width: 1.5,
      );
    } else {
      background = cs.surfaceContainer;
      foreground = cs.onSurfaceVariant;
      subtitleColor = cs.onSurfaceVariant;
      iconColor = cs.onSurfaceVariant;
    }

    return Semantics(
      button: true,
      toggled: selected,
      label: '${area.label}. ${area.subtitle}.',
      hint: selected
          ? 'Ausgewählt'
          : (centered
              ? 'Tippen, um auszuwählen'
              : 'Zum Auswählen hierher wischen'),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(18),
            border: border,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(area.icon, size: 30, color: iconColor),
              const SizedBox(height: 8),
              Text(
                area.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                area.subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(color: subtitleColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
