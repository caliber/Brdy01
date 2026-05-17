import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../theme/brdy_colors.dart';
import '../../theme/brdy_spacing.dart';
import '../setup/providers/active_round_id_provider.dart';

class ShotCaptureScreen extends ConsumerWidget {
  final int roundId;
  const ShotCaptureScreen({super.key, required this.roundId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeId = ref.watch(activeRoundIdProvider);
    return Scaffold(
      backgroundColor: BrdyColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ROUND $roundId',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const Gap(BrdySpacing.md),
              Text(
                'active provider: ${activeId ?? "null"}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: BrdyColors.onSurfaceMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
