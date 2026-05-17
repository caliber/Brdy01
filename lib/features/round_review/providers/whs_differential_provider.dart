import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/local/database/app_database.dart';
import '../../../data/local/database/app_database_provider.dart';
import '../../../domain/enums/hole_outcome.dart';
import '../../shot_capture/providers/course_for_round_provider.dart';
import '../../shot_capture/providers/hole_list_provider.dart';

part 'whs_differential_provider.g.dart';

// ── Model ───────────────────────────────────────────────────────────────────

class WhsDifferential {
  const WhsDifferential({
    required this.displayValue,
    required this.isIndicative,
    required this.isUnavailable,
    this.indicativeLabel,
  });

  final String displayValue;
  final bool isIndicative;
  final bool isUnavailable;
  final String? indicativeLabel;
}

// ── Provider ────────────────────────────────────────────────────────────────

@riverpod
Future<WhsDifferential> whsDifferential(Ref ref, int roundId) async {
  final course = await ref.watch(courseForRoundProvider(roundId).future);
  final holes = await ref.watch(holeListProvider(roundId).future);
  final db = ref.watch(appDatabaseProvider);
  final round = await db.roundDao.getRoundById(roundId);

  // If courseRating or slope is null, differential cannot be computed.
  if (course?.courseRating == null || course?.slope == null) {
    return const WhsDifferential(
      displayValue: 'N/A',
      isUnavailable: true,
      isIndicative: false,
      indicativeLabel: null,
    );
  }

  final courseRating = course!.courseRating!;
  final slope = course.slope!;
  final par = course.par;
  final handicapIndex = round?.handicapIndex ?? 0.0;

  // WHS Course Handicap = round(handicapIndex × (slope / 113) + (courseRating − par)).
  final playingHandicap =
      (handicapIndex * (slope / 113) + (courseRating - par)).round();

  // Determine if fewer than 18 holes have outcomes (indicative).
  final scoredHoles = holes.where((h) => h.outcome != null).length;
  final bool isIndicative = scoredHoles < 18;
  final String? indicativeLabel =
      isIndicative ? 'Indicative — fewer than 18 holes' : null;

  // Build a map from holeNumber → Drift Hole for quick lookup.
  final holeByNumber = {for (final h in holes) h.holeNumber: h};

  // Compute AGS (Adjusted Gross Score) using all 18 course holes.
  // For each hole: raw score is par + offset; cap at par + 2 + handicap_strokes_on_hole.
  // If no Drift hole exists or outcome is null, use the cap directly.
  double ags = 0;

  for (final courseHole in course.holes) {
    final int holePar = courseHole.par;
    final int strokeIndex = courseHole.strokeIndex ?? 18;

    // Handicap strokes received on this hole: 1 if playingHandicap >= strokeIndex, else 0.
    final int handicapStrokesOnHole = playingHandicap >= strokeIndex ? 1 : 0;
    final int escCap = holePar + 2 + handicapStrokesOnHole;

    final Hole? driftHole = holeByNumber[courseHole.holeNumber];

    if (driftHole == null || driftHole.outcome == null) {
      // No recorded outcome — use ESC cap (net double bogey).
      ags += escCap;
      continue;
    }

    // Parse outcome to get raw stroke offset.
    int rawScore = escCap; // default to cap on parse failure
    try {
      final outcome = HoleOutcome.values.byName(driftHole.outcome!);
      final int offset = _outcomeOffset(outcome);
      rawScore = holePar + offset;
    } catch (_) {
      // Unknown outcome — use cap.
    }

    // Apply ESC cap: score cannot exceed net double bogey.
    ags += rawScore < escCap ? rawScore : escCap;
  }

  // If course.holes is empty (edge case), use all Drift holes as fallback.
  if (course.holes.isEmpty) {
    for (final h in holes) {
      if (h.outcome == null) continue;
      final int holePar = h.par;
      final int strokeIndex = h.strokeIndex ?? 18;
      final int handicapStrokesOnHole = playingHandicap >= strokeIndex ? 1 : 0;
      final int escCap = holePar + 2 + handicapStrokesOnHole;

      int rawScore = escCap;
      try {
        final outcome = HoleOutcome.values.byName(h.outcome!);
        rawScore = holePar + _outcomeOffset(outcome);
      } catch (_) {}

      ags += rawScore < escCap ? rawScore : escCap;
    }
  }

  // Differential = (AGS − courseRating) × 113 ÷ slope.
  final differential = (ags - courseRating) * 113 / slope;
  final formatted = NumberFormat('0.0').format(differential);

  return WhsDifferential(
    displayValue: formatted,
    isIndicative: isIndicative,
    isUnavailable: false,
    indicativeLabel: indicativeLabel,
  );
}

// ── Helpers ─────────────────────────────────────────────────────────────────

int _outcomeOffset(HoleOutcome outcome) => switch (outcome) {
      HoleOutcome.eagle => -2,
      HoleOutcome.birdie => -1,
      HoleOutcome.par => 0,
      HoleOutcome.bogey => 1,
      HoleOutcome.doubleBogey => 2,
      HoleOutcome.pickup => 2,
    };
