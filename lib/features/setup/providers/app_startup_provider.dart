import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_startup_provider.g.dart';

// Auto-dispose: runs once on startup; router redirect consumes it then discards.
// TODO(plan-02): query roundDao.findIncompleteRoundId() once Drift is wired.
@riverpod
Future<int?> appStartup(Ref ref) async {
  return null;
}
