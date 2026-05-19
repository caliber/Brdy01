import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../round_history/providers/completed_rounds_provider.dart';
import '../../round_review/providers/stats_provider.dart';

part 'cross_round_averages_provider.g.dart';

// ── Model ───────────────────────────────────────────────────────────────────

class CrossRoundAverages {
  const CrossRoundAverages({
    required this.avgScoreToPar,
    required this.avgPutts,
    required this.avgFirPercent,
    required this.avgGirPercent,
    required this.roundCount,
  });

  final double avgScoreToPar;
  final double avgPutts;
  final double avgFirPercent;
  final double avgGirPercent;
  final int roundCount;
}

// ── Provider ────────────────────────────────────────────────────────────────

@riverpod
Future<CrossRoundAverages?> crossRoundAverages(Ref ref) async {
  final rounds = await ref.watch(completedRoundsProvider.future);

  if (rounds.isEmpty) return null;

  double totalScoreToPar = 0;
  double totalPutts = 0;
  double totalFirPercent = 0;
  double totalGirPercent = 0;
  int count = 0;

  for (final round in rounds) {
    final stats = await ref.watch(statsProvider(round.id).future);
    if (stats == null) continue;

    totalScoreToPar += stats.scoreToPar.toDouble();
    totalPutts += stats.totalPutts.toDouble();
    totalFirPercent += stats.firPercent;
    totalGirPercent += stats.girPercent;
    count++;
  }

  if (count == 0) return null;

  return CrossRoundAverages(
    avgScoreToPar: totalScoreToPar / count,
    avgPutts: totalPutts / count,
    avgFirPercent: totalFirPercent / count,
    avgGirPercent: totalGirPercent / count,
    roundCount: count,
  );
}
