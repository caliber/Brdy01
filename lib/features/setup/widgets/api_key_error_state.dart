import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../theme/brdy_colors.dart';
import '../../../theme/brdy_spacing.dart';

class ApiKeyErrorState extends StatelessWidget {
  final bool isInvalidKey;

  const ApiKeyErrorState({super.key, required this.isInvalidKey});

  @override
  Widget build(BuildContext context) {
    final heading = isInvalidKey ? 'API KEY INVALID' : 'API KEY NOT CONFIGURED';
    final body = isInvalidKey
        ? 'The Golf Course API key was rejected. Check the key and restart the app.'
        : 'Add your Golf Course API key via --dart-define=GOLF_API_KEY=<value> and restart the app.';

    return Scaffold(
      backgroundColor: context.brdyColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: BrdySpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.key_off,
                  size: 48,
                  color: context.brdyColors.destructive,
                ),
                const Gap(BrdySpacing.lg),
                Text(
                  heading,
                  style: Theme.of(context).textTheme.labelLarge,
                  textAlign: TextAlign.center,
                ),
                const Gap(BrdySpacing.sm),
                Text(
                  body,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: context.brdyColors.onSurfaceMuted),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
