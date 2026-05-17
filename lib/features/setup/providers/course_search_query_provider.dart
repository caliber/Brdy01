import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'course_search_query_provider.g.dart';

@riverpod
class CourseSearchQuery extends _$CourseSearchQuery {
  @override
  String build() => '';

  void set(String value) => state = value;
}
