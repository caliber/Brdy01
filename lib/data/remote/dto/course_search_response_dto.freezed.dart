// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'course_search_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CourseSearchResponseDto _$CourseSearchResponseDtoFromJson(
    Map<String, dynamic> json) {
  return _CourseSearchResponseDto.fromJson(json);
}

/// @nodoc
mixin _$CourseSearchResponseDto {
  List<CourseSearchResultDto> get courses => throw _privateConstructorUsedError;

  /// Serializes this CourseSearchResponseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CourseSearchResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CourseSearchResponseDtoCopyWith<CourseSearchResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CourseSearchResponseDtoCopyWith<$Res> {
  factory $CourseSearchResponseDtoCopyWith(CourseSearchResponseDto value,
          $Res Function(CourseSearchResponseDto) then) =
      _$CourseSearchResponseDtoCopyWithImpl<$Res, CourseSearchResponseDto>;
  @useResult
  $Res call({List<CourseSearchResultDto> courses});
}

/// @nodoc
class _$CourseSearchResponseDtoCopyWithImpl<$Res,
        $Val extends CourseSearchResponseDto>
    implements $CourseSearchResponseDtoCopyWith<$Res> {
  _$CourseSearchResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CourseSearchResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? courses = null,
  }) {
    return _then(_value.copyWith(
      courses: null == courses
          ? _value.courses
          : courses // ignore: cast_nullable_to_non_nullable
              as List<CourseSearchResultDto>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CourseSearchResponseDtoImplCopyWith<$Res>
    implements $CourseSearchResponseDtoCopyWith<$Res> {
  factory _$$CourseSearchResponseDtoImplCopyWith(
          _$CourseSearchResponseDtoImpl value,
          $Res Function(_$CourseSearchResponseDtoImpl) then) =
      __$$CourseSearchResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<CourseSearchResultDto> courses});
}

/// @nodoc
class __$$CourseSearchResponseDtoImplCopyWithImpl<$Res>
    extends _$CourseSearchResponseDtoCopyWithImpl<$Res,
        _$CourseSearchResponseDtoImpl>
    implements _$$CourseSearchResponseDtoImplCopyWith<$Res> {
  __$$CourseSearchResponseDtoImplCopyWithImpl(
      _$CourseSearchResponseDtoImpl _value,
      $Res Function(_$CourseSearchResponseDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of CourseSearchResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? courses = null,
  }) {
    return _then(_$CourseSearchResponseDtoImpl(
      courses: null == courses
          ? _value._courses
          : courses // ignore: cast_nullable_to_non_nullable
              as List<CourseSearchResultDto>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CourseSearchResponseDtoImpl implements _CourseSearchResponseDto {
  const _$CourseSearchResponseDtoImpl(
      {required final List<CourseSearchResultDto> courses})
      : _courses = courses;

  factory _$CourseSearchResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CourseSearchResponseDtoImplFromJson(json);

  final List<CourseSearchResultDto> _courses;
  @override
  List<CourseSearchResultDto> get courses {
    if (_courses is EqualUnmodifiableListView) return _courses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_courses);
  }

  @override
  String toString() {
    return 'CourseSearchResponseDto(courses: $courses)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CourseSearchResponseDtoImpl &&
            const DeepCollectionEquality().equals(other._courses, _courses));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_courses));

  /// Create a copy of CourseSearchResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CourseSearchResponseDtoImplCopyWith<_$CourseSearchResponseDtoImpl>
      get copyWith => __$$CourseSearchResponseDtoImplCopyWithImpl<
          _$CourseSearchResponseDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CourseSearchResponseDtoImplToJson(
      this,
    );
  }
}

abstract class _CourseSearchResponseDto implements CourseSearchResponseDto {
  const factory _CourseSearchResponseDto(
          {required final List<CourseSearchResultDto> courses}) =
      _$CourseSearchResponseDtoImpl;

  factory _CourseSearchResponseDto.fromJson(Map<String, dynamic> json) =
      _$CourseSearchResponseDtoImpl.fromJson;

  @override
  List<CourseSearchResultDto> get courses;

  /// Create a copy of CourseSearchResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CourseSearchResponseDtoImplCopyWith<_$CourseSearchResponseDtoImpl>
      get copyWith => throw _privateConstructorUsedError;
}

CourseSearchResultDto _$CourseSearchResultDtoFromJson(
    Map<String, dynamic> json) {
  return _CourseSearchResultDto.fromJson(json);
}

/// @nodoc
mixin _$CourseSearchResultDto {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'club_name')
  String get clubName => throw _privateConstructorUsedError;
  @JsonKey(name: 'course_name')
  String get courseName => throw _privateConstructorUsedError;
  TeesDto get tees => throw _privateConstructorUsedError;
  LocationDto? get location => throw _privateConstructorUsedError;

  /// Serializes this CourseSearchResultDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CourseSearchResultDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CourseSearchResultDtoCopyWith<CourseSearchResultDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CourseSearchResultDtoCopyWith<$Res> {
  factory $CourseSearchResultDtoCopyWith(CourseSearchResultDto value,
          $Res Function(CourseSearchResultDto) then) =
      _$CourseSearchResultDtoCopyWithImpl<$Res, CourseSearchResultDto>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'club_name') String clubName,
      @JsonKey(name: 'course_name') String courseName,
      TeesDto tees,
      LocationDto? location});

  $TeesDtoCopyWith<$Res> get tees;
  $LocationDtoCopyWith<$Res>? get location;
}

/// @nodoc
class _$CourseSearchResultDtoCopyWithImpl<$Res,
        $Val extends CourseSearchResultDto>
    implements $CourseSearchResultDtoCopyWith<$Res> {
  _$CourseSearchResultDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CourseSearchResultDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? clubName = null,
    Object? courseName = null,
    Object? tees = null,
    Object? location = freezed,
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
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as LocationDto?,
    ) as $Val);
  }

  /// Create a copy of CourseSearchResultDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeesDtoCopyWith<$Res> get tees {
    return $TeesDtoCopyWith<$Res>(_value.tees, (value) {
      return _then(_value.copyWith(tees: value) as $Val);
    });
  }

  /// Create a copy of CourseSearchResultDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationDtoCopyWith<$Res>? get location {
    if (_value.location == null) {
      return null;
    }

    return $LocationDtoCopyWith<$Res>(_value.location!, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CourseSearchResultDtoImplCopyWith<$Res>
    implements $CourseSearchResultDtoCopyWith<$Res> {
  factory _$$CourseSearchResultDtoImplCopyWith(
          _$CourseSearchResultDtoImpl value,
          $Res Function(_$CourseSearchResultDtoImpl) then) =
      __$$CourseSearchResultDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'club_name') String clubName,
      @JsonKey(name: 'course_name') String courseName,
      TeesDto tees,
      LocationDto? location});

  @override
  $TeesDtoCopyWith<$Res> get tees;
  @override
  $LocationDtoCopyWith<$Res>? get location;
}

/// @nodoc
class __$$CourseSearchResultDtoImplCopyWithImpl<$Res>
    extends _$CourseSearchResultDtoCopyWithImpl<$Res,
        _$CourseSearchResultDtoImpl>
    implements _$$CourseSearchResultDtoImplCopyWith<$Res> {
  __$$CourseSearchResultDtoImplCopyWithImpl(_$CourseSearchResultDtoImpl _value,
      $Res Function(_$CourseSearchResultDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of CourseSearchResultDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? clubName = null,
    Object? courseName = null,
    Object? tees = null,
    Object? location = freezed,
  }) {
    return _then(_$CourseSearchResultDtoImpl(
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
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as LocationDto?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CourseSearchResultDtoImpl implements _CourseSearchResultDto {
  const _$CourseSearchResultDtoImpl(
      {required this.id,
      @JsonKey(name: 'club_name') required this.clubName,
      @JsonKey(name: 'course_name') required this.courseName,
      required this.tees,
      this.location});

  factory _$CourseSearchResultDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CourseSearchResultDtoImplFromJson(json);

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
  final LocationDto? location;

  @override
  String toString() {
    return 'CourseSearchResultDto(id: $id, clubName: $clubName, courseName: $courseName, tees: $tees, location: $location)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CourseSearchResultDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.clubName, clubName) ||
                other.clubName == clubName) &&
            (identical(other.courseName, courseName) ||
                other.courseName == courseName) &&
            (identical(other.tees, tees) || other.tees == tees) &&
            (identical(other.location, location) ||
                other.location == location));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, clubName, courseName, tees, location);

  /// Create a copy of CourseSearchResultDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CourseSearchResultDtoImplCopyWith<_$CourseSearchResultDtoImpl>
      get copyWith => __$$CourseSearchResultDtoImplCopyWithImpl<
          _$CourseSearchResultDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CourseSearchResultDtoImplToJson(
      this,
    );
  }
}

abstract class _CourseSearchResultDto implements CourseSearchResultDto {
  const factory _CourseSearchResultDto(
      {required final int id,
      @JsonKey(name: 'club_name') required final String clubName,
      @JsonKey(name: 'course_name') required final String courseName,
      required final TeesDto tees,
      final LocationDto? location}) = _$CourseSearchResultDtoImpl;

  factory _CourseSearchResultDto.fromJson(Map<String, dynamic> json) =
      _$CourseSearchResultDtoImpl.fromJson;

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
  @override
  LocationDto? get location;

  /// Create a copy of CourseSearchResultDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CourseSearchResultDtoImplCopyWith<_$CourseSearchResultDtoImpl>
      get copyWith => throw _privateConstructorUsedError;
}

LocationDto _$LocationDtoFromJson(Map<String, dynamic> json) {
  return _LocationDto.fromJson(json);
}

/// @nodoc
mixin _$LocationDto {
  String? get city => throw _privateConstructorUsedError;
  String? get country => throw _privateConstructorUsedError;

  /// Serializes this LocationDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LocationDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocationDtoCopyWith<LocationDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocationDtoCopyWith<$Res> {
  factory $LocationDtoCopyWith(
          LocationDto value, $Res Function(LocationDto) then) =
      _$LocationDtoCopyWithImpl<$Res, LocationDto>;
  @useResult
  $Res call({String? city, String? country});
}

/// @nodoc
class _$LocationDtoCopyWithImpl<$Res, $Val extends LocationDto>
    implements $LocationDtoCopyWith<$Res> {
  _$LocationDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocationDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? city = freezed,
    Object? country = freezed,
  }) {
    return _then(_value.copyWith(
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      country: freezed == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LocationDtoImplCopyWith<$Res>
    implements $LocationDtoCopyWith<$Res> {
  factory _$$LocationDtoImplCopyWith(
          _$LocationDtoImpl value, $Res Function(_$LocationDtoImpl) then) =
      __$$LocationDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? city, String? country});
}

/// @nodoc
class __$$LocationDtoImplCopyWithImpl<$Res>
    extends _$LocationDtoCopyWithImpl<$Res, _$LocationDtoImpl>
    implements _$$LocationDtoImplCopyWith<$Res> {
  __$$LocationDtoImplCopyWithImpl(
      _$LocationDtoImpl _value, $Res Function(_$LocationDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of LocationDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? city = freezed,
    Object? country = freezed,
  }) {
    return _then(_$LocationDtoImpl(
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      country: freezed == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LocationDtoImpl implements _LocationDto {
  const _$LocationDtoImpl({this.city, this.country});

  factory _$LocationDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocationDtoImplFromJson(json);

  @override
  final String? city;
  @override
  final String? country;

  @override
  String toString() {
    return 'LocationDto(city: $city, country: $country)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocationDtoImpl &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.country, country) || other.country == country));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, city, country);

  /// Create a copy of LocationDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocationDtoImplCopyWith<_$LocationDtoImpl> get copyWith =>
      __$$LocationDtoImplCopyWithImpl<_$LocationDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocationDtoImplToJson(
      this,
    );
  }
}

abstract class _LocationDto implements LocationDto {
  const factory _LocationDto({final String? city, final String? country}) =
      _$LocationDtoImpl;

  factory _LocationDto.fromJson(Map<String, dynamic> json) =
      _$LocationDtoImpl.fromJson;

  @override
  String? get city;
  @override
  String? get country;

  /// Create a copy of LocationDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocationDtoImplCopyWith<_$LocationDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
