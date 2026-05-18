import '../../domain/models/course_model.dart';
import '../../domain/models/hole_model.dart';
import '../../domain/repositories/course_repository.dart';
import '../../data/remote/api/golf_course_api.dart';
import '../../data/remote/dto/course_search_response_dto.dart';
import '../../data/remote/dto/course_detail_response_dto.dart';
import '../../data/remote/dto/tee_dto.dart';
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
    _hive.writeCourse(model.id, model);
    return model;
  }

  @override
  CourseModel? getCachedCourse(String id) => _hive.readCourse(id);

  @override
  void cacheCourse(CourseModel course) => _hive.writeCourse(course.id, course);

  TeeDto? _primaryTee(TeesDto tees) =>
      (tees.male?.isNotEmpty == true ? tees.male!.first : null) ??
      (tees.female?.isNotEmpty == true ? tees.female!.first : null);

  CourseModel _searchDtoToModel(CourseSearchResultDto dto) {
    final tee = _primaryTee(dto.tees);
    return CourseModel(
      id: dto.id.toString(),
      clubName: dto.clubName,
      courseName: dto.courseName,
      courseRating: tee?.courseRating,
      slope: tee?.slopeRating,
      par: tee?.parTotal ?? 72,
      holes: const [],
    );
  }

  CourseModel _detailDtoToModel(CourseDetailDto dto) {
    final tee = _primaryTee(dto.tees);
    final holes = tee?.holes ?? [];
    return CourseModel(
      id: dto.id.toString(),
      clubName: dto.clubName,
      courseName: dto.courseName,
      courseRating: tee?.courseRating,
      slope: tee?.slopeRating,
      par: tee?.parTotal ?? 72,
      holes: holes
          .asMap()
          .entries
          .map((e) => _holeDtoToModel(e.key + 1, e.value))
          .toList(),
    );
  }

  HoleModel _holeDtoToModel(int number, HoleDto dto) => HoleModel(
        holeNumber: number,
        par: dto.par,
        strokeIndex: dto.handicap,
        teeLat: null,
        teeLng: null,
        greenLat: null,
        greenLng: null,
      );
}
