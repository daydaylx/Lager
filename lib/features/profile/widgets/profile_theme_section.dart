import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../shared/widgets/app_ui.dart';

class ProfileThemeSection extends StatefulWidget {
  final ThemePreset current;
  final Future<void> Function(ThemePreset)? onChanged;

  const ProfileThemeSection({
    super.key,
    required this.current,
    required this.onChanged,
  });

  @override
  State<ProfileThemeSection> createState() => _ProfileThemeSectionState();
}

class _ProfileThemeSectionState extends State<ProfileThemeSection> {
  bool _applying = false;

  Future<void> _select(ThemePreset preset) async {
    if (_applying || preset == widget.current || widget.onChanged == null) {
      return;
    }
    setState(() => _applying = true);
    try {
      await widget.onChanged!(preset);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Das Farbtheme konnte nicht gespeichert werden.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppSettingsSection(
      title: 'Darstellung',
      description: 'Farbtheme der App.',
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            const columns = 3;
            const spacing = 12.0;
            final tileWidth =
                (constraints.maxWidth - spacing * (columns - 1)) / columns;
            return Wrap(
              key: const ValueKey('theme_selector'),
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final preset in ThemePreset.values)
                  SizedBox(
                    key: ValueKey('theme_${preset.name}'),
                    width: tileWidth,
                    height: tileWidth / 0.82,
                    child: _ThemePresetTile(
                      preset: preset,
                      selected: preset == widget.current,
                      disabled: _applying,
                      onTap: () => _select(preset),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Tappable Farbvorschau-Kachel für ein [ThemePreset].
///
/// Die Miniatur zeigt Helligkeit (Hintergrund = [ThemePreset.surfaceColor])
/// und Farbton (Akzentbalken + Punkt = [ThemePreset.seedColor]); das gewählte
/// Preset wird mit einem primary-Ring und Häkchen markiert.
class _ThemePresetTile extends StatelessWidget {
  final ThemePreset preset;
  final bool selected;
  final bool disabled;
  final VoidCallback? onTap;

  const _ThemePresetTile({
    required this.preset,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final lightSeed =
        Color.lerp(preset.seedColor, Colors.white, 0.25) ?? preset.seedColor;

    return Opacity(
      opacity: disabled ? 0.6 : 1,
      child: Material(
        color: colorScheme.surfaceContainerLow,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              border: Border.all(
                color:
                    selected ? colorScheme.primary : colorScheme.outlineVariant,
                width: selected ? 2 : 1,
              ),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ColoredBox(color: preset.surfaceColor),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            height: 10,
                            width: double.infinity,
                            color: preset.seedColor,
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: lightSeed,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        if (selected)
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Icon(
                                Icons.check_circle,
                                size: 18,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  preset.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: colorScheme.onSurface),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
