import 'package:flutter/material.dart';

enum ThemePreset {
  lagerTeal,
  nachtGruen,
  warmSand,
  blauGrau,
  hell,
  nachtTeal,
  fliederNacht,
  terracottaNacht,
  anthrazit,
}

extension ThemePresetDetails on ThemePreset {
  String get label => switch (this) {
        ThemePreset.lagerTeal => 'Lager Teal',
        ThemePreset.nachtGruen => 'Nacht Grün',
        ThemePreset.warmSand => 'Warm Sand',
        ThemePreset.blauGrau => 'Blau Grau',
        ThemePreset.hell => 'Hell',
        ThemePreset.nachtTeal => 'Nacht Teal',
        ThemePreset.fliederNacht => 'Flieder Nacht',
        ThemePreset.terracottaNacht => 'Terrakotta Nacht',
        ThemePreset.anthrazit => 'Anthrazit',
      };

  Color get seedColor => switch (this) {
        ThemePreset.lagerTeal => const Color(0xFF347A63), // #22f: minimal wärmer/grüner
        ThemePreset.nachtGruen => const Color(0xFF1A5C40),
        ThemePreset.warmSand => const Color(0xFF8B6914),
        ThemePreset.blauGrau => const Color(0xFF3A5B8C),
        ThemePreset.hell => const Color(0xFF2E7D6B),
        ThemePreset.nachtTeal => const Color(0xFF1F6B5C),
        ThemePreset.fliederNacht => const Color(0xFF6B5B95),
        ThemePreset.terracottaNacht => const Color(0xFFA65A3C),
        ThemePreset.anthrazit => const Color(0xFF5C6470),
      };

  Color get _surfaceColor => switch (this) {
        ThemePreset.lagerTeal => const Color(0xFF142822),
        ThemePreset.nachtGruen => const Color(0xFF081510),
        ThemePreset.warmSand => const Color(0xFF1A1208),
        ThemePreset.blauGrau => const Color(0xFF0C1520),
        ThemePreset.hell => const Color(0xFFF8FAF9),
        ThemePreset.nachtTeal => const Color(0xFF0B1714),
        ThemePreset.fliederNacht => const Color(0xFF13111C),
        ThemePreset.terracottaNacht => const Color(0xFF1B110D),
        ThemePreset.anthrazit => const Color(0xFF101214),
      };

  /// Öffentlicher Zugang zur Hintergrundfarbe (für Theme-Vorschauen).
  Color get surfaceColor => _surfaceColor;

  Brightness get brightness => switch (this) {
        ThemePreset.hell => Brightness.light,
        _ => Brightness.dark,
      };
}

ThemeData buildThemeForPreset(ThemePreset preset) =>
    _buildTheme(preset.brightness, preset.seedColor, preset._surfaceColor);

ThemeData _buildTheme(
  Brightness brightness,
  Color seedColor,
  Color surfaceColor,
) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: brightness,
    surface: surfaceColor,
  );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    typography: Typography.material2021(),
  );
  final roundedShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: BorderSide(
      color: colorScheme.outlineVariant.withValues(
        alpha: brightness == Brightness.dark ? 0.34 : 0.55,
      ),
    ),
  );

  // Slightly lifted secondary text for dark themes (#27)
  final secondaryTextColor = brightness == Brightness.dark
      ? colorScheme.onSurface.withValues(alpha: 0.72)
      : colorScheme.onSurfaceVariant;

  return base.copyWith(
    scaffoldBackgroundColor: colorScheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      scrolledUnderElevation: 3,
      centerTitle: false,
      titleTextStyle: base.textTheme.titleLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72, // #22e: leichtere Bottom-Leiste (vorher 80)
      backgroundColor: colorScheme.surfaceContainerLow,
      indicatorColor: colorScheme.surfaceContainerHighest, // dezenter Pillenhintergrund
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        return base.textTheme.labelMedium?.copyWith(
          color: states.contains(WidgetState.selected)
              ? colorScheme.onSurface
              : secondaryTextColor, // #27: more readable inactive labels
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
        );
      }),
    ),
    cardTheme: CardThemeData(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      surfaceTintColor: colorScheme.primary.withValues(alpha: 0.05),
      shape: roundedShape,
    ),
    dividerTheme: DividerThemeData(
      color: colorScheme.outlineVariant,
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerLowest,
      hintStyle: base.textTheme.bodyLarge?.copyWith(
        color: secondaryTextColor, // #27: more readable placeholder
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        disabledForegroundColor:
            colorScheme.onSurface.withValues(alpha: 0.45), // #27: readable disabled text
        textStyle: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 52),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide(color: colorScheme.outline),
        textStyle: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide(color: colorScheme.outlineVariant),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      labelStyle: base.textTheme.labelLarge,
    ),
    listTileTheme: ListTileThemeData(
      minTileHeight: 56,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      iconColor: colorScheme.onSurfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colorScheme.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colorScheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 0,
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle: base.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onInverseSurface,
      ),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
