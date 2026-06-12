import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2E7D6B),
      brightness: Brightness.light,
    ),
    typography: Typography.material2021(),
  );
}
