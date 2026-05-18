import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/enums/hole_outcome.dart';
import '../../../theme/brdy_colors.dart';
import '../../../theme/brdy_spacing.dart';
import '../providers/active_hole_index_provider.dart';
import '../providers/course_for_round_provider.dart';
import '../providers/hole_list_provider.dart';
import 'score_bar.dart';

class HoleHeader extends ConsumerWidget {
  final int roundId;
  final int highestScoredHoleIndex;

  /// Called when the giant hole number is tapped — used to toggle the nav strip.
  final VoidCallback? onHoleNumberTap;

  const HoleHeader({
    super.key,
    required this.roundId,
    required this.highestScoredHoleIndex,
    this.onHoleNumberTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holeIndex = ref.watch(activeHoleIndexProvider);
    final courseAsync = ref.watch(courseForRoundProvider(roundId));
    final holesAsync = ref.watch(holeListProvider(roundId));

    // Compute SHOTS total from hole list
    final int totalShots = holesAsync.whenData((holes) {
      int shots = 0;
      for (final h in holes) {
        if (h.outcome == null) continue;
        final outcome = HoleOutcome.values.byName(h.outcome!);
        final offset = switch (outcome) {
          HoleOutcome.eagle => -2,
          HoleOutcome.birdie => -1,
          HoleOutcome.par => 0,
          HoleOutcome.bogey => 1,
          HoleOutcome.doubleBogey => 2,
          HoleOutcome.pickup => 2,
        };
        shots += h.par + offset;
      }
      return shots;
    }).value ?? 0;

    // Extract course info
    final course = courseAsync.valueOrNull;
    final holeModel =
        (course != null && holeIndex < course.holes.length)
            ? course.holes[holeIndex]
            : null;

    final String courseInfoLine1;
    final String courseInfoLine2;
    if (course == null) {
      courseInfoLine1 = '— PAR —';
      courseInfoLine2 = 'HCP —';
    } else {
      final name = course.clubName;
      final truncated = name.length > 16 ? '${name.substring(0, 16)}…' : name;
      courseInfoLine1 = '$truncated PAR ${course.par}';
      courseInfoLine2 = 'HCP ${course.slope ?? '—'}';
    }

    final holePar = holeModel?.par;
    final holeSi = holeModel?.strokeIndex;
    final siLabel = holeSi != null ? 'SI $holeSi' : 'SI —';
    final parLabel = holePar != null ? 'PAR $holePar' : 'PAR —';

    final bool leftDisabled = holeIndex == 0;
    final bool rightDisabled = holeIndex >= highestScoredHoleIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: BrdySpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Course info row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    courseInfoLine1.toUpperCase(),
                    style: GoogleFonts.barlowCondensed(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: BrdyColors.onSurfaceMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    courseInfoLine2.toUpperCase(),
                    style: GoogleFonts.barlowCondensed(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: BrdyColors.onSurfaceMuted,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // PAR pill
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: BrdyColors.onSurface, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      parLabel.toUpperCase(),
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: BrdyColors.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: BrdySpacing.xs),
                  // SI pill
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: BrdyColors.onSurface, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      siLabel.toUpperCase(),
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: BrdyColors.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: BrdySpacing.xs),
                  // HOLE pill
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: BrdyColors.onSurface, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'HOLE ${holeIndex + 1}',
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: BrdyColors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: BrdySpacing.lg),
          // Giant hole number — centred, no chevrons
          Center(
            child: Semantics(
              label: 'HOLE ${holeIndex + 1} OF 18 — TAP TO NAVIGATE HOLES',
              button: onHoleNumberTap != null,
              child: GestureDetector(
                onTap: onHoleNumberTap != null
                    ? () {
                        HapticFeedback.selectionClick();
                        onHoleNumberTap!();
                      }
                    : null,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Text(
                      (holeIndex + 1).toString().padLeft(2, '0'),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 96,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                        color: BrdyColors.onSurface,
                      ),
                    )
                        .animate(key: ValueKey(holeIndex))
                        .fadeOut(duration: 50.ms, curve: Curves.easeOut)
                        .then()
                        .fadeIn(duration: 100.ms, curve: Curves.easeOut),
                    Positioned(
                      right: -8,
                      top: 0,
                      child: ScoreBar(roundId: roundId),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: BrdySpacing.md),
          // SHOTS total with chevrons on screen edges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left chevron — screen edge
              Semantics(
                label: 'PREVIOUS HOLE',
                child: IconButton(
                  icon: Icon(
                    Icons.chevron_left,
                    size: 40,
                    color: leftDisabled
                        ? BrdyColors.onSurfaceMuted
                        : BrdyColors.onSurface,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                  onPressed: leftDisabled
                      ? null
                      : () {
                          HapticFeedback.lightImpact();
                          ref
                              .read(activeHoleIndexProvider.notifier)
                              .set(holeIndex - 1);
                        },
                ),
              ),
              // SHOTS counter — centred between chevrons
              Text(
                'SHOTS $totalShots',
                style: GoogleFonts.barlowCondensed(
                  fontSize: 56,
                  fontWeight: FontWeight.w700,
                  color: BrdyColors.onSurface,
                ),
              ),
              // Right chevron — screen edge
              Semantics(
                label: 'NEXT HOLE',
                child: IconButton(
                  icon: Icon(
                    Icons.chevron_right,
                    size: 40,
                    color: rightDisabled
                        ? BrdyColors.onSurfaceMuted
                        : BrdyColors.onSurface,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                  onPressed: rightDisabled
                      ? null
                      : () {
                          HapticFeedback.lightImpact();
                          ref
                              .read(activeHoleIndexProvider.notifier)
                              .set(holeIndex + 1);
                        },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
