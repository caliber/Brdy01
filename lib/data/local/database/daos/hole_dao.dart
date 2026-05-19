import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/holes_table.dart';

part 'hole_dao.g.dart';

@DriftAccessor(tables: [Holes])
class HoleDao extends DatabaseAccessor<AppDatabase> with _$HoleDaoMixin {
  HoleDao(super.db);

  Future<void> insertOrUpdateHole(HolesCompanion hole) async {
    final existing = await (select(holes)
          ..where((h) => h.roundId.equals(hole.roundId.value))
          ..where((h) => h.holeNumber.equals(hole.holeNumber.value)))
        .getSingleOrNull();
    if (existing == null) {
      await into(holes).insert(hole);
    } else {
      await (update(holes)
            ..where((h) => h.id.equals(existing.id)))
          .write(hole);
    }
  }

  Future<List<Hole>> getHolesForRound(int roundId) =>
      (select(holes)..where((h) => h.roundId.equals(roundId))).get();

  Stream<List<Hole>> watchHolesForRound(int roundId) =>
      (select(holes)..where((h) => h.roundId.equals(roundId))).watch();

  Future<Hole?> getHoleByRoundAndNumber(int roundId, int holeNumber) =>
      (select(holes)
            ..where((h) => h.roundId.equals(roundId))
            ..where((h) => h.holeNumber.equals(holeNumber)))
          .getSingleOrNull();
}
