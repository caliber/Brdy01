import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../theme/brdy_colors.dart';
import '../../theme/brdy_spacing.dart';
import '../../data/local/preferences/hive_player_prefs_provider.dart';
import '../../data/local/preferences/hive_course_box_provider.dart';
import 'providers/course_search_results_provider.dart';
import 'providers/round_setup_notifier.dart';
import 'providers/selected_course_provider.dart';
import 'providers/tile_cache_progress_provider.dart' hide TileCacheProgress;
import 'widgets/handicap_input.dart';
import 'widgets/course_search_field.dart';
import 'widgets/course_result_tile.dart';
import 'widgets/course_card.dart';
import 'widgets/tile_cache_progress.dart';
import 'widgets/api_key_error_state.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prePopulateFromCache());
  }

  void _prePopulateFromCache() {
    final prefs = ref.read(hivePlayerPrefsProvider);
    final lastId = prefs.lastUsedCourseId;
    if (lastId == null) return;
    final cached = ref.read(hiveCourseBoxProvider).readCourse(lastId);
    if (cached != null) {
      ref.read(selectedCourseProvider.notifier).loadFromCache(cached);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(selectedCourseProvider, (prev, next) {
      final wasNull = prev?.valueOrNull == null;
      final nowLoaded = next.valueOrNull;
      if (wasNull && nowLoaded != null) {
        HapticFeedback.lightImpact();
        ref.read(tileCacheProgressProvider.notifier).start(nowLoaded.holes);
      }
    });

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background: same gradient + texture used in the score screen bottom zone
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE5E0DE), Color(0xFF8E8C8A)],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: BrdySpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Gap(50),

                  // ── App icon card ───────────────────────────────────────────
                  const _AppIconCard(),

                  const Gap(25),

                  // ── BRDY.01: SETUP heading ──────────────────────────────────
                  Text(
                    'BRDY.01:  SETUP',
                    style: GoogleFonts.sometypeMono(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.5,
                      color: const Color(0xFF0A0A0A),
                    ),
                  ),
                  const Gap(8),
                  const Divider(
                    color: Color(0x40535150),
                    thickness: 1,
                    height: 1,
                  ),

                  const Gap(BrdySpacing.md),

                  // ── Handicap section ────────────────────────────────────────
                  const _SectionLabel(
                    text: 'YOUR HANDICAP',
                    dotColor: BrdyColors.accent,
                  ),
                  const Gap(BrdySpacing.xs),
                  const HandicapInput(),

                  const Gap(BrdySpacing.md),

                  // ── Course section ──────────────────────────────────────────
                  _SectionLabel(
                    text: 'LOAD COURSE',
                    dotColor: context.brdyColors.onSurfaceMuted,
                  ),
                  const Gap(BrdySpacing.xs),
                  CourseSearchField(controller: _searchController),

                  const Gap(BrdySpacing.sm),

                  // ── Course results / card ───────────────────────────────────
                  ref.watch(selectedCourseProvider).maybeWhen(
                    data: (course) => course != null
                        ? const CourseCard()
                        : ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 220),
                            child: _SearchResultsList(
                              searchController: _searchController,
                            ),
                          ),
                    orElse: () => ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: _SearchResultsList(
                        searchController: _searchController,
                      ),
                    ),
                  ),

                  const TileCacheProgress(),
                  const Gap(40),

                  // ── Action row: STATS · ROUND HISTORY · START ROUND ─────────
                  _ActionRow(
                    onStatsTap: () => context.push('/stats'),
                    onHistoryTap: () => context.push('/round-history'),
                  ),

                  const Gap(BrdySpacing.sm),
                ],
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── App icon card ──────────────────────────────────────────────────────────────

class _AppIconCard extends StatelessWidget {
  const _AppIconCard();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          children: [
            // B — always perfectly centred, unaffected by 01
            Center(
              child: Text(
                'B',
                style: GoogleFonts.sometypeMono(
                  fontSize: 68,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  height: 1.0,
                ),
              ),
            ),
            // 01 — independent position, tight kerning
            const Positioned(
              top: 18,
              right: 11,
              child: Text(
                '01',
                style: TextStyle(
                  fontFamily: 'SometypeMono',
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -1.0,
                  color: BrdyColors.accent,
                  height: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section label with coloured dot ───────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  final Color dotColor;

  const _SectionLabel({required this.text, required this.dotColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.sometypeMono(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: const Color(0xFF535150),
          ),
        ),
      ],
    );
  }
}

// ── Search results list ────────────────────────────────────────────────────────

class _SearchResultsList extends ConsumerWidget {
  final TextEditingController searchController;

  const _SearchResultsList({required this.searchController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(courseSearchResultsProvider).when(
          loading: () => const SizedBox.shrink(),
          error: (e, _) {
            if (e is DioException) {
              if (e.message == 'API_KEY_MISSING') {
                return const ApiKeyErrorState(isInvalidKey: false);
              }
              if (e.message == 'API_KEY_INVALID') {
                return const ApiKeyErrorState(isInvalidKey: true);
              }
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Could not reach the course database. Check your connection and try again.',
                  ),
                  duration: Duration(seconds: 6),
                ),
              );
            });
            return const SizedBox.shrink();
          },
          data: (results) {
            if (results.isEmpty) return const SizedBox.shrink();
            return ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, i) {
                final result = results[i];
                return CourseResultTile(
                  courseName: result.clubName,
                  city: null,
                  country: null,
                  courseRating: result.courseRating,
                  slope: result.slope,
                  onTap: () => ref
                      .read(selectedCourseProvider.notifier)
                      .loadCourse(result.id),
                );
              },
            );
          },
        );
  }
}

// ── Action row: STATS · ROUND HISTORY · START ROUND ───────────────────────────

class _ActionRow extends ConsumerWidget {
  final VoidCallback onStatsTap;
  final VoidCallback onHistoryTap;

  const _ActionRow({required this.onStatsTap, required this.onHistoryTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = ref.watch(selectedCourseProvider).valueOrNull;
    final roundSetupAsync = ref.watch(roundSetupNotifierProvider);
    final isLoading = roundSetupAsync.isLoading;
    final isStartEnabled = course != null && !isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            // Match NEXT button: 1/4 of row width, square (SVG is 81×81)
            final btnWidth = (constraints.maxWidth - 3 * BrdySpacing.xs) / 4;
            return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: btnWidth,
              child: _ActionButton(
                label: 'STATS',
                svg: 'assets/images/btn_charcoal.svg',
                height: btnWidth,
                onTap: onStatsTap,
              ),
            ),
            const SizedBox(width: BrdySpacing.xs),
            SizedBox(
              width: btnWidth,
              child: _ActionButton(
                label: 'HISTORY',
                svg: 'assets/images/btn_charcoal.svg',
                height: btnWidth,
                onTap: onHistoryTap,
              ),
            ),
            const SizedBox(width: BrdySpacing.xs),
            // START — orange (same as bogey/next)
            SizedBox(
              width: btnWidth,
              child: Opacity(
                opacity: isStartEnabled ? 1.0 : 0.35,
                child: _ActionButton(
                  label: isLoading ? '' : 'START',
                  svg: 'assets/images/btn_bogey.svg',
                  height: btnWidth,
                  onTap: isStartEnabled
                      ? () async {
                          await HapticFeedback.mediumImpact();
                          final handicap = ref
                                  .read(hivePlayerPrefsProvider)
                                  .handicapIndex ??
                              0.0;
                          try {
                            final roundId = await ref
                                .read(roundSetupNotifierProvider.notifier)
                                .createRound(course, handicap);
                            if (!context.mounted) return;
                            context.go('/shot-capture/$roundId');
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                    'Could not load course details. Tap to retry.'),
                                backgroundColor: context.brdyColors.surface,
                                duration: const Duration(seconds: 6),
                              ),
                            );
                          }
                        }
                      : null,
                  loadingChild: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ],
            );
          },
        ),
        if (course == null) ...[
          const Gap(BrdySpacing.xs),
          Text(
            'Search and select a course to start',
            style: GoogleFonts.sometypeMono(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF535150),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

// ── Shared action button — matches score screen _ButtonColumn exactly ──────────

class _ActionButton extends StatefulWidget {
  final String label;
  final String svg;
  final double height;
  final VoidCallback? onTap;
  final Widget? loadingChild;

  const _ActionButton({
    required this.label,
    required this.svg,
    this.height = 80,
    this.onTap,
    this.loadingChild,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressing = true),
      onTapUp: (_) {
        setState(() => _pressing = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressing = false),
      child: AnimatedScale(
        scale: _pressing ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SizedBox(
            height: widget.height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                SvgPicture.asset(widget.svg, fit: BoxFit.fill),
                widget.loadingChild != null
                    ? Center(child: widget.loadingChild)
                    : Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            widget.label,
                            style: GoogleFonts.sometypeMono(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
