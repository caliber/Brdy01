import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/models/course_model.dart';
import '../../../infrastructure/repositories/round_repository_provider.dart';
import 'active_round_id_provider.dart';

part 'round_setup_notifier.g.dart';

@riverpod
class RoundSetupNotifier extends _$RoundSetupNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<int> createRound(CourseModel course, double handicapIndex) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(roundRepositoryProvider);
      final roundId = await repo.createRound(
        courseName: course.clubName,
        handicapIndex: handicapIndex,
        courseRating: course.courseRating,
        slope: course.slope,
        courseJson: jsonEncode(course.toJson()),
      );
      ref.read(activeRoundIdProvider.notifier).set(roundId);
      state = const AsyncData(null);
      return roundId;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
