import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../app/constants.dart';
import 'hive_course_box.dart';

part 'hive_course_box_provider.g.dart';

@Riverpod(keepAlive: true)
HiveCourseBox hiveCourseBox(Ref ref) =>
    HiveCourseBox(Hive.box(AppConstants.courseCacheBox));
