import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/local/database/app_database_provider.dart';
import '../../../data/local/database/app_database.dart';

part 'completed_rounds_provider.g.dart';

@riverpod
Stream<List<Round>> completedRounds(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.roundDao.watchCompletedRounds();
}
