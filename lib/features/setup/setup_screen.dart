import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    // Fire haptic + trigger tile pre-cache when a course loads
    ref.listen(selectedCourseProvider, (prev, next) {
      final wasNull = prev?.valueOrNull == null;
      final nowLoaded = next.valueOrNull;
      if (wasNull && nowLoaded != null) {
        HapticFeedback.lightImpact();
        ref
            .read(tileCacheProgressProvider.notifier)
            .start(nowLoaded.holes);
      }
    });

    return Scaffold(
      body: Container(
        color: Colors.black,
        child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: BrdySpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Gap(BrdySpacing.sm),
              Transform.translate(
                offset: const Offset(-19, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SvgPicture.asset(
                    'assets/images/brdy_logo.svg',
                    height: MediaQuery.of(context).size.height * 0.15,
                  ),
                ),
              ),
              const Gap(BrdySpacing.sm),
              const HandicapInput(),
              const Gap(BrdySpacing.md),
              CourseSearchField(controller: _searchController),
              const Gap(BrdySpacing.sm),
              Expanded(
                child: ref.watch(selectedCourseProvider).maybeWhen(
                      data: (course) => course != null
                          ? const CourseCard()
                          : _SearchResultsList(
                              searchController: _searchController,
                            ),
                      orElse: () => _SearchResultsList(
                        searchController: _searchController,
                      ),
                    ),
              ),
              const TileCacheProgress(),
              const Gap(BrdySpacing.md),
              const _StartRoundButton(),
              const Gap(BrdySpacing.sm),
              OutlinedButton(
                onPressed: () => context.push('/stats'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: context.brdyColors.divider),
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(
                  'STATS',
                  style: GoogleFonts.sometypeMono(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: context.brdyColors.onSurfaceMuted,
                  ),
                ),
              ),
              const Gap(BrdySpacing.sm),
              OutlinedButton(
                onPressed: () => context.push('/round-history'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: context.brdyColors.divider),
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(
                  'ROUND HISTORY',
                  style: GoogleFonts.sometypeMono(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: context.brdyColors.onSurfaceMuted,
                  ),
                ),
              ),
              const Gap(BrdySpacing.sm),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

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

class _StartRoundButton extends ConsumerWidget {
  const _StartRoundButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = ref.watch(selectedCourseProvider).valueOrNull;
    final roundSetupAsync = ref.watch(roundSetupNotifierProvider);
    final isLoading = roundSetupAsync.isLoading;
    final isEnabled = course != null && !isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: FractionallySizedBox(
            widthFactor: 0.25,
            child: Opacity(
          opacity: isEnabled ? 1.0 : 0.4,
          child: GestureDetector(
            onTap: isEnabled
                ? () async {
                    await HapticFeedback.mediumImpact();
                    final handicap =
                        ref.read(hivePlayerPrefsProvider).handicapIndex ?? 0.0;
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
            child: SizedBox(
              height: 80,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SvgPicture.asset(
                    'assets/images/btn_bogey.svg',
                    fit: BoxFit.fill,
                  ),
                  isLoading
                      ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              'LOAD',
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
          ),
        ),
        if (course == null) ...[
          const Gap(BrdySpacing.xs),
          Text(
            'Search and select a course to start',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: context.brdyColors.onSurfaceMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
