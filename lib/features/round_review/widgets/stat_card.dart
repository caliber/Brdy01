import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/brdy_colors.dart';
import '../../../theme/brdy_spacing.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.fullWidth = false,
  });

  final String label;
  final String value;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(
        horizontal: BrdySpacing.md,
        vertical: BrdySpacing.sm,
      ),
      decoration: BoxDecoration(
        color: BrdyColors.surface,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.sometypeMono(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: BrdyColors.onSurfaceMuted,
              letterSpacing: 1.2,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.sometypeMono(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: BrdyColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
