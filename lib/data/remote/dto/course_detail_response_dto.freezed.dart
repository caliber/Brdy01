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
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'club_name')
  String get clubName => throw _privateConstructorUsedError;
  @JsonKey(name: 'course_name')
  String get courseName => throw _privateConstructorUsedError;
  TeesDto get tees => throw _privateConstructorUsedError;

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
      {int id,
      @JsonKey(name: 'club_name') String clubName,
      @JsonKey(name: 'course_name') String courseName,
      TeesDto tees});

  $TeesDtoCopyWith<$Res> get tees;
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
    Object? tees = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      clubName: null == clubName
          ? _value.clubName
          : clubName // ignore: cast_nullable_to_non_nullable
              as String,
      courseName: null == courseName
          ? _value.courseName
          : courseName // ignore: cast_nullable_to_non_nullable
              as String,
      tees: null == tees
          ? _value.tees
          : tees // ignore: cast_nullable_to_non_nullable
              as TeesDto,
    ) as $Val);
  }

  /// Create a copy of CourseDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeesDtoCopyWith<$Res> get tees {
    return $TeesDtoCopyWith<$Res>(_value.tees, (value) {
      return _then(_value.copyWith(tees: value) as $Val);
    });
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
      {int id,
      @JsonKey(name: 'club_name') String clubName,
      @JsonKey(name: 'course_name') String courseName,
      TeesDto tees});

  @override
  $TeesDtoCopyWith<$Res> get tees;
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
    Object? tees = null,
  }) {
    return _then(_$CourseDetailDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      clubName: null == clubName
          ? _value.clubName
          : clubName // ignore: cast_nullable_to_non_nullable
              as String,
      courseName: null == courseName
          ? _value.courseName
          : courseName // ignore: cast_nullable_to_non_nullable
              as String,
      tees: null == tees
          ? _value.tees
          : tees // ignore: cast_nullable_to_non_nullable
              as TeesDto,
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
      required this.tees});

  factory _$CourseDetailDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CourseDetailDtoImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'club_name')
  final String clubName;
  @override
  @JsonKey(name: 'course_name')
  final String courseName;
  @override
  final TeesDto tees;

  @override
  String toString() {
    return 'CourseDetailDto(id: $id, clubName: $clubName, courseName: $courseName, tees: $tees)';
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
            (identical(other.tees, tees) || other.tees == tees));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, clubName, courseName, tees);

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
      {required final int id,
      @JsonKey(name: 'club_name') required final String clubName,
      @JsonKey(name: 'course_name') required final String courseName,
      required final TeesDto tees}) = _$CourseDetailDtoImpl;

  factory _CourseDetailDto.fromJson(Map<String, dynamic> json) =
      _$CourseDetailDtoImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'club_name')
  String get clubName;
  @override
  @JsonKey(name: 'course_name')
  String get courseName;
  @override
  TeesDto get tees;

  /// Create a copy of CourseDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CourseDetailDtoImplCopyWith<_$CourseDetailDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
