import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/local/database/app_database_provider.dart';
import '../../../domain/models/course_model.dart';

part 'course_for_round_provider.g.dart';

@riverpod
Future<CourseModel?> courseForRound(Ref ref, int roundId) async {
  final db = ref.watch(appDatabaseProvider);
  final round = await db.roundDao.getRoundById(roundId);
  if (round == null || round.courseJson.isEmpty) return null;
  return CourseModel.fromJson(
    jsonDecode(round.courseJson) as Map<String, dynamic>,
  );
}
