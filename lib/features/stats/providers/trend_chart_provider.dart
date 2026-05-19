import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../round_history/providers/completed_rounds_provider.dart';
import '../../round_review/providers/whs_differential_provider.dart';

part 'trend_chart_provider.g.dart';

// ── Provider ────────────────────────────────────────────────────────────────

@riverpod
Future<List<FlSpot>> trendChart(Ref ref) async {
  final rounds = await ref.watch(completedRoundsProvider.future);

  // Take at most 20 most recent rounds (completedRoundsProvider is desc order),
  // then reverse to oldest-first so x:0 = oldest, x:19 = most recent.
  final recent = rounds.take(20).toList().reversed.toList();

  final spots = <FlSpot>[];

  for (var i = 0; i < recent.length; i++) {
    final round = recent[i];
    final diff = await ref.watch(whsDifferentialProvider(round.id).future);

    // Skip rounds where WHS differential cannot be computed.
    if (diff.isUnavailable) continue;

    final v = double.tryParse(diff.displayValue);
    if (v != null) {
      spots.add(FlSpot(i.toDouble(), v));
    }
  }

  return spots;
}
