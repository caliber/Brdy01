# Plan 01-05 Summary — FMTC Tile Pre-Cache + SETUP-05 Missing Rating

**Phase:** 01-foundation-setup  
**Plan:** 01-05  
**Wave:** 5  
**Status:** Complete  
**Completed:** 2026-05-17

## Files Created

| File | Purpose |
|------|---------|
| `lib/infrastructure/repositories/tile_cache_repository.dart` | `TileCacheRepository.preCacheCourse`: RectangleRegion + Z14–17 download, null on no GPS (D-08) |
| `lib/infrastructure/repositories/tile_cache_provider.dart` | `tileCacheProvider` keepAlive |
| `lib/features/setup/providers/tile_cache_progress_provider.dart` | `TileCacheProgressProvider`: Notifier<DownloadProgress?>, start(holes), StreamSubscription with onDispose cancel |
| `lib/features/setup/widgets/tile_cache_progress.dart` | `TileCacheProgress` widget: 2dp accent LinearProgressIndicator + `'DOWNLOADING MAP TILES… N%'` |
| `lib/features/setup/widgets/missing_rating_banner.dart` | `MissingRatingBanner`: 0x26CC2200 bg, 3dp destructive left border, locked copy, slideY animate |
| `lib/features/setup/widgets/manual_rating_form.dart` | `ManualRatingForm`: CR (55.0–80.0) + SLOPE (55–155), SAVE RATING → `overrideRating`, AnimatedSize |

## Files Modified

| File | Change |
|------|--------|
| `lib/features/setup/widgets/course_card.dart` | Converted to `ConsumerStatefulWidget`; added `_manualFormOpen` state; conditional `MissingRatingBanner` / `ManualRatingForm` |
| `lib/features/setup/setup_screen.dart` | Added `ref.listen` for tile pre-cache trigger + haptic; inserted `TileCacheProgress` widget between CourseCard area and START ROUND |

## Build Results

- `dart run build_runner build --delete-conflicting-outputs` — exit 0
- `flutter analyze --no-fatal-warnings` — No issues found
- `flutter test` — 1 passing (BrdyApp smoke test)

**Note:** Name collision between provider class `TileCacheProgress` and widget class `TileCacheProgress` resolved by `hide TileCacheProgress` on provider import in `setup_screen.dart`.

**FMTC API correction:** RESEARCH.md described `seaTileRemoval: false` and a record return type — actual FMTC v9.1.4 API uses `skipSeaTiles: false` and returns `Stream<DownloadProgress>` directly (not a record). Implemented with the correct API.

## Human-Verify Checkpoint (Task 3) — APPROVED

**Outcome:** Approved 2026-05-17. Architecture and code review complete.

**Verification notes:**
- Steps 1–5 approved via architecture and code review
- End-to-end device test (tile download, banner, manual form) deferred until Android Studio installed
- D-10 (non-blocking START ROUND) confirmed by code review — `TileCacheProgress` widget is rendered independently of `_StartRoundButton`; no `await` on download stream in button path

## Phase 1 Status: COMPLETE

All 10 requirements satisfied:

| Req | Description | Status |
|-----|-------------|--------|
| FOUND-01 | Write-through Drift on round creation | ✅ Plan 04 |
| FOUND-02 | Crash recovery — incomplete round detected on restart | ✅ Plan 02 + 04 |
| FOUND-03 | Redirect to Shot Capture at correct hole on recovery | ✅ Plan 01 + 04 |
| FOUND-04 | API key error state (missing / invalid) | ✅ Plan 03 |
| FOUND-05 | OSM tiles pre-cached for course bounding box | ✅ Plan 05 |
| SETUP-01 | Handicap index input persists to Hive | ✅ Plan 03 |
| SETUP-02 | Course search with 400ms debounce + min 2 chars | ✅ Plan 03 |
| SETUP-03 | Load full course detail (name, CR, slope, par/SI/GPS per hole) | ✅ Plan 03 |
| SETUP-04 | Last-used course pre-selected from Hive cache on reopen | ✅ Plan 03 |
| SETUP-05 | Missing-rating warning + manual entry | ✅ Plan 05 |

**Final note:** Phase 1 complete — all 10 requirements satisfied; ready for `/gsd:verify-work` and `/gsd:plan-phase 2`
