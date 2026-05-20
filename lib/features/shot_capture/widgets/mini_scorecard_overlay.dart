import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/enums/hole_outcome.dart';
import '../../../theme/brdy_colors.dart';
import '../providers/active_hole_index_provider.dart';
import '../providers/highest_scored_hole_index_provider.dart';
import '../providers/hole_list_provider.dart';
import '../providers/running_score_provider.dart';

class MiniScorecardOverlay extends ConsumerWidget {
  final int roundId;
  final bool isOpen;
  final VoidCallback? onClose;

  const MiniScorecardOverlay({
    super.key,
    required this.roundId,
    required this.isOpen,
    this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeHoleIndex = ref.watch(activeHoleIndexProvider);
    final holesAsync = ref.watch(holeListProvider(roundId));
    final highestScoredIndex = ref.watch(highestScoredHoleIndexProvider(roundId));
    final runningScore = ref.watch(runningScoreProvider(roundId));

    // Build outcome map: holeNumber (1-based) → outcome string
    final Map<int, String?> outcomeByHole = {};
    holesAsync.whenData((holes) {
      for (final h in holes) {
        outcomeByHole[h.holeNumber] = h.outcome;
      }
    });

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      height: isOpen ? 132 : 0,
      color: BrdyColors.surface,
      child: isOpen ? _buildContent(ref, activeHoleIndex, highestScoredIndex, outcomeByHole, runningScore) : const SizedBox.shrink(),
    );
  }

  Widget _buildContent(
    WidgetRef ref,
    int activeHoleIndex,
    int highestScoredIndex,
    Map<int, String?> outcomeByHole,
    int? runningScore,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: holes 1–9
          _buildChipRow(ref, 0, 9, activeHoleIndex, highestScoredIndex, outcomeByHole),
          const SizedBox(height: 4),
          // Row 2: holes 10–18
          _buildChipRow(ref, 9, 18, activeHoleIndex, highestScoredIndex, outcomeByHole),
          const SizedBox(height: 6),
          // Score summary bar
          _buildScoreBar(runningScore),
        ],
      ),
    );
  }

  Widget _buildChipRow(
    WidgetRef ref,
    int startIndex,
    int endIndex,
    int activeHoleIndex,
    int highestScoredIndex,
    Map<int, String?> outcomeByHole,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (int i = startIndex; i < endIndex; i++)
          _buildChip(ref, i, activeHoleIndex, highestScoredIndex, outcomeByHole[i + 1]),
      ],
    );
  }

  Widget _buildChip(
    WidgetRef ref,
    int index,
    int activeHoleIndex,
    int highestScoredIndex,
    String? outcomeName,
  ) {
    final fillColor = _outcomeToFill(outcomeName);
    final textColor = _outcomeToTextColor(outcomeName);
    final isActive = index == activeHoleIndex;
    final isTappable = index <= highestScoredIndex + 1;

    return GestureDetector(
      onTap: isTappable
          ? () async {
              await HapticFeedback.lightImpact();
              ref.read(activeHoleIndexProvider.notifier).set(index);
              onClose?.call();
            }
          : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(4),
          border: isActive
              ? Border.all(color: BrdyColors.onSurface, width: 2)
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          '${index + 1}',
          style: GoogleFonts.sometypeMono(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: textColor,
            decoration: outcomeName == 'bogey' ? TextDecoration.underline : null,
            decorationColor: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBar(int? runningScore) {
    final String label;
    if (runningScore == null) {
      label = 'E';
    } else if (runningScore == 0) {
      label = 'E';
    } else if (runningScore > 0) {
      label = '+$runningScore';
    } else {
      label = '$runningScore';
    }

    return Text(
      label,
      style: GoogleFonts.sometypeMono(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
    );
  }

  static Color _outcomeToFill(String? outcomeName) {
    if (outcomeName == null) return BrdyColors.surface;
    try {
      return switch (HoleOutcome.values.byName(outcomeName)) {
        HoleOutcome.eagle => const Color(0xFFFFD700),
        HoleOutcome.birdie => BrdyColors.accent,
        HoleOutcome.par => const Color(0xFF2563EB),
        HoleOutcome.bogey => BrdyColors.surface,
        HoleOutcome.doubleBogey => BrdyColors.destructive,
        HoleOutcome.pickup => BrdyColors.destructive,
      };
    } catch (_) {
      return BrdyColors.surface;
    }
  }

  static Color _outcomeToTextColor(String? outcomeName) {
    if (outcomeName == null) return BrdyColors.onSurface;
    try {
      return switch (HoleOutcome.values.byName(outcomeName)) {
        HoleOutcome.eagle => BrdyColors.background,
        HoleOutcome.birdie => BrdyColors.onAccent,
        HoleOutcome.par => const Color(0xFFFFFFFF),
        HoleOutcome.bogey => BrdyColors.onSurface,
        HoleOutcome.doubleBogey => BrdyColors.onDestructive,
        HoleOutcome.pickup => BrdyColors.onDestructive,
      };
    } catch (_) {
      return BrdyColors.onSurface;
    }
  }
}
