import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/app.dart';
import 'app/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox(AppConstants.playerPrefsBox);
  await Hive.openBox(AppConstants.courseCacheBox);
  runApp(
    const ProviderScope(
      child: BrdyApp(),
    ),
  );
}
