import 'package:freezed_annotation/freezed_annotation.dart';
import 'tee_dto.dart';

part 'course_search_response_dto.freezed.dart';
part 'course_search_response_dto.g.dart';

@freezed
class CourseSearchResponseDto with _$CourseSearchResponseDto {
  const factory CourseSearchResponseDto({
    required List<CourseSearchResultDto> courses,
  }) = _CourseSearchResponseDto;

  factory CourseSearchResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CourseSearchResponseDtoFromJson(json);
}

@freezed
class CourseSearchResultDto with _$CourseSearchResultDto {
  const factory CourseSearchResultDto({
    required int id,
    @JsonKey(name: 'club_name') required String clubName,
    @JsonKey(name: 'course_name') required String courseName,
    required TeesDto tees,
    LocationDto? location,
  }) = _CourseSearchResultDto;

  factory CourseSearchResultDto.fromJson(Map<String, dynamic> json) =>
      _$CourseSearchResultDtoFromJson(json);
}

@freezed
class LocationDto with _$LocationDto {
  const factory LocationDto({
    String? city,
    String? country,
  }) = _LocationDto;

  factory LocationDto.fromJson(Map<String, dynamic> json) =>
      _$LocationDtoFromJson(json);
}
