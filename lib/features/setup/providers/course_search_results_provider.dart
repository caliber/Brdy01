import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/models/course_model.dart';
import '../../../infrastructure/repositories/course_repository_provider.dart';
import 'course_search_query_provider.dart';

part 'course_search_results_provider.g.dart';

@riverpod
Future<List<CourseModel>> courseSearchResults(Ref ref) async {
  final query = ref.watch(courseSearchQueryProvider);
  if (query.length < 2) return [];
  final link = ref.keepAlive();
  await Future.delayed(const Duration(milliseconds: 400));
  link.close();
  return ref.watch(courseRepositoryProvider).searchCourses(query);
}
