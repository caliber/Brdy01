// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'course_detail_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CourseDetailResponseDto _$CourseDetailResponseDtoFromJson(
    Map<String, dynamic> json) {
  return _CourseDetailResponseDto.fromJson(json);
}

/// @nodoc
mixin _$CourseDetailResponseDto {
  CourseDetailDto get course => throw _privateConstructorUsedError;

  /// Serializes this CourseDetailResponseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CourseDetailResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CourseDetailResponseDtoCopyWith<CourseDetailResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CourseDetailResponseDtoCopyWith<$Res> {
  factory $CourseDetailResponseDtoCopyWith(CourseDetailResponseDto value,
          $Res Function(CourseDetailResponseDto) then) =
      _$CourseDetailResponseDtoCopyWithImpl<$Res, CourseDetailResponseDto>;
  @useResult
  $Res call({CourseDetailDto course});

  $CourseDetailDtoCopyWith<$Res> get course;
}

/// @nodoc
class _$CourseDetailResponseDtoCopyWithImpl<$Res,
        $Val extends CourseDetailResponseDto>
    implements $CourseDetailResponseDtoCopyWith<$Res> {
  _$CourseDetailResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CourseDetailResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? course = null,
  }) {
    return _then(_value.copyWith(
      course: null == course
          ? _value.course
          : course // ignore: cast_nullable_to_non_nullable
              as CourseDetailDto,
    ) as $Val);
  }

  /// Create a copy of CourseDetailResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CourseDetailDtoCopyWith<$Res> get course {
    return $CourseDetailDtoCopyWith<$Res>(_value.course, (value) {
      return _then(_value.copyWith(course: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CourseDetailResponseDtoImplCopyWith<$Res>
    implements $CourseDetailResponseDtoCopyWith<$Res> {
  factory _$$CourseDetailResponseDtoImplCopyWith(
          _$CourseDetailResponseDtoImpl value,
          $Res Function(_$CourseDetailResponseDtoImpl) then) =
      __$$CourseDetailResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({CourseDetailDto course});

  @override
  $CourseDetailDtoCopyWith<$Res> get course;
}

/// @nodoc
class __$$CourseDetailResponseDtoImplCopyWithImpl<$Res>
    extends _$CourseDetailResponseDtoCopyWithImpl<$Res,
        _$CourseDetailResponseDtoImpl>
    implements _$$CourseDetailResponseDtoImplCopyWith<$Res> {
  __$$CourseDetailResponseDtoImplCopyWithImpl(
      _$CourseDetailResponseDtoImpl _value,
      $Res Function(_$CourseDetailResponseDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of CourseDetailResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? course = null,
  }) {
    return _then(_$CourseDetailResponseDtoImpl(
      course: null == course
          ? _value.course
          : course // ignore: cast_nullable_to_non_nullable
              as CourseDetailDto,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CourseDetailResponseDtoImpl implements _CourseDetailResponseDto {
  const _$CourseDetailResponseDtoImpl({required this.course});

  factory _$CourseDetailResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CourseDetailResponseDtoImplFromJson(json);

  @override
  final CourseDetailDto course;

  @override
  String toString() {
    return 'CourseDetailResponseDto(course: $course)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CourseDetailResponseDtoImpl &&
            (identical(other.course, course) || other.course == course));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, course);

  /// Create a copy of CourseDetailResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CourseDetailResponseDtoImplCopyWith<_$CourseDetailResponseDtoImpl>
      get copyWith => __$$CourseDetailResponseDtoImplCopyWithImpl<
          _$CourseDetailResponseDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CourseDetailResponseDtoImplToJson(
      this,
    );
  }
}

abstract class _CourseDetailResponseDto implements CourseDetailResponseDto {
  const factory _CourseDetailResponseDto(
      {required final CourseDetailDto course}) = _$CourseDetailResponseDtoImpl;

  factory _CourseDetailResponseDto.fromJson(Map<String, dynamic> json) =
      _$CourseDetailResponseDtoImpl.fromJson;

  @override
  CourseDetailDto get course;

  /// Create a copy of CourseDetailResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CourseDetailResponseDtoImplCopyWith<_$CourseDetailResponseDtoImpl>
      get copyWith => throw _privateConstructorUsedError;
}

CourseDetailDto _$CourseDetailDtoFromJson(Map<String, dynamic> json) {
  return _CourseDetailDto.fromJson(json);
}

/// @nodoc
mixin _$CourseDetailDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'club_name')
  String get clubName => throw _privateConstructorUsedError;
  @JsonKey(name: 'course_name')
  String get courseName => throw _privateConstructorUsedError;
  @JsonKey(name: 'course_rating')
  double? get courseRating => throw _privateConstructorUsedError;
  @JsonKey(name: 'slope_rating')
  int? get slopeRating => throw _privateConstructorUsedError;
  int get par => throw _privateConstructorUsedError;
  List<HoleDto> get holes => throw _privateConstructorUsedError;

  /// Serializes this CourseDetailDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CourseDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CourseDetailDtoCopyWith<CourseDetailDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CourseDetailDtoCopyWith<$Res> {
  factory $CourseDetailDtoCopyWith(
          CourseDetailDto value, $Res Function(CourseDetailDto) then) =
      _$CourseDetailDtoCopyWithImpl<$Res, CourseDetailDto>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'club_name') String clubName,
      @JsonKey(name: 'course_name') String courseName,
      @JsonKey(name: 'course_rating') double? courseRating,
      @JsonKey(name: 'slope_rating') int? slopeRating,
      int par,
      List<HoleDto> holes});
}

/// @nodoc
class _$CourseDetailDtoCopyWithImpl<$Res, $Val extends CourseDetailDto>
    implements $CourseDetailDtoCopyWith<$Res> {
  _$CourseDetailDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CourseDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? clubName = null,
    Object? courseName = null,
    Object? courseRating = freezed,
    Object? slopeRating = freezed,
    Object? par = null,
    Object? holes = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      clubName: null == clubName
          ? _value.clubName
          : clubName // ignore: cast_nullable_to_non_nullable
              as String,
      courseName: null == courseName
          ? _value.courseName
          : courseName // ignore: cast_nullable_to_non_nullable
              as String,
      courseRating: freezed == courseRating
          ? _value.courseRating
          : courseRating // ignore: cast_nullable_to_non_nullable
              as double?,
      slopeRating: freezed == slopeRating
          ? _value.slopeRating
          : slopeRating // ignore: cast_nullable_to_non_nullable
              as int?,
      par: null == par
          ? _value.par
          : par // ignore: cast_nullable_to_non_nullable
              as int,
      holes: null == holes
          ? _value.holes
          : holes // ignore: cast_nullable_to_non_nullable
              as List<HoleDto>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CourseDetailDtoImplCopyWith<$Res>
    implements $CourseDetailDtoCopyWith<$Res> {
  factory _$$CourseDetailDtoImplCopyWith(_$CourseDetailDtoImpl value,
          $Res Function(_$CourseDetailDtoImpl) then) =
      __$$CourseDetailDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'club_name') String clubName,
      @JsonKey(name: 'course_name') String courseName,
      @JsonKey(name: 'course_rating') double? courseRating,
      @JsonKey(name: 'slope_rating') int? slopeRating,
      int par,
      List<HoleDto> holes});
}

/// @nodoc
class __$$CourseDetailDtoImplCopyWithImpl<$Res>
    extends _$CourseDetailDtoCopyWithImpl<$Res, _$CourseDetailDtoImpl>
    implements _$$CourseDetailDtoImplCopyWith<$Res> {
  __$$CourseDetailDtoImplCopyWithImpl(
      _$CourseDetailDtoImpl _value, $Res Function(_$CourseDetailDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of CourseDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? clubName = null,
    Object? courseName = null,
    Object? courseRating = freezed,
    Object? slopeRating = freezed,
    Object? par = null,
    Object? holes = null,
  }) {
    return _then(_$CourseDetailDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      clubName: null == clubName
          ? _value.clubName
          : clubName // ignore: cast_nullable_to_non_nullable
              as String,
      courseName: null == courseName
          ? _value.courseName
          : courseName // ignore: cast_nullable_to_non_nullable
              as String,
      courseRating: freezed == courseRating
          ? _value.courseRating
          : courseRating // ignore: cast_nullable_to_non_nullable
              as double?,
      slopeRating: freezed == slopeRating
          ? _value.slopeRating
          : slopeRating // ignore: cast_nullable_to_non_nullable
              as int?,
      par: null == par
          ? _value.par
          : par // ignore: cast_nullable_to_non_nullable
              as int,
      holes: null == holes
          ? _value._holes
          : holes // ignore: cast_nullable_to_non_nullable
              as List<HoleDto>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CourseDetailDtoImpl implements _CourseDetailDto {
  const _$CourseDetailDtoImpl(
      {required this.id,
      @JsonKey(name: 'club_name') required this.clubName,
      @JsonKey(name: 'course_name') required this.courseName,
      @JsonKey(name: 'course_rating') this.courseRating,
      @JsonKey(name: 'slope_rating') this.slopeRating,
      required this.par,
      required final List<HoleDto> holes})
      : _holes = holes;

  factory _$CourseDetailDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CourseDetailDtoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'club_name')
  final String clubName;
  @override
  @JsonKey(name: 'course_name')
  final String courseName;
  @override
  @JsonKey(name: 'course_rating')
  final double? courseRating;
  @override
  @JsonKey(name: 'slope_rating')
  final int? slopeRating;
  @override
  final int par;
  final List<HoleDto> _holes;
  @override
  List<HoleDto> get holes {
    if (_holes is EqualUnmodifiableListView) return _holes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_holes);
  }

  @override
  String toString() {
    return 'CourseDetailDto(id: $id, clubName: $clubName, courseName: $courseName, courseRating: $courseRating, slopeRating: $slopeRating, par: $par, holes: $holes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CourseDetailDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.clubName, clubName) ||
                other.clubName == clubName) &&
            (identical(other.courseName, courseName) ||
                other.courseName == courseName) &&
            (identical(other.courseRating, courseRating) ||
                other.courseRating == courseRating) &&
            (identical(other.slopeRating, slopeRating) ||
                other.slopeRating == slopeRating) &&
            (identical(other.par, par) || other.par == par) &&
            const DeepCollectionEquality().equals(other._holes, _holes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      clubName,
      courseName,
      courseRating,
      slopeRating,
      par,
      const DeepCollectionEquality().hash(_holes));

  /// Create a copy of CourseDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CourseDetailDtoImplCopyWith<_$CourseDetailDtoImpl> get copyWith =>
      __$$CourseDetailDtoImplCopyWithImpl<_$CourseDetailDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CourseDetailDtoImplToJson(
      this,
    );
  }
}

abstract class _CourseDetailDto implements CourseDetailDto {
  const factory _CourseDetailDto(
      {required final String id,
      @JsonKey(name: 'club_name') required final String clubName,
      @JsonKey(name: 'course_name') required final String courseName,
      @JsonKey(name: 'course_rating') final double? courseRating,
      @JsonKey(name: 'slope_rating') final int? slopeRating,
      required final int par,
      required final List<HoleDto> holes}) = _$CourseDetailDtoImpl;

  factory _CourseDetailDto.fromJson(Map<String, dynamic> json) =
      _$CourseDetailDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'club_name')
  String get clubName;
  @override
  @JsonKey(name: 'course_name')
  String get courseName;
  @override
  @JsonKey(name: 'course_rating')
  double? get courseRating;
  @override
  @JsonKey(name: 'slope_rating')
  int? get slopeRating;
  @override
  int get par;
  @override
  List<HoleDto> get holes;

  /// Create a copy of CourseDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CourseDetailDtoImplCopyWith<_$CourseDetailDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HoleDto _$HoleDtoFromJson(Map<String, dynamic> json) {
  return _HoleDto.fromJson(json);
}

/// @nodoc
mixin _$HoleDto {
  @JsonKey(name: 'hole_number')
  int get holeNumber => throw _privateConstructorUsedError;
  int get par => throw _privateConstructorUsedError;
  @JsonKey(name: 'stroke_index')
  int? get strokeIndex => throw _privateConstructorUsedError;
  @JsonKey(name: 'tee_lat')
  double? get teeLat => throw _privateConstructorUsedError;
  @JsonKey(name: 'tee_lng')
  double? get teeLng => throw _privateConstructorUsedError;
  @JsonKey(name: 'green_lat')
  double? get greenLat => throw _privateConstructorUsedError;
  @JsonKey(name: 'green_lng')
  double? get greenLng => throw _privateConstructorUsedError;

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
  $Res call(
      {@JsonKey(name: 'hole_number') int holeNumber,
      int par,
      @JsonKey(name: 'stroke_index') int? strokeIndex,
      @JsonKey(name: 'tee_lat') double? teeLat,
      @JsonKey(name: 'tee_lng') double? teeLng,
      @JsonKey(name: 'green_lat') double? greenLat,
      @JsonKey(name: 'green_lng') double? greenLng});
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
abstract class _$$HoleDtoImplCopyWith<$Res> implements $HoleDtoCopyWith<$Res> {
  factory _$$HoleDtoImplCopyWith(
          _$HoleDtoImpl value, $Res Function(_$HoleDtoImpl) then) =
      __$$HoleDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'hole_number') int holeNumber,
      int par,
      @JsonKey(name: 'stroke_index') int? strokeIndex,
      @JsonKey(name: 'tee_lat') double? teeLat,
      @JsonKey(name: 'tee_lng') double? teeLng,
      @JsonKey(name: 'green_lat') double? greenLat,
      @JsonKey(name: 'green_lng') double? greenLng});
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
    Object? holeNumber = null,
    Object? par = null,
    Object? strokeIndex = freezed,
    Object? teeLat = freezed,
    Object? teeLng = freezed,
    Object? greenLat = freezed,
    Object? greenLng = freezed,
  }) {
    return _then(_$HoleDtoImpl(
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
class _$HoleDtoImpl implements _HoleDto {
  const _$HoleDtoImpl(
      {@JsonKey(name: 'hole_number') required this.holeNumber,
      required this.par,
      @JsonKey(name: 'stroke_index') this.strokeIndex,
      @JsonKey(name: 'tee_lat') this.teeLat,
      @JsonKey(name: 'tee_lng') this.teeLng,
      @JsonKey(name: 'green_lat') this.greenLat,
      @JsonKey(name: 'green_lng') this.greenLng});

  factory _$HoleDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$HoleDtoImplFromJson(json);

  @override
  @JsonKey(name: 'hole_number')
  final int holeNumber;
  @override
  final int par;
  @override
  @JsonKey(name: 'stroke_index')
  final int? strokeIndex;
  @override
  @JsonKey(name: 'tee_lat')
  final double? teeLat;
  @override
  @JsonKey(name: 'tee_lng')
  final double? teeLng;
  @override
  @JsonKey(name: 'green_lat')
  final double? greenLat;
  @override
  @JsonKey(name: 'green_lng')
  final double? greenLng;

  @override
  String toString() {
    return 'HoleDto(holeNumber: $holeNumber, par: $par, strokeIndex: $strokeIndex, teeLat: $teeLat, teeLng: $teeLng, greenLat: $greenLat, greenLng: $greenLng)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HoleDtoImpl &&
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
      {@JsonKey(name: 'hole_number') required final int holeNumber,
      required final int par,
      @JsonKey(name: 'stroke_index') final int? strokeIndex,
      @JsonKey(name: 'tee_lat') final double? teeLat,
      @JsonKey(name: 'tee_lng') final double? teeLng,
      @JsonKey(name: 'green_lat') final double? greenLat,
      @JsonKey(name: 'green_lng') final double? greenLng}) = _$HoleDtoImpl;

  factory _HoleDto.fromJson(Map<String, dynamic> json) = _$HoleDtoImpl.fromJson;

  @override
  @JsonKey(name: 'hole_number')
  int get holeNumber;
  @override
  int get par;
  @override
  @JsonKey(name: 'stroke_index')
  int? get strokeIndex;
  @override
  @JsonKey(name: 'tee_lat')
  double? get teeLat;
  @override
  @JsonKey(name: 'tee_lng')
  double? get teeLng;
  @override
  @JsonKey(name: 'green_lat')
  double? get greenLat;
  @override
  @JsonKey(name: 'green_lng')
  double? get greenLng;

  /// Create a copy of HoleDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HoleDtoImplCopyWith<_$HoleDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
