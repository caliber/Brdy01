// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CourseModelImpl _$$CourseModelImplFromJson(Map<String, dynamic> json) =>
    _$CourseModelImpl(
      id: json['id'] as String,
      clubName: json['clubName'] as String,
      courseName: json['courseName'] as String,
      courseRating: (json['courseRating'] as num?)?.toDouble(),
      slope: (json['slope'] as num?)?.toInt(),
      par: (json['par'] as num).toInt(),
      holes: (json['holes'] as List<dynamic>)
          .map((e) => HoleModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$CourseModelImplToJson(_$CourseModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clubName': instance.clubName,
      'courseName': instance.courseName,
      'courseRating': instance.courseRating,
      'slope': instance.slope,
      'par': instance.par,
      'holes': instance.holes,
    };
