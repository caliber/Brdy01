---
phase: 02-shot-capture
plan: 01
subsystem: database
tags: [drift, riverpod, sqlite, hole-scoring, providers]

# Dependency graph
requires:
  - phase: 01-foundation-setup
    provides: AppDatabase, RoundDao, Holes table, HoleOutcome enum, CourseModel, app_database_provider

provides:
  - HoleDao with insertOrUpdateHole (SELECT-then-branch upsert), getHolesForRound, watchHolesForRound
  - HoleScoreNotifier AsyncNotifier family — recordOutcome, setPutts, setFairwayHit, setGir, undoOutcome
  - holeListProvider(roundId) StreamProvider family — live Drift stream of hole rows
  - runningScoreProvider(roundId) — derived int? score-vs-par
  - courseForRoundProvider(roundId) — FutureProvider<CourseModel?> from rounds.courseJson
  - highestScoredHoleIndexProvider(roundId) — derived 0-based index of last scored hole
  - roundCompleteProvider(roundId) — derived bool when 18 holes have outcomes

affects: [02-02-PLAN.md, 02-03-PLAN.md, shot-capture UI, round-review]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - SELECT-then-branch upsert in HoleDao (no schema bump, no DoUpdate)
    - Drift write-through: every HoleScoreNotifier mutation writes Drift first, then ref.invalidateSelf()
    - ref.watch(appDatabaseProvider) in build(), ref.read in async mutations
    - switch expression for exhaustive HoleOutcome offset mapping

key-files:
  created:
    - lib/features/shot_capture/providers/hole_score_notifier.dart
    - lib/features/shot_capture/providers/hole_list_provider.dart
    - lib/features/shot_capture/providers/running_score_provider.dart
    - lib/features/shot_capture/providers/course_for_round_provider.dart
    - lib/features/shot_capture/providers/highest_scored_hole_index_provider.dart
    - lib/features/shot_capture/providers/round_complete_provider.dart
  modified:
    - lib/data/local/database/daos/hole_dao.dart

key-decisions:
  - "HoleDao upsert uses SELECT-then-branch (Option A) — no schema version bump, no DoUpdate; acceptable for single-user sequential taps"
  - "runningScoreProvider parses stored strings via HoleOutcome.values.byName() — never raw string comparison"
  - "courseForRoundProvider reads from Drift rounds.courseJson, not Hive — survives crash recovery even if Hive cache is cleared"
  - "All 6 new providers are auto-dispose (@riverpod); no new keepAlive providers introduced"

patterns-established:
  - "Drift write-through: await db.holeDao.insertOrUpdateHole(companion) then ref.invalidateSelf() — never update Riverpod state directly"
  - "ref.watch(appDatabaseProvider) in build() only; ref.read(appDatabaseProvider) in all async mutation methods"
  - "HoleScoreNotifier does NOT advance activeHoleIndexProvider — that is the screen widget's responsibility"

requirements-completed: [SHOT-01, SHOT-10, SHOT-11, SHOT-12]

# Metrics
duration: 4min
completed: 2026-05-17
---

# Phase 2 Plan 01: Shot Capture Data Foundation Summary

**HoleDao upsert + six Riverpod providers (HoleScoreNotifier, holeList, runningScore, courseForRound, highestScoredHoleIndex, roundComplete) with Drift write-through and auto-dispose families**

## Performance

- **Duration:** 4 min
- **Started:** 2026-05-17T06:22:14Z
- **Completed:** 2026-05-17T06:25:18Z
- **Tasks:** 1
- **Files modified:** 13 (7 source + 6 generated)

## Accomplishments

- Completed HoleDao with upsert semantics (SELECT-then-branch, no schema bump) and live stream query
- Created HoleScoreNotifier AsyncNotifier family with five mutation methods, all using Drift write-through before ref.invalidateSelf()
- Created five derived/stream providers covering live hole list, running score, course data, highest scored index, and round completion status
- build_runner exits 0 and flutter analyze reports zero issues

## Task Commits

Each task was committed atomically:

1. **Task 1: Implement HoleDao methods and create all six providers** - `f976370` (feat)

## Files Created/Modified

- `lib/data/local/database/daos/hole_dao.dart` — Added insertOrUpdateHole (upsert), getHolesForRound, watchHolesForRound
- `lib/features/shot_capture/providers/hole_score_notifier.dart` — AsyncNotifier family; recordOutcome, setPutts, setFairwayHit, setGir, undoOutcome
- `lib/features/shot_capture/providers/hole_list_provider.dart` — StreamProvider family watching Drift for live hole data
- `lib/features/shot_capture/providers/running_score_provider.dart` — Derived int? score-vs-par from holeListProvider
- `lib/features/shot_capture/providers/course_for_round_provider.dart` — FutureProvider reading CourseModel from rounds.courseJson
- `lib/features/shot_capture/providers/highest_scored_hole_index_provider.dart` — Derived 0-based index of last scored hole
- `lib/features/shot_capture/providers/round_complete_provider.dart` — Derived bool when 18 holes have outcomes

## Decisions Made

- HoleDao upsert uses SELECT-then-branch (Option A from RESEARCH.md) — no schema version bump, no DoUpdate; single-user app with sequential taps means no concurrent write risk
- `runningScoreProvider` parses stored strings via `HoleOutcome.values.byName()` — never raw string comparison (protects against T-02-02 ArgumentError threat)
- `courseForRoundProvider` reads from Drift `rounds.courseJson`, not Hive — more reliable after crash recovery

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Removed unary plus operator from switch expression arms**
- **Found during:** Task 1 (build_runner run)
- **Issue:** `+1` and `+2` in switch expression arms caused parse error "Expected an identifier" — Dart switch expressions do not accept unary `+` as a literal value prefix
- **Fix:** Changed `+1` → `1` and `+2` → `2` in `running_score_provider.dart` switch arms (semantically identical)
- **Files modified:** `lib/features/shot_capture/providers/running_score_provider.dart`
- **Verification:** build_runner succeeded; flutter analyze reports zero issues
- **Committed in:** f976370 (Task 1 commit)

---

**Total deviations:** 1 auto-fixed (Rule 1 - syntax bug)
**Impact on plan:** Minor syntax correction only. No logic or behavioural change.

## Issues Encountered

- build_runner failed first pass due to unary `+` in switch expression arms (Dart parser limitation). Fixed immediately.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- All 6 providers compile and generate correctly; Wave 2 UI work (02-02) can proceed immediately
- HoleScoreNotifier write-through path verified: Drift row exists within session after any outcome tap
- No new keepAlive providers; provider graph is clean

---
*Phase: 02-shot-capture*
*Completed: 2026-05-17*
