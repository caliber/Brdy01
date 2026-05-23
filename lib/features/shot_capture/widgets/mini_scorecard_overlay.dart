import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/enums/hole_outcome.dart';
import '../../../theme/brdy_colors.dart';
import '../providers/active_hole_index_provider.dart';
import '../providers/highest_scored_hole_index_provider.dart';
import '../providers/hole_list_provider.dart';


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
      height: isOpen ? 90 : 0,
      color: context.brdyColors.surface,
      child: isOpen ? _buildContent(context, ref, activeHoleIndex, highestScoredIndex, outcomeByHole) : const SizedBox.shrink(),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    int activeHoleIndex,
    int highestScoredIndex,
    Map<int, String?> outcomeByHole,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: holes 1–9
          _buildChipRow(context, ref, 0, 9, activeHoleIndex, highestScoredIndex, outcomeByHole),
          const SizedBox(height: 4),
          // Row 2: holes 10–18
          _buildChipRow(context, ref, 9, 18, activeHoleIndex, highestScoredIndex, outcomeByHole),
        ],
      ),
    );
  }

  Widget _buildChipRow(
    BuildContext context,
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
          _buildChip(context, ref, i, activeHoleIndex, highestScoredIndex, outcomeByHole[i + 1]),
      ],
    );
  }

  Widget _buildChip(
    BuildContext context,
    WidgetRef ref,
    int index,
    int activeHoleIndex,
    int highestScoredIndex,
    String? outcomeName,
  ) {
    final fillColor = _outcomeToFill(context, outcomeName);
    final textColor = _outcomeToTextColor(context, outcomeName);
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
              ? Border.all(color: context.brdyColors.onSurface, width: 2)
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

  static Color _outcomeToFill(BuildContext context, String? outcomeName) {
    if (outcomeName == null) return context.brdyColors.surface;
    try {
      return switch (HoleOutcome.values.byName(outcomeName)) {
        HoleOutcome.eagle => const Color(0xFFFFD700),
        HoleOutcome.birdie => BrdyColors.accent,
        HoleOutcome.par => const Color(0xFF2563EB),
        HoleOutcome.bogey => context.brdyColors.surface,
        HoleOutcome.doubleBogey => BrdyColors.destructive,
        HoleOutcome.pickup => BrdyColors.destructive,
      };
    } catch (_) {
      return context.brdyColors.surface;
    }
  }

  static Color _outcomeToTextColor(BuildContext context, String? outcomeName) {
    if (outcomeName == null) return context.brdyColors.onSurface;
    try {
      return switch (HoleOutcome.values.byName(outcomeName)) {
        HoleOutcome.eagle => context.brdyColors.background,
        HoleOutcome.birdie => BrdyColors.onAccent,
        HoleOutcome.par => const Color(0xFFFFFFFF),
        HoleOutcome.bogey => context.brdyColors.onSurface,
        HoleOutcome.doubleBogey => BrdyColors.onDestructive,
        HoleOutcome.pickup => BrdyColors.onDestructive,
      };
    } catch (_) {
      return context.brdyColors.onSurface;
    }
  }
}
