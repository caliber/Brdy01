// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tee_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TeesDtoImpl _$$TeesDtoImplFromJson(Map<String, dynamic> json) =>
    _$TeesDtoImpl(
      male: (json['male'] as List<dynamic>?)
          ?.map((e) => TeeDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      female: (json['female'] as List<dynamic>?)
          ?.map((e) => TeeDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$TeesDtoImplToJson(_$TeesDtoImpl instance) =>
    <String, dynamic>{
      'male': instance.male,
      'female': instance.female,
    };

_$TeeDtoImpl _$$TeeDtoImplFromJson(Map<String, dynamic> json) => _$TeeDtoImpl(
      teeName: json['tee_name'] as String?,
      courseRating: (json['course_rating'] as num?)?.toDouble(),
      slopeRating: (json['slope_rating'] as num?)?.toInt(),
      parTotal: (json['par_total'] as num?)?.toInt(),
      holes: (json['holes'] as List<dynamic>?)
          ?.map((e) => HoleDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$TeeDtoImplToJson(_$TeeDtoImpl instance) =>
    <String, dynamic>{
      'tee_name': instance.teeName,
      'course_rating': instance.courseRating,
      'slope_rating': instance.slopeRating,
      'par_total': instance.parTotal,
      'holes': instance.holes,
    };

_$HoleDtoImpl _$$HoleDtoImplFromJson(Map<String, dynamic> json) =>
    _$HoleDtoImpl(
      par: (json['par'] as num).toInt(),
      yardage: (json['yardage'] as num?)?.toInt(),
      handicap: (json['stroke_index'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$HoleDtoImplToJson(_$HoleDtoImpl instance) =>
    <String, dynamic>{
      'par': instance.par,
      'yardage': instance.yardage,
      'stroke_index': instance.handicap,
    };
