import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/brdy_colors.dart';
import '../providers/running_score_provider.dart';

class ScoreBar extends ConsumerWidget {
  final int roundId;

  const ScoreBar({super.key, required this.roundId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = ref.watch(runningScoreProvider(roundId));

    final String display;
    if (score == null) {
      display = 'E';
    } else if (score == 0) {
      display = 'E';
    } else if (score > 0) {
      display = '+$score';
    } else {
      display = '$score';
    }

    return Semantics(
      label: 'RUNNING SCORE $display VERSUS PAR',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: BrdyColors.accent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          display,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: BrdyColors.onAccent,
          ),
        ),
      )
          .animate(key: ValueKey(score))
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.1, 1.1),
            duration: 75.ms,
          )
          .then()
          .scale(
            end: const Offset(1.0, 1.0),
            duration: 75.ms,
          ),
    );
  }
}
