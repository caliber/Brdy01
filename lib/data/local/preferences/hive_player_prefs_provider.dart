import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../app/constants.dart';
import 'hive_player_prefs.dart';

part 'hive_player_prefs_provider.g.dart';

@Riverpod(keepAlive: true)
HivePlayerPrefs hivePlayerPrefs(Ref ref) =>
    HivePlayerPrefs(Hive.box(AppConstants.playerPrefsBox));
