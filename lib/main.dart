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
  // Pre-load SometypeMono so it renders correctly on the splash screen
  await GoogleFonts.pendingFonts([
    GoogleFonts.sometypeMono(),
  ]);
  await Hive.initFlutter();
  await Hive.openBox(AppConstants.playerPrefsBox);
  await Hive.openBox(AppConstants.courseCacheBox);
  try {
    await FMTCObjectBoxBackend().initialise();
    await const FMTCStore(AppConstants.tileCacheStoreName).manage.create();
  } catch (e) {
    // P-03: store may already exist on re-launch — non-blocking
    Logger().w('FMTC init: $e');
  }
  runApp(
    const ProviderScope(
      child: BrdyApp(),
    ),
  );
}
