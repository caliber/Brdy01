import 'package:freezed_annotation/freezed_annotation.dart';

part 'course_detail_response_dto.freezed.dart';
part 'course_detail_response_dto.g.dart';

@freezed
class CourseDetailResponseDto with _$CourseDetailResponseDto {
  const factory CourseDetailResponseDto({
    required CourseDetailDto course,
  }) = _CourseDetailResponseDto;

  factory CourseDetailResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CourseDetailResponseDtoFromJson(json);
}

@freezed
class CourseDetailDto with _$CourseDetailDto {
  const factory CourseDetailDto({
    required String id,
    @JsonKey(name: 'club_name') required String clubName,
    @JsonKey(name: 'course_name') required String courseName,
    @JsonKey(name: 'course_rating') double? courseRating,
    @JsonKey(name: 'slope_rating') int? slopeRating,
    required int par,
    required List<HoleDto> holes,
  }) = _CourseDetailDto;

  factory CourseDetailDto.fromJson(Map<String, dynamic> json) =>
      _$CourseDetailDtoFromJson(json);
}

@freezed
class HoleDto with _$HoleDto {
  const factory HoleDto({
    @JsonKey(name: 'hole_number') required int holeNumber,
    required int par,
    @JsonKey(name: 'stroke_index') int? strokeIndex,
    @JsonKey(name: 'tee_lat') double? teeLat,
    @JsonKey(name: 'tee_lng') double? teeLng,
    @JsonKey(name: 'green_lat') double? greenLat,
    @JsonKey(name: 'green_lng') double? greenLng,
  }) = _HoleDto;

  factory HoleDto.fromJson(Map<String, dynamic> json) =>
      _$HoleDtoFromJson(json);
}
