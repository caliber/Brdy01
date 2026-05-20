import 'package:flutter/material.dart';
import 'brdy_colors.dart';
import 'brdy_text_theme.dart';

abstract final class BrdyTheme {
  static ThemeData get dark => _build(BrdyColorSet.dark, Brightness.dark);
  static ThemeData get light => _build(BrdyColorSet.light, Brightness.light);

  static ThemeData _build(BrdyColorSet c, Brightness brightness) => ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: c.background,
    colorScheme: ColorScheme(
      brightness: brightness,
      surface: c.surface,
      onSurface: c.onSurface,
      primary: c.accent,
      onPrimary: c.onAccent,
      secondary: c.surface,
      onSecondary: c.onSurface,
      error: c.destructive,
      onError: c.onDestructive,
    ),
    textTheme: BrdyTextTheme.textTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: c.accent,
        foregroundColor: c.onAccent,
        minimumSize: const Size(double.infinity, 56),
        shape: const RoundedRectangleBorder(),
        textStyle: BrdyTextTheme.textTheme.labelLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: c.divider, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: c.accent, width: 2),
      ),
    ),
  );
}
