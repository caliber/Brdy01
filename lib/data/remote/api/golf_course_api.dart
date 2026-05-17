import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../dto/course_search_response_dto.dart';
import '../dto/course_detail_response_dto.dart';

part 'golf_course_api.g.dart';

@RestApi()
abstract class GolfCourseApi {
  factory GolfCourseApi(Dio dio, {String baseUrl}) = _GolfCourseApi;

  @GET('/search')
  Future<CourseSearchResponseDto> searchCourses(
    @Query('search_query') String query,
  );

  @GET('/courses/{id}')
  Future<CourseDetailResponseDto> getCourseDetail(
    @Path('id') String id,
  );
}
