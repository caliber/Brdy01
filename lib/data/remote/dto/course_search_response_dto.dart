import 'package:freezed_annotation/freezed_annotation.dart';

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
    required String id,
    @JsonKey(name: 'club_name') required String clubName,
    @JsonKey(name: 'course_name') required String courseName,
    @JsonKey(name: 'course_rating') double? courseRating,
    @JsonKey(name: 'slope_rating') int? slopeRating,
    required int par,
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
