import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/brdy_colors.dart';
import '../../../theme/brdy_spacing.dart';
import '../providers/stats_provider.dart';
import 'stat_card.dart';
import 'whs_block.dart';

String _formatScoreToPar(int score) =>
    score == 0 ? 'E' : (score > 0 ? '+$score' : '$score');

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += 2) {
      final left = children[i];
      final right = i + 1 < children.length ? children[i + 1] : const SizedBox.shrink();
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: left),
              const SizedBox(width: BrdySpacing.sm),
              Expanded(child: right),
            ],
          ),
        ),
      );
      if (i + 2 < children.length) rows.add(const SizedBox(height: BrdySpacing.sm));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }
}

class StatsSection extends ConsumerWidget {
  const StatsSection({super.key, required this.roundId});

  final int roundId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider(roundId));

    if (statsAsync.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: BrdyColors.accent),
      );
    }

    if (statsAsync.hasError) {
      return Text(
        'Stats unavailable',
        style: GoogleFonts.sometypeMono(
          fontSize: 14,
          color: BrdyColors.onSurfaceMuted,
        ),
      );
    }

    final stats = statsAsync.valueOrNull;
    if (stats == null) {
      return const SizedBox.shrink();
    }

    final sectionHeaderStyle = GoogleFonts.sometypeMono(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: BrdyColors.onSurfaceMuted,
      letterSpacing: 1.5,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── WHS Differential ────────────────────────────────────────────
        WhsBlock(roundId: roundId),
        const Gap(BrdySpacing.xl),
        // ── Scoring section ──────────────────────────────────────────────
        Text('SCORING', style: sectionHeaderStyle),
        const Gap(BrdySpacing.sm + 10),
        _StatGrid(children: [
          StatCard(label: 'STROKES', value: stats.totalStrokes.toString()),
          StatCard(label: 'VS PAR', value: _formatScoreToPar(stats.scoreToPar)),
          StatCard(label: 'NET SCORE', value: stats.netScore.toString()),
          StatCard(label: 'EAGLES', value: stats.eagles.toString()),
          StatCard(label: 'BIRDIES', value: stats.birdies.toString()),
          StatCard(label: 'PARS', value: stats.pars.toString()),
          StatCard(label: 'BOGEYS', value: stats.bogeys.toString()),
          StatCard(label: 'DOUBLES', value: stats.doubles.toString()),
          StatCard(label: 'TRIPLES', value: stats.triples.toString()),
          StatCard(label: 'PICKUPS', value: stats.pickups.toString()),
        ]),
        const Gap(BrdySpacing.xl),
        // ── Approach & Putting section ───────────────────────────────────
        Text('APPROACH & PUTTING', style: sectionHeaderStyle),
        const Gap(BrdySpacing.sm + 10),
        _StatGrid(children: [
          StatCard(label: 'PUTTS', value: stats.totalPutts.toString()),
          StatCard(
            label: 'PUTTS/GIR',
            value: stats.puttsPerGir.toStringAsFixed(1),
          ),
          StatCard(label: 'GIRS', value: stats.girCount.toString()),
          StatCard(
            label: 'GIR%',
            value: '${stats.girPercent.toStringAsFixed(0)}%',
          ),
          StatCard(label: 'FWY HIT', value: stats.fairwaysHit.toString()),
          StatCard(
            label: 'FIR%',
            value: '${stats.firPercent.toStringAsFixed(0)}%',
          ),
        ]),
      ],
    );
  }
}
