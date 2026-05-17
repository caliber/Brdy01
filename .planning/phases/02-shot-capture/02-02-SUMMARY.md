---
phase: 02-shot-capture
plan: 02
subsystem: ui
tags: [flutter, riverpod, shot-capture, outcome-buttons, undo-toast, score-badge, hole-header]

# Dependency graph
requires:
  - phase: 02-shot-capture
    plan: 01
    provides: HoleScoreNotifier, holeListProvider, runningScoreProvider, courseForRoundProvider, highestScoredHoleIndexProvider, roundCompleteProvider, activeHoleIndexProvider

provides:
  - ShotCaptureScreen: ConsumerStatefulWidget with two-zone layout, ref.listen round completion, undo toast orchestration
  - OutcomeButtonGrid: 4+4 button layout with dot indicators, BIRDIE GestureDetector double-tap EAGLE, scale animations, putts controls, NEXT button, pagination dots, bottom toggle strip stub
  - HoleHeader: course info row, giant 96dp hole number with score badge Stack, SHOTS total, left/right chevrons
  - ScoreBar: accent pill badge E/+n/-n reactive from runningScoreProvider

affects: [02-03-PLAN.md, round-review]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - Two-zone layout: Expanded(flex:55) top + Expanded(flex:45) bottom separated by 1dp divider
    - ConsumerStatefulWidget for screen-level state (_lastScoredHoleIndex for undo)
    - ref.listen<bool>(roundCompleteProvider) in build() for round completion navigation
    - GestureDetector on BIRDIE only for onDoubleTap EAGLE — prevents 300ms delay on all other buttons
    - _handleOutcomeTapped stores _lastScoredHoleIndex BEFORE Drift write (captures correct pre-advance index)
    - completeRound called when holeIndex==17, BEFORE roundCompleteProvider navigates
    - StatefulWidget press-animation via onTapDown/onTapUp setState + flutter_animate target

key-files:
  created:
    - lib/features/shot_capture/widgets/hole_header.dart
    - lib/features/shot_capture/widgets/score_bar.dart
    - lib/features/shot_capture/widgets/outcome_button_grid.dart
  modified:
    - lib/features/shot_capture/shot_capture_screen.dart

key-decisions:
  - "ShotCaptureScreen is ConsumerStatefulWidget (not ConsumerWidget) — needs _lastScoredHoleIndex local state for undo tracking"
  - "completeRound(roundId, DateTime.now()) called at holeIndex==17 BEFORE roundCompleteProvider fires — ensures completedAt is set for crash recovery"
  - "BIRDIE uses GestureDetector with onDoubleTap; all other buttons use InkWell — prevents 300ms tap delay on the entire grid"
  - "persist: false omitted (Flutter 3.24.5 does not have this parameter); SnackBarBehavior.floating used instead; add persist: false when upgrading to Flutter 3.38+"
  - "SHOTS total computed from par + outcome offset, not from putts count"
  - "Fairway/GIR toggle logic stubbed with TODO(02-03) comments — visual state reads from holeState but writes are no-op"

patterns-established:
  - "Two-zone ShotCaptureScreen layout: Expanded(flex:55) + Container(1dp divider) + Expanded(flex:45)"
  - "Undo pattern: store _lastScoredHoleIndex before write → show toast → on UNDO: undoOutcome() + set activeHoleIndex back"
  - "Press animation: StatefulWidget with onTapDown/onTapUp setState(_pressing) + flutter_animate .animate(target:) .scale()"

requirements-completed: [SHOT-01, SHOT-02, SHOT-03, SHOT-04, SHOT-10, SHOT-11]

# Metrics
duration: 6min
completed: 2026-05-17T06:34:00Z
---

# Phase 2 Plan 02: Shot Capture UI Summary

**Two-zone ShotCaptureScreen with outcome button grid (EAGLE double-tap, undo toast, score badge), HoleHeader with giant hole number, and ScoreBar reactive pill — 4 files replacing the placeholder screen**

## Performance

- **Duration:** ~6 min
- **Started:** 2026-05-17T06:28:32Z
- **Completed:** 2026-05-17T06:34:00Z
- **Tasks:** 2
- **Files modified:** 4 (1 replaced, 3 new)

## Accomplishments

- Created ScoreBar: accent pill badge with E/+n/-n display, flutter_animate scale pulse on score change, reactive from runningScoreProvider
- Created HoleHeader: course info row (truncated at 16 chars), giant 96dp JetBrains Mono hole number with fade animation, ScoreBar Stack at top-right, SHOTS total from hole outcomes, left/right chevrons with disabled states
- Created OutcomeButtonGrid: 4+4 button layout, dot indicators, BIRDIE with GestureDetector double-tap for EAGLE, putts SUB/ADD controls, NEXT button with opacity/disabled state, pagination dots, bottom toggle strip stub
- Replaced ShotCaptureScreen placeholder: ConsumerStatefulWidget with two-zone layout, ref.listen round completion, _handleOutcomeTapped write-then-advance pattern, _showUndoToast with 4-second SnackBar UNDO action, _handleUndo clearing Drift outcome
- flutter analyze reports zero issues across all 4 files

## Task Commits

1. **Task 1: Build HoleHeader and ScoreBar widgets** — `24a97b1` (feat)
2. **Task 2: Build OutcomeButtonGrid and replace ShotCaptureScreen** — `596e8fb` (feat)

## Files Created/Modified

- `lib/features/shot_capture/widgets/score_bar.dart` — ConsumerWidget; accent pill badge with E/+n/-n; flutter_animate scale pulse keyed on score
- `lib/features/shot_capture/widgets/hole_header.dart` — ConsumerWidget; course info row, giant 96dp hole number, ScoreBar Stack, SHOTS total, chevrons
- `lib/features/shot_capture/widgets/outcome_button_grid.dart` — ConsumerWidget; 4+4 buttons, BIRDIE double-tap, putts controls, NEXT, pagination dots, toggle strip
- `lib/features/shot_capture/shot_capture_screen.dart` — Replaced placeholder with full ConsumerStatefulWidget; two-zone layout; undo toast; round completion navigation

## Decisions Made

- `ShotCaptureScreen` is `ConsumerStatefulWidget` (not `ConsumerWidget`) — `_lastScoredHoleIndex` local state needed for undo tracking across the toast lifetime
- `completeRound` called at `holeIndex == 17` before `roundCompleteProvider` fires navigation — ensures `completedAt` is set in Drift for crash recovery (Phase 3 gate)
- BIRDIE uses `GestureDetector` with `onDoubleTap`; all other buttons use `InkWell` — placing `onDoubleTap` on a parent would add 300ms delay to ALL button taps
- Fairway/GIR toggle writes are no-op stubs in plan 02 (TODO comments left); visual state reads correctly from `holeState` — wired in plan 03
- SHOTS total = sum of (par + outcome_offset) across scored holes, NOT putts count

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Compatibility] `persist: false` omitted — not available in Flutter 3.24.5**
- **Found during:** Task 2 (writing SnackBar code)
- **Issue:** Plan specified `persist: false` for "Flutter 3.38+" auto-dismiss behavior. The project runs Flutter 3.24.5 — this parameter does not exist and would cause a compile error.
- **Fix:** Used `behavior: SnackBarBehavior.floating` instead (standard Flutter pattern for dismissible snackbars). Added inline comment: "add `persist: false` when upgrading to Flutter 3.38+"
- **Files modified:** `lib/features/shot_capture/shot_capture_screen.dart`
- **Commit:** 596e8fb

---

**Total deviations:** 1 auto-fixed (Rule 1 - compatibility)
**Impact on plan:** No behavioral difference in Flutter 3.24.5. SnackBars with `SnackBarAction` auto-dismiss at the configured duration by default. The comment ensures the upgrade path is documented.

## Known Stubs

| Stub | File | Reason |
|------|------|--------|
| Fairway toggle `onTap: null` (TODO 02-03) | outcome_button_grid.dart:199 | Logic wired in plan 03; visual state reads correctly from holeState |
| GIR toggle `onTap: null` (TODO 02-03) | outcome_button_grid.dart:213 | Logic wired in plan 03; visual state reads correctly from holeState |

These stubs are intentional and documented. They do NOT prevent the plan's goal (working scoring tool) from being achieved — outcome buttons, EAGLE double-tap, undo toast, score badge, and hole navigation all function end-to-end.

## Threat Surface Scan

No new network endpoints, auth paths, file access patterns, or schema changes introduced. All user input flows through typed `HoleOutcome` enum (no injection risk). Navigation uses `context.go()` only (no push). Within threat model defined in plan.

## Self-Check: PASSED

Files created/modified:
- `lib/features/shot_capture/widgets/score_bar.dart` — FOUND
- `lib/features/shot_capture/widgets/hole_header.dart` — FOUND  
- `lib/features/shot_capture/widgets/outcome_button_grid.dart` — FOUND
- `lib/features/shot_capture/shot_capture_screen.dart` — FOUND (modified)

Commits:
- `24a97b1` — feat(02-02): build HoleHeader and ScoreBar widgets
- `596e8fb` — feat(02-02): build OutcomeButtonGrid and replace ShotCaptureScreen

flutter analyze: zero issues

---
*Phase: 02-shot-capture*
*Completed: 2026-05-17*
