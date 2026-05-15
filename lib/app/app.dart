import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/setup/setup_screen.dart';

class BrdyApp extends ConsumerWidget {
  const BrdyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'BRDY.01',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFE8520A)),
        useMaterial3: true,
      ),
      home: const SetupScreen(),
    );
  }
}
