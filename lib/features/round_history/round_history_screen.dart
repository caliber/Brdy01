import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/brdy_colors.dart';
import 'providers/completed_rounds_provider.dart';
import 'widgets/round_history_tile.dart';

class RoundHistoryScreen extends ConsumerWidget {
  const RoundHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roundsAsync = ref.watch(completedRoundsProvider);

    return Scaffold(
      backgroundColor: BrdyColors.background,
      appBar: AppBar(
        title: Text(
          'ROUND HISTORY',
          style: GoogleFonts.sometypeMono(
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: BrdyColors.background,
        elevation: 0,
      ),
      body: roundsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: BrdyColors.accent),
        ),
        error: (_, __) => Center(
          child: Text(
            'Could not load rounds',
            style: GoogleFonts.sometypeMono(
              color: BrdyColors.onSurfaceMuted,
            ),
          ),
        ),
        data: (rounds) {
          if (rounds.isEmpty) {
            return Center(
              child: Text(
                'NO ROUNDS YET',
                style: GoogleFonts.sometypeMono(
                  color: BrdyColors.onSurfaceMuted,
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: rounds.length,
            separatorBuilder: (_, __) => const Divider(
              color: BrdyColors.divider,
              height: 1,
              thickness: 1,
            ),
            itemBuilder: (_, i) => RoundHistoryTile(round: rounds[i]),
          );
        },
      ),
    );
  }
}
