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
      id: json['id'] as String,
      clubName: json['club_name'] as String,
      courseName: json['course_name'] as String,
      courseRating: (json['course_rating'] as num?)?.toDouble(),
      slopeRating: (json['slope_rating'] as num?)?.toInt(),
      par: (json['par'] as num).toInt(),
      holes: (json['holes'] as List<dynamic>)
          .map((e) => HoleDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$CourseDetailDtoImplToJson(
        _$CourseDetailDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'club_name': instance.clubName,
      'course_name': instance.courseName,
      'course_rating': instance.courseRating,
      'slope_rating': instance.slopeRating,
      'par': instance.par,
      'holes': instance.holes,
    };

_$HoleDtoImpl _$$HoleDtoImplFromJson(Map<String, dynamic> json) =>
    _$HoleDtoImpl(
      holeNumber: (json['hole_number'] as num).toInt(),
      par: (json['par'] as num).toInt(),
      strokeIndex: (json['stroke_index'] as num?)?.toInt(),
      teeLat: (json['tee_lat'] as num?)?.toDouble(),
      teeLng: (json['tee_lng'] as num?)?.toDouble(),
      greenLat: (json['green_lat'] as num?)?.toDouble(),
      greenLng: (json['green_lng'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$HoleDtoImplToJson(_$HoleDtoImpl instance) =>
    <String, dynamic>{
      'hole_number': instance.holeNumber,
      'par': instance.par,
      'stroke_index': instance.strokeIndex,
      'tee_lat': instance.teeLat,
      'tee_lng': instance.teeLng,
      'green_lat': instance.greenLat,
      'green_lng': instance.greenLng,
    };
