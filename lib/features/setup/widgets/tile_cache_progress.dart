import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../theme/brdy_colors.dart';
import '../../../theme/brdy_spacing.dart';
import '../providers/tile_cache_progress_provider.dart';

class TileCacheProgress extends ConsumerWidget {
  const TileCacheProgress({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(tileCacheProgressProvider);
    if (progress == null) return const SizedBox.shrink();

    final pct = progress.percentageProgress.clamp(0.0, 100.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DOWNLOADING MAP TILES… ${pct.toInt()}%',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: context.brdyColors.onSurfaceMuted),
        ),
        const Gap(BrdySpacing.xs),
        LinearProgressIndicator(
          value: pct / 100,
          color: context.brdyColors.accent,
          backgroundColor: context.brdyColors.divider,
          minHeight: 2,
        ),
      ],
    );
  }
}
