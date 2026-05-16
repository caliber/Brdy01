import 'package:flutter/material.dart';
import '../../theme/brdy_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrdyColors.background,
      body: Center(
        child: Text(
          'BRDY.01',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: BrdyColors.onSurface,
              ),
        ),
      ),
    );
  }
}
