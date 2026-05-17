# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-05-16)

**Core value:** A golfer finishes a hole, taps one button, and the round stays accurate — frictionless hole-by-hole scoring on the course.
**Current focus:** Phase 1 — Foundation + Setup

## Current Position

Phase: 1 of 5 (Foundation + Setup)
Plan: 3 of 5 in current phase
Status: In progress — Plan 01-03 complete; Plan 01-04 next
Last activity: 2026-05-17 — Plan 01-03 complete (API layer, CourseRepositoryImpl, search providers, Setup screen UI with all 5 widgets)

Progress: [██████░░░░] 60%

## Performance Metrics

**Velocity:**
- Total plans completed: 1
- Average duration: —
- Total execution time: —

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| Phase 1 | 1/5 | — | — |

**Recent Trend:**
- Last 5 plans: Plan 01-01 ✓
- Trend: —

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

### Pending Todos

None yet.

### Blockers/Concerns

- [Research] Verify Golf Course API returns Stroke Index per hole before implementing pickup scoring (Phase 1 gate)
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
Stopped at: Plan 01-03 complete — Retrofit GolfCourseApi + DTOs + AuthInterceptor, CourseRepositoryImpl (D-04 write-through), debounced search results provider (400ms + min 2 chars), SelectedCourseProvider (loadCourse, loadFromCache, overrideRating), all 5 Setup widgets + SetupScreen rebuilt as ConsumerStatefulWidget (SETUP-01/02/03/04, FOUND-04). Live API verification deferred (no API key in CI) — A3 gate (stroke_index) unverified. START ROUND button rendered with placeholder onPressed.
Resume file: .planning/phase-01/01-04-PLAN.md
