import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/local/database/app_database_provider.dart';
import '../../../data/local/database/app_database.dart';

part 'shots_for_hole_provider.g.dart';

/// Streams shots for the given [holeIndex] within [roundId].
///
/// Looks up the hole row by (roundId, holeNumber). If the hole row does not
/// yet exist (unscored hole), yields an empty list rather than crashing or
/// waiting indefinitely.
///
/// Uses @riverpod (auto-dispose) — screen-level lifetime only.
@riverpod
Stream<List<Shot>> shotsForHole(Ref ref, int roundId, int holeIndex) {
  final db = ref.watch(appDatabaseProvider);
  final holeNumber = holeIndex + 1;

  // Watch all holes for this round, then switchMap to shots for the matched hole.
  return db.holeDao
      .watchHolesForRound(roundId)
      .asyncExpand((holes) {
        final matching = holes.where((h) => h.holeNumber == holeNumber);
        if (matching.isEmpty) {
          // Hole row not yet created — yield empty list immediately.
          return Stream.value(<Shot>[]);
        }
        final hole = matching.first;
        return db.shotDao.watchShotsForHole(hole.id);
      });
}
