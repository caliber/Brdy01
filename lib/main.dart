import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'app/app.dart';
import 'app/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Use locally bundled fonts only — never fetch from Google CDN at runtime.
  // SometypeMono is registered in pubspec.yaml assets/fonts/
  GoogleFonts.config.allowRuntimeFetching = false;
  await Hive.initFlutter();
  await Hive.openBox(AppConstants.playerPrefsBox);
  await Hive.openBox(AppConstants.courseCacheBox);
  // FMTC tile cache init deferred — map overlay not active in current build
  // TODO: re-enable when GPS/map features are restored
  // try {
  //   await FMTCObjectBoxBackend().initialise();
  //   await const FMTCStore(AppConstants.tileCacheStoreName).manage.create();
  // } catch (e) {
  //   Logger().w('FMTC init: $e');
  // }
  runApp(
    const ProviderScope(
      child: BrdyApp(),
    ),
  );
}
