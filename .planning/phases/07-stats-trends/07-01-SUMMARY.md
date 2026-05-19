---
phase: 07-stats-trends
plan: 01
subsystem: ui
tags: [fl_chart, riverpod, stats, charts, flutter]

# Dependency graph
requires:
  - phase: 06-round-history
    provides: completedRoundsProvider Stream<List<Round>>
  - phase: 03-round-review
    provides: whsDifferentialProvider, statsProvider, StatsData, WhsDifferential

provides:
  - trendChartProvider — Future<List<FlSpot>> from last 20 completed rounds WHS differentials
  - crossRoundAveragesProvider — Future<CrossRoundAverages?> with avgScoreToPar, avgPutts, avgFirPercent, avgGirPercent, roundCount
  - CrossRoundAverages plain Dart class
  - fl_chart 0.71.0 dependency pinned in pubspec.yaml

affects: [07-02-stats-ui, stats-screen, trend-chart]

# Tech tracking
tech-stack:
  added: [fl_chart ^0.71.0]
  patterns: [cross-provider async chaining with ref.watch(...future) inside async loops]

key-files:
  created:
    - lib/features/stats/providers/trend_chart_provider.dart
    - lib/features/stats/providers/trend_chart_provider.g.dart
    - lib/features/stats/providers/cross_round_averages_provider.dart
    - lib/features/stats/providers/cross_round_averages_provider.g.dart
  modified:
    - pubspec.yaml
    - pubspec.lock

key-decisions:
  - "fl_chart pinned to ^0.71.0 (not latest 1.x) — 1.x requires Flutter >=3.27.4; project runs 3.24.5"
  - "CrossRoundAverages uses plain Dart class (const constructor) — no freezed, consistent with Phase 3 pattern"
  - "trendChartProvider uses index i for x-axis (contiguous), not round.id — gaps from isUnavailable rounds are acceptable in v1"
  - "Both providers use @riverpod auto-dispose (no keepAlive) — consistent with existing provider pattern"

patterns-established:
  - "Cross-round aggregation pattern: await ref.watch(completedRoundsProvider.future) then iterate with await ref.watch(perRoundProvider(id).future)"

requirements-completed: [STAT-01, STAT-02, STAT-03]

# Metrics
duration: 8min
completed: 2026-05-20
---

# Phase 7 Plan 01: Stats & Trends — Data Providers Summary

**fl_chart 0.71.0 pinned + trendChartProvider (List<FlSpot> from WHS differentials) and crossRoundAveragesProvider (CrossRoundAverages? with per-round stat averages) implemented using ref.watch async chaining over completedRoundsProvider**

## Performance

- **Duration:** ~8 min
- **Started:** 2026-05-20T00:00:00Z
- **Completed:** 2026-05-20T00:08:00Z
- **Tasks:** 2
- **Files modified:** 6

## Accomplishments
- Pinned fl_chart to ^0.71.0 in pubspec.yaml, compatible with project Flutter 3.24.5
- Created trendChartProvider returning Future<List<FlSpot>> from up to 20 most recent completed rounds, with isUnavailable exclusion and oldest-first x-axis ordering
- Created crossRoundAveragesProvider returning Future<CrossRoundAverages?> averaging scoreToPar, totalPutts, firPercent, girPercent across all completed rounds
- Generated Riverpod boilerplate via build_runner (both .g.dart files, 0 errors)

## Task Commits

Each task was committed atomically:

1. **Task 1: Pin fl_chart dependency** - `e97c971` (chore)
2. **Task 2: trendChartProvider + crossRoundAveragesProvider** - `8dfb531` (feat)

**Plan metadata:** TBD (docs commit)

## Files Created/Modified
- `pubspec.yaml` - Added fl_chart: ^0.71.0 dependency
- `pubspec.lock` - Updated lock file
- `lib/features/stats/providers/trend_chart_provider.dart` - trendChartProvider returning Future<List<FlSpot>>
- `lib/features/stats/providers/trend_chart_provider.g.dart` - Generated Riverpod boilerplate
- `lib/features/stats/providers/cross_round_averages_provider.dart` - crossRoundAveragesProvider + CrossRoundAverages class
- `lib/features/stats/providers/cross_round_averages_provider.g.dart` - Generated Riverpod boilerplate

## Decisions Made
- fl_chart version pinned to ^0.71.0 not latest 1.x — 1.x requires Flutter >=3.27.4 which exceeds the project constraint of 3.24.5
- CrossRoundAverages is a plain Dart class with const constructor — consistent with Phase 3 pattern (StatsData, WhsDifferential), no freezed overhead
- x-axis in trendChartProvider uses loop index `i` (contiguous), not round.id — gaps from isUnavailable rounds are acceptable in v1 per plan specification
- Both providers use @riverpod lowercase (auto-dispose) — consistent with all existing providers in codebase

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Both providers ready for consumption by 07-02 Stats UI plan
- trendChartProvider supplies List<FlSpot> directly consumable by fl_chart LineChartData
- crossRoundAveragesProvider supplies CrossRoundAverages? for stat summary cards
- No blockers

---
*Phase: 07-stats-trends*
*Completed: 2026-05-20*
