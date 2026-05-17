import '../../domain/models/course_model.dart';
import '../../domain/models/hole_model.dart';
import '../../domain/repositories/course_repository.dart';
import '../../data/remote/api/golf_course_api.dart';
import '../../data/remote/dto/course_search_response_dto.dart';
import '../../data/remote/dto/course_detail_response_dto.dart';
import '../../data/local/preferences/hive_course_box.dart';

class CourseRepositoryImpl implements CourseRepository {
  final GolfCourseApi _api;
  final HiveCourseBox _hive;

  CourseRepositoryImpl(this._api, this._hive);

  @override
  Future<List<CourseModel>> searchCourses(String query) async {
    final response = await _api.searchCourses(query);
    return response.courses.map(_searchDtoToModel).toList();
  }

  @override
  Future<CourseModel> getCourseDetail(String id) async {
    final response = await _api.getCourseDetail(id);
    final model = _detailDtoToModel(response.course);
    // D-04: write through to Hive immediately after API success (SETUP-04)
    _hive.writeCourse(model.id, model);
    return model;
  }

  @override
  CourseModel? getCachedCourse(String id) => _hive.readCourse(id);

  @override
  void cacheCourse(CourseModel course) => _hive.writeCourse(course.id, course);

  CourseModel _searchDtoToModel(CourseSearchResultDto dto) => CourseModel(
        id: dto.id,
        clubName: dto.clubName,
        courseName: dto.courseName,
        courseRating: dto.courseRating,
        slope: dto.slopeRating,
        par: dto.par,
        holes: const [], // search response carries no per-hole data
      );

  CourseModel _detailDtoToModel(CourseDetailDto dto) => CourseModel(
        id: dto.id,
        clubName: dto.clubName,
        courseName: dto.courseName,
        courseRating: dto.courseRating,
        slope: dto.slopeRating,
        par: dto.par,
        holes: dto.holes.map(_holeDtoToModel).toList(),
      );

  HoleModel _holeDtoToModel(HoleDto dto) => HoleModel(
        holeNumber: dto.holeNumber,
        par: dto.par,
        strokeIndex: dto.strokeIndex,
        teeLat: dto.teeLat,
        teeLng: dto.teeLng,
        greenLat: dto.greenLat,
        greenLng: dto.greenLng,
      );
}
