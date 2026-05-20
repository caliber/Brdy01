import 'package:flutter/material.dart';

/// Immutable color set — one instance per brightness mode.
class BrdyColorSet {
  final Color background;
  final Color surface;
  final Color onSurface;
  final Color onSurfaceMuted;
  final Color accent;
  final Color onAccent;
  final Color destructive;
  final Color onDestructive;
  final Color divider;

  const BrdyColorSet({
    required this.background,
    required this.surface,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.accent,
    required this.onAccent,
    required this.destructive,
    required this.onDestructive,
    required this.divider,
  });

  static const dark = BrdyColorSet(
    background:     Color(0xFF0A0A0A),
    surface:        Color(0xFF1A1A1A),
    onSurface:      Color(0xFFF0F0F0),
    onSurfaceMuted: Color(0xFFA0A0A0),
    accent:         Color(0xFFE8520A),
    onAccent:       Color(0xFF0A0A0A),
    destructive:    Color(0xFFCC2200),
    onDestructive:  Color(0xFFF0F0F0),
    divider:        Color(0xFF2A2A2A),
  );

  static const light = BrdyColorSet(
    background:     Color(0xFFF5F4F2),
    surface:        Color(0xFFE8E6E3),
    onSurface:      Color(0xFF0A0A0A),
    onSurfaceMuted: Color(0xFF555555),
    accent:         Color(0xFFE8520A),
    onAccent:       Color(0xFFFFFFFF),
    destructive:    Color(0xFFCC2200),
    onDestructive:  Color(0xFFFFFFFF),
    divider:        Color(0xFFCCCCCC),
  );
}

/// Backward-compatible static accessors (dark mode constants).
/// Use `context.brdyColors.X` for theme-aware access.
abstract final class BrdyColors {
  static const Color background     = Color(0xFF0A0A0A);
  static const Color surface        = Color(0xFF1A1A1A);
  static const Color onSurface      = Color(0xFFF0F0F0);
  static const Color onSurfaceMuted = Color(0xFFA0A0A0);
  static const Color accent         = Color(0xFFE8520A);
  static const Color onAccent       = Color(0xFF0A0A0A);
  static const Color destructive    = Color(0xFFCC2200);
  static const Color onDestructive  = Color(0xFFF0F0F0);
  static const Color divider        = Color(0xFF2A2A2A);

  /// Theme-aware accessor — use this in build methods.
  static BrdyColorSet of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? BrdyColorSet.light
        : BrdyColorSet.dark;
  }
}

/// Convenience extension so widgets can write `context.brdyColors.background`.
extension BrdyColorsContext on BuildContext {
  BrdyColorSet get brdyColors => BrdyColors.of(this);
}
