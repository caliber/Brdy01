import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/remote/api/golf_course_api_provider.dart';
import '../../../data/remote/dto/course_search_response_dto.dart';
import 'course_search_query_provider.dart';

part 'course_search_results_provider.g.dart';

@riverpod
Future<List<CourseSearchResultDto>> courseSearchResults(Ref ref) async {
  final query = ref.watch(courseSearchQueryProvider);
  if (query.length < 2) return [];
  final link = ref.keepAlive();
  await Future.delayed(const Duration(milliseconds: 400));
  link.close();
  final api = ref.watch(golfCourseApiProvider);
  final response = await api.searchCourses(query);
  return response.courses;
}
