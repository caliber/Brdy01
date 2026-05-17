import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/enums/hole_outcome.dart';
import 'hole_list_provider.dart';

part 'running_score_provider.g.dart';

@riverpod
int? runningScore(Ref ref, int roundId) {
  final holesAsync = ref.watch(holeListProvider(roundId));
  return holesAsync.whenData((holes) {
    int score = 0;
    for (final h in holes) {
      if (h.outcome == null) continue;
      try {
        final outcome = HoleOutcome.values.byName(h.outcome!);
        final offset = switch (outcome) {
          HoleOutcome.eagle => -2,
          HoleOutcome.birdie => -1,
          HoleOutcome.par => 0,
          HoleOutcome.bogey => 1,
          HoleOutcome.doubleBogey => 2,
          HoleOutcome.pickup => 2,
        };
        score += offset;
      } catch (_) {
        // Unknown outcome string — skip hole rather than crash the provider
      }
    }
    return score;
  }).value;
}
