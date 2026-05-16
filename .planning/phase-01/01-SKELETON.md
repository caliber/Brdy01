# Walking Skeleton — BRDY.01

**Phase:** 1
**Generated:** 2026-05-16

## Capability Proven End-to-End

A golfer launches BRDY.01, sees the splash, lands on Setup, types a handicap index (stored in Hive), searches for a course by name (live call to golfcourseapi.com), selects a result, sees the loaded Course Card (name + CR + Slope + par), taps START ROUND — the app inserts a row into the Drift `rounds` table and `context.go()`s to `/shot-capture/$roundId`. If the OS kills the app mid-round, the next launch redirects automatically back to `/shot-capture/$roundId` from the splash without flashing the Setup screen. If the API key is absent at build time, the user sees a full-screen `API KEY NOT CONFIGURED` error state instead of a broken search field. OSM tiles for the loaded course bounding box are pre-cached in the background (best-effort, non-blocking).

## Architectural Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Framework | Flutter 3.22+ / Dart >=3.3 | Cross-platform single codebase; phone + Wear OS in later phases |
| State | Riverpod 2.x with `@riverpod` code-gen | Project convention (CLAUDE.md); never hand-write Provider boilerplate |
| Local relational DB | Drift (SQLite) at `schemaVersion: 1` with `rounds` + `holes` + `shots` tables | Transactional; survives OS kill; full schema defined now (D-01..D-03) so Phase 2/5 add no tables |
| Local key-value store | Hive — `player_prefs` box (handicap, last course id) and `course_cache` box (JSON-string of `CourseModel.toJson()`) | Hive is NOT used for round data (write-through to Drift only) per CLAUDE.md |
| Course cache shape | JSON string via `jsonEncode(course.toJson())` — no TypeAdapter | D-05: avoids Hive runtime errors flagged in CONCERNS.md (P-06) |
| HTTP client | Dio 5.x + Retrofit 4.x + Freezed DTOs | Codegen for type-safe API contract; `AuthInterceptor` validates `--dart-define=GOLF_API_KEY` per FOUND-04 |
| Navigation | go_router 14.x with `routerProvider` (keepAlive), `_RouterListenable` ChangeNotifier bridge, redirect-based crash recovery | D-11/D-12/D-13: never `context.push()` for main screens; hole navigation is internal state (no 18-deep back-stack) |
| Initial route | `/splash` — `appStartupProvider` resolves, then redirect picks `/setup` or `/shot-capture/$roundId` | D-13: user never sees Setup flash on crash recovery |
| Map tile cache | flutter_map_tile_caching v9 with single store `brdy_tiles` initialised in `main()` before `runApp` | D-07: resolves "dead dependency" in STATE.md; precaches Z14–17 over course bounding box; non-blocking per D-10 |
| API key transport | `String.fromEnvironment('GOLF_API_KEY')` injected via `--dart-define=GOLF_API_KEY=<value>` at build | CLAUDE.md: never hardcode; validated at first API call, surfaced as full-screen error state |
| Theme | Brutalist locked tokens in `lib/theme/` (BrdyColors, BrdySpacing, BrdyTextTheme, BrdyTheme) | UI-SPEC + CLAUDE.md design system; `abstract final class` with `static const` only |
| Directory layout | Clean Architecture under `lib/`: `features/<screen>/`, `domain/{models,enums,repositories}/`, `data/{local,remote}/`, `infrastructure/repositories/`, `app/`, `theme/` | Established scaffold; respected in CONVENTIONS.md |

## Stack Touched in Phase 1

- [x] Project scaffold — `pubspec.yaml` deps already present (Riverpod, Drift, Hive, Dio, Retrofit, FMTC, go_router); build_runner ready
- [x] Routing — `/splash`, `/setup`, `/shot-capture/:roundId`, `/round-review/:roundId` all wired through `MaterialApp.router(routerConfig: ref.watch(routerProvider))`
- [x] Database — Drift `RoundDao.insertRound()` (write) AND `RoundDao.findIncompleteRoundId()` (read) both exercised end-to-end via START ROUND tap and `appStartupProvider`
- [x] UI — Setup screen with HandicapInput → CourseSearchField → CourseResultTile list → CourseCard → START ROUND button, wired to providers
- [x] External integration — Retrofit `GolfCourseApi.searchCourses()` and `getCourseDetail()` hitting golfcourseapi.com; cached to Hive `course_cache`
- [x] Local full-stack run command: `flutter run --dart-define=GOLF_API_KEY=<value>`

## Out of Scope (Deferred to Later Slices)

- Hole scoring UI (outcome buttons, putts, fairway, GIR) — Phase 2
- Running score vs par, undo toast, hole navigation — Phase 2
- Scorecard grid, stat cards, WHS differential calculation — Phase 3
- Wear OS companion app and Data Layer sync — Phase 4
- GPS shot pins on the map and voice scoring — Phase 5
- Round history / past-round list — v2 (out of scope entirely)
- The `Holes` table is created but NO hole rows are inserted in Phase 1 (D-02 — first hole row written when user scores in Phase 2)
- The `Shots` table is created but NO shot rows are inserted in Phase 1 (D-03 — Phase 5 only)
- Tile pre-caching is best-effort: START ROUND is never blocked on download completion (D-10)

## Subsequent Slice Plan

Each later phase adds one vertical slice on top of this skeleton without altering its architectural decisions:

- Phase 2 — Shot Capture: insert `holes` rows on first score per hole; outcome buttons (EAGLE / BIRDIE / PAR / BOGEY / DOUBLE / PICKUP) write through to Drift; running score; undo; hole navigation via `activeHoleIndexProvider` (internal state, never `context.push()`).
- Phase 3 — Round Review: read complete `holes` rows; scorecard grid with colour coding; stat cards; WHS differential using stored Course Rating / Slope / Stroke Index from the Phase 1 `rounds.courseJson` snapshot.
- Phase 4 — Wear OS: phone-side service consumes phone's active round (already keyed by `activeRoundIdProvider`); watch app added under `android/wear/`.
- Phase 5 — Polish: insert `shots` rows on map tap (table already exists from Phase 1); voice STT integration; final error-state hardening.
