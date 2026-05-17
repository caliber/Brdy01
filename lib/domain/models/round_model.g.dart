// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'round_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoundModelImpl _$$RoundModelImplFromJson(Map<String, dynamic> json) =>
    _$RoundModelImpl(
      id: (json['id'] as num).toInt(),
      courseName: json['courseName'] as String,
      courseRating: (json['courseRating'] as num?)?.toDouble(),
      slope: (json['slope'] as num?)?.toInt(),
      handicapIndex: (json['handicapIndex'] as num).toDouble(),
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$$RoundModelImplToJson(_$RoundModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'courseName': instance.courseName,
      'courseRating': instance.courseRating,
      'slope': instance.slope,
      'handicapIndex': instance.handicapIndex,
      'startedAt': instance.startedAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
    };
