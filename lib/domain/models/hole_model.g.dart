// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hole_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HoleModelImpl _$$HoleModelImplFromJson(Map<String, dynamic> json) =>
    _$HoleModelImpl(
      holeNumber: (json['holeNumber'] as num).toInt(),
      par: (json['par'] as num).toInt(),
      strokeIndex: (json['strokeIndex'] as num?)?.toInt(),
      teeLat: (json['teeLat'] as num?)?.toDouble(),
      teeLng: (json['teeLng'] as num?)?.toDouble(),
      greenLat: (json['greenLat'] as num?)?.toDouble(),
      greenLng: (json['greenLng'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$HoleModelImplToJson(_$HoleModelImpl instance) =>
    <String, dynamic>{
      'holeNumber': instance.holeNumber,
      'par': instance.par,
      'strokeIndex': instance.strokeIndex,
      'teeLat': instance.teeLat,
      'teeLng': instance.teeLng,
      'greenLat': instance.greenLat,
      'greenLng': instance.greenLng,
    };
