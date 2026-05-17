import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/local/database/app_database_provider.dart';
import '../../../data/local/database/app_database.dart';
import '../../../domain/enums/hole_outcome.dart';

part 'hole_score_notifier.g.dart';

@riverpod
class HoleScoreNotifier extends _$HoleScoreNotifier {
  @override
  Future<Hole?> build(int roundId, int holeIndex) async {
    final db = ref.watch(appDatabaseProvider);
    final rows = await db.holeDao.getHolesForRound(roundId);
    final holeNumber = holeIndex + 1;
    try {
      return rows.firstWhere((h) => h.holeNumber == holeNumber);
    } catch (_) {
      return null;
    }
  }

  Future<void> recordOutcome({
    required HoleOutcome outcome,
    required int par,
    int? strokeIndex,
  }) async {
    final db = ref.read(appDatabaseProvider);
    final holeNumber = holeIndex + 1;
    await db.holeDao.insertOrUpdateHole(HolesCompanion(
      roundId: Value(roundId),
      holeNumber: Value(holeNumber),
      par: Value(par),
      strokeIndex: Value(strokeIndex),
      outcome: Value(outcome.name),
      fairwayHit: par == 3 ? const Value(null) : const Value(false),
      recordedAt: Value(DateTime.now()),
    ));
    ref.invalidateSelf();
  }

  Future<void> setPutts(int putts) async {
    final db = ref.read(appDatabaseProvider);
    final current = await future;
    if (current == null) return;
    await db.holeDao.insertOrUpdateHole(HolesCompanion(
      roundId: Value(current.roundId),
      holeNumber: Value(current.holeNumber),
      par: Value(current.par),
      putts: Value(putts),
    ));
    ref.invalidateSelf();
  }

  Future<void> setFairwayHit(bool? fairwayHit) async {
    final db = ref.read(appDatabaseProvider);
    final current = await future;
    if (current == null) return;
    await db.holeDao.insertOrUpdateHole(HolesCompanion(
      roundId: Value(current.roundId),
      holeNumber: Value(current.holeNumber),
      par: Value(current.par),
      fairwayHit: Value(fairwayHit),
    ));
    ref.invalidateSelf();
  }

  Future<void> setGir(bool? gir) async {
    final db = ref.read(appDatabaseProvider);
    final current = await future;
    if (current == null) return;
    await db.holeDao.insertOrUpdateHole(HolesCompanion(
      roundId: Value(current.roundId),
      holeNumber: Value(current.holeNumber),
      par: Value(current.par),
      greenInRegulation: Value(gir),
    ));
    ref.invalidateSelf();
  }

  Future<void> undoOutcome() async {
    final db = ref.read(appDatabaseProvider);
    final current = await future;
    if (current == null) return;
    await db.holeDao.insertOrUpdateHole(HolesCompanion(
      roundId: Value(current.roundId),
      holeNumber: Value(current.holeNumber),
      par: Value(current.par),
      outcome: const Value(null),
      recordedAt: const Value(null),
    ));
    ref.invalidateSelf();
  }
}
