# Phase 05 Plan 02 — Summary

**Plan:** GPS Map Overlay + Tap-to-Drop Shot Pins
**Status:** Complete
**Completed:** 2026-05-20

## What was built

- `lib/features/shot_capture/widgets/map_overlay_widget.dart` — FlutterMap with FMTC tile caching and shot pin markers from shotsForHoleProvider. Null guard on course prevents crash while courseForRoundProvider loads.
- `lib/features/shot_capture/providers/shots_for_hole_provider.dart` — Stream provider combining roundId + holeIndex, queries ShotDao.watchShotsForHole after resolving holeId via HoleDao.getHoleByRoundAndNumber.
- `lib/features/shot_capture/shot_capture_screen.dart` — `_dropPinAtCurrentPosition()` added: permission check → GPS fetch (15s timeout) → FK-safe Drift insert → sequential shot numbering. `_TopZone` now embeds MapOverlayWidget in top 36% zone.

## Decisions made

- GPS fetch is on-demand (getCurrentPosition) not streaming — matches CLAUDE.md directive
- Permission denied forever opens app settings automatically
- Snackbar error states for both permission denied and GPS timeout
- Shot number derived from getShotCountForHole (existing row count + 1)

## Verification

- `flutter analyze` clean on all modified files
- MapOverlayWidget renders black placeholder when course is null
