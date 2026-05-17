import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      backgroundColor: BrdyColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: BrdySpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Gap(BrdySpacing.md),
              Text(
                'BRDY.01',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const Gap(BrdySpacing.lg),
              const HandicapInput(),
              const Gap(BrdySpacing.xl),
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
              const Gap(BrdySpacing.x2l),
              const _StartRoundButton(),
              const Gap(BrdySpacing.md),
            ],
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
                  city: result.location?.city,
                  country: result.location?.country,
                  courseRating: result.courseRating,
                  slope: result.slopeRating,
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
        ElevatedButton(
          onPressed: isEnabled
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
                      const SnackBar(
                        content: Text(
                            'Could not load course details. Tap to retry.'),
                        backgroundColor: BrdyColors.surface,
                        duration: Duration(seconds: 6),
                      ),
                    );
                  }
                }
              : null,
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: BrdyColors.onAccent,
                  ),
                )
              : const Text('START ROUND'),
        ),
        if (course == null) ...[
          const Gap(BrdySpacing.xs),
          Text(
            'Search and select a course to start',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: BrdyColors.onSurfaceMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
