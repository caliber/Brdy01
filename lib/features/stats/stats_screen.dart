import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/brdy_colors.dart';
import '../../theme/brdy_spacing.dart';
import 'providers/cross_round_averages_provider.dart';
import 'providers/trend_chart_provider.dart';
import 'widgets/average_stat_card.dart';
import 'widgets/differential_line_chart.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'STATS',
          style: GoogleFonts.sometypeMono(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.black,
        foregroundColor: context.brdyColors.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(BrdySpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'HANDICAP TREND',
                style: GoogleFonts.sometypeMono(
                  fontSize: 12,
                  color: context.brdyColors.onSurfaceMuted,
                ),
              ),
              const Gap(BrdySpacing.sm),
              ref.watch(trendChartProvider).when(
                    loading: () => SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: context.brdyColors.accent,
                        ),
                      ),
                    ),
                    error: (_, __) => SizedBox(
                      height: 200,
                      child: Center(
                        child: Text(
                          '—',
                          style: GoogleFonts.sometypeMono(
                            color: context.brdyColors.onSurfaceMuted,
                          ),
                        ),
                      ),
                    ),
                    data: (spots) => DifferentialLineChart(spots: spots),
                  ),
              const Gap(BrdySpacing.lg),
              Text(
                'AVERAGES — ALL ROUNDS',
                style: GoogleFonts.sometypeMono(
                  fontSize: 12,
                  color: context.brdyColors.onSurfaceMuted,
                ),
              ),
              const Gap(BrdySpacing.sm),
              ref.watch(crossRoundAveragesProvider).when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (averages) => GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: BrdySpacing.sm,
                      crossAxisSpacing: BrdySpacing.sm,
                      childAspectRatio: 2.2,
                      children: [
                        AverageStatCard(
                          label: 'Score to Par',
                          value: averages == null
                              ? null
                              : _formatScoreToPar(averages.avgScoreToPar),
                        ),
                        AverageStatCard(
                          label: 'Avg Putts',
                          value: averages?.avgPutts.toStringAsFixed(1),
                        ),
                        AverageStatCard(
                          label: 'FIR %',
                          value: averages == null
                              ? null
                              : '${averages.avgFirPercent.toStringAsFixed(0)}%',
                        ),
                        AverageStatCard(
                          label: 'GIR %',
                          value: averages == null
                              ? null
                              : '${averages.avgGirPercent.toStringAsFixed(0)}%',
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatScoreToPar(double value) {
  if (value >= 0) return '+${value.toStringAsFixed(1)}';
  return value.toStringAsFixed(1);
}
