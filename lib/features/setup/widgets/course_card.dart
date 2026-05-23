import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: BrdySpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.courseName.toUpperCase(),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: const Color(0xFF0A0A0A),
                          fontSize: 16,
                        ),
                  ),
                  const SizedBox(height: BrdySpacing.xs),
                  // PAR · RATING · SLOPE all inline
                  _StatRow(
                    par: '${course.par}',
                    rating: course.courseRating?.toStringAsFixed(1) ?? 'N/A',
                    slope: course.slope?.toString() ?? 'N/A',
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
                  const SizedBox(height: BrdySpacing.xs),
                  GestureDetector(
                    onTap: () {
                      setState(() => _manualFormOpen = false);
                      ref.read(selectedCourseProvider.notifier).clear();
                    },
                    child: Text(
                      'CHANGE COURSE',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: BrdyColors.accent,
                            decoration: TextDecoration.none,
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

// ── Stat row: PAR 72 · RATING 68.5 · SLOPE 125 ───────────────────────────────

class _StatRow extends StatelessWidget {
  final String par;
  final String rating;
  final String slope;

  const _StatRow({required this.par, required this.rating, required this.slope});

  @override
  Widget build(BuildContext context) {
    final labelStyle = GoogleFonts.sometypeMono(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF0A0A0A),
    );
    final valueStyle = GoogleFonts.sometypeMono(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: const Color(0xFF0A0A0A),
    );

    return Row(
      children: [
        Text('PAR ', style: labelStyle),
        Text(par, style: valueStyle),
        const SizedBox(width: 12),
        Text('RATING ', style: labelStyle),
        Text(rating, style: valueStyle),
        const SizedBox(width: 12),
        Text('SLOPE ', style: labelStyle),
        Text(slope, style: valueStyle),
      ],
    );
  }
}
