import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/local/database/app_database_provider.dart';

part 'app_startup_provider.g.dart';

@riverpod
Future<int?> appStartup(Ref ref) async {
  final db = ref.watch(appDatabaseProvider);
  return db.roundDao.findIncompleteRoundId();
}
