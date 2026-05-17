// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hole_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HoleModel _$HoleModelFromJson(Map<String, dynamic> json) {
  return _HoleModel.fromJson(json);
}

/// @nodoc
mixin _$HoleModel {
  int get holeNumber => throw _privateConstructorUsedError;
  int get par => throw _privateConstructorUsedError;
  int? get strokeIndex => throw _privateConstructorUsedError;
  double? get teeLat => throw _privateConstructorUsedError;
  double? get teeLng => throw _privateConstructorUsedError;
  double? get greenLat => throw _privateConstructorUsedError;
  double? get greenLng => throw _privateConstructorUsedError;

  /// Serializes this HoleModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HoleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HoleModelCopyWith<HoleModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HoleModelCopyWith<$Res> {
  factory $HoleModelCopyWith(HoleModel value, $Res Function(HoleModel) then) =
      _$HoleModelCopyWithImpl<$Res, HoleModel>;
  @useResult
  $Res call(
      {int holeNumber,
      int par,
      int? strokeIndex,
      double? teeLat,
      double? teeLng,
      double? greenLat,
      double? greenLng});
}

/// @nodoc
class _$HoleModelCopyWithImpl<$Res, $Val extends HoleModel>
    implements $HoleModelCopyWith<$Res> {
  _$HoleModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HoleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? holeNumber = null,
    Object? par = null,
    Object? strokeIndex = freezed,
    Object? teeLat = freezed,
    Object? teeLng = freezed,
    Object? greenLat = freezed,
    Object? greenLng = freezed,
  }) {
    return _then(_value.copyWith(
      holeNumber: null == holeNumber
          ? _value.holeNumber
          : holeNumber // ignore: cast_nullable_to_non_nullable
              as int,
      par: null == par
          ? _value.par
          : par // ignore: cast_nullable_to_non_nullable
              as int,
      strokeIndex: freezed == strokeIndex
          ? _value.strokeIndex
          : strokeIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      teeLat: freezed == teeLat
          ? _value.teeLat
          : teeLat // ignore: cast_nullable_to_non_nullable
              as double?,
      teeLng: freezed == teeLng
          ? _value.teeLng
          : teeLng // ignore: cast_nullable_to_non_nullable
              as double?,
      greenLat: freezed == greenLat
          ? _value.greenLat
          : greenLat // ignore: cast_nullable_to_non_nullable
              as double?,
      greenLng: freezed == greenLng
          ? _value.greenLng
          : greenLng // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HoleModelImplCopyWith<$Res>
    implements $HoleModelCopyWith<$Res> {
  factory _$$HoleModelImplCopyWith(
          _$HoleModelImpl value, $Res Function(_$HoleModelImpl) then) =
      __$$HoleModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int holeNumber,
      int par,
      int? strokeIndex,
      double? teeLat,
      double? teeLng,
      double? greenLat,
      double? greenLng});
}

/// @nodoc
class __$$HoleModelImplCopyWithImpl<$Res>
    extends _$HoleModelCopyWithImpl<$Res, _$HoleModelImpl>
    implements _$$HoleModelImplCopyWith<$Res> {
  __$$HoleModelImplCopyWithImpl(
      _$HoleModelImpl _value, $Res Function(_$HoleModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of HoleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? holeNumber = null,
    Object? par = null,
    Object? strokeIndex = freezed,
    Object? teeLat = freezed,
    Object? teeLng = freezed,
    Object? greenLat = freezed,
    Object? greenLng = freezed,
  }) {
    return _then(_$HoleModelImpl(
      holeNumber: null == holeNumber
          ? _value.holeNumber
          : holeNumber // ignore: cast_nullable_to_non_nullable
              as int,
      par: null == par
          ? _value.par
          : par // ignore: cast_nullable_to_non_nullable
              as int,
      strokeIndex: freezed == strokeIndex
          ? _value.strokeIndex
          : strokeIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      teeLat: freezed == teeLat
          ? _value.teeLat
          : teeLat // ignore: cast_nullable_to_non_nullable
              as double?,
      teeLng: freezed == teeLng
          ? _value.teeLng
          : teeLng // ignore: cast_nullable_to_non_nullable
              as double?,
      greenLat: freezed == greenLat
          ? _value.greenLat
          : greenLat // ignore: cast_nullable_to_non_nullable
              as double?,
      greenLng: freezed == greenLng
          ? _value.greenLng
          : greenLng // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HoleModelImpl implements _HoleModel {
  const _$HoleModelImpl(
      {required this.holeNumber,
      required this.par,
      this.strokeIndex,
      this.teeLat,
      this.teeLng,
      this.greenLat,
      this.greenLng});

  factory _$HoleModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$HoleModelImplFromJson(json);

  @override
  final int holeNumber;
  @override
  final int par;
  @override
  final int? strokeIndex;
  @override
  final double? teeLat;
  @override
  final double? teeLng;
  @override
  final double? greenLat;
  @override
  final double? greenLng;

  @override
  String toString() {
    return 'HoleModel(holeNumber: $holeNumber, par: $par, strokeIndex: $strokeIndex, teeLat: $teeLat, teeLng: $teeLng, greenLat: $greenLat, greenLng: $greenLng)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HoleModelImpl &&
            (identical(other.holeNumber, holeNumber) ||
                other.holeNumber == holeNumber) &&
            (identical(other.par, par) || other.par == par) &&
            (identical(other.strokeIndex, strokeIndex) ||
                other.strokeIndex == strokeIndex) &&
            (identical(other.teeLat, teeLat) || other.teeLat == teeLat) &&
            (identical(other.teeLng, teeLng) || other.teeLng == teeLng) &&
            (identical(other.greenLat, greenLat) ||
                other.greenLat == greenLat) &&
            (identical(other.greenLng, greenLng) ||
                other.greenLng == greenLng));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, holeNumber, par, strokeIndex,
      teeLat, teeLng, greenLat, greenLng);

  /// Create a copy of HoleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HoleModelImplCopyWith<_$HoleModelImpl> get copyWith =>
      __$$HoleModelImplCopyWithImpl<_$HoleModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HoleModelImplToJson(
      this,
    );
  }
}

abstract class _HoleModel implements HoleModel {
  const factory _HoleModel(
      {required final int holeNumber,
      required final int par,
      final int? strokeIndex,
      final double? teeLat,
      final double? teeLng,
      final double? greenLat,
      final double? greenLng}) = _$HoleModelImpl;

  factory _HoleModel.fromJson(Map<String, dynamic> json) =
      _$HoleModelImpl.fromJson;

  @override
  int get holeNumber;
  @override
  int get par;
  @override
  int? get strokeIndex;
  @override
  double? get teeLat;
  @override
  double? get teeLng;
  @override
  double? get greenLat;
  @override
  double? get greenLng;

  /// Create a copy of HoleModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HoleModelImplCopyWith<_$HoleModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
