import 'package:freezed_annotation/freezed_annotation.dart';

part 'tee_dto.freezed.dart';
part 'tee_dto.g.dart';

@freezed
class TeesDto with _$TeesDto {
  const factory TeesDto({
    List<TeeDto>? male,
    List<TeeDto>? female,
  }) = _TeesDto;

  factory TeesDto.fromJson(Map<String, dynamic> json) =>
      _$TeesDtoFromJson(json);
}

@freezed
class TeeDto with _$TeeDto {
  const factory TeeDto({
    @JsonKey(name: 'tee_name') String? teeName,
    @JsonKey(name: 'course_rating') double? courseRating,
    @JsonKey(name: 'slope_rating') int? slopeRating,
    @JsonKey(name: 'par_total') int? parTotal,
    List<HoleDto>? holes,
  }) = _TeeDto;

  factory TeeDto.fromJson(Map<String, dynamic> json) =>
      _$TeeDtoFromJson(json);
}

@freezed
class HoleDto with _$HoleDto {
  const factory HoleDto({
    required int par,
    int? yardage,
    int? handicap,
  }) = _HoleDto;

  factory HoleDto.fromJson(Map<String, dynamic> json) =>
      _$HoleDtoFromJson(json);
}
