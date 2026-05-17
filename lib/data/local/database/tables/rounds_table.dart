import 'package:drift/drift.dart';

class Rounds extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get courseName => text()();
  RealColumn get courseRating => real().nullable()();
  IntColumn get courseSlope => integer().nullable()();
  RealColumn get handicapIndex => real()();
  TextColumn get courseJson => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
}
