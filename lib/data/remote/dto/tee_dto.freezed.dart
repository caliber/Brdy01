// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tee_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TeesDto _$TeesDtoFromJson(Map<String, dynamic> json) {
  return _TeesDto.fromJson(json);
}

/// @nodoc
mixin _$TeesDto {
  List<TeeDto>? get male => throw _privateConstructorUsedError;
  List<TeeDto>? get female => throw _privateConstructorUsedError;

  /// Serializes this TeesDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeesDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeesDtoCopyWith<TeesDto> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeesDtoCopyWith<$Res> {
  factory $TeesDtoCopyWith(TeesDto value, $Res Function(TeesDto) then) =
      _$TeesDtoCopyWithImpl<$Res, TeesDto>;
  @useResult
  $Res call({List<TeeDto>? male, List<TeeDto>? female});
}

/// @nodoc
class _$TeesDtoCopyWithImpl<$Res, $Val extends TeesDto>
    implements $TeesDtoCopyWith<$Res> {
  _$TeesDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeesDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? male = freezed,
    Object? female = freezed,
  }) {
    return _then(_value.copyWith(
      male: freezed == male
          ? _value.male
          : male // ignore: cast_nullable_to_non_nullable
              as List<TeeDto>?,
      female: freezed == female
          ? _value.female
          : female // ignore: cast_nullable_to_non_nullable
              as List<TeeDto>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TeesDtoImplCopyWith<$Res> implements $TeesDtoCopyWith<$Res> {
  factory _$$TeesDtoImplCopyWith(
          _$TeesDtoImpl value, $Res Function(_$TeesDtoImpl) then) =
      __$$TeesDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<TeeDto>? male, List<TeeDto>? female});
}

/// @nodoc
class __$$TeesDtoImplCopyWithImpl<$Res>
    extends _$TeesDtoCopyWithImpl<$Res, _$TeesDtoImpl>
    implements _$$TeesDtoImplCopyWith<$Res> {
  __$$TeesDtoImplCopyWithImpl(
      _$TeesDtoImpl _value, $Res Function(_$TeesDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of TeesDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? male = freezed,
    Object? female = freezed,
  }) {
    return _then(_$TeesDtoImpl(
      male: freezed == male
          ? _value._male
          : male // ignore: cast_nullable_to_non_nullable
              as List<TeeDto>?,
      female: freezed == female
          ? _value._female
          : female // ignore: cast_nullable_to_non_nullable
              as List<TeeDto>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TeesDtoImpl implements _TeesDto {
  const _$TeesDtoImpl({final List<TeeDto>? male, final List<TeeDto>? female})
      : _male = male,
        _female = female;

  factory _$TeesDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeesDtoImplFromJson(json);

  final List<TeeDto>? _male;
  @override
  List<TeeDto>? get male {
    final value = _male;
    if (value == null) return null;
    if (_male is EqualUnmodifiableListView) return _male;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<TeeDto>? _female;
  @override
  List<TeeDto>? get female {
    final value = _female;
    if (value == null) return null;
    if (_female is EqualUnmodifiableListView) return _female;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'TeesDto(male: $male, female: $female)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeesDtoImpl &&
            const DeepCollectionEquality().equals(other._male, _male) &&
            const DeepCollectionEquality().equals(other._female, _female));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_male),
      const DeepCollectionEquality().hash(_female));

  /// Create a copy of TeesDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeesDtoImplCopyWith<_$TeesDtoImpl> get copyWith =>
      __$$TeesDtoImplCopyWithImpl<_$TeesDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TeesDtoImplToJson(
      this,
    );
  }
}

abstract class _TeesDto implements TeesDto {
  const factory _TeesDto(
      {final List<TeeDto>? male, final List<TeeDto>? female}) = _$TeesDtoImpl;

  factory _TeesDto.fromJson(Map<String, dynamic> json) = _$TeesDtoImpl.fromJson;

  @override
  List<TeeDto>? get male;
  @override
  List<TeeDto>? get female;

  /// Create a copy of TeesDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeesDtoImplCopyWith<_$TeesDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TeeDto _$TeeDtoFromJson(Map<String, dynamic> json) {
  return _TeeDto.fromJson(json);
}

/// @nodoc
mixin _$TeeDto {
  @JsonKey(name: 'tee_name')
  String? get teeName => throw _privateConstructorUsedError;
  @JsonKey(name: 'course_rating')
  double? get courseRating => throw _privateConstructorUsedError;
  @JsonKey(name: 'slope_rating')
  int? get slopeRating => throw _privateConstructorUsedError;
  @JsonKey(name: 'par_total')
  int? get parTotal => throw _privateConstructorUsedError;
  List<HoleDto>? get holes => throw _privateConstructorUsedError;

  /// Serializes this TeeDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeeDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeeDtoCopyWith<TeeDto> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeeDtoCopyWith<$Res> {
  factory $TeeDtoCopyWith(TeeDto value, $Res Function(TeeDto) then) =
      _$TeeDtoCopyWithImpl<$Res, TeeDto>;
  @useResult
  $Res call(
      {@JsonKey(name: 'tee_name') String? teeName,
      @JsonKey(name: 'course_rating') double? courseRating,
      @JsonKey(name: 'slope_rating') int? slopeRating,
      @JsonKey(name: 'par_total') int? parTotal,
      List<HoleDto>? holes});
}

/// @nodoc
class _$TeeDtoCopyWithImpl<$Res, $Val extends TeeDto>
    implements $TeeDtoCopyWith<$Res> {
  _$TeeDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeeDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? teeName = freezed,
    Object? courseRating = freezed,
    Object? slopeRating = freezed,
    Object? parTotal = freezed,
    Object? holes = freezed,
  }) {
    return _then(_value.copyWith(
      teeName: freezed == teeName
          ? _value.teeName
          : teeName // ignore: cast_nullable_to_non_nullable
              as String?,
      courseRating: freezed == courseRating
          ? _value.courseRating
          : courseRating // ignore: cast_nullable_to_non_nullable
              as double?,
      slopeRating: freezed == slopeRating
          ? _value.slopeRating
          : slopeRating // ignore: cast_nullable_to_non_nullable
              as int?,
      parTotal: freezed == parTotal
          ? _value.parTotal
          : parTotal // ignore: cast_nullable_to_non_nullable
              as int?,
      holes: freezed == holes
          ? _value.holes
          : holes // ignore: cast_nullable_to_non_nullable
              as List<HoleDto>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TeeDtoImplCopyWith<$Res> implements $TeeDtoCopyWith<$Res> {
  factory _$$TeeDtoImplCopyWith(
          _$TeeDtoImpl value, $Res Function(_$TeeDtoImpl) then) =
      __$$TeeDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'tee_name') String? teeName,
      @JsonKey(name: 'course_rating') double? courseRating,
      @JsonKey(name: 'slope_rating') int? slopeRating,
      @JsonKey(name: 'par_total') int? parTotal,
      List<HoleDto>? holes});
}

/// @nodoc
class __$$TeeDtoImplCopyWithImpl<$Res>
    extends _$TeeDtoCopyWithImpl<$Res, _$TeeDtoImpl>
    implements _$$TeeDtoImplCopyWith<$Res> {
  __$$TeeDtoImplCopyWithImpl(
      _$TeeDtoImpl _value, $Res Function(_$TeeDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of TeeDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? teeName = freezed,
    Object? courseRating = freezed,
    Object? slopeRating = freezed,
    Object? parTotal = freezed,
    Object? holes = freezed,
  }) {
    return _then(_$TeeDtoImpl(
      teeName: freezed == teeName
          ? _value.teeName
          : teeName // ignore: cast_nullable_to_non_nullable
              as String?,
      courseRating: freezed == courseRating
          ? _value.courseRating
          : courseRating // ignore: cast_nullable_to_non_nullable
              as double?,
      slopeRating: freezed == slopeRating
          ? _value.slopeRating
          : slopeRating // ignore: cast_nullable_to_non_nullable
              as int?,
      parTotal: freezed == parTotal
          ? _value.parTotal
          : parTotal // ignore: cast_nullable_to_non_nullable
              as int?,
      holes: freezed == holes
          ? _value._holes
          : holes // ignore: cast_nullable_to_non_nullable
              as List<HoleDto>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TeeDtoImpl implements _TeeDto {
  const _$TeeDtoImpl(
      {@JsonKey(name: 'tee_name') this.teeName,
      @JsonKey(name: 'course_rating') this.courseRating,
      @JsonKey(name: 'slope_rating') this.slopeRating,
      @JsonKey(name: 'par_total') this.parTotal,
      final List<HoleDto>? holes})
      : _holes = holes;

  factory _$TeeDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeeDtoImplFromJson(json);

  @override
  @JsonKey(name: 'tee_name')
  final String? teeName;
  @override
  @JsonKey(name: 'course_rating')
  final double? courseRating;
  @override
  @JsonKey(name: 'slope_rating')
  final int? slopeRating;
  @override
  @JsonKey(name: 'par_total')
  final int? parTotal;
  final List<HoleDto>? _holes;
  @override
  List<HoleDto>? get holes {
    final value = _holes;
    if (value == null) return null;
    if (_holes is EqualUnmodifiableListView) return _holes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'TeeDto(teeName: $teeName, courseRating: $courseRating, slopeRating: $slopeRating, parTotal: $parTotal, holes: $holes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeeDtoImpl &&
            (identical(other.teeName, teeName) || other.teeName == teeName) &&
            (identical(other.courseRating, courseRating) ||
                other.courseRating == courseRating) &&
            (identical(other.slopeRating, slopeRating) ||
                other.slopeRating == slopeRating) &&
            (identical(other.parTotal, parTotal) ||
                other.parTotal == parTotal) &&
            const DeepCollectionEquality().equals(other._holes, _holes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, teeName, courseRating,
      slopeRating, parTotal, const DeepCollectionEquality().hash(_holes));

  /// Create a copy of TeeDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeeDtoImplCopyWith<_$TeeDtoImpl> get copyWith =>
      __$$TeeDtoImplCopyWithImpl<_$TeeDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TeeDtoImplToJson(
      this,
    );
  }
}

abstract class _TeeDto implements TeeDto {
  const factory _TeeDto(
      {@JsonKey(name: 'tee_name') final String? teeName,
      @JsonKey(name: 'course_rating') final double? courseRating,
      @JsonKey(name: 'slope_rating') final int? slopeRating,
      @JsonKey(name: 'par_total') final int? parTotal,
      final List<HoleDto>? holes}) = _$TeeDtoImpl;

  factory _TeeDto.fromJson(Map<String, dynamic> json) = _$TeeDtoImpl.fromJson;

  @override
  @JsonKey(name: 'tee_name')
  String? get teeName;
  @override
  @JsonKey(name: 'course_rating')
  double? get courseRating;
  @override
  @JsonKey(name: 'slope_rating')
  int? get slopeRating;
  @override
  @JsonKey(name: 'par_total')
  int? get parTotal;
  @override
  List<HoleDto>? get holes;

  /// Create a copy of TeeDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeeDtoImplCopyWith<_$TeeDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HoleDto _$HoleDtoFromJson(Map<String, dynamic> json) {
  return _HoleDto.fromJson(json);
}

/// @nodoc
mixin _$HoleDto {
  int get par => throw _privateConstructorUsedError;
  int? get yardage => throw _privateConstructorUsedError;
  int? get handicap => throw _privateConstructorUsedError;

  /// Serializes this HoleDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HoleDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HoleDtoCopyWith<HoleDto> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HoleDtoCopyWith<$Res> {
  factory $HoleDtoCopyWith(HoleDto value, $Res Function(HoleDto) then) =
      _$HoleDtoCopyWithImpl<$Res, HoleDto>;
  @useResult
  $Res call({int par, int? yardage, int? handicap});
}

/// @nodoc
class _$HoleDtoCopyWithImpl<$Res, $Val extends HoleDto>
    implements $HoleDtoCopyWith<$Res> {
  _$HoleDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HoleDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? par = null,
    Object? yardage = freezed,
    Object? handicap = freezed,
  }) {
    return _then(_value.copyWith(
      par: null == par
          ? _value.par
          : par // ignore: cast_nullable_to_non_nullable
              as int,
      yardage: freezed == yardage
          ? _value.yardage
          : yardage // ignore: cast_nullable_to_non_nullable
              as int?,
      handicap: freezed == handicap
          ? _value.handicap
          : handicap // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HoleDtoImplCopyWith<$Res> implements $HoleDtoCopyWith<$Res> {
  factory _$$HoleDtoImplCopyWith(
          _$HoleDtoImpl value, $Res Function(_$HoleDtoImpl) then) =
      __$$HoleDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int par, int? yardage, int? handicap});
}

/// @nodoc
class __$$HoleDtoImplCopyWithImpl<$Res>
    extends _$HoleDtoCopyWithImpl<$Res, _$HoleDtoImpl>
    implements _$$HoleDtoImplCopyWith<$Res> {
  __$$HoleDtoImplCopyWithImpl(
      _$HoleDtoImpl _value, $Res Function(_$HoleDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of HoleDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? par = null,
    Object? yardage = freezed,
    Object? handicap = freezed,
  }) {
    return _then(_$HoleDtoImpl(
      par: null == par
          ? _value.par
          : par // ignore: cast_nullable_to_non_nullable
              as int,
      yardage: freezed == yardage
          ? _value.yardage
          : yardage // ignore: cast_nullable_to_non_nullable
              as int?,
      handicap: freezed == handicap
          ? _value.handicap
          : handicap // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HoleDtoImpl implements _HoleDto {
  const _$HoleDtoImpl({required this.par, this.yardage, this.handicap});

  factory _$HoleDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$HoleDtoImplFromJson(json);

  @override
  final int par;
  @override
  final int? yardage;
  @override
  final int? handicap;

  @override
  String toString() {
    return 'HoleDto(par: $par, yardage: $yardage, handicap: $handicap)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HoleDtoImpl &&
            (identical(other.par, par) || other.par == par) &&
            (identical(other.yardage, yardage) || other.yardage == yardage) &&
            (identical(other.handicap, handicap) ||
                other.handicap == handicap));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, par, yardage, handicap);

  /// Create a copy of HoleDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HoleDtoImplCopyWith<_$HoleDtoImpl> get copyWith =>
      __$$HoleDtoImplCopyWithImpl<_$HoleDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HoleDtoImplToJson(
      this,
    );
  }
}

abstract class _HoleDto implements HoleDto {
  const factory _HoleDto(
      {required final int par,
      final int? yardage,
      final int? handicap}) = _$HoleDtoImpl;

  factory _HoleDto.fromJson(Map<String, dynamic> json) = _$HoleDtoImpl.fromJson;

  @override
  int get par;
  @override
  int? get yardage;
  @override
  int? get handicap;

  /// Create a copy of HoleDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HoleDtoImplCopyWith<_$HoleDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
