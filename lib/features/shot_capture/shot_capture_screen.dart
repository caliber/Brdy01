import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/local/database/app_database_provider.dart';
import '../../domain/enums/hole_outcome.dart';
import '../../theme/brdy_colors.dart';
import '../../theme/brdy_spacing.dart';
import 'providers/active_hole_index_provider.dart';
import 'providers/course_for_round_provider.dart';
import 'providers/highest_scored_hole_index_provider.dart';
import 'providers/hole_score_notifier.dart';
import 'providers/round_complete_provider.dart';
import 'widgets/hole_header.dart';
import 'widgets/hole_nav_drawer.dart';
import 'widgets/outcome_button_grid.dart';

class ShotCaptureScreen extends ConsumerStatefulWidget {
  final int roundId;

  const ShotCaptureScreen({super.key, required this.roundId});

  @override
  ConsumerState<ShotCaptureScreen> createState() => _ShotCaptureScreenState();
}

class _ShotCaptureScreenState extends ConsumerState<ShotCaptureScreen> {
  int? _lastScoredHoleIndex;
  bool _navStripOpen = false;

  @override
  Widget build(BuildContext context) {
    final roundId = widget.roundId;
    final holeIndex = ref.watch(activeHoleIndexProvider);
    final highestIndex = ref.watch(highestScoredHoleIndexProvider(roundId));
    final courseAsync = ref.watch(courseForRoundProvider(roundId));
    final course = courseAsync.valueOrNull;
    final holeModel =
        (course != null && holeIndex < course.holes.length)
            ? course.holes[holeIndex]
            : null;
    final holePar = holeModel?.par ?? 4;
    final holeStrokeIndex = holeModel?.strokeIndex;

    ref.listen<bool>(roundCompleteProvider(roundId), (prev, next) {
      if (next == true) {
        context.go('/round-review/$roundId');
      }
    });

    return Scaffold(
      backgroundColor: BrdyColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 55,
              child: _TopZone(
                roundId: roundId,
                highestScoredHoleIndex: highestIndex,
                navStripOpen: _navStripOpen,
                onHoleNumberTap: () =>
                    setState(() => _navStripOpen = !_navStripOpen),
              ),
            ),
            Container(height: 1, color: BrdyColors.divider),
            Expanded(
              flex: 45,
              child: _BottomZone(
                roundId: roundId,
                holeIndex: holeIndex,
                holePar: holePar,
                holeStrokeIndex: holeStrokeIndex,
                onOutcomeTapped: _handleOutcomeTapped,
                onNextTapped: _handleNext,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleOutcomeTapped(
      HoleOutcome outcome, int par, int? si) async {
    final holeIndex = ref.read(activeHoleIndexProvider);
    // Store BEFORE the Drift write — captures correct pre-advance index
    setState(() => _lastScoredHoleIndex = holeIndex);

    await HapticFeedback.mediumImpact();
    await ref
        .read(holeScoreNotifierProvider(widget.roundId, holeIndex).notifier)
        .recordOutcome(outcome: outcome, par: par, strokeIndex: si);

    // CRITICAL: Mark round complete in Drift when hole 18 is scored.
    // Must run BEFORE context.go() so Phase 3 and crash recovery see completedAt.
    if (holeIndex == 17) {
      await ref
          .read(appDatabaseProvider)
          .roundDao
          .completeRound(widget.roundId, DateTime.now());
    }

    if (!mounted) return;
    _showUndoToast(context, outcome, holeIndex + 1);

    // Advance to next hole — roundCompleteProvider handles hole 18 navigation
    if (holeIndex < 17) {
      ref.read(activeHoleIndexProvider.notifier).set(holeIndex + 1);
    }
  }

  Future<void> _handleNext() async {
    await HapticFeedback.lightImpact();
    final hi = ref.read(activeHoleIndexProvider);
    if (hi < 17) {
      ref.read(activeHoleIndexProvider.notifier).set(hi + 1);
    }
  }

  void _showUndoToast(
      BuildContext context, HoleOutcome outcome, int holeNumber) {
    final outcomeLabel = const {
      'eagle': 'EAGLE',
      'birdie': 'BIRDIE',
      'par': 'PAR',
      'bogey': 'BOGEY',
      'doubleBogey': 'DOUBLE',
      'pickup': 'PICKUP',
    }[outcome.name] ??
        outcome.name.toUpperCase();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '$outcomeLabel — HOLE $holeNumber',
            style: GoogleFonts.barlowCondensed(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: BrdyColors.onSurface,
            ),
          ),
          backgroundColor: BrdyColors.surface,
          duration: const Duration(seconds: 4),
          // NOTE: Flutter 3.24.5 — SnackBar auto-dismisses with actions by default.
          // When upgrading to Flutter 3.38+, add persist: false here for explicit control.
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'UNDO',
            textColor: BrdyColors.accent,
            onPressed: _handleUndo,
          ),
        ),
      );
  }

  Future<void> _handleUndo() async {
    final last = _lastScoredHoleIndex;
    if (last == null) return;
    await HapticFeedback.lightImpact();
    await ref
        .read(holeScoreNotifierProvider(widget.roundId, last).notifier)
        .undoOutcome();
    ref.read(activeHoleIndexProvider.notifier).set(last);
    setState(() => _lastScoredHoleIndex = null);
  }
}

// ── _TopZone ───────────────────────────────────────────────────────────────────

class _TopZone extends StatelessWidget {
  final int roundId;
  final int highestScoredHoleIndex;
  final bool navStripOpen;
  final VoidCallback onHoleNumberTap;

  const _TopZone({
    required this.roundId,
    required this.highestScoredHoleIndex,
    required this.navStripOpen,
    required this.onHoleNumberTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HoleHeader(
          roundId: roundId,
          highestScoredHoleIndex: highestScoredHoleIndex,
          onHoleNumberTap: onHoleNumberTap,
        ),
        HoleNavDrawer(
          roundId: roundId,
          isOpen: navStripOpen,
        ),
      ],
    );
  }
}

// ── _BottomZone ────────────────────────────────────────────────────────────────

class _BottomZone extends StatelessWidget {
  final int roundId;
  final int holeIndex;
  final int holePar;
  final int? holeStrokeIndex;
  final void Function(HoleOutcome, int, int?) onOutcomeTapped;
  final void Function() onNextTapped;

  const _BottomZone({
    required this.roundId,
    required this.holeIndex,
    required this.holePar,
    required this.holeStrokeIndex,
    required this.onOutcomeTapped,
    required this.onNextTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: BrdyColors.onSurface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: BrdySpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Gap(BrdySpacing.sm),
            // BRDY.01 wordmark rule
            Row(
              children: [
                Text(
                  'BRDY.01',
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: BrdyColors.background,
                  ),
                ),
                const Gap(BrdySpacing.sm),
                const Expanded(
                  child: Divider(
                    color: BrdyColors.divider,
                    thickness: 1,
                  ),
                ),
              ],
            ),
            const Gap(BrdySpacing.sm),
            OutcomeButtonGrid(
              roundId: roundId,
              holeIndex: holeIndex,
              holePar: holePar,
              holeStrokeIndex: holeStrokeIndex,
              onOutcomeTapped: onOutcomeTapped,
              onNextTapped: onNextTapped,
            ),
          ],
        ),
      ),
    );
  }
}
