// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'round_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RoundModel _$RoundModelFromJson(Map<String, dynamic> json) {
  return _RoundModel.fromJson(json);
}

/// @nodoc
mixin _$RoundModel {
  int get id => throw _privateConstructorUsedError;
  String get courseName => throw _privateConstructorUsedError;
  double? get courseRating => throw _privateConstructorUsedError;
  int? get slope => throw _privateConstructorUsedError;
  double get handicapIndex => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Serializes this RoundModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RoundModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoundModelCopyWith<RoundModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoundModelCopyWith<$Res> {
  factory $RoundModelCopyWith(
          RoundModel value, $Res Function(RoundModel) then) =
      _$RoundModelCopyWithImpl<$Res, RoundModel>;
  @useResult
  $Res call(
      {int id,
      String courseName,
      double? courseRating,
      int? slope,
      double handicapIndex,
      DateTime startedAt,
      DateTime? completedAt});
}

/// @nodoc
class _$RoundModelCopyWithImpl<$Res, $Val extends RoundModel>
    implements $RoundModelCopyWith<$Res> {
  _$RoundModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RoundModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? courseName = null,
    Object? courseRating = freezed,
    Object? slope = freezed,
    Object? handicapIndex = null,
    Object? startedAt = null,
    Object? completedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      courseName: null == courseName
          ? _value.courseName
          : courseName // ignore: cast_nullable_to_non_nullable
              as String,
      courseRating: freezed == courseRating
          ? _value.courseRating
          : courseRating // ignore: cast_nullable_to_non_nullable
              as double?,
      slope: freezed == slope
          ? _value.slope
          : slope // ignore: cast_nullable_to_non_nullable
              as int?,
      handicapIndex: null == handicapIndex
          ? _value.handicapIndex
          : handicapIndex // ignore: cast_nullable_to_non_nullable
              as double,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RoundModelImplCopyWith<$Res>
    implements $RoundModelCopyWith<$Res> {
  factory _$$RoundModelImplCopyWith(
          _$RoundModelImpl value, $Res Function(_$RoundModelImpl) then) =
      __$$RoundModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String courseName,
      double? courseRating,
      int? slope,
      double handicapIndex,
      DateTime startedAt,
      DateTime? completedAt});
}

/// @nodoc
class __$$RoundModelImplCopyWithImpl<$Res>
    extends _$RoundModelCopyWithImpl<$Res, _$RoundModelImpl>
    implements _$$RoundModelImplCopyWith<$Res> {
  __$$RoundModelImplCopyWithImpl(
      _$RoundModelImpl _value, $Res Function(_$RoundModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of RoundModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? courseName = null,
    Object? courseRating = freezed,
    Object? slope = freezed,
    Object? handicapIndex = null,
    Object? startedAt = null,
    Object? completedAt = freezed,
  }) {
    return _then(_$RoundModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      courseName: null == courseName
          ? _value.courseName
          : courseName // ignore: cast_nullable_to_non_nullable
              as String,
      courseRating: freezed == courseRating
          ? _value.courseRating
          : courseRating // ignore: cast_nullable_to_non_nullable
              as double?,
      slope: freezed == slope
          ? _value.slope
          : slope // ignore: cast_nullable_to_non_nullable
              as int?,
      handicapIndex: null == handicapIndex
          ? _value.handicapIndex
          : handicapIndex // ignore: cast_nullable_to_non_nullable
              as double,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RoundModelImpl implements _RoundModel {
  const _$RoundModelImpl(
      {required this.id,
      required this.courseName,
      this.courseRating,
      this.slope,
      required this.handicapIndex,
      required this.startedAt,
      this.completedAt});

  factory _$RoundModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoundModelImplFromJson(json);

  @override
  final int id;
  @override
  final String courseName;
  @override
  final double? courseRating;
  @override
  final int? slope;
  @override
  final double handicapIndex;
  @override
  final DateTime startedAt;
  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'RoundModel(id: $id, courseName: $courseName, courseRating: $courseRating, slope: $slope, handicapIndex: $handicapIndex, startedAt: $startedAt, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoundModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.courseName, courseName) ||
                other.courseName == courseName) &&
            (identical(other.courseRating, courseRating) ||
                other.courseRating == courseRating) &&
            (identical(other.slope, slope) || other.slope == slope) &&
            (identical(other.handicapIndex, handicapIndex) ||
                other.handicapIndex == handicapIndex) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, courseName, courseRating,
      slope, handicapIndex, startedAt, completedAt);

  /// Create a copy of RoundModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoundModelImplCopyWith<_$RoundModelImpl> get copyWith =>
      __$$RoundModelImplCopyWithImpl<_$RoundModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoundModelImplToJson(
      this,
    );
  }
}

abstract class _RoundModel implements RoundModel {
  const factory _RoundModel(
      {required final int id,
      required final String courseName,
      final double? courseRating,
      final int? slope,
      required final double handicapIndex,
      required final DateTime startedAt,
      final DateTime? completedAt}) = _$RoundModelImpl;

  factory _RoundModel.fromJson(Map<String, dynamic> json) =
      _$RoundModelImpl.fromJson;

  @override
  int get id;
  @override
  String get courseName;
  @override
  double? get courseRating;
  @override
  int? get slope;
  @override
  double get handicapIndex;
  @override
  DateTime get startedAt;
  @override
  DateTime? get completedAt;

  /// Create a copy of RoundModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoundModelImplCopyWith<_$RoundModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
