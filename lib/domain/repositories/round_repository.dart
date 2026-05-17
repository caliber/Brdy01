import '../models/round_model.dart';

abstract class RoundRepository {
  Future<int> createRound({
    required String courseName,
    required double handicapIndex,
    double? courseRating,
    int? slope,
    required String courseJson,
  });
  Future<int?> findIncompleteRoundId();
  Future<RoundModel?> getRound(int id);
  Future<void> completeRound(int id);
}
