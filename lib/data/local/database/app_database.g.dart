// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RoundsTable extends Rounds with TableInfo<$RoundsTable, Round> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoundsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _courseNameMeta =
      const VerificationMeta('courseName');
  @override
  late final GeneratedColumn<String> courseName = GeneratedColumn<String>(
      'course_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _courseRatingMeta =
      const VerificationMeta('courseRating');
  @override
  late final GeneratedColumn<double> courseRating = GeneratedColumn<double>(
      'course_rating', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _courseSlopeMeta =
      const VerificationMeta('courseSlope');
  @override
  late final GeneratedColumn<int> courseSlope = GeneratedColumn<int>(
      'course_slope', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _handicapIndexMeta =
      const VerificationMeta('handicapIndex');
  @override
  late final GeneratedColumn<double> handicapIndex = GeneratedColumn<double>(
      'handicap_index', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _courseJsonMeta =
      const VerificationMeta('courseJson');
  @override
  late final GeneratedColumn<String> courseJson = GeneratedColumn<String>(
      'course_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        courseName,
        courseRating,
        courseSlope,
        handicapIndex,
        courseJson,
        startedAt,
        completedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rounds';
  @override
  VerificationContext validateIntegrity(Insertable<Round> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('course_name')) {
      context.handle(
          _courseNameMeta,
          courseName.isAcceptableOrUnknown(
              data['course_name']!, _courseNameMeta));
    } else if (isInserting) {
      context.missing(_courseNameMeta);
    }
    if (data.containsKey('course_rating')) {
      context.handle(
          _courseRatingMeta,
          courseRating.isAcceptableOrUnknown(
              data['course_rating']!, _courseRatingMeta));
    }
    if (data.containsKey('course_slope')) {
      context.handle(
          _courseSlopeMeta,
          courseSlope.isAcceptableOrUnknown(
              data['course_slope']!, _courseSlopeMeta));
    }
    if (data.containsKey('handicap_index')) {
      context.handle(
          _handicapIndexMeta,
          handicapIndex.isAcceptableOrUnknown(
              data['handicap_index']!, _handicapIndexMeta));
    } else if (isInserting) {
      context.missing(_handicapIndexMeta);
    }
    if (data.containsKey('course_json')) {
      context.handle(
          _courseJsonMeta,
          courseJson.isAcceptableOrUnknown(
              data['course_json']!, _courseJsonMeta));
    } else if (isInserting) {
      context.missing(_courseJsonMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Round map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Round(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      courseName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}course_name'])!,
      courseRating: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}course_rating']),
      courseSlope: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}course_slope']),
      handicapIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}handicap_index'])!,
      courseJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}course_json'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
    );
  }

  @override
  $RoundsTable createAlias(String alias) {
    return $RoundsTable(attachedDatabase, alias);
  }
}

class Round extends DataClass implements Insertable<Round> {
  final int id;
  final String courseName;
  final double? courseRating;
  final int? courseSlope;
  final double handicapIndex;
  final String courseJson;
  final DateTime startedAt;
  final DateTime? completedAt;
  const Round(
      {required this.id,
      required this.courseName,
      this.courseRating,
      this.courseSlope,
      required this.handicapIndex,
      required this.courseJson,
      required this.startedAt,
      this.completedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['course_name'] = Variable<String>(courseName);
    if (!nullToAbsent || courseRating != null) {
      map['course_rating'] = Variable<double>(courseRating);
    }
    if (!nullToAbsent || courseSlope != null) {
      map['course_slope'] = Variable<int>(courseSlope);
    }
    map['handicap_index'] = Variable<double>(handicapIndex);
    map['course_json'] = Variable<String>(courseJson);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  RoundsCompanion toCompanion(bool nullToAbsent) {
    return RoundsCompanion(
      id: Value(id),
      courseName: Value(courseName),
      courseRating: courseRating == null && nullToAbsent
          ? const Value.absent()
          : Value(courseRating),
      courseSlope: courseSlope == null && nullToAbsent
          ? const Value.absent()
          : Value(courseSlope),
      handicapIndex: Value(handicapIndex),
      courseJson: Value(courseJson),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory Round.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Round(
      id: serializer.fromJson<int>(json['id']),
      courseName: serializer.fromJson<String>(json['courseName']),
      courseRating: serializer.fromJson<double?>(json['courseRating']),
      courseSlope: serializer.fromJson<int?>(json['courseSlope']),
      handicapIndex: serializer.fromJson<double>(json['handicapIndex']),
      courseJson: serializer.fromJson<String>(json['courseJson']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'courseName': serializer.toJson<String>(courseName),
      'courseRating': serializer.toJson<double?>(courseRating),
      'courseSlope': serializer.toJson<int?>(courseSlope),
      'handicapIndex': serializer.toJson<double>(handicapIndex),
      'courseJson': serializer.toJson<String>(courseJson),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  Round copyWith(
          {int? id,
          String? courseName,
          Value<double?> courseRating = const Value.absent(),
          Value<int?> courseSlope = const Value.absent(),
          double? handicapIndex,
          String? courseJson,
          DateTime? startedAt,
          Value<DateTime?> completedAt = const Value.absent()}) =>
      Round(
        id: id ?? this.id,
        courseName: courseName ?? this.courseName,
        courseRating:
            courseRating.present ? courseRating.value : this.courseRating,
        courseSlope: courseSlope.present ? courseSlope.value : this.courseSlope,
        handicapIndex: handicapIndex ?? this.handicapIndex,
        courseJson: courseJson ?? this.courseJson,
        startedAt: startedAt ?? this.startedAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
      );
  Round copyWithCompanion(RoundsCompanion data) {
    return Round(
      id: data.id.present ? data.id.value : this.id,
      courseName:
          data.courseName.present ? data.courseName.value : this.courseName,
      courseRating: data.courseRating.present
          ? data.courseRating.value
          : this.courseRating,
      courseSlope:
          data.courseSlope.present ? data.courseSlope.value : this.courseSlope,
      handicapIndex: data.handicapIndex.present
          ? data.handicapIndex.value
          : this.handicapIndex,
      courseJson:
          data.courseJson.present ? data.courseJson.value : this.courseJson,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Round(')
          ..write('id: $id, ')
          ..write('courseName: $courseName, ')
          ..write('courseRating: $courseRating, ')
          ..write('courseSlope: $courseSlope, ')
          ..write('handicapIndex: $handicapIndex, ')
          ..write('courseJson: $courseJson, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, courseName, courseRating, courseSlope,
      handicapIndex, courseJson, startedAt, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Round &&
          other.id == this.id &&
          other.courseName == this.courseName &&
          other.courseRating == this.courseRating &&
          other.courseSlope == this.courseSlope &&
          other.handicapIndex == this.handicapIndex &&
          other.courseJson == this.courseJson &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt);
}

class RoundsCompanion extends UpdateCompanion<Round> {
  final Value<int> id;
  final Value<String> courseName;
  final Value<double?> courseRating;
  final Value<int?> courseSlope;
  final Value<double> handicapIndex;
  final Value<String> courseJson;
  final Value<DateTime> startedAt;
  final Value<DateTime?> completedAt;
  const RoundsCompanion({
    this.id = const Value.absent(),
    this.courseName = const Value.absent(),
    this.courseRating = const Value.absent(),
    this.courseSlope = const Value.absent(),
    this.handicapIndex = const Value.absent(),
    this.courseJson = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  RoundsCompanion.insert({
    this.id = const Value.absent(),
    required String courseName,
    this.courseRating = const Value.absent(),
    this.courseSlope = const Value.absent(),
    required double handicapIndex,
    required String courseJson,
    required DateTime startedAt,
    this.completedAt = const Value.absent(),
  })  : courseName = Value(courseName),
        handicapIndex = Value(handicapIndex),
        courseJson = Value(courseJson),
        startedAt = Value(startedAt);
  static Insertable<Round> custom({
    Expression<int>? id,
    Expression<String>? courseName,
    Expression<double>? courseRating,
    Expression<int>? courseSlope,
    Expression<double>? handicapIndex,
    Expression<String>? courseJson,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (courseName != null) 'course_name': courseName,
      if (courseRating != null) 'course_rating': courseRating,
      if (courseSlope != null) 'course_slope': courseSlope,
      if (handicapIndex != null) 'handicap_index': handicapIndex,
      if (courseJson != null) 'course_json': courseJson,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  RoundsCompanion copyWith(
      {Value<int>? id,
      Value<String>? courseName,
      Value<double?>? courseRating,
      Value<int?>? courseSlope,
      Value<double>? handicapIndex,
      Value<String>? courseJson,
      Value<DateTime>? startedAt,
      Value<DateTime?>? completedAt}) {
    return RoundsCompanion(
      id: id ?? this.id,
      courseName: courseName ?? this.courseName,
      courseRating: courseRating ?? this.courseRating,
      courseSlope: courseSlope ?? this.courseSlope,
      handicapIndex: handicapIndex ?? this.handicapIndex,
      courseJson: courseJson ?? this.courseJson,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (courseName.present) {
      map['course_name'] = Variable<String>(courseName.value);
    }
    if (courseRating.present) {
      map['course_rating'] = Variable<double>(courseRating.value);
    }
    if (courseSlope.present) {
      map['course_slope'] = Variable<int>(courseSlope.value);
    }
    if (handicapIndex.present) {
      map['handicap_index'] = Variable<double>(handicapIndex.value);
    }
    if (courseJson.present) {
      map['course_json'] = Variable<String>(courseJson.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoundsCompanion(')
          ..write('id: $id, ')
          ..write('courseName: $courseName, ')
          ..write('courseRating: $courseRating, ')
          ..write('courseSlope: $courseSlope, ')
          ..write('handicapIndex: $handicapIndex, ')
          ..write('courseJson: $courseJson, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

class $HolesTable extends Holes with TableInfo<$HolesTable, Hole> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HolesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _roundIdMeta =
      const VerificationMeta('roundId');
  @override
  late final GeneratedColumn<int> roundId = GeneratedColumn<int>(
      'round_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES rounds (id) ON DELETE CASCADE'));
  static const VerificationMeta _holeNumberMeta =
      const VerificationMeta('holeNumber');
  @override
  late final GeneratedColumn<int> holeNumber = GeneratedColumn<int>(
      'hole_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _parMeta = const VerificationMeta('par');
  @override
  late final GeneratedColumn<int> par = GeneratedColumn<int>(
      'par', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _strokeIndexMeta =
      const VerificationMeta('strokeIndex');
  @override
  late final GeneratedColumn<int> strokeIndex = GeneratedColumn<int>(
      'stroke_index', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _outcomeMeta =
      const VerificationMeta('outcome');
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
      'outcome', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _puttsMeta = const VerificationMeta('putts');
  @override
  late final GeneratedColumn<int> putts = GeneratedColumn<int>(
      'putts', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _fairwayHitMeta =
      const VerificationMeta('fairwayHit');
  @override
  late final GeneratedColumn<bool> fairwayHit = GeneratedColumn<bool>(
      'fairway_hit', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("fairway_hit" IN (0, 1))'));
  static const VerificationMeta _greenInRegulationMeta =
      const VerificationMeta('greenInRegulation');
  @override
  late final GeneratedColumn<bool> greenInRegulation = GeneratedColumn<bool>(
      'green_in_regulation', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("green_in_regulation" IN (0, 1))'));
  static const VerificationMeta _recordedAtMeta =
      const VerificationMeta('recordedAt');
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
      'recorded_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        roundId,
        holeNumber,
        par,
        strokeIndex,
        outcome,
        putts,
        fairwayHit,
        greenInRegulation,
        recordedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'holes';
  @override
  VerificationContext validateIntegrity(Insertable<Hole> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('round_id')) {
      context.handle(_roundIdMeta,
          roundId.isAcceptableOrUnknown(data['round_id']!, _roundIdMeta));
    } else if (isInserting) {
      context.missing(_roundIdMeta);
    }
    if (data.containsKey('hole_number')) {
      context.handle(
          _holeNumberMeta,
          holeNumber.isAcceptableOrUnknown(
              data['hole_number']!, _holeNumberMeta));
    } else if (isInserting) {
      context.missing(_holeNumberMeta);
    }
    if (data.containsKey('par')) {
      context.handle(
          _parMeta, par.isAcceptableOrUnknown(data['par']!, _parMeta));
    } else if (isInserting) {
      context.missing(_parMeta);
    }
    if (data.containsKey('stroke_index')) {
      context.handle(
          _strokeIndexMeta,
          strokeIndex.isAcceptableOrUnknown(
              data['stroke_index']!, _strokeIndexMeta));
    }
    if (data.containsKey('outcome')) {
      context.handle(_outcomeMeta,
          outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta));
    }
    if (data.containsKey('putts')) {
      context.handle(
          _puttsMeta, putts.isAcceptableOrUnknown(data['putts']!, _puttsMeta));
    }
    if (data.containsKey('fairway_hit')) {
      context.handle(
          _fairwayHitMeta,
          fairwayHit.isAcceptableOrUnknown(
              data['fairway_hit']!, _fairwayHitMeta));
    }
    if (data.containsKey('green_in_regulation')) {
      context.handle(
          _greenInRegulationMeta,
          greenInRegulation.isAcceptableOrUnknown(
              data['green_in_regulation']!, _greenInRegulationMeta));
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
          _recordedAtMeta,
          recordedAt.isAcceptableOrUnknown(
              data['recorded_at']!, _recordedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Hole map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Hole(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      roundId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}round_id'])!,
      holeNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}hole_number'])!,
      par: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}par'])!,
      strokeIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stroke_index']),
      outcome: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}outcome']),
      putts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}putts']),
      fairwayHit: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}fairway_hit']),
      greenInRegulation: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}green_in_regulation']),
      recordedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}recorded_at']),
    );
  }

  @override
  $HolesTable createAlias(String alias) {
    return $HolesTable(attachedDatabase, alias);
  }
}

class Hole extends DataClass implements Insertable<Hole> {
  final int id;
  final int roundId;
  final int holeNumber;
  final int par;
  final int? strokeIndex;
  final String? outcome;
  final int? putts;
  final bool? fairwayHit;
  final bool? greenInRegulation;
  final DateTime? recordedAt;
  const Hole(
      {required this.id,
      required this.roundId,
      required this.holeNumber,
      required this.par,
      this.strokeIndex,
      this.outcome,
      this.putts,
      this.fairwayHit,
      this.greenInRegulation,
      this.recordedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['round_id'] = Variable<int>(roundId);
    map['hole_number'] = Variable<int>(holeNumber);
    map['par'] = Variable<int>(par);
    if (!nullToAbsent || strokeIndex != null) {
      map['stroke_index'] = Variable<int>(strokeIndex);
    }
    if (!nullToAbsent || outcome != null) {
      map['outcome'] = Variable<String>(outcome);
    }
    if (!nullToAbsent || putts != null) {
      map['putts'] = Variable<int>(putts);
    }
    if (!nullToAbsent || fairwayHit != null) {
      map['fairway_hit'] = Variable<bool>(fairwayHit);
    }
    if (!nullToAbsent || greenInRegulation != null) {
      map['green_in_regulation'] = Variable<bool>(greenInRegulation);
    }
    if (!nullToAbsent || recordedAt != null) {
      map['recorded_at'] = Variable<DateTime>(recordedAt);
    }
    return map;
  }

  HolesCompanion toCompanion(bool nullToAbsent) {
    return HolesCompanion(
      id: Value(id),
      roundId: Value(roundId),
      holeNumber: Value(holeNumber),
      par: Value(par),
      strokeIndex: strokeIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(strokeIndex),
      outcome: outcome == null && nullToAbsent
          ? const Value.absent()
          : Value(outcome),
      putts:
          putts == null && nullToAbsent ? const Value.absent() : Value(putts),
      fairwayHit: fairwayHit == null && nullToAbsent
          ? const Value.absent()
          : Value(fairwayHit),
      greenInRegulation: greenInRegulation == null && nullToAbsent
          ? const Value.absent()
          : Value(greenInRegulation),
      recordedAt: recordedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(recordedAt),
    );
  }

  factory Hole.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Hole(
      id: serializer.fromJson<int>(json['id']),
      roundId: serializer.fromJson<int>(json['roundId']),
      holeNumber: serializer.fromJson<int>(json['holeNumber']),
      par: serializer.fromJson<int>(json['par']),
      strokeIndex: serializer.fromJson<int?>(json['strokeIndex']),
      outcome: serializer.fromJson<String?>(json['outcome']),
      putts: serializer.fromJson<int?>(json['putts']),
      fairwayHit: serializer.fromJson<bool?>(json['fairwayHit']),
      greenInRegulation: serializer.fromJson<bool?>(json['greenInRegulation']),
      recordedAt: serializer.fromJson<DateTime?>(json['recordedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'roundId': serializer.toJson<int>(roundId),
      'holeNumber': serializer.toJson<int>(holeNumber),
      'par': serializer.toJson<int>(par),
      'strokeIndex': serializer.toJson<int?>(strokeIndex),
      'outcome': serializer.toJson<String?>(outcome),
      'putts': serializer.toJson<int?>(putts),
      'fairwayHit': serializer.toJson<bool?>(fairwayHit),
      'greenInRegulation': serializer.toJson<bool?>(greenInRegulation),
      'recordedAt': serializer.toJson<DateTime?>(recordedAt),
    };
  }

  Hole copyWith(
          {int? id,
          int? roundId,
          int? holeNumber,
          int? par,
          Value<int?> strokeIndex = const Value.absent(),
          Value<String?> outcome = const Value.absent(),
          Value<int?> putts = const Value.absent(),
          Value<bool?> fairwayHit = const Value.absent(),
          Value<bool?> greenInRegulation = const Value.absent(),
          Value<DateTime?> recordedAt = const Value.absent()}) =>
      Hole(
        id: id ?? this.id,
        roundId: roundId ?? this.roundId,
        holeNumber: holeNumber ?? this.holeNumber,
        par: par ?? this.par,
        strokeIndex: strokeIndex.present ? strokeIndex.value : this.strokeIndex,
        outcome: outcome.present ? outcome.value : this.outcome,
        putts: putts.present ? putts.value : this.putts,
        fairwayHit: fairwayHit.present ? fairwayHit.value : this.fairwayHit,
        greenInRegulation: greenInRegulation.present
            ? greenInRegulation.value
            : this.greenInRegulation,
        recordedAt: recordedAt.present ? recordedAt.value : this.recordedAt,
      );
  Hole copyWithCompanion(HolesCompanion data) {
    return Hole(
      id: data.id.present ? data.id.value : this.id,
      roundId: data.roundId.present ? data.roundId.value : this.roundId,
      holeNumber:
          data.holeNumber.present ? data.holeNumber.value : this.holeNumber,
      par: data.par.present ? data.par.value : this.par,
      strokeIndex:
          data.strokeIndex.present ? data.strokeIndex.value : this.strokeIndex,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      putts: data.putts.present ? data.putts.value : this.putts,
      fairwayHit:
          data.fairwayHit.present ? data.fairwayHit.value : this.fairwayHit,
      greenInRegulation: data.greenInRegulation.present
          ? data.greenInRegulation.value
          : this.greenInRegulation,
      recordedAt:
          data.recordedAt.present ? data.recordedAt.value : this.recordedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Hole(')
          ..write('id: $id, ')
          ..write('roundId: $roundId, ')
          ..write('holeNumber: $holeNumber, ')
          ..write('par: $par, ')
          ..write('strokeIndex: $strokeIndex, ')
          ..write('outcome: $outcome, ')
          ..write('putts: $putts, ')
          ..write('fairwayHit: $fairwayHit, ')
          ..write('greenInRegulation: $greenInRegulation, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, roundId, holeNumber, par, strokeIndex,
      outcome, putts, fairwayHit, greenInRegulation, recordedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Hole &&
          other.id == this.id &&
          other.roundId == this.roundId &&
          other.holeNumber == this.holeNumber &&
          other.par == this.par &&
          other.strokeIndex == this.strokeIndex &&
          other.outcome == this.outcome &&
          other.putts == this.putts &&
          other.fairwayHit == this.fairwayHit &&
          other.greenInRegulation == this.greenInRegulation &&
          other.recordedAt == this.recordedAt);
}

class HolesCompanion extends UpdateCompanion<Hole> {
  final Value<int> id;
  final Value<int> roundId;
  final Value<int> holeNumber;
  final Value<int> par;
  final Value<int?> strokeIndex;
  final Value<String?> outcome;
  final Value<int?> putts;
  final Value<bool?> fairwayHit;
  final Value<bool?> greenInRegulation;
  final Value<DateTime?> recordedAt;
  const HolesCompanion({
    this.id = const Value.absent(),
    this.roundId = const Value.absent(),
    this.holeNumber = const Value.absent(),
    this.par = const Value.absent(),
    this.strokeIndex = const Value.absent(),
    this.outcome = const Value.absent(),
    this.putts = const Value.absent(),
    this.fairwayHit = const Value.absent(),
    this.greenInRegulation = const Value.absent(),
    this.recordedAt = const Value.absent(),
  });
  HolesCompanion.insert({
    this.id = const Value.absent(),
    required int roundId,
    required int holeNumber,
    required int par,
    this.strokeIndex = const Value.absent(),
    this.outcome = const Value.absent(),
    this.putts = const Value.absent(),
    this.fairwayHit = const Value.absent(),
    this.greenInRegulation = const Value.absent(),
    this.recordedAt = const Value.absent(),
  })  : roundId = Value(roundId),
        holeNumber = Value(holeNumber),
        par = Value(par);
  static Insertable<Hole> custom({
    Expression<int>? id,
    Expression<int>? roundId,
    Expression<int>? holeNumber,
    Expression<int>? par,
    Expression<int>? strokeIndex,
    Expression<String>? outcome,
    Expression<int>? putts,
    Expression<bool>? fairwayHit,
    Expression<bool>? greenInRegulation,
    Expression<DateTime>? recordedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roundId != null) 'round_id': roundId,
      if (holeNumber != null) 'hole_number': holeNumber,
      if (par != null) 'par': par,
      if (strokeIndex != null) 'stroke_index': strokeIndex,
      if (outcome != null) 'outcome': outcome,
      if (putts != null) 'putts': putts,
      if (fairwayHit != null) 'fairway_hit': fairwayHit,
      if (greenInRegulation != null) 'green_in_regulation': greenInRegulation,
      if (recordedAt != null) 'recorded_at': recordedAt,
    });
  }

  HolesCompanion copyWith(
      {Value<int>? id,
      Value<int>? roundId,
      Value<int>? holeNumber,
      Value<int>? par,
      Value<int?>? strokeIndex,
      Value<String?>? outcome,
      Value<int?>? putts,
      Value<bool?>? fairwayHit,
      Value<bool?>? greenInRegulation,
      Value<DateTime?>? recordedAt}) {
    return HolesCompanion(
      id: id ?? this.id,
      roundId: roundId ?? this.roundId,
      holeNumber: holeNumber ?? this.holeNumber,
      par: par ?? this.par,
      strokeIndex: strokeIndex ?? this.strokeIndex,
      outcome: outcome ?? this.outcome,
      putts: putts ?? this.putts,
      fairwayHit: fairwayHit ?? this.fairwayHit,
      greenInRegulation: greenInRegulation ?? this.greenInRegulation,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (roundId.present) {
      map['round_id'] = Variable<int>(roundId.value);
    }
    if (holeNumber.present) {
      map['hole_number'] = Variable<int>(holeNumber.value);
    }
    if (par.present) {
      map['par'] = Variable<int>(par.value);
    }
    if (strokeIndex.present) {
      map['stroke_index'] = Variable<int>(strokeIndex.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (putts.present) {
      map['putts'] = Variable<int>(putts.value);
    }
    if (fairwayHit.present) {
      map['fairway_hit'] = Variable<bool>(fairwayHit.value);
    }
    if (greenInRegulation.present) {
      map['green_in_regulation'] = Variable<bool>(greenInRegulation.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HolesCompanion(')
          ..write('id: $id, ')
          ..write('roundId: $roundId, ')
          ..write('holeNumber: $holeNumber, ')
          ..write('par: $par, ')
          ..write('strokeIndex: $strokeIndex, ')
          ..write('outcome: $outcome, ')
          ..write('putts: $putts, ')
          ..write('fairwayHit: $fairwayHit, ')
          ..write('greenInRegulation: $greenInRegulation, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }
}

class $ShotsTable extends Shots with TableInfo<$ShotsTable, Shot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _holeIdMeta = const VerificationMeta('holeId');
  @override
  late final GeneratedColumn<int> holeId = GeneratedColumn<int>(
      'hole_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES holes (id) ON DELETE CASCADE'));
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _shotNumberMeta =
      const VerificationMeta('shotNumber');
  @override
  late final GeneratedColumn<int> shotNumber = GeneratedColumn<int>(
      'shot_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _recordedAtMeta =
      const VerificationMeta('recordedAt');
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
      'recorded_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, holeId, latitude, longitude, shotNumber, recordedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shots';
  @override
  VerificationContext validateIntegrity(Insertable<Shot> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('hole_id')) {
      context.handle(_holeIdMeta,
          holeId.isAcceptableOrUnknown(data['hole_id']!, _holeIdMeta));
    } else if (isInserting) {
      context.missing(_holeIdMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('shot_number')) {
      context.handle(
          _shotNumberMeta,
          shotNumber.isAcceptableOrUnknown(
              data['shot_number']!, _shotNumberMeta));
    } else if (isInserting) {
      context.missing(_shotNumberMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
          _recordedAtMeta,
          recordedAt.isAcceptableOrUnknown(
              data['recorded_at']!, _recordedAtMeta));
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Shot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Shot(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      holeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}hole_id'])!,
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude'])!,
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude'])!,
      shotNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}shot_number'])!,
      recordedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}recorded_at'])!,
    );
  }

  @override
  $ShotsTable createAlias(String alias) {
    return $ShotsTable(attachedDatabase, alias);
  }
}

class Shot extends DataClass implements Insertable<Shot> {
  final int id;
  final int holeId;
  final double latitude;
  final double longitude;
  final int shotNumber;
  final DateTime recordedAt;
  const Shot(
      {required this.id,
      required this.holeId,
      required this.latitude,
      required this.longitude,
      required this.shotNumber,
      required this.recordedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['hole_id'] = Variable<int>(holeId);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['shot_number'] = Variable<int>(shotNumber);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    return map;
  }

  ShotsCompanion toCompanion(bool nullToAbsent) {
    return ShotsCompanion(
      id: Value(id),
      holeId: Value(holeId),
      latitude: Value(latitude),
      longitude: Value(longitude),
      shotNumber: Value(shotNumber),
      recordedAt: Value(recordedAt),
    );
  }

  factory Shot.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Shot(
      id: serializer.fromJson<int>(json['id']),
      holeId: serializer.fromJson<int>(json['holeId']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      shotNumber: serializer.fromJson<int>(json['shotNumber']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'holeId': serializer.toJson<int>(holeId),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'shotNumber': serializer.toJson<int>(shotNumber),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
    };
  }

  Shot copyWith(
          {int? id,
          int? holeId,
          double? latitude,
          double? longitude,
          int? shotNumber,
          DateTime? recordedAt}) =>
      Shot(
        id: id ?? this.id,
        holeId: holeId ?? this.holeId,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        shotNumber: shotNumber ?? this.shotNumber,
        recordedAt: recordedAt ?? this.recordedAt,
      );
  Shot copyWithCompanion(ShotsCompanion data) {
    return Shot(
      id: data.id.present ? data.id.value : this.id,
      holeId: data.holeId.present ? data.holeId.value : this.holeId,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      shotNumber:
          data.shotNumber.present ? data.shotNumber.value : this.shotNumber,
      recordedAt:
          data.recordedAt.present ? data.recordedAt.value : this.recordedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Shot(')
          ..write('id: $id, ')
          ..write('holeId: $holeId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('shotNumber: $shotNumber, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, holeId, latitude, longitude, shotNumber, recordedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Shot &&
          other.id == this.id &&
          other.holeId == this.holeId &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.shotNumber == this.shotNumber &&
          other.recordedAt == this.recordedAt);
}

class ShotsCompanion extends UpdateCompanion<Shot> {
  final Value<int> id;
  final Value<int> holeId;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<int> shotNumber;
  final Value<DateTime> recordedAt;
  const ShotsCompanion({
    this.id = const Value.absent(),
    this.holeId = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.shotNumber = const Value.absent(),
    this.recordedAt = const Value.absent(),
  });
  ShotsCompanion.insert({
    this.id = const Value.absent(),
    required int holeId,
    required double latitude,
    required double longitude,
    required int shotNumber,
    required DateTime recordedAt,
  })  : holeId = Value(holeId),
        latitude = Value(latitude),
        longitude = Value(longitude),
        shotNumber = Value(shotNumber),
        recordedAt = Value(recordedAt);
  static Insertable<Shot> custom({
    Expression<int>? id,
    Expression<int>? holeId,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<int>? shotNumber,
    Expression<DateTime>? recordedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (holeId != null) 'hole_id': holeId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (shotNumber != null) 'shot_number': shotNumber,
      if (recordedAt != null) 'recorded_at': recordedAt,
    });
  }

  ShotsCompanion copyWith(
      {Value<int>? id,
      Value<int>? holeId,
      Value<double>? latitude,
      Value<double>? longitude,
      Value<int>? shotNumber,
      Value<DateTime>? recordedAt}) {
    return ShotsCompanion(
      id: id ?? this.id,
      holeId: holeId ?? this.holeId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      shotNumber: shotNumber ?? this.shotNumber,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (holeId.present) {
      map['hole_id'] = Variable<int>(holeId.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (shotNumber.present) {
      map['shot_number'] = Variable<int>(shotNumber.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShotsCompanion(')
          ..write('id: $id, ')
          ..write('holeId: $holeId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('shotNumber: $shotNumber, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RoundsTable rounds = $RoundsTable(this);
  late final $HolesTable holes = $HolesTable(this);
  late final $ShotsTable shots = $ShotsTable(this);
  late final RoundDao roundDao = RoundDao(this as AppDatabase);
  late final HoleDao holeDao = HoleDao(this as AppDatabase);
  late final ShotDao shotDao = ShotDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [rounds, holes, shots];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('rounds',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('holes', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('holes',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('shots', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$RoundsTableCreateCompanionBuilder = RoundsCompanion Function({
  Value<int> id,
  required String courseName,
  Value<double?> courseRating,
  Value<int?> courseSlope,
  required double handicapIndex,
  required String courseJson,
  required DateTime startedAt,
  Value<DateTime?> completedAt,
});
typedef $$RoundsTableUpdateCompanionBuilder = RoundsCompanion Function({
  Value<int> id,
  Value<String> courseName,
  Value<double?> courseRating,
  Value<int?> courseSlope,
  Value<double> handicapIndex,
  Value<String> courseJson,
  Value<DateTime> startedAt,
  Value<DateTime?> completedAt,
});

class $$RoundsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RoundsTable,
    Round,
    $$RoundsTableFilterComposer,
    $$RoundsTableOrderingComposer,
    $$RoundsTableCreateCompanionBuilder,
    $$RoundsTableUpdateCompanionBuilder> {
  $$RoundsTableTableManager(_$AppDatabase db, $RoundsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$RoundsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$RoundsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> courseName = const Value.absent(),
            Value<double?> courseRating = const Value.absent(),
            Value<int?> courseSlope = const Value.absent(),
            Value<double> handicapIndex = const Value.absent(),
            Value<String> courseJson = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
          }) =>
              RoundsCompanion(
            id: id,
            courseName: courseName,
            courseRating: courseRating,
            courseSlope: courseSlope,
            handicapIndex: handicapIndex,
            courseJson: courseJson,
            startedAt: startedAt,
            completedAt: completedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String courseName,
            Value<double?> courseRating = const Value.absent(),
            Value<int?> courseSlope = const Value.absent(),
            required double handicapIndex,
            required String courseJson,
            required DateTime startedAt,
            Value<DateTime?> completedAt = const Value.absent(),
          }) =>
              RoundsCompanion.insert(
            id: id,
            courseName: courseName,
            courseRating: courseRating,
            courseSlope: courseSlope,
            handicapIndex: handicapIndex,
            courseJson: courseJson,
            startedAt: startedAt,
            completedAt: completedAt,
          ),
        ));
}

class $$RoundsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $RoundsTable> {
  $$RoundsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get courseName => $state.composableBuilder(
      column: $state.table.courseName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get courseRating => $state.composableBuilder(
      column: $state.table.courseRating,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get courseSlope => $state.composableBuilder(
      column: $state.table.courseSlope,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get handicapIndex => $state.composableBuilder(
      column: $state.table.handicapIndex,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get courseJson => $state.composableBuilder(
      column: $state.table.courseJson,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get startedAt => $state.composableBuilder(
      column: $state.table.startedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get completedAt => $state.composableBuilder(
      column: $state.table.completedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter holesRefs(
      ComposableFilter Function($$HolesTableFilterComposer f) f) {
    final $$HolesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.holes,
        getReferencedColumn: (t) => t.roundId,
        builder: (joinBuilder, parentComposers) => $$HolesTableFilterComposer(
            ComposerState(
                $state.db, $state.db.holes, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$RoundsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $RoundsTable> {
  $$RoundsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get courseName => $state.composableBuilder(
      column: $state.table.courseName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get courseRating => $state.composableBuilder(
      column: $state.table.courseRating,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get courseSlope => $state.composableBuilder(
      column: $state.table.courseSlope,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get handicapIndex => $state.composableBuilder(
      column: $state.table.handicapIndex,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get courseJson => $state.composableBuilder(
      column: $state.table.courseJson,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get startedAt => $state.composableBuilder(
      column: $state.table.startedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get completedAt => $state.composableBuilder(
      column: $state.table.completedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$HolesTableCreateCompanionBuilder = HolesCompanion Function({
  Value<int> id,
  required int roundId,
  required int holeNumber,
  required int par,
  Value<int?> strokeIndex,
  Value<String?> outcome,
  Value<int?> putts,
  Value<bool?> fairwayHit,
  Value<bool?> greenInRegulation,
  Value<DateTime?> recordedAt,
});
typedef $$HolesTableUpdateCompanionBuilder = HolesCompanion Function({
  Value<int> id,
  Value<int> roundId,
  Value<int> holeNumber,
  Value<int> par,
  Value<int?> strokeIndex,
  Value<String?> outcome,
  Value<int?> putts,
  Value<bool?> fairwayHit,
  Value<bool?> greenInRegulation,
  Value<DateTime?> recordedAt,
});

class $$HolesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HolesTable,
    Hole,
    $$HolesTableFilterComposer,
    $$HolesTableOrderingComposer,
    $$HolesTableCreateCompanionBuilder,
    $$HolesTableUpdateCompanionBuilder> {
  $$HolesTableTableManager(_$AppDatabase db, $HolesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$HolesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$HolesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> roundId = const Value.absent(),
            Value<int> holeNumber = const Value.absent(),
            Value<int> par = const Value.absent(),
            Value<int?> strokeIndex = const Value.absent(),
            Value<String?> outcome = const Value.absent(),
            Value<int?> putts = const Value.absent(),
            Value<bool?> fairwayHit = const Value.absent(),
            Value<bool?> greenInRegulation = const Value.absent(),
            Value<DateTime?> recordedAt = const Value.absent(),
          }) =>
              HolesCompanion(
            id: id,
            roundId: roundId,
            holeNumber: holeNumber,
            par: par,
            strokeIndex: strokeIndex,
            outcome: outcome,
            putts: putts,
            fairwayHit: fairwayHit,
            greenInRegulation: greenInRegulation,
            recordedAt: recordedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int roundId,
            required int holeNumber,
            required int par,
            Value<int?> strokeIndex = const Value.absent(),
            Value<String?> outcome = const Value.absent(),
            Value<int?> putts = const Value.absent(),
            Value<bool?> fairwayHit = const Value.absent(),
            Value<bool?> greenInRegulation = const Value.absent(),
            Value<DateTime?> recordedAt = const Value.absent(),
          }) =>
              HolesCompanion.insert(
            id: id,
            roundId: roundId,
            holeNumber: holeNumber,
            par: par,
            strokeIndex: strokeIndex,
            outcome: outcome,
            putts: putts,
            fairwayHit: fairwayHit,
            greenInRegulation: greenInRegulation,
            recordedAt: recordedAt,
          ),
        ));
}

class $$HolesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $HolesTable> {
  $$HolesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get holeNumber => $state.composableBuilder(
      column: $state.table.holeNumber,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get par => $state.composableBuilder(
      column: $state.table.par,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get strokeIndex => $state.composableBuilder(
      column: $state.table.strokeIndex,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get outcome => $state.composableBuilder(
      column: $state.table.outcome,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get putts => $state.composableBuilder(
      column: $state.table.putts,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get fairwayHit => $state.composableBuilder(
      column: $state.table.fairwayHit,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get greenInRegulation => $state.composableBuilder(
      column: $state.table.greenInRegulation,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get recordedAt => $state.composableBuilder(
      column: $state.table.recordedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$RoundsTableFilterComposer get roundId {
    final $$RoundsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.roundId,
        referencedTable: $state.db.rounds,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$RoundsTableFilterComposer(
            ComposerState(
                $state.db, $state.db.rounds, joinBuilder, parentComposers)));
    return composer;
  }

  ComposableFilter shotsRefs(
      ComposableFilter Function($$ShotsTableFilterComposer f) f) {
    final $$ShotsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.shots,
        getReferencedColumn: (t) => t.holeId,
        builder: (joinBuilder, parentComposers) => $$ShotsTableFilterComposer(
            ComposerState(
                $state.db, $state.db.shots, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$HolesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $HolesTable> {
  $$HolesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get holeNumber => $state.composableBuilder(
      column: $state.table.holeNumber,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get par => $state.composableBuilder(
      column: $state.table.par,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get strokeIndex => $state.composableBuilder(
      column: $state.table.strokeIndex,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get outcome => $state.composableBuilder(
      column: $state.table.outcome,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get putts => $state.composableBuilder(
      column: $state.table.putts,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get fairwayHit => $state.composableBuilder(
      column: $state.table.fairwayHit,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get greenInRegulation => $state.composableBuilder(
      column: $state.table.greenInRegulation,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get recordedAt => $state.composableBuilder(
      column: $state.table.recordedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$RoundsTableOrderingComposer get roundId {
    final $$RoundsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.roundId,
        referencedTable: $state.db.rounds,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$RoundsTableOrderingComposer(ComposerState(
                $state.db, $state.db.rounds, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$ShotsTableCreateCompanionBuilder = ShotsCompanion Function({
  Value<int> id,
  required int holeId,
  required double latitude,
  required double longitude,
  required int shotNumber,
  required DateTime recordedAt,
});
typedef $$ShotsTableUpdateCompanionBuilder = ShotsCompanion Function({
  Value<int> id,
  Value<int> holeId,
  Value<double> latitude,
  Value<double> longitude,
  Value<int> shotNumber,
  Value<DateTime> recordedAt,
});

class $$ShotsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ShotsTable,
    Shot,
    $$ShotsTableFilterComposer,
    $$ShotsTableOrderingComposer,
    $$ShotsTableCreateCompanionBuilder,
    $$ShotsTableUpdateCompanionBuilder> {
  $$ShotsTableTableManager(_$AppDatabase db, $ShotsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ShotsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ShotsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> holeId = const Value.absent(),
            Value<double> latitude = const Value.absent(),
            Value<double> longitude = const Value.absent(),
            Value<int> shotNumber = const Value.absent(),
            Value<DateTime> recordedAt = const Value.absent(),
          }) =>
              ShotsCompanion(
            id: id,
            holeId: holeId,
            latitude: latitude,
            longitude: longitude,
            shotNumber: shotNumber,
            recordedAt: recordedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int holeId,
            required double latitude,
            required double longitude,
            required int shotNumber,
            required DateTime recordedAt,
          }) =>
              ShotsCompanion.insert(
            id: id,
            holeId: holeId,
            latitude: latitude,
            longitude: longitude,
            shotNumber: shotNumber,
            recordedAt: recordedAt,
          ),
        ));
}

class $$ShotsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ShotsTable> {
  $$ShotsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get latitude => $state.composableBuilder(
      column: $state.table.latitude,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get longitude => $state.composableBuilder(
      column: $state.table.longitude,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get shotNumber => $state.composableBuilder(
      column: $state.table.shotNumber,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get recordedAt => $state.composableBuilder(
      column: $state.table.recordedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$HolesTableFilterComposer get holeId {
    final $$HolesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.holeId,
        referencedTable: $state.db.holes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$HolesTableFilterComposer(
            ComposerState(
                $state.db, $state.db.holes, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$ShotsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ShotsTable> {
  $$ShotsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get latitude => $state.composableBuilder(
      column: $state.table.latitude,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get longitude => $state.composableBuilder(
      column: $state.table.longitude,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get shotNumber => $state.composableBuilder(
      column: $state.table.shotNumber,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get recordedAt => $state.composableBuilder(
      column: $state.table.recordedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$HolesTableOrderingComposer get holeId {
    final $$HolesTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.holeId,
        referencedTable: $state.db.holes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$HolesTableOrderingComposer(
            ComposerState(
                $state.db, $state.db.holes, joinBuilder, parentComposers)));
    return composer;
  }
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RoundsTableTableManager get rounds =>
      $$RoundsTableTableManager(_db, _db.rounds);
  $$HolesTableTableManager get holes =>
      $$HolesTableTableManager(_db, _db.holes);
  $$ShotsTableTableManager get shots =>
      $$ShotsTableTableManager(_db, _db.shots);
}
