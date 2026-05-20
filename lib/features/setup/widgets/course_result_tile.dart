import 'package:flutter/material.dart';
import '../../../theme/brdy_colors.dart';
import '../../../theme/brdy_spacing.dart';
import '../../../theme/brdy_text_theme.dart';

class CourseResultTile extends StatelessWidget {
  final String courseName;
  final String? city;
  final String? country;
  final double? courseRating;
  final int? slope;
  final VoidCallback onTap;

  const CourseResultTile({
    super.key,
    required this.courseName,
    this.city,
    this.country,
    this.courseRating,
    this.slope,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final locationParts = [city, country].where((s) => s != null && s.isNotEmpty).join(', ');

    return Material(
      color: context.brdyColors.surface,
      child: InkWell(
        splashColor: Colors.white.withOpacity(0.08),
        highlightColor: Colors.white.withOpacity(0.04),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: context.brdyColors.divider, width: 1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: BrdySpacing.md,
              vertical: 12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        courseName,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      if (locationParts.isNotEmpty)
                        Text(
                          locationParts,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: context.brdyColors.onSurfaceMuted,
                              ),
                        ),
                      if (courseRating != null && slope != null)
                        Text(
                          'CR $courseRating / SL $slope',
                          style: BrdyTextTheme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: context.brdyColors.onSurfaceMuted,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: context.brdyColors.onSurfaceMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
