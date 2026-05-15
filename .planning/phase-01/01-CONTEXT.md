# Phase 1: Foundation + Setup - Context

**Gathered:** 2026-05-16
**Status:** Ready for planning

<domain>
## Phase Boundary

Wire up the full persistence and infrastructure stack — Drift DB, Hive prefs, Retrofit API client, go_router with crash-recovery redirect — and implement the Setup screen so a golfer can search for a course, load it, and start a round with crash-safe persistence backing every subsequent feature.

</domain>

<decisions>
## Implementation Decisions

### Drift Schema

- **D-01:** Define the full Drift schema (rounds + holes + shots tables) in Phase 1 at `schemaVersion: 1`. All three tables land together so no table-creation migrations are needed in later phases.
- **D-02:** Phase 1 `createRound()` creates the `rounds` row only. Hole rows are created on first score in Phase 2 (`INSERT` when the user first scores a hole, not upfront).
- **D-03:** The `shots` table is defined in Phase 1 as part of the complete schema, even though shot data is not written until Phase 5.

### Course Hive Cache

- **D-04:** Cache the full SETUP-03 dataset in Hive when a course is loaded: name, par, Course Rating, Slope, hole-by-hole par, Stroke Index per hole, and GPS hole coordinates. The full dataset is cached in one API call — no re-fetch needed in Phases 2, 3, or 5.
- **D-05:** Serialize the course object to a JSON string via Freezed `toJson()` and store it as a `String` value in the `course_cache` Hive box. No TypeAdapter needed — `json_annotation` is already in pubspec.
- **D-06:** GPS hole layout fields (tee/green lat-lng per hole) are nullable in the domain model. Cache them if the API returns them; skip gracefully if not. No special Phase 5 re-fetch needed.

### FMTC Tile Pre-Caching

- **D-07:** Initialize `flutter_map_tile_caching` in `main()` (before `runApp`) with a single named store, e.g. `'brdy_tiles'`. This resolves the dead-dependency noted in STATE.md.
- **D-08:** When a course is loaded, derive the tile bounding box from the hole GPS coordinates stored in Hive (min/max lat-lng across all holes, plus a buffer). If no GPS data is available for the course, skip pre-caching silently.
- **D-09:** Pre-cache zoom levels Z14–17 for the course bounding box. Covers full-course overview through green-level detail at a reasonable tile count.
- **D-10:** Tile pre-caching is best-effort and non-blocking. Show the progress bar (UI-SPEC Component 8) while downloading, but do not disable the START ROUND button. Players can start immediately; any un-cached tiles load on-demand if the device is online.

### go_router + Crash Recovery

- **D-11:** GoRouter is held in a `@Riverpod(keepAlive: true)` provider (`routerProvider`). This keeps routing consistent with the CLAUDE.md `keepAlive` rules and lets the router watch `appStartupProvider` so redirect re-evaluates when the startup check resolves.
- **D-12:** Crash-recovery redirect is implemented as a GoRouter `redirect:` callback, not an `initialLocation` override. The callback reads `appStartupProvider` (AsyncValue): loading → return `/splash`; incomplete round found → return `/shot-capture/$roundId`; no incomplete round → return `/setup`.
- **D-13:** A dedicated `/splash` route is the `initialLocation`. While `appStartupProvider` is loading, the redirect keeps the user on `/splash`. The splash widget matches the UI-SPEC: `background` color (#0A0A0A), centered `BRDY.01` wordmark in `labelLarge` style, no spinner. User never sees a Setup screen flash.

### Claude's Discretion

- **Shots table in Phase 1:** User deferred this to Claude. Decision: include shots table at `schemaVersion: 1` for schema completeness — Phase 5 just inserts rows, no migration needed.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase Requirements and Roadmap
- `.planning/REQUIREMENTS.md` — FOUND-01..05, SETUP-01..05 define what Phase 1 must deliver
- `.planning/ROADMAP.md` — Phase 1 goal, success criteria, and phase dependencies

### UI Design Contract (locked)
- `.planning/phase-01/01-UI-SPEC.md` — MUST read. Full visual and interaction contract: color tokens, typography, spacing, all 8 component contracts, copywriting, animations, accessibility, interaction contracts (crash recovery, debounce, haptic). All visual decisions are locked here. Do NOT override any value without a CLAUDE.md update.

### Project Architecture and Constraints
- `CLAUDE.md` — Design system (locked), architecture rules, provider keepAlive rules, navigation model, Drift schema rules, Critical Don'ts

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `lib/main.dart` — Already initializes Hive (two boxes: `player_prefs`, `course_cache`) and wraps `BrdyApp` in `ProviderScope`. Phase 1 adds FMTC initialization here before `runApp`.
- `lib/app/constants.dart` — `AppConstants` already provides box names and `golfApiKey` constant (`String.fromEnvironment`). Extend with any new constants needed.
- `lib/app/app.dart` — `BrdyApp extends ConsumerWidget` establishes the Riverpod consumption pattern. Phase 1 replaces `MaterialApp(home:)` with `MaterialApp.router(routerConfig:)`.

### Established Patterns
- **Riverpod code-gen:** All providers use `@riverpod` / `@Riverpod(keepAlive: true)` annotations — never hand-write Provider boilerplate. Run `build_runner` after every provider change.
- **Drift schema rules:** Every `Table` class change bumps `schemaVersion` and adds an `onUpgrade` migration case. Commit `drift_schemas/` JSON for every version.
- **Navigation:** `context.go()` not `context.push()` for main screen transitions. Hole navigation uses internal `StateProvider`, not route pushes.

### Integration Points
- `lib/main.dart` → add `await FlutterMapTileCaching.initialise()` (FMTC) before `runApp`
- `lib/app/app.dart` → replace `MaterialApp(home:)` with `MaterialApp.router(routerConfig: ref.watch(routerProvider))`
- `lib/data/local/database/` → write Drift `AppDatabase`, tables (`rounds`, `holes`, `shots`), DAOs
- `lib/data/local/preferences/` → write Hive wrappers (`HivePlayerPrefs`, `HiveCourseBox`)
- `lib/data/remote/api/` → write Retrofit client for `golfcourseapi.com`
- `lib/features/setup/` → implement `SetupScreen` and `widgets/` subfolder per UI-SPEC file list

</code_context>

<specifics>
## Specific Ideas

- **UI-SPEC file list** (from `01-UI-SPEC.md §Files to Create`): `lib/theme/brdy_colors.dart`, `lib/theme/brdy_spacing.dart`, `lib/theme/brdy_text_theme.dart`, `lib/theme/brdy_theme.dart`, `lib/app/app.dart` (update), `lib/features/setup/setup_screen.dart`, `lib/features/setup/widgets/handicap_input.dart`, `course_search_field.dart`, `course_result_tile.dart`, `course_card.dart`, `missing_rating_banner.dart`.
- **Provider names prescribed in UI-SPEC:** `appStartupProvider`, `roundSetupNotifierProvider`, `courseSearchQueryProvider`, `courseSearchResultsProvider`, `courseRepositoryProvider`, `hivePlayerPrefsProvider`, `selectedCourseProvider`.
- **FMTC store name:** `'brdy_tiles'` (single store for the whole app).
- **Tile zoom range:** Z14–17.
- **Widget test:** Update `test/widget_test.dart` to import `BrdyApp` (wrapped in `ProviderScope`) — it currently imports non-existent `MyApp` and will fail to compile.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 1-Foundation + Setup*
*Context gathered: 2026-05-16*
