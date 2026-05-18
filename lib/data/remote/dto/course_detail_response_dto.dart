import 'package:freezed_annotation/freezed_annotation.dart';
import 'tee_dto.dart';

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
    required int id,
    @JsonKey(name: 'club_name') required String clubName,
    @JsonKey(name: 'course_name') required String courseName,
    required TeesDto tees,
  }) = _CourseDetailDto;

  factory CourseDetailDto.fromJson(Map<String, dynamic> json) =>
      _$CourseDetailDtoFromJson(json);
}
