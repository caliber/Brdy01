import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'hole_list_provider.dart';

part 'round_complete_provider.g.dart';

@riverpod
bool roundComplete(Ref ref, int roundId) {
  final holesAsync = ref.watch(holeListProvider(roundId));
  return holesAsync.whenData((holes) =>
    holes.where((h) => h.outcome != null).length >= 18
  ).value ?? false;
}
