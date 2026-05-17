import 'package:freezed_annotation/freezed_annotation.dart';

part 'round_model.freezed.dart';
part 'round_model.g.dart';

@freezed
class RoundModel with _$RoundModel {
  const factory RoundModel({
    required int id,
    required String courseName,
    double? courseRating,
    int? slope,
    required double handicapIndex,
    required DateTime startedAt,
    DateTime? completedAt,
  }) = _RoundModel;

  factory RoundModel.fromJson(Map<String, dynamic> json) =>
      _$RoundModelFromJson(json);
}
