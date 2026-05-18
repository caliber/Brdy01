// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_detail_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CourseDetailResponseDtoImpl _$$CourseDetailResponseDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$CourseDetailResponseDtoImpl(
      course: CourseDetailDto.fromJson(json['course'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$CourseDetailResponseDtoImplToJson(
        _$CourseDetailResponseDtoImpl instance) =>
    <String, dynamic>{
      'course': instance.course,
    };

_$CourseDetailDtoImpl _$$CourseDetailDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$CourseDetailDtoImpl(
      id: (json['id'] as num).toInt(),
      clubName: json['club_name'] as String,
      courseName: json['course_name'] as String,
      tees: TeesDto.fromJson(json['tees'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$CourseDetailDtoImplToJson(
        _$CourseDetailDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'club_name': instance.clubName,
      'course_name': instance.courseName,
      'tees': instance.tees,
    };
