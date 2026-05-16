import 'package:flutter/material.dart';
import 'brdy_colors.dart';
import 'brdy_text_theme.dart';

abstract final class BrdyTheme {
  static ThemeData get themeData => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: BrdyColors.background,
    colorScheme: const ColorScheme.dark(
      surface: BrdyColors.surface,
      primary: BrdyColors.accent,
      onPrimary: BrdyColors.onAccent,
      secondary: BrdyColors.surface,
      onSecondary: BrdyColors.onSurface,
      error: BrdyColors.destructive,
      onError: BrdyColors.onDestructive,
    ),
    textTheme: BrdyTextTheme.textTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: BrdyColors.accent,
        foregroundColor: BrdyColors.onAccent,
        minimumSize: const Size(double.infinity, 56),
        shape: const RoundedRectangleBorder(), // 0dp radius — brutalist
        textStyle: BrdyTextTheme.textTheme.labelLarge,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: BrdyColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.zero, // 0dp radius — brutalist
        borderSide: BorderSide(color: BrdyColors.divider, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: BrdyColors.accent, width: 2),
      ),
    ),
  );
}
