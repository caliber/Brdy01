import 'package:drift/drift.dart';
import 'rounds_table.dart';

class Holes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get roundId => integer().references(Rounds, #id, onDelete: KeyAction.cascade)();
  IntColumn get holeNumber => integer()();
  IntColumn get par => integer()();
  IntColumn get strokeIndex => integer().nullable()();
  TextColumn get outcome => text().nullable()();
  IntColumn get putts => integer().nullable()();
  BoolColumn get fairwayHit => boolean().nullable()();
  BoolColumn get greenInRegulation => boolean().nullable()();
  DateTimeColumn get recordedAt => dateTime().nullable()();
}
