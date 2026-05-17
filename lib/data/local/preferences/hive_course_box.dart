import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../domain/models/course_model.dart';

class HiveCourseBox {
  final Box _box;

  HiveCourseBox(this._box);

  void writeCourse(String courseId, CourseModel course) =>
      _box.put(courseId, jsonEncode(course.toJson()));

  CourseModel? readCourse(String courseId) {
    final raw = _box.get(courseId) as String?;
    if (raw == null) return null;
    return CourseModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Iterable<String> get cachedCourseIds => _box.keys.cast<String>();
}
