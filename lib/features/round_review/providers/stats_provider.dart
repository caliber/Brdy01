import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/local/database/app_database_provider.dart';
import '../../../domain/enums/hole_outcome.dart';
import '../../shot_capture/providers/course_for_round_provider.dart';
import '../../shot_capture/providers/hole_list_provider.dart';

part 'stats_provider.g.dart';

// ── Model ───────────────────────────────────────────────────────────────────

class StatsData {
  const StatsData({
    required this.totalStrokes,
    required this.scoreToPar,
    required this.netScore,
    required this.eagles,
    required this.birdies,
    required this.pars,
    required this.bogeys,
    required this.doubles,
    required this.triples,
    required this.pickups,
    required this.totalPutts,
    required this.puttsPerGir,
    required this.girCount,
    required this.girPercent,
    required this.fairwaysHit,
    required this.firPercent,
  });

  final int totalStrokes;
  final int scoreToPar;
  final int netScore;
  final int eagles;
  final int birdies;
  final int pars;
  final int bogeys;
  final int doubles;
  // HoleOutcome has no triple value; always 0 until enum is extended.
  final int triples;
  final int pickups;
  final int totalPutts;
  final double puttsPerGir;
  final int girCount;
  final double girPercent;
  final int fairwaysHit;
  final double firPercent;

  factory StatsData.empty() => const StatsData(
        totalStrokes: 0,
        scoreToPar: 0,
        netScore: 0,
        eagles: 0,
        birdies: 0,
        pars: 0,
        bogeys: 0,
        doubles: 0,
        triples: 0,
        pickups: 0,
        totalPutts: 0,
        puttsPerGir: 0.0,
        girCount: 0,
        girPercent: 0.0,
        fairwaysHit: 0,
        firPercent: 0.0,
      );
}

// ── Provider ────────────────────────────────────────────────────────────────

@riverpod
Future<StatsData?> stats(Ref ref, int roundId) async {
  final holes = await ref.watch(holeListProvider(roundId).future);
  final course = await ref.watch(courseForRoundProvider(roundId).future);
  final db = ref.watch(appDatabaseProvider);
  final round = await db.roundDao.getRoundById(roundId);

  if (holes.isEmpty) return StatsData.empty();

  final handicapIndex = round?.handicapIndex ?? 0.0;
  final slope = course?.slope ?? 113;
  final courseRating = course?.courseRating ?? 0.0;
  final par = course?.par ?? 72;

  // WHS Course Handicap = round(handicapIndex × (slope / 113) + (courseRating − par)).
  // Fallback: if courseRating is unavailable use handicapIndex × (slope / 113).
  final int playingHandicap;
  if (course?.courseRating != null) {
    playingHandicap = (handicapIndex * (slope / 113) + (courseRating - par)).round();
  } else {
    // Fallback — courseRating not available; omit (courseRating − par) term.
    playingHandicap = (handicapIndex * (slope / 113)).round();
  }

  int totalStrokes = 0;
  int scoreToPar = 0;
  int eagles = 0;
  int birdies = 0;
  int pars = 0;
  int bogeys = 0;
  int doubles = 0;
  // triples: HoleOutcome has no triple value; always 0 until enum is extended.
  const int triples = 0;
  int pickups = 0;
  int totalPutts = 0;
  int girCount = 0;
  int girPutts = 0;
  int holesWithOutcome = 0;
  int fairwaysHit = 0;
  int eligibleFairwayHoles = 0;

  for (final h in holes) {
    // Putts (all holes, regardless of outcome).
    totalPutts += h.putts ?? 0;

    // GIR.
    if (h.greenInRegulation == true) {
      girCount++;
      girPutts += h.putts ?? 0;
    }

    // Fairways hit — exclude par-3 holes from denominator.
    if (h.par != 3) {
      eligibleFairwayHoles++;
      if (h.fairwayHit == true) fairwaysHit++;
    }

    if (h.outcome == null) continue;

    HoleOutcome outcome;
    try {
      outcome = HoleOutcome.values.byName(h.outcome!);
    } catch (_) {
      // Unknown outcome string — skip hole.
      continue;
    }

    holesWithOutcome++;

    final int offset = switch (outcome) {
      HoleOutcome.eagle => -2,
      HoleOutcome.birdie => -1,
      HoleOutcome.par => 0,
      HoleOutcome.bogey => 1,
      HoleOutcome.doubleBogey => 2,
      HoleOutcome.pickup => 2,
    };

    totalStrokes += h.par + offset;
    scoreToPar += offset;

    switch (outcome) {
      case HoleOutcome.eagle:
        eagles++;
      case HoleOutcome.birdie:
        birdies++;
      case HoleOutcome.par:
        pars++;
      case HoleOutcome.bogey:
        bogeys++;
      case HoleOutcome.doubleBogey:
        doubles++;
      case HoleOutcome.pickup:
        pickups++;
    }
  }

  final netScore = totalStrokes - playingHandicap;

  final puttsPerGir =
      girCount > 0 ? girPutts / girCount : 0.0;

  final girPercent =
      holesWithOutcome > 0 ? girCount / holesWithOutcome * 100 : 0.0;

  final firPercent =
      eligibleFairwayHoles > 0 ? fairwaysHit / eligibleFairwayHoles * 100 : 0.0;

  return StatsData(
    totalStrokes: totalStrokes,
    scoreToPar: scoreToPar,
    netScore: netScore,
    eagles: eagles,
    birdies: birdies,
    pars: pars,
    bogeys: bogeys,
    doubles: doubles,
    triples: triples,
    pickups: pickups,
    totalPutts: totalPutts,
    puttsPerGir: puttsPerGir,
    girCount: girCount,
    girPercent: girPercent,
    fairwaysHit: fairwaysHit,
    firPercent: firPercent,
  );
}
