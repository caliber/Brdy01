---
phase: 02-shot-capture
plan: 03
subsystem: ui
tags: [flutter, riverpod, shot-capture, fairway-gir-toggles, hole-nav-drawer, p2-08-fix]

# Dependency graph
requires:
  - phase: 02-shot-capture
    plan: 02
    provides: ShotCaptureScreen, OutcomeButtonGrid, HoleHeader, ScoreBar, HoleScoreNotifier, activeHoleIndexProvider

provides:
  - FairwayGirToggles: fairway (par3 gate) + GIR + voice-stub toggles writing to Drift
  - HoleNavDrawer: 18-chip animated strip with outcome colours, future-chip lock, NOW chip
  - HoleHeader.onHoleNumberTap: GestureDetector wrapping hole number to toggle nav strip
  - P2-08 fix: activeHoleIndexProvider.set(0) in RoundSetupNotifier.createRound()
  - Full ShotCaptureScreen assembly: nav strip toggle state, HoleNavDrawer in _TopZone

affects: [round-review, phase-03]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - if (holePar != 3) for par3 gate — removes widget from tree entirely (not Visibility)
    - HoleOutcome.values.byName() for outcome→chip-colour mapping in HoleNavDrawer
    - AnimatedContainer height 0→56dp for drawer reveal animation
    - GestureDetector on hole number only (not chevrons) for toggle — avoids InkWell overflow
    - FairwayGirToggles replaces _ToggleButton stubs; _ToggleButton removed from OutcomeButtonGrid

key-files:
  created:
    - lib/features/shot_capture/widgets/fairway_gir_toggles.dart
    - lib/features/shot_capture/widgets/hole_nav_drawer.dart
  modified:
    - lib/features/shot_capture/shot_capture_screen.dart
    - lib/features/shot_capture/widgets/hole_header.dart
    - lib/features/shot_capture/widgets/outcome_button_grid.dart
    - lib/features/setup/providers/round_setup_notifier.dart

key-decisions:
  - "FairwayGirToggles extracted as separate ConsumerWidget in outcome_button_grid.dart — not inlined in OutcomeButtonGrid.build(); this keeps the toggle strip file reusable and the grid clean"
  - "HoleNavDrawer placed in _TopZone Column below HoleHeader — not as overlay; matches UI-SPEC strip placement"
  - "HoleHeader extended with onHoleNumberTap VoidCallback? — screen controls the toggle state (_navStripOpen bool in _ShotCaptureScreenState), header fires the callback"
  - "_ToggleButton private class removed from outcome_button_grid.dart — superseded by FairwayGirToggles; no backward-compat issue as it was private"

# Metrics
duration: 8min
completed: 2026-05-17T06:41:00Z
---

# Phase 2 Plan 03: FairwayGirToggles, HoleNavDrawer, and P2-08 Fix Summary

**FairwayGirToggles (par3 gate + Drift writes), animated HoleNavDrawer with outcome-coloured chips, HoleHeader tap-to-toggle wiring, and P2-08 hole-index-reset fix — completing all Phase 2 requirements**

## Performance

- **Duration:** ~8 min
- **Started:** 2026-05-17T06:33:00Z
- **Completed:** 2026-05-17T06:41:00Z
- **Tasks:** 2
- **Files modified:** 6 (2 new, 4 modified)

## Accomplishments

- Created `FairwayGirToggles`: ConsumerWidget with Drift-wired fairway toggle (removed from tree on par 3 via `if (holePar != 3)`), GIR toggle, and VOICE stub; HapticFeedback on each tap; Semantics labels for accessibility
- Created `HoleNavDrawer`: AnimatedContainer 0→56dp, 18 outcome-coloured chips via `HoleOutcome.values.byName()`, future chips locked (`onTap: null`), NOW chip visible when `activeHoleIndex < highestScoredIndex`, all navigation via `activeHoleIndexProvider.notifier.set()` (never context.go/push)
- Updated `HoleHeader`: added `onHoleNumberTap VoidCallback?` wrapping hole-number Stack in GestureDetector + selectionClick haptic
- Updated `ShotCaptureScreen`: added `_navStripOpen bool`, wired to `_TopZone` which now includes `HoleNavDrawer`; replaced fairway/GIR stubs in `OutcomeButtonGrid` by delegating to `FairwayGirToggles`; removed dead `_ToggleButton` class
- Applied P2-08 fix: `RoundSetupNotifier.createRound()` now calls `activeHoleIndexProvider.notifier.set(0)` synchronously before returning, preventing new rounds from starting on hole 18
- flutter analyze: zero issues; flutter test: 1/1 passing

## Task Commits

1. **Task 1: FairwayGirToggles, HoleNavDrawer and P2-08 fix** — `8c33e46` (feat)
2. **Task 2: Wire full ShotCaptureScreen assembly and flutter analyze clean** — `fe54e5f` (feat)

## Files Created/Modified

- `lib/features/shot_capture/widgets/fairway_gir_toggles.dart` — ConsumerWidget; fairway (par3 gate), GIR, VOICE stub toggles with Drift writes
- `lib/features/shot_capture/widgets/hole_nav_drawer.dart` — ConsumerWidget; AnimatedContainer 0→56dp, 18 chips + NOW chip, outcome colour mapping via HoleOutcome enum
- `lib/features/shot_capture/widgets/hole_header.dart` — Added `onHoleNumberTap VoidCallback?` parameter and GestureDetector wrapping hole number Stack
- `lib/features/shot_capture/widgets/outcome_button_grid.dart` — Replaced toggle strip stubs with `FairwayGirToggles(...)`, removed unused `_ToggleButton` class and `fairwayHit`/`gir` local variables, added import for `fairway_gir_toggles.dart`
- `lib/features/shot_capture/shot_capture_screen.dart` — Added `_navStripOpen bool`, updated `_TopZone` to include `HoleNavDrawer`, wired `onHoleNumberTap` callback; added imports for `hole_nav_drawer.dart`
- `lib/features/setup/providers/round_setup_notifier.dart` — Added import for `active_hole_index_provider.dart`; added `activeHoleIndexProvider.notifier.set(0)` after `activeRoundIdProvider.notifier.set(roundId)` (P2-08 fix)

## Decisions Made

- `FairwayGirToggles` is a dedicated ConsumerWidget file rather than inlining the toggles back into `OutcomeButtonGrid.build()`. Keeps the grid clean and makes toggle logic independently testable.
- `HoleNavDrawer` uses `AnimatedContainer` (not `flutter_animate`) for height reveal — simpler and the plan suggested it. No new package dependency.
- `_navStripOpen` state lives in `_ShotCaptureScreenState` (not a provider) — it's pure UI state, transient per screen session. No Drift persistence needed.
- P2-08 fix is synchronous inside `createRound()` before the `return roundId` — ordering guarantee satisfied. The caller's `context.go()` fires after `await createRound()` returns, so the index is reset before navigation.

## Deviations from Plan

None — plan executed exactly as written.

## Known Stubs

| Stub | File | Reason |
|------|------|--------|
| VOICE toggle `onTap: () {}` (no-op) | fairway_gir_toggles.dart | Phase 5 will wire speech_to_text; Phase 2 stub renders correctly |

The VOICE stub is intentional and documented. It does not prevent any Phase 2 goal from being achieved.

## Threat Surface Scan

No new network endpoints, auth paths, file access patterns, or schema changes introduced. All user input flows through typed providers and Drift write-through. Navigation uses `activeHoleIndexProvider.notifier.set()` only (no route pushes). All threats in the plan's threat model are mitigated:

- T-02-10: Future chips have `onTap: null` — verified by grep and manual code review
- T-02-11: `setFairwayHit`/`setGir` guard `if (current == null) return` — pre-existing in HoleScoreNotifier
- T-02-12: P2-08 fix is synchronous inside `createRound()` — ordering guaranteed
- T-02-13: Fairway toggle never writes `null`; only writes `true`/`false`; par 3 null guard is in HoleScoreNotifier.recordOutcome (plan 01)

## Self-Check: PASSED

Files created/modified:
- `lib/features/shot_capture/widgets/fairway_gir_toggles.dart` — FOUND
- `lib/features/shot_capture/widgets/hole_nav_drawer.dart` — FOUND
- `lib/features/shot_capture/widgets/hole_header.dart` — FOUND (modified)
- `lib/features/shot_capture/widgets/outcome_button_grid.dart` — FOUND (modified)
- `lib/features/shot_capture/shot_capture_screen.dart` — FOUND (modified)
- `lib/features/setup/providers/round_setup_notifier.dart` — FOUND (modified)

Commits:
- `8c33e46` — feat(02-03): add FairwayGirToggles, HoleNavDrawer and P2-08 index-reset fix
- `fe54e5f` — feat(02-03): wire full ShotCaptureScreen assembly and flutter analyze clean

flutter analyze: zero issues
flutter test: 1/1 passing

---
*Phase: 02-shot-capture*
*Completed: 2026-05-17*
