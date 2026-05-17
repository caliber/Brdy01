import 'package:freezed_annotation/freezed_annotation.dart';
import 'hole_model.dart';

part 'course_model.freezed.dart';
part 'course_model.g.dart';

@freezed
class CourseModel with _$CourseModel {
  const factory CourseModel({
    required String id,
    required String clubName,
    required String courseName,
    double? courseRating,
    int? slope,
    required int par,
    required List<HoleModel> holes,
  }) = _CourseModel;

  factory CourseModel.fromJson(Map<String, dynamic> json) =>
      _$CourseModelFromJson(json);
}
