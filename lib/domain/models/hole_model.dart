import 'package:freezed_annotation/freezed_annotation.dart';

part 'hole_model.freezed.dart';
part 'hole_model.g.dart';

@freezed
class HoleModel with _$HoleModel {
  const factory HoleModel({
    required int holeNumber,
    required int par,
    int? strokeIndex,
    double? teeLat,
    double? teeLng,
    double? greenLat,
    double? greenLng,
  }) = _HoleModel;

  factory HoleModel.fromJson(Map<String, dynamic> json) =>
      _$HoleModelFromJson(json);
}
