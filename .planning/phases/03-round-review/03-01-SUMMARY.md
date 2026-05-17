---
phase: "03-round-review"
plan: 01
subsystem: "round-review-providers"
tags: [riverpod, whs, scorecard, stats, drift, code-gen]
dependency_graph:
  requires:
    - lib/features/shot_capture/providers/hole_list_provider.dart
    - lib/features/shot_capture/providers/course_for_round_provider.dart
    - lib/data/local/database/daos/round_dao.dart
    - lib/domain/enums/hole_outcome.dart
    - lib/theme/brdy_colors.dart
  provides:
    - lib/features/round_review/providers/scorecard_provider.dart
    - lib/features/round_review/providers/stats_provider.dart
    - lib/features/round_review/providers/whs_differential_provider.dart
  affects: []
tech_stack:
  added: []
  patterns:
    - "@riverpod auto-dispose with family parameter (int roundId)"
    - "ScorecardData/StatsData/WhsDifferential plain Dart view-model classes (no freezed)"
    - ".whenData().value pattern for Stream AsyncValue unwrapping"
    - "WHS Course Handicap formula with ESC cap per hole"
key_files:
  created:
    - lib/features/round_review/providers/scorecard_provider.dart
    - lib/features/round_review/providers/scorecard_provider.g.dart
    - lib/features/round_review/providers/stats_provider.dart
    - lib/features/round_review/providers/stats_provider.g.dart
    - lib/features/round_review/providers/whs_differential_provider.dart
    - lib/features/round_review/providers/whs_differential_provider.g.dart
  modified: []
decisions:
  - "Plain Dart view-model classes (no freezed) for HoleRow, ScorecardSubtotal, ScorecardData, StatsData, WhsDifferential — these are computation results not domain entities"
  - "statsProvider uses Future<StatsData?> (async) to accommodate courseForRound and roundDao being futures"
  - "WHS Course Handicap fallback: if courseRating null, omit (courseRating - par) term rather than returning N/A"
  - "ESC cap applied to all holes including pickup outcomes — pickup already equals the cap (par+2+handicap_strokes), no special casing needed"
  - "triples field always 0 in Phase 3 — HoleOutcome enum has no triple value; documented with comment"
metrics:
  duration: "~15 minutes"
  completed_date: "2026-05-18"
  tasks_completed: 2
  files_created: 6
---

# Phase 3 Plan 01: Round Review Providers + WHS Logic Summary

Three typed @riverpod providers powering Round Review: scorecard aggregation with per-hole outcome colours, full stat computation including GIR%/FIR%/netScore, and WHS differential via ESC-adjusted AGS formula.

## What Was Built

### Task 1: ScorecardData model and scorecardProvider (commit: 124cc3a)

Created `lib/features/round_review/providers/scorecard_provider.dart` with:

- `HoleRow` — per-hole view-model: holeNumber, par, outcomeAbbr (E/B/–/+1/+2/P), outcomeColor (gold/accent/onSurface/onSurfaceMuted/destructive), putts
- `ScorecardSubtotal` — label, totalStrokes, scoreToPar for front9/back9
- `ScorecardData` — 18 HoleRows + front9/back9 subtotals
- `scorecardProvider` (@riverpod auto-dispose) watches holeListProvider(roundId) stream; returns `ScorecardData?` via `.whenData().value`

### Task 2: StatsData, WhsDifferential providers + build_runner (commit: ddce350)

**stats_provider.dart:**
- `StatsData` — 16 fields: totalStrokes, scoreToPar, netScore, all outcome counts (eagles/birdies/pars/bogeys/doubles/triples=0/pickups), totalPutts, puttsPerGir, girCount, girPercent, fairwaysHit, firPercent
- `StatsData.empty()` factory returns zero state
- `statsProvider` (@riverpod async) computes WHS Course Handicap = round(handicapIndex × (slope/113) + (courseRating − par)); uses fallback if courseRating null
- FIR denominator excludes par-3 holes; puttsPerGir uses only GIR holes

**whs_differential_provider.dart:**
- `WhsDifferential` — displayValue (formatted "12.3"), isIndicative, isUnavailable, indicativeLabel
- `whsDifferentialProvider` (@riverpod async) implements full WHS formula:
  1. Returns "N/A" if courseRating or slope null
  2. Applies ESC cap per hole: min(rawScore, par + 2 + handicap_strokes_on_hole)
  3. handicap_strokes_on_hole = 1 if playingHandicap >= strokeIndex, else 0
  4. Differential = (AGS − courseRating) × 113 ÷ slope, formatted via intl NumberFormat('0.0')
  5. Sets isIndicative=true and indicativeLabel when fewer than 18 outcomes

**build_runner:** Exit 0, 85 outputs generated, zero conflicts.

## Verification Results

| Check | Result |
|-------|--------|
| ls providers/ shows 3 .dart + 3 .g.dart | PASS |
| flutter analyze providers/ | No issues found |
| grep keepAlive *.dart | 0 (all auto-dispose) |
| holeListProvider/courseForRoundProvider referenced | PASS (scorecard, stats, whs) |

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Renamed local function `_subtotal` to `subtotal`**
- **Found during:** Task 1 — flutter analyze lint check
- **Issue:** `no_leading_underscores_for_local_identifiers` lint rule — local functions cannot start with underscore
- **Fix:** Renamed `_subtotal(...)` to `subtotal(...)` in scorecard_provider.dart
- **Files modified:** lib/features/round_review/providers/scorecard_provider.dart
- **Commit:** ddce350 (included in Task 2 commit as the fix preceded build_runner)

None other — plan executed essentially as written.

## Known Stubs

None — all three providers compute from live Drift data via holeListProvider and courseForRoundProvider.

## Self-Check

- [x] scorecard_provider.dart exists and has HoleRow, ScorecardSubtotal, ScorecardData, @riverpod
- [x] stats_provider.dart exists with StatsData and @riverpod
- [x] whs_differential_provider.dart exists with WhsDifferential and @riverpod
- [x] All three .g.dart files generated (build_runner exit 0)
- [x] flutter analyze: no issues
- [x] No keepAlive in any provider file
- [x] Commit 124cc3a: Task 1
- [x] Commit ddce350: Task 2
