import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/holes_table.dart';

part 'hole_dao.g.dart';

@DriftAccessor(tables: [Holes])
class HoleDao extends DatabaseAccessor<AppDatabase> with _$HoleDaoMixin {
  HoleDao(super.db);
  // Phase 2 will add insert/update methods
}
