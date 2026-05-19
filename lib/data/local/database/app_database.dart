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
import 'daos/shot_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Rounds, Holes, Shots], daos: [RoundDao, HoleDao, ShotDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => await m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // SQLite does not support ALTER COLUMN, so we recreate holes and
            // shots with ON DELETE CASCADE on their FK columns using the
            // create-copy-drop-rename pattern.

            // --- holes table ---
            await customStatement(
              'CREATE TABLE IF NOT EXISTS holes_new ('
              'id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'round_id INTEGER NOT NULL REFERENCES rounds(id) ON DELETE CASCADE, '
              'hole_number INTEGER NOT NULL, '
              'par INTEGER NOT NULL, '
              'stroke_index INTEGER, '
              'outcome TEXT, '
              'putts INTEGER, '
              'fairway_hit INTEGER, '
              'green_in_regulation INTEGER, '
              'recorded_at INTEGER'
              ')',
            );
            await customStatement('INSERT INTO holes_new SELECT * FROM holes');
            await customStatement('DROP TABLE holes');
            await customStatement('ALTER TABLE holes_new RENAME TO holes');

            // --- shots table (must come after holes, shots FK refs holes) ---
            await customStatement(
              'CREATE TABLE IF NOT EXISTS shots_new ('
              'id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'hole_id INTEGER NOT NULL REFERENCES holes(id) ON DELETE CASCADE, '
              'latitude REAL NOT NULL, '
              'longitude REAL NOT NULL, '
              'shot_number INTEGER NOT NULL, '
              'recorded_at INTEGER NOT NULL'
              ')',
            );
            await customStatement('INSERT INTO shots_new SELECT * FROM shots');
            await customStatement('DROP TABLE shots');
            await customStatement('ALTER TABLE shots_new RENAME TO shots');
          }
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
