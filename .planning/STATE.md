# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-05-16)

**Core value:** A golfer finishes a hole, taps one button, and the round stays accurate — frictionless hole-by-hole scoring on the course.
**Current focus:** Phase 3 — Round Review (SHOT-13, REV-01..07)

## Current Position

Phase: 2 of 5 (Shot Capture) — **COMPLETE** ✅
Plan: 3 of 3 complete
Status: Phase 2 complete — all 10 requirements satisfied (SHOT-01..07, SHOT-10..12). Human-verify approved. Ready for `/gsd:verify-work` then `/gsd:plan-phase 3`
Last activity: 2026-05-17 — Phase 2 complete. Human-verify approved. FairwayGirToggles (par3 gate), HoleNavDrawer (18 chips + NOW chip), P2-08 reset fix, full ShotCaptureScreen assembly. All 13 device checks passed.

Progress: [██████████] 100% (Phase 1) | [██████████] 100% (Phase 2)

## Performance Metrics

**Velocity:**
- Total plans completed: 8 (Phase 1 + Phase 2 complete)
- Average duration: —
- Total execution time: 2026-05-17 (single session)

**By Phase:**

| Phase | Plans | Status |
|-------|-------|--------|
| Phase 1 | 5/5 | ✅ Complete |
| Phase 2 | 3/3 | ✅ Complete |
| Phase 3 | TBD | Not started |

**Recent Trend:**
- Last 8 plans: 01-01 ✓ 01-02 ✓ 01-03 ✓ 01-04 ✓ 01-05 ✓ 02-01 ✓ 02-02 ✓ 02-03 ✓
- Trend: All on track

*Updated after each plan completion*

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

- [Pre-Phase 1]: Use `@riverpod` code-gen throughout — never hand-write Provider boilerplate
- [Pre-Phase 1]: EAGLE is a 6th outcome button (double-tap BIRDIE); schema already supports ordinal 0
- [Pre-Phase 1]: `flutter_map_tile_caching` is a dead dependency — must be initialised in `main()` before Phase 2 map work
- [Pre-Phase 1]: Write-through to Drift on every score entry; never accumulate state in Riverpod alone
- [Pre-Phase 1]: Hole navigation is internal `StateProvider` change, not a go_router push; back-stack must not reach 18 levels
- [02-01]: HoleDao upsert uses SELECT-then-branch (Option A) — no schema version bump, no DoUpdate
- [02-01]: courseForRoundProvider reads from Drift rounds.courseJson (not Hive) — survives crash recovery
- [02-01]: HoleScoreNotifier does NOT advance activeHoleIndexProvider — screen widget's responsibility
- [02-02]: ShotCaptureScreen is ConsumerStatefulWidget for _lastScoredHoleIndex undo tracking
- [02-02]: completeRound(roundId, DateTime.now()) called at holeIndex==17 BEFORE roundCompleteProvider fires — ensures completedAt set for crash recovery
- [02-02]: BIRDIE uses GestureDetector with onDoubleTap; all others use InkWell — prevents 300ms tap delay on entire grid
- [02-02]: persist: false omitted (not in Flutter 3.24.5); add when upgrading to Flutter 3.38+
- [02-03]: FairwayGirToggles extracted as separate ConsumerWidget; _navStripOpen lives in screen state (not a provider)
- [02-03]: P2-08 fix: activeHoleIndexProvider.set(0) synchronous inside createRound() before return — ordering guaranteed

### Pending Todos

None yet.

### Blockers/Concerns

- [Research] Verify Golf Course API returns Stroke Index per hole before implementing pickup scoring (Phase 1 gate) — A3 unverified, needs real API key + device
- [Decision] Web target excluded from project: Drift FFI + sqlite3_flutter_libs incompatible with dart2js
- [Research] Release keystore must be generated before Wear OS Data Layer work begins (Phase 4 gate)
- [Research] `wear_plus` version compatibility with current Flutter must be verified before Phase 4
- [Research] Test voice recognition with airplane mode on non-Pixel Android before shipping Phase 5

## Deferred Items

| Category | Item | Status | Deferred At |
|----------|------|--------|-------------|
| v2 | Round history (HIST-01..03) | Deferred | Init |
| v2 | 9-hole rounds (NINE-01..02) | Deferred | Init |
| v2 | Enhanced voice stats (VOIC-01..02) | Deferred | Init |
| v2 | Course management (COUR-01..02) | Deferred | Init |

## Session Continuity

Last session: 2026-05-17
Stopped at: Phase 2 complete. Human-verify approved (all 13 device checks passed). FairwayGirToggles (par3 gate), HoleNavDrawer (18 chips + NOW chip), P2-08 reset fix, full ShotCaptureScreen assembly. All 10 Phase 2 requirements satisfied (SHOT-01..07, SHOT-10..12).
Next: `/gsd:verify-work` to confirm Phase 2 goal delivery, then `/gsd:plan-phase 3` for Round Review.
