import 'package:drift/drift.dart';
import '../../domain/models/round_model.dart';
import '../../domain/repositories/round_repository.dart';
import '../../data/local/database/app_database.dart';

class RoundRepositoryImpl implements RoundRepository {
  final AppDatabase _db;

  RoundRepositoryImpl(this._db);

  @override
  Future<int> createRound({
    required String courseName,
    required double handicapIndex,
    double? courseRating,
    int? slope,
    required String courseJson,
  }) =>
      _db.roundDao.insertRound(
        RoundsCompanion.insert(
          courseName: courseName,
          handicapIndex: handicapIndex,
          courseJson: courseJson,
          startedAt: DateTime.now(),
          courseRating: Value(courseRating),
          courseSlope: Value(slope),
        ),
      );

  @override
  Future<int?> findIncompleteRoundId() => _db.roundDao.findIncompleteRoundId();

  @override
  Future<RoundModel?> getRound(int id) async {
    final row = await _db.roundDao.getRoundById(id);
    if (row == null) return null;
    return RoundModel(
      id: row.id,
      courseName: row.courseName,
      courseRating: row.courseRating,
      slope: row.courseSlope,
      handicapIndex: row.handicapIndex,
      startedAt: row.startedAt,
      completedAt: row.completedAt,
    );
  }

  @override
  Future<void> completeRound(int id) =>
      _db.roundDao.completeRound(id, DateTime.now());
}
