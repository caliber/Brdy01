import 'package:hive_flutter/hive_flutter.dart';

class HivePlayerPrefs {
  final Box _box;

  HivePlayerPrefs(this._box);

  static const _keyHandicapIndex = 'handicap_index';
  static const _keyLastUsedCourseId = 'last_used_course_id';

  double? get handicapIndex => _box.get(_keyHandicapIndex) as double?;
  void setHandicapIndex(double value) => _box.put(_keyHandicapIndex, value);

  String? get lastUsedCourseId => _box.get(_keyLastUsedCourseId) as String?;
  void setLastUsedCourseId(String id) => _box.put(_keyLastUsedCourseId, id);
}
