import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Color(0xFF2A2A2A),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          display,
          style: GoogleFonts.sometypeMono(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
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
