import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/brdy_colors.dart';
import '../../../theme/brdy_spacing.dart';
import '../providers/selected_course_provider.dart';
import 'missing_rating_banner.dart';
import 'manual_rating_form.dart';

class CourseCard extends ConsumerStatefulWidget {
  const CourseCard({super.key});

  @override
  ConsumerState<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends ConsumerState<CourseCard> {
  bool _manualFormOpen = false;

  @override
  Widget build(BuildContext context) {
    return ref.watch(selectedCourseProvider).when(
          data: (course) {
            if (course == null) return const SizedBox.shrink();
            final missingRating =
                course.courseRating == null || course.slope == null;

            return Container(
              decoration: BoxDecoration(
                color: BrdyColors.surface,
                border: Border.all(color: BrdyColors.accent, width: 1),
              ),
              padding: const EdgeInsets.symmetric(horizontal: BrdySpacing.md, vertical: BrdySpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.courseName.toUpperCase(),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: BrdyColors.accent,
                        ),
                  ),
                  Text(
                    'PAR ${course.par}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: BrdyColors.onSurfaceMuted,
                        ),
                  ),
                  const SizedBox(height: BrdySpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RATING',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: BrdyColors.onSurfaceMuted),
                            ),
                            Text(
                              course.courseRating?.toStringAsFixed(1) ?? 'N/A',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SLOPE',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: BrdyColors.onSurfaceMuted),
                            ),
                            Text(
                              course.slope?.toString() ?? 'N/A',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (missingRating) ...[
                    const SizedBox(height: BrdySpacing.sm),
                    if (!_manualFormOpen)
                      MissingRatingBanner(
                        onEnterManuallyTap: () =>
                            setState(() => _manualFormOpen = true),
                      )
                    else
                      ManualRatingForm(
                        onSaved: () => setState(() => _manualFormOpen = false),
                      ),
                  ],
                  const SizedBox(height: BrdySpacing.sm),
                  GestureDetector(
                    onTap: () {
                      setState(() => _manualFormOpen = false);
                      ref.read(selectedCourseProvider.notifier).clear();
                    },
                    child: Text(
                      'change course',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: BrdyColors.onSurfaceMuted,
                            decoration: TextDecoration.underline,
                          ),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 200.ms, curve: Curves.easeOut)
                .slideY(
                    begin: 0.1, end: 0, duration: 200.ms, curve: Curves.easeOut);
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
  }
}
