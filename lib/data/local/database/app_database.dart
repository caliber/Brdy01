import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables/rounds_table.dart';
import 'tables/holes_table.dart';
import 'tables/shots_table.dart';
import 'daos/round_dao.dart';
import 'daos/hole_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Rounds, Holes, Shots], daos: [RoundDao, HoleDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => await m.createAll(),
        onUpgrade: (m, from, to) async {
          // Phase 2+: if (from < 2) await m.addColumn(...)
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'brdy.sqlite'));
    return NativeDatabase(file);
  });
}
