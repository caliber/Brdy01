import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'golf_course_api.dart';
import 'dio_provider.dart';

part 'golf_course_api_provider.g.dart';

@Riverpod(keepAlive: true)
GolfCourseApi golfCourseApi(Ref ref) => GolfCourseApi(ref.watch(dioProvider));
