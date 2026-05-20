import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/enums/hole_outcome.dart';
import '../../../theme/brdy_colors.dart';
import '../../../theme/brdy_spacing.dart';
import '../providers/active_hole_index_provider.dart';
import '../providers/highest_scored_hole_index_provider.dart';
import '../providers/hole_list_provider.dart';

/// Animated hole navigation strip.
///
/// Shows 18 hole chips coloured by outcome, plus an optional NOW chip to
/// return to the current live hole. Visible only when [isOpen] is true.
///
/// Chip taps call [activeHoleIndexProvider.notifier.set()] — never context.go()
/// or context.push() (CLAUDE.md navigation constraint).
class HoleNavDrawer extends ConsumerWidget {
  final int roundId;
  final bool isOpen;

  const HoleNavDrawer({
    super.key,
    required this.roundId,
    required this.isOpen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeHoleIndex = ref.watch(activeHoleIndexProvider);
    final holesAsync = ref.watch(holeListProvider(roundId));
    final highestScoredIndex =
        ref.watch(highestScoredHoleIndexProvider(roundId));

    // Build a map from holeNumber (1-based) → outcome string
    final Map<int, String?> outcomeByHole = {};
    holesAsync.whenData((holes) {
      for (final h in holes) {
        outcomeByHole[h.holeNumber] = h.outcome;
      }
    });

    final bool showNow = activeHoleIndex < highestScoredIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      height: isOpen ? 56 : 0,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: BrdySpacing.sm,
          vertical: BrdySpacing.sm,
        ),
        child: Row(
          children: [
            // 18 hole chips (0-based index)
            for (int i = 0; i < 18; i++) ...[
              _HoleChip(
                holeNumber: i + 1,
                index: i,
                activeHoleIndex: activeHoleIndex,
                highestScoredIndex: highestScoredIndex,
                outcomeName: outcomeByHole[i + 1],
                onTap: i <= highestScoredIndex + 1
                    ? () async {
                        await HapticFeedback.lightImpact();
                        ref
                            .read(activeHoleIndexProvider.notifier)
                            .set(i);
                      }
                    : null,
              ),
              if (i < 17) const SizedBox(width: BrdySpacing.xs),
            ],
            // NOW chip — visible when the user has navigated back to a previous hole
            if (showNow) ...[
              const SizedBox(width: BrdySpacing.xs),
              _NowChip(
                onTap: () async {
                  await HapticFeedback.lightImpact();
                  ref
                      .read(activeHoleIndexProvider.notifier)
                      .set(highestScoredIndex);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Maps an outcome name string to the chip fill color.
  static Color _outcomeToFill(BuildContext context, String? outcomeName) {
    if (outcomeName == null) return context.brdyColors.surface;
    try {
      return switch (HoleOutcome.values.byName(outcomeName)) {
        HoleOutcome.eagle => const Color(0xFFFFD700),
        HoleOutcome.birdie => BrdyColors.accent,
        HoleOutcome.par => const Color(0xFF2563EB),
        HoleOutcome.bogey => context.brdyColors.surface,
        HoleOutcome.doubleBogey => BrdyColors.destructive,
        HoleOutcome.pickup => BrdyColors.destructive,
      };
    } catch (_) {
      return context.brdyColors.surface;
    }
  }

  /// Maps an outcome name string to the chip text color.
  static Color _outcomeToTextColor(BuildContext context, String? outcomeName) {
    if (outcomeName == null) return context.brdyColors.onSurface;
    try {
      return switch (HoleOutcome.values.byName(outcomeName)) {
        HoleOutcome.eagle => context.brdyColors.background,
        HoleOutcome.birdie => BrdyColors.onAccent,
        HoleOutcome.par => const Color(0xFFFFFFFF),
        HoleOutcome.bogey => context.brdyColors.onSurface,
        HoleOutcome.doubleBogey => BrdyColors.onDestructive,
        HoleOutcome.pickup => BrdyColors.onDestructive,
      };
    } catch (_) {
      return context.brdyColors.onSurface;
    }
  }

  /// Returns the outcome label for semantics.
  static String _outcomeLabel(String? outcomeName) {
    if (outcomeName == null) return 'unscored';
    try {
      return switch (HoleOutcome.values.byName(outcomeName)) {
        HoleOutcome.eagle => 'eagle',
        HoleOutcome.birdie => 'birdie',
        HoleOutcome.par => 'par',
        HoleOutcome.bogey => 'bogey',
        HoleOutcome.doubleBogey => 'double bogey',
        HoleOutcome.pickup => 'pickup',
      };
    } catch (_) {
      return 'unscored';
    }
  }
}

// ── _HoleChip ──────────────────────────────────────────────────────────────────

class _HoleChip extends StatelessWidget {
  final int holeNumber;
  final int index;
  final int activeHoleIndex;
  final int highestScoredIndex;
  final String? outcomeName;
  final VoidCallback? onTap;

  const _HoleChip({
    required this.holeNumber,
    required this.index,
    required this.activeHoleIndex,
    required this.highestScoredIndex,
    required this.outcomeName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFuture =
        index > highestScoredIndex + 1 && outcomeName == null;
    final bool isActive = index == activeHoleIndex;
    final bool isScored = outcomeName != null;
    final bool isBogey = isScored &&
        (() {
          try {
            return HoleOutcome.values.byName(outcomeName!) == HoleOutcome.bogey;
          } catch (_) {
            return false;
          }
        })();

    final Color fill = isFuture
        ? context.brdyColors.divider
        : isScored
            ? HoleNavDrawer._outcomeToFill(context, outcomeName)
            : context.brdyColors.surface;

    final Color textColor = isFuture
        ? context.brdyColors.onSurfaceMuted
        : isScored
            ? HoleNavDrawer._outcomeToTextColor(context, outcomeName)
            : context.brdyColors.onSurface;

    BoxBorder? border;
    if (!isScored && !isFuture) {
      border = Border.all(color: context.brdyColors.divider, width: 1);
    }
    if (isActive) {
      border = Border.all(color: context.brdyColors.onSurface, width: 2);
    }

    return Semantics(
      label:
          'Hole $holeNumber, ${HoleNavDrawer._outcomeLabel(outcomeName)}',
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(4),
            border: border,
          ),
          alignment: Alignment.center,
          child: Text(
            holeNumber.toString(),
            style: GoogleFonts.sometypeMono(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textColor,
              decoration:
                  isBogey ? TextDecoration.underline : TextDecoration.none,
              decorationColor: textColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// ── _NowChip ───────────────────────────────────────────────────────────────────

class _NowChip extends StatelessWidget {
  final VoidCallback onTap;

  const _NowChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: context.brdyColors.accent,
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text(
          'NOW',
          style: GoogleFonts.sometypeMono(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: context.brdyColors.onAccent,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
