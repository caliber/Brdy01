import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/rounds_table.dart';

part 'round_dao.g.dart';

@DriftAccessor(tables: [Rounds])
class RoundDao extends DatabaseAccessor<AppDatabase> with _$RoundDaoMixin {
  RoundDao(super.db);

  Future<int> insertRound(RoundsCompanion round) => into(rounds).insert(round);

  Future<int?> findIncompleteRoundId() async {
    final row = await (select(rounds)
          ..where((r) => r.completedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    return row?.id;
  }

  Future<Round?> getRoundById(int id) =>
      (select(rounds)..where((r) => r.id.equals(id))).getSingleOrNull();

  Future<void> completeRound(int id, DateTime completedAt) =>
      (update(rounds)..where((r) => r.id.equals(id)))
          .write(RoundsCompanion(completedAt: Value(completedAt)));

  Stream<List<Round>> watchCompletedRounds() =>
      (select(rounds)
            ..where((r) => r.completedAt.isNotNull())
            ..orderBy([
              (r) => OrderingTerm(
                    expression: r.completedAt,
                    mode: OrderingMode.desc,
                  )
            ]))
          .watch();

  Future<void> deleteRound(int id) =>
      (delete(rounds)..where((r) => r.id.equals(id))).go();
}
