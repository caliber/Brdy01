import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import '../theme/brdy_theme.dart';

class BrdyApp extends ConsumerWidget {
  const BrdyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'BRDY.01',
      theme: BrdyTheme.themeData,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
