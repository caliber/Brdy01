// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_search_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CourseSearchResponseDtoImpl _$$CourseSearchResponseDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$CourseSearchResponseDtoImpl(
      courses: (json['courses'] as List<dynamic>)
          .map((e) => CourseSearchResultDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$CourseSearchResponseDtoImplToJson(
        _$CourseSearchResponseDtoImpl instance) =>
    <String, dynamic>{
      'courses': instance.courses,
    };

_$CourseSearchResultDtoImpl _$$CourseSearchResultDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$CourseSearchResultDtoImpl(
      id: json['id'] as String,
      clubName: json['club_name'] as String,
      courseName: json['course_name'] as String,
      courseRating: (json['course_rating'] as num?)?.toDouble(),
      slopeRating: (json['slope_rating'] as num?)?.toInt(),
      par: (json['par'] as num).toInt(),
      location: json['location'] == null
          ? null
          : LocationDto.fromJson(json['location'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$CourseSearchResultDtoImplToJson(
        _$CourseSearchResultDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'club_name': instance.clubName,
      'course_name': instance.courseName,
      'course_rating': instance.courseRating,
      'slope_rating': instance.slopeRating,
      'par': instance.par,
      'location': instance.location,
    };

_$LocationDtoImpl _$$LocationDtoImplFromJson(Map<String, dynamic> json) =>
    _$LocationDtoImpl(
      city: json['city'] as String?,
      country: json['country'] as String?,
    );

Map<String, dynamic> _$$LocationDtoImplToJson(_$LocationDtoImpl instance) =>
    <String, dynamic>{
      'city': instance.city,
      'country': instance.country,
    };
