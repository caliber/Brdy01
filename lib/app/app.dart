import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import '../theme/brdy_theme.dart';
import '../providers/theme_mode_provider.dart';

class BrdyApp extends ConsumerWidget {
  const BrdyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'BRDY.01',
      theme: BrdyTheme.light,
      darkTheme: BrdyTheme.dark,
      themeMode: themeMode,
      routerConfig: ref.watch(routerProvider),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context),
          child: child!,
        );
      },
    );
  }
}
