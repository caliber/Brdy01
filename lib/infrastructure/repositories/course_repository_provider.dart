import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/repositories/course_repository.dart';
import '../../data/remote/api/golf_course_api_provider.dart';
import '../../data/local/preferences/hive_course_box_provider.dart';
import 'course_repository_impl.dart';

part 'course_repository_provider.g.dart';

@Riverpod(keepAlive: true)
CourseRepository courseRepository(Ref ref) => CourseRepositoryImpl(
      ref.watch(golfCourseApiProvider),
      ref.watch(hiveCourseBoxProvider),
    );
