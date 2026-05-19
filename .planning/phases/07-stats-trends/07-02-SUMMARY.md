---
phase: 07-stats-trends
plan: 02
subsystem: ui
tags: [fl_chart, riverpod, stats, flutter, charts, navigation]

# Dependency graph
requires:
  - phase: 07-01
    provides: trendChartProvider, crossRoundAveragesProvider, CrossRoundAverages
  - phase: 06-round-history
    provides: completedRoundsProvider

provides:
  - DifferentialLineChart widget — fl_chart LineChart with accent styling + NOT ENOUGH DATA guard
  - AverageStatCard widget — label/value card with em dash fallback
  - StatsScreen — ConsumerWidget with chart + 4 average cards
  - /stats route in GoRouter with redirect allowlist
  - STATS button on SetupScreen navigating to /stats

affects: [setup-screen, router, stats-screen]

# Tech tracking
tech-stack:
  added: []
  patterns: [AsyncValue.when() for provider-driven UI, GridView.count with shrinkWrap for stat cards]

key-files:
  created:
    - lib/features/stats/widgets/differential_line_chart.dart
    - lib/features/stats/widgets/average_stat_card.dart
    - lib/features/stats/stats_screen.dart
  modified:
    - lib/app/router.dart
    - lib/features/setup/setup_screen.dart

key-decisions:
  - "AverageStatCard uses Container + BrdyColors.surface background (matching existing StatCard pattern from Phase 3 — no Card widget overhead)"
  - "DifferentialLineChart uses spots.length < 2 guard (renders text widget, no LineChart instantiated — prevents fl_chart RangeError)"
  - "StatsScreen uses _formatScoreToPar file-level private function (avoids class method noise, consistent with single-file helpers pattern)"
  - "/stats allowlist entry added immediately after /round-review readOnly allowlist — stats is read-only, intentionally accessible during active round"

# Metrics
duration: 12min
completed: 2026-05-20
---

# Phase 7 Plan 02: Stats Screen UI Summary

**StatsScreen ConsumerWidget with DifferentialLineChart (fl_chart) and 4 AverageStatCard widgets, wired to Plan 07-01 providers, /stats route added to GoRouter allowlist, STATS button added to SetupScreen**

## Performance

- **Duration:** ~12 min
- **Started:** 2026-05-20T00:08:00Z
- **Completed:** 2026-05-20T00:20:00Z
- **Tasks:** 2 (+ checkpoint pending human verify)
- **Files modified:** 5

## Accomplishments

- Created `DifferentialLineChart` wrapping fl_chart `LineChart` with BrdyColors accent styling, left axis labels in SometypeMono 10sp, no vertical grid, below-bar fill at 8% opacity. Guard: `spots.length < 2` renders 'NOT ENOUGH DATA' text — no LineChart instantiated, RangeError prevented (T-07-03 mitigated).
- Created `AverageStatCard` displaying label/value with em dash fallback when value is null. Uses BrdyColors.surface background consistent with Phase 3 StatCard.
- Created `StatsScreen` ConsumerWidget with HANDICAP TREND section (DifferentialLineChart) and AVERAGES ALL ROUNDS section (2x2 GridView of AverageStatCard).
- Added `/stats` GoRoute and allowlist entry to router.dart (T-07-04 accepted: stats is read-only, safe during active round).
- Added STATS OutlinedButton above ROUND HISTORY button on SetupScreen.

## Task Commits

1. **Task 1: DifferentialLineChart + AverageStatCard** - `9ce9675` (feat)
2. **Task 2: StatsScreen + router + setup button** - `c578e08` (feat)

## Files Created/Modified

- `lib/features/stats/widgets/differential_line_chart.dart` — DifferentialLineChart widget
- `lib/features/stats/widgets/average_stat_card.dart` — AverageStatCard widget
- `lib/features/stats/stats_screen.dart` — StatsScreen ConsumerWidget
- `lib/app/router.dart` — /stats route + allowlist entry + StatsScreen import
- `lib/features/setup/setup_screen.dart` — STATS OutlinedButton above ROUND HISTORY

## Deviations from Plan

None - plan executed exactly as written.

## Threat Surface Scan

No new threat surface beyond what the plan's threat model covers:
- T-07-03 (RangeError on empty spots): mitigated by `spots.length < 2` guard
- T-07-04 (/stats allowlist during active round): accepted — stats is read-only

## Known Stubs

None — all data is wired to live providers (trendChartProvider and crossRoundAveragesProvider).

## Self-Check: PASSED

- `lib/features/stats/widgets/differential_line_chart.dart` — exists
- `lib/features/stats/widgets/average_stat_card.dart` — exists
- `lib/features/stats/stats_screen.dart` — exists
- Commit `9ce9675` — exists
- Commit `c578e08` — exists
- `/stats` appears twice in router.dart (allowlist + GoRoute) — confirmed
- `context.push('/stats')` in setup_screen.dart — confirmed
- `spots.length < 2` guard in differential_line_chart.dart — confirmed

## Next Phase Readiness

- Human-verify checkpoint pending (Test A/B/C/D)
- On approval: Stats & Trends feature (Phase 07) complete
