import 'package:flutter/material.dart';

enum AppMessageTone { neutral, success, warning, error }

class AppSectionHeader extends StatelessWidget {
  final String title;
  final String? description;
  final String? badge;
  final bool? badgeRequired;
  final Widget? trailing;

  const AppSectionHeader({
    super.key,
    required this.title,
    this.description,
    this.badge,
    this.badgeRequired,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (badge case final b?) ...[
                    const SizedBox(width: 8),
                    _BadgePill(
                        label: b,
                        highlighted: badgeRequired ?? (b == 'Benötigt')),
                  ],
                ],
              ),
              if (description case final description?) ...[
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing case final trailing?) ...[
          const SizedBox(width: 12),
          trailing,
        ],
      ],
    );
  }
}

class _BadgePill extends StatelessWidget {
  final String label;
  final bool highlighted;

  const _BadgePill({required this.label, required this.highlighted});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: highlighted
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: highlighted
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class AppMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final AppMessageTone tone;
  final Widget? action;

  const AppMessage({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.tone = AppMessageTone.neutral,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _colors(theme.colorScheme);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.foreground),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (message case final message?) ...[
                  const SizedBox(height: 3),
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.foreground,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action case final action?) ...[
            const SizedBox(width: 8),
            action,
          ],
        ],
      ),
    );
  }

  ({Color background, Color foreground}) _colors(ColorScheme scheme) {
    return switch (tone) {
      AppMessageTone.neutral => (
          background: scheme.surfaceContainer,
          foreground: scheme.onSurfaceVariant,
        ),
      AppMessageTone.success => (
          background: scheme.secondaryContainer,
          foreground: scheme.onSecondaryContainer,
        ),
      AppMessageTone.warning => (
          background: scheme.tertiaryContainer,
          foreground: scheme.onTertiaryContainer,
        ),
      AppMessageTone.error => (
          background: scheme.errorContainer,
          foreground: scheme.onErrorContainer,
        ),
    };
  }
}

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (action case final action?) ...[
                const SizedBox(height: 20),
                action,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AppSettingsSection extends StatelessWidget {
  final String title;
  final String? description;
  final List<Widget> children;

  const AppSettingsSection({
    super.key,
    required this.title,
    this.description,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionHeader(title: title, description: description),
        const SizedBox(height: 12),
        Material(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      ],
    );
  }
}

/// Dezente Sektions-Trennung für den Heute-Screen (#24a): eine dünne Linie
/// mit vertikalem Abstand, die Hauptsektionen visuell voneinander abgrenzt,
/// ohne die ruhige Optik zu stören.
class AppSectionDivider extends StatelessWidget {
  const AppSectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Theme.of(context).colorScheme.outlineVariant.withAlpha(128),
      ),
    );
  }
}

/// Kompakter Schritt-Indikator (#UX-1 A2): N Punkte, davon der aktive
/// breiter und in Primärfarbe. Erledigte Schritte dezent in Primärfarbe,
/// kommende im neutralen Surface-Ton. Liefert zusätzlich ein
/// `Semantics`-Label für Screenreader.
class AppStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String? semanticLabel;

  const AppStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.semanticLabel,
  })  : assert(currentStep >= 1, 'currentStep muss >= 1 sein'),
        assert(totalSteps >= 1, 'totalSteps muss >= 1 sein'),
        assert(currentStep <= totalSteps, 'currentStep darf totalSteps nicht überschreiten');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final dots = <Widget>[];
    for (int i = 0; i < totalSteps; i++) {
      final isCurrent = i + 1 == currentStep;
      final isDone = i + 1 < currentStep;
      dots.add(
        AnimatedContainer(
          key: ValueKey('app_step_indicator_dot_${i + 1}'),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: isCurrent ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isCurrent || isDone
                ? cs.primary
                : cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );
      if (i < totalSteps - 1) {
        dots.add(const SizedBox(width: 6));
      }
    }
    return Semantics(
      label: semanticLabel ?? 'Schritt $currentStep von $totalSteps',
      container: true,
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: dots,
      ),
    );
  }
}
