import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'hole_list_provider.dart';

part 'highest_scored_hole_index_provider.g.dart';

@riverpod
int highestScoredHoleIndex(Ref ref, int roundId) {
  final holesAsync = ref.watch(holeListProvider(roundId));
  return holesAsync.when(
    loading: () => 0,
    error: (_, __) => 0,
    data: (holes) {
      final scored = holes.where((h) => h.outcome != null).length;
      return scored > 0 ? scored - 1 : 0;
    },
  );
}
