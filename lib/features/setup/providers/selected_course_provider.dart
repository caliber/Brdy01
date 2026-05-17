import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/models/course_model.dart';
import '../../../data/local/preferences/hive_player_prefs_provider.dart';
import '../../../infrastructure/repositories/course_repository_provider.dart';

part 'selected_course_provider.g.dart';

@riverpod
class SelectedCourse extends _$SelectedCourse {
  @override
  AsyncValue<CourseModel?> build() => const AsyncData(null);

  Future<void> loadCourse(String courseId) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(courseRepositoryProvider);
      final course = await repo.getCourseDetail(courseId);
      ref.read(hivePlayerPrefsProvider).setLastUsedCourseId(course.id);
      state = AsyncData(course);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void overrideRating({double? rating, int? slope}) {
    state.whenData((c) {
      if (c != null) state = AsyncData(c.copyWith(courseRating: rating, slope: slope));
    });
  }

  void loadFromCache(CourseModel course) => state = AsyncData(course);

  void clear() => state = const AsyncData(null);
}
