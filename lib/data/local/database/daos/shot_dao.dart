import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/shots_table.dart';

part 'shot_dao.g.dart';

@DriftAccessor(tables: [Shots])
class ShotDao extends DatabaseAccessor<AppDatabase> with _$ShotDaoMixin {
  ShotDao(super.db);

  Future<void> insertShot({
    required int holeId,
    required double latitude,
    required double longitude,
    required int shotNumber,
  }) =>
      into(shots).insert(
        ShotsCompanion.insert(
          holeId: holeId,
          latitude: latitude,
          longitude: longitude,
          shotNumber: shotNumber,
          recordedAt: DateTime.now(),
        ),
      );

  Stream<List<Shot>> watchShotsForHole(int holeId) =>
      (select(shots)..where((s) => s.holeId.equals(holeId))).watch();

  Future<void> deleteShotsForHole(int holeId) =>
      (delete(shots)..where((s) => s.holeId.equals(holeId))).go();

  Future<int> getShotCountForHole(int holeId) async {
    final rows = await (select(shots)
          ..where((s) => s.holeId.equals(holeId)))
        .get();
    return rows.length;
  }
}
