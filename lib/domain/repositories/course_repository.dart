import '../models/course_model.dart';

abstract class CourseRepository {
  Future<List<CourseModel>> searchCourses(String query);
  Future<CourseModel> getCourseDetail(String id);
  CourseModel? getCachedCourse(String id);
  void cacheCourse(CourseModel course);
}
