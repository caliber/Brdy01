import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/local/database/app_database_provider.dart';
import '../../../data/local/database/app_database.dart';

part 'hole_list_provider.g.dart';

@riverpod
Stream<List<Hole>> holeList(Ref ref, int roundId) {
  final db = ref.watch(appDatabaseProvider);
  return db.holeDao.watchHolesForRound(roundId);
}
