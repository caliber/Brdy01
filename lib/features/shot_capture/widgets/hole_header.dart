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
import '../providers/hole_score_notifier.dart';
import '../providers/last_scored_outcome_provider.dart';
import 'score_bar.dart';

class HoleHeader extends ConsumerWidget {
  final int roundId;
  final int highestScoredHoleIndex;
  final VoidCallback? onHoleNumberTap;
  final String voicePartialText;

  const HoleHeader({
    super.key,
    required this.roundId,
    required this.highestScoredHoleIndex,
    this.onHoleNumberTap,
    this.voicePartialText = '',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holeIndex = ref.watch(activeHoleIndexProvider);
    final courseAsync = ref.watch(courseForRoundProvider(roundId));
    final holesAsync = ref.watch(holeListProvider(roundId));

    int totalShots = 0;
    holesAsync.whenData((holes) {
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
        totalShots += h.par + offset;
      }
    });

    final course = courseAsync.valueOrNull;
    final holeModel = (course != null && holeIndex < course.holes.length)
        ? course.holes[holeIndex]
        : null;

    final String courseInfoLine1;
    final String courseInfoLine2;
    if (course == null) {
      courseInfoLine1 = '—';
      courseInfoLine2 = 'PAR — · HCP —';
    } else {
      courseInfoLine1 = course.clubName;
      courseInfoLine2 = 'PAR ${course.par} · HCP ${course.slope ?? '—'}';
    }

    final holePar = holeModel?.par;
    final holeSi = holeModel?.strokeIndex;

    final flashOutcome = ref.watch(lastScoredOutcomeProvider(roundId));

    final currentHoleState = ref.watch(
      holeScoreNotifierProvider(roundId, holeIndex),
    ).valueOrNull;
    int currentHoleShots = 0;
    if (currentHoleState?.outcome != null && holePar != null) {
      final outcome = HoleOutcome.values.byName(currentHoleState!.outcome!);
      final offset = switch (outcome) {
        HoleOutcome.eagle => -2,
        HoleOutcome.birdie => -1,
        HoleOutcome.par => 0,
        HoleOutcome.bogey => 1,
        HoleOutcome.doubleBogey => 2,
        HoleOutcome.pickup => 2,
      };
      currentHoleShots = holePar + offset;
    }

    final parLabel = holePar != null ? 'PAR $holePar' : 'PAR —';
    final siLabel = holeSi != null ? 'SI $holeSi' : null;
    final bool leftDisabled = holeIndex == 0;
    final bool rightDisabled = holeIndex >= highestScoredHoleIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: BrdySpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Course info row ──────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      courseInfoLine1.toUpperCase(),
                      style: GoogleFonts.sometypeMono(
                          fontSize: 13, fontWeight: FontWeight.w700, color: context.brdyColors.onSurfaceMuted),
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Transform.translate(
                      offset: const Offset(0, -6),
                      child: Text(
                        courseInfoLine2.toUpperCase(),
                        style: GoogleFonts.sometypeMono(
                            fontSize: 13, fontWeight: FontWeight.w700, color: context.brdyColors.onSurfaceMuted),
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: BrdySpacing.md),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: onHoleNumberTap != null
                          ? () {
                              HapticFeedback.selectionClick();
                              onHoleNumberTap!();
                            }
                          : null,
                      child: _pill(context, 'HOLE ${holeIndex + 1}'),
                    ),
                    const SizedBox(width: BrdySpacing.xs),
                    _pill(context, parLabel),
                    if (siLabel != null) ...[
                      const SizedBox(width: BrdySpacing.xs),
                      _pill(context, siLabel, fontSize: 11),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // ── Stack: hole number behind, chevrons + shots + total in front ──
          Stack(
            alignment: Alignment.center,
            children: [
              // Giant hole number — behind everything
              Semantics(
                label: 'HOLE ${holeIndex + 1} OF 18 — TAP TO NAVIGATE HOLES',
                button: onHoleNumberTap != null,
                child: GestureDetector(
                  onTap: onHoleNumberTap != null
                      ? () {
                          HapticFeedback.selectionClick();
                          onHoleNumberTap!();
                        }
                      : null,
                  child: Text(
                    (holeIndex + 1).toString().padLeft(2, '0'),
                    style: GoogleFonts.sometypeMono(
                      fontSize: 72,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                      color: context.brdyColors.onSurface,
                    ),
                  )
                      .animate(key: ValueKey(holeIndex))
                      .fadeOut(duration: 50.ms, curve: Curves.easeOut)
                      .then()
                      .fadeIn(duration: 100.ms, curve: Curves.easeOut),
                ),
              ),

              // Chevrons + shot counter + total — overlaid on hole number
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left chevron
                      Semantics(
                        label: 'PREVIOUS HOLE',
                        child: IconButton(
                          icon: Icon(Icons.chevron_left,
                              size: 40,
                              color: leftDisabled
                                  ? context.brdyColors.onSurfaceMuted
                                  : context.brdyColors.onSurface),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                          onPressed: leftDisabled
                              ? null
                              : () {
                                  HapticFeedback.lightImpact();
                                  ref.read(activeHoleIndexProvider.notifier).set(holeIndex - 1);
                                },
                        ),
                      ),

                      // Shot counter + ScoreBar
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) =>
                                FadeTransition(opacity: animation, child: child),
                            child: SizedBox(
                              key: ValueKey(holeIndex),
                              child: Text(
                                '$currentHoleShots',
                                style: GoogleFonts.sometypeMono(
                                  fontSize: 100,
                                  fontWeight: FontWeight.w700,
                                  color: context.brdyColors.onSurface,
                                ),
                              )
                                  // Outcome tint flash
                                  .animate(key: ValueKey(flashOutcome))
                                  .tint(
                                    color: _outcomeFlashColor(flashOutcome),
                                    end: flashOutcome != null ? 0.4 : 0.0,
                                    duration: 300.ms,
                                    curve: Curves.easeOut,
                                  )
                                  .then()
                                  .tint(
                                    color: _outcomeFlashColor(flashOutcome),
                                    begin: flashOutcome != null ? 0.4 : 0.0,
                                    end: 0.0,
                                    duration: 200.ms,
                                  )
                                  .callback(
                                    callback: (_) {
                                      ref
                                          .read(lastScoredOutcomeProvider(roundId)
                                              .notifier)
                                          .set(null);
                                    },
                                  ),
                            ),
                          ),
                          Positioned(
                            right: -30,
                            top: 20,
                            child: ScoreBar(roundId: roundId),
                          ),
                        ],
                      ),

                      // Right chevron
                      Semantics(
                        label: 'NEXT HOLE',
                        child: IconButton(
                          icon: Icon(Icons.chevron_right,
                              size: 40,
                              color: rightDisabled
                                  ? context.brdyColors.onSurfaceMuted
                                  : context.brdyColors.onSurface),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                          onPressed: rightDisabled
                              ? null
                              : () {
                                  HapticFeedback.lightImpact();
                                  ref.read(activeHoleIndexProvider.notifier).set(holeIndex + 1);
                                },
                        ),
                      ),
                    ],
                  ),

                  // SHOTS TAKEN total
                  Transform.translate(
                    offset: const Offset(0, -30),
                    child: Text(
                    'TOTAL SHOTS $totalShots',
                    style: GoogleFonts.sometypeMono(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: context.brdyColors.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  ),
                  // Voice partial text — shown below TOTAL SHOTS
                  if (voicePartialText.isNotEmpty)
                    Text(
                      voicePartialText.toUpperCase(),
                      style: GoogleFonts.sometypeMono(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: context.brdyColors.onSurfaceMuted,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Color _outcomeFlashColor(HoleOutcome? outcome) => switch (outcome) {
    HoleOutcome.eagle       => const Color(0xFFFFD700),
    HoleOutcome.birdie      => const Color(0xFF22C55E),
    HoleOutcome.par         => const Color(0xFF1F82B4),
    HoleOutcome.bogey       => const Color(0xFFF3490E),
    HoleOutcome.doubleBogey => BrdyColors.destructive,
    HoleOutcome.pickup      => BrdyColors.destructive,
    null                    => Colors.transparent,
  };

  Widget _pill(BuildContext context, String text, {double fontSize = 13}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: context.brdyColors.onSurface,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.sometypeMono(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: context.brdyColors.background,
        ),
      ),
    );
  }
}

// ── _HoleBlur ──────────────────────────────────────────────────────────────────
// Blurs its child when holeIndex changes, then fully removes the filter at 0.
