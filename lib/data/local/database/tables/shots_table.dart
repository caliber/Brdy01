import 'package:drift/drift.dart';
import 'holes_table.dart';

class Shots extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get holeId => integer().references(Holes, #id)();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  IntColumn get shotNumber => integer()();
  DateTimeColumn get recordedAt => dateTime()();
}
