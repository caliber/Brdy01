# Plan 01-03 Summary — API Layer, CourseRepository, Setup Screen UI

**Phase:** 01-foundation-setup  
**Plan:** 01-03  
**Wave:** 3  
**Status:** Complete  
**Completed:** 2026-05-17

## Files Created

### Remote layer

| File | Purpose |
|------|---------|
| `lib/data/remote/dto/course_search_response_dto.dart` | `CourseSearchResponseDto`, `CourseSearchResultDto`, `LocationDto` (Freezed) |
| `lib/data/remote/dto/course_detail_response_dto.dart` | `CourseDetailResponseDto`, `CourseDetailDto`, `HoleDto` (Freezed) |
| `lib/data/remote/api/interceptors/auth_interceptor.dart` | `API_KEY_MISSING` (cancel) + `API_KEY_INVALID` (401) typed DioExceptions |
| `lib/data/remote/api/golf_course_api.dart` | `@RestApi` interface: `/search` + `/courses/{id}` |
| `lib/data/remote/api/dio_provider.dart` | `dioProvider` keepAlive — Dio with AuthInterceptor |
| `lib/data/remote/api/golf_course_api_provider.dart` | `golfCourseApiProvider` keepAlive |

### Infrastructure

| File | Purpose |
|------|---------|
| `lib/infrastructure/repositories/course_repository_impl.dart` | `CourseRepositoryImpl`: searchCourses (no holes), getCourseDetail (D-04 write-through), getCachedCourse, cacheCourse |
| `lib/infrastructure/repositories/course_repository_provider.dart` | `courseRepositoryProvider` keepAlive |

### Providers

| File | Purpose |
|------|---------|
| `lib/features/setup/providers/course_search_query_provider.dart` | Raw query string state (auto-dispose) |
| `lib/features/setup/providers/course_search_results_provider.dart` | 400ms debounce + min 2 chars + `ref.keepAlive()` cancellation |
| `lib/features/setup/providers/selected_course_provider.dart` | `loadCourse`, `loadFromCache`, `overrideRating`, `clear` |

### Setup screen widgets

| File | Purpose |
|------|---------|
| `lib/features/setup/widgets/handicap_input.dart` | ConsumerStateful, Hive write-through on every valid keystroke |
| `lib/features/setup/widgets/course_search_field.dart` | Search icon + clear tooltip + LinearProgressIndicator |
| `lib/features/setup/widgets/course_result_tile.dart` | Surface tile with course name/location/rating, chevron, InkWell |
| `lib/features/setup/widgets/course_card.dart` | Accent border, flutter_animate fade+slideY, change course link |
| `lib/features/setup/widgets/api_key_error_state.dart` | Full-screen Component 7 — missing/invalid modes |

## Files Modified

| File | Change |
|------|--------|
| `lib/features/setup/setup_screen.dart` | Rebuilt as `ConsumerStatefulWidget` — SETUP-04 cache pre-populate, HapticFeedback, assembles all widgets |
| `analysis_options.yaml` | Added `invalid_annotation_target: ignore` for Freezed `@JsonKey` pattern |

## Live API Verification

**Status: Deferred** — no real API key available in this execution context. DTO field names follow RESEARCH.md §7 assumed schema (MEDIUM confidence):
- Search: `club_name`, `course_name`, `course_rating`, `slope_rating`
- Detail: same plus `holes[]` with `hole_number`, `par`, `stroke_index`, `tee_lat`, `tee_lng`, `green_lat`, `green_lng`
- **A3 gate (stroke_index present):** Unverified. First live run must check `/courses/{id}` response and adjust `@JsonKey(name:)` if field names differ.
- If GPS field names differ (e.g., nested `tee_position.latitude`), `HoleDto` must be updated before Phase 2 GPS work.

## Build Results

- `dart run build_runner build --delete-conflicting-outputs` — exit 0
- `flutter analyze --no-fatal-warnings` — No issues found
- `flutter test` — 1 passing (BrdyApp smoke test)

## Key Notes

- Setup screen wired through to `SelectedCourseProvider`; awaiting Plan 04 to wire START ROUND
- `_StartRoundButton.onPressed` is `() {}` placeholder — Plan 04 replaces with `createRound + context.go()`
- SETUP-05 missing-rating banner deferred to Plan 05 per plan scope
- `courseSearchResultsProvider` returns `List<CourseSearchResultDto>` (not `CourseModel`) — SetupScreen maps inline for display
