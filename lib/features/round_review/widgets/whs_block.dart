import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/brdy_colors.dart';
import '../../../theme/brdy_spacing.dart';
import '../providers/whs_differential_provider.dart';

class WhsBlock extends ConsumerWidget {
  const WhsBlock({super.key, required this.roundId});

  final int roundId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final whsAsync = ref.watch(whsDifferentialProvider(roundId));

    if (whsAsync.isLoading) {
      return Container(height: 48);
    }

    if (whsAsync.hasError) {
      return Text(
        'WHS N/A',
        style: GoogleFonts.barlowCondensed(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: BrdyColors.onSurfaceMuted,
        ),
      );
    }

    final whs = whsAsync.valueOrNull;
    if (whs == null) {
      return Container(height: 48);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(BrdySpacing.md),
      decoration: BoxDecoration(
        color: BrdyColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: label
          Text(
            'WHS DIFFERENTIAL',
            style: GoogleFonts.barlowCondensed(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: BrdyColors.onSurfaceMuted,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: BrdySpacing.xs),
          // Row 2: prominent differential value
          Text(
            whs.displayValue,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: BrdyColors.onSurface,
            ),
          ),
          // Row 3 (conditional): indicative label
          if (whs.isIndicative && whs.indicativeLabel != null) ...[
            const SizedBox(height: BrdySpacing.xs),
            Text(
              whs.indicativeLabel!,
              style: GoogleFonts.barlowCondensed(
                fontSize: 11,
                color: BrdyColors.onSurfaceMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
