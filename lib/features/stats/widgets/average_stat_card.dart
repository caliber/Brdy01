import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/brdy_colors.dart';

class AverageStatCard extends StatelessWidget {
  const AverageStatCard({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: BrdyColors.surface,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.sometypeMono(
              fontSize: 11,
              color: BrdyColors.onSurfaceMuted,
            ),
          ),
          const Gap(4),
          Text(
            value ?? '—',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: value != null
                  ? BrdyColors.onSurface
                  : BrdyColors.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}
