import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../../theme/brdy_colors.dart';
import '../../../theme/brdy_spacing.dart';

class MissingRatingBanner extends StatelessWidget {
  final VoidCallback onEnterManuallyTap;

  const MissingRatingBanner({super.key, required this.onEnterManuallyTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0x26CC2200),
        border: Border(
          left: BorderSide(color: BrdyColors.destructive, width: 3),
        ),
      ),
      padding: const EdgeInsets.all(BrdySpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Course Rating or Slope not found. WHS differential will not be calculated. Enter values manually to enable it.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: BrdyColors.destructive),
          ),
          const Gap(BrdySpacing.sm),
          InkWell(
            onTap: onEnterManuallyTap,
            child: Text(
              'ENTER MANUALLY',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: BrdyColors.destructive,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationColor: BrdyColors.destructive,
                  ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .slideY(begin: -0.1, end: 0, duration: 200.ms, curve: Curves.easeOut);
  }
}
