---
phase: 05-gps-voice-polish
plan: 01
subsystem: database
tags: [drift, gps, android, geolocator, permissions, sqlite]

# Dependency graph
requires:
  - phase: 02-shot-capture
    provides: Shots table definition (shots_table.dart), HoleDao, AppDatabase

provides:
  - Android ACCESS_FINE_LOCATION and ACCESS_COARSE_LOCATION permissions in AndroidManifest.xml
  - ShotDao with insertShot, watchShotsForHole, deleteShotsForHole, getShotCountForHole
  - HoleDao.getHoleByRoundAndNumber for FK resolution without schema bump
  - AppDatabase with ShotDao registered; schemaVersion stays 1

affects: [05-02-gps-map-overlay, 05-03-voice-polish, any plan reading shot pins from Drift]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "DriftAccessor DAO pattern: @DriftAccessor(tables:[X]) + DatabaseAccessor<AppDatabase> with _$XMixin"
    - "Android permissions added before <application> element in uses-permission block"

key-files:
  created:
    - lib/data/local/database/daos/shot_dao.dart
    - lib/data/local/database/daos/shot_dao.g.dart
  modified:
    - android/app/src/main/AndroidManifest.xml
    - lib/data/local/database/daos/hole_dao.dart
    - lib/data/local/database/app_database.dart
    - lib/data/local/database/app_database.g.dart

key-decisions:
  - "schemaVersion stays 1 — Shots table already defined at v1, adding a DAO is not a schema change"
  - "ACCESS_BACKGROUND_LOCATION intentionally excluded — geolocator on-demand only needs foreground permissions"
  - "getShotCountForHole uses in-memory .length rather than SQL COUNT — consistent with Drift stream pattern"

patterns-established:
  - "ShotDao pattern: insertShot uses ShotsCompanion.insert with recordedAt: DateTime.now() server-side"
  - "HoleDao FK resolution: getHoleByRoundAndNumber (roundId + holeNumber) avoids raw ID coupling in overlay code"

requirements-completed: [SHOT-08]

# Metrics
duration: 10min
completed: 2026-05-19
---

# Phase 05 Plan 01: Android GPS Permissions + ShotDao Persistence Layer Summary

**Android ACCESS_FINE_LOCATION/ACCESS_COARSE_LOCATION permissions added; ShotDao providing insertShot, watchShotsForHole, deleteShotsForHole, getShotCountForHole wired into AppDatabase via Drift @DriftAccessor pattern**

## Performance

- **Duration:** ~10 min
- **Started:** 2026-05-19T00:00:00Z
- **Completed:** 2026-05-19T00:10:00Z
- **Tasks:** 2 of 2
- **Files modified:** 6

## Accomplishments

- Added foreground location permissions to AndroidManifest.xml, unblocking geolocator GPS on Android
- Created ShotDao with all four required data-layer methods for pin persistence
- Extended HoleDao with getHoleByRoundAndNumber for FK resolution in map overlay
- Registered ShotDao in AppDatabase without bumping schemaVersion (Shots table already at v1)
- build_runner regenerated shot_dao.g.dart and app_database.g.dart; flutter analyze clean

## Task Commits

Each task was committed atomically:

1. **Task 1: Add Android location permissions** - `4432037` (feat)
2. **Task 2: Create ShotDao and register in AppDatabase; extend HoleDao** - `230d996` (feat)

**Plan metadata:** (docs commit follows)

## Files Created/Modified

- `android/app/src/main/AndroidManifest.xml` - Added ACCESS_FINE_LOCATION and ACCESS_COARSE_LOCATION uses-permission entries
- `lib/data/local/database/daos/shot_dao.dart` - New ShotDao with insertShot, watchShotsForHole, deleteShotsForHole, getShotCountForHole
- `lib/data/local/database/daos/shot_dao.g.dart` - Generated Drift mixin for ShotDao
- `lib/data/local/database/daos/hole_dao.dart` - Added getHoleByRoundAndNumber for FK resolution
- `lib/data/local/database/app_database.dart` - Registered ShotDao in @DriftDatabase daos list
- `lib/data/local/database/app_database.g.dart` - Regenerated with ShotDao wired

## Decisions Made

- schemaVersion stays 1 — the Shots table was already defined at v1 in Phase 2. Adding a DAO is not a schema change; bumping without a table/column change causes migration exceptions.
- ACCESS_BACKGROUND_LOCATION intentionally excluded — geolocator on-demand only needs foreground permissions (as specified in plan).
- getShotCountForHole fetches rows then uses .length (in-memory count) — appropriate for the use case (sequential shotNumber assignment per hole, typically 1-6 shots).

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- GPS is now unblocked on Android — geolocator.checkPermission() will return the correct status
- ShotDao is ready for 05-02 (GPS map overlay) to call insertShot and watchShotsForHole
- HoleDao.getHoleByRoundAndNumber resolves Drift row IDs for the overlay FK without schema changes
- schemaVersion remains 1 — no migration risk for existing installed instances

## Self-Check

- [x] `4432037` commit exists: `git log --oneline | grep 4432037` — confirmed
- [x] `230d996` commit exists: `git log --oneline | grep 230d996` — confirmed
- [x] `shot_dao.g.dart` exists at `lib/data/local/database/daos/shot_dao.g.dart` — confirmed
- [x] ACCESS_FINE_LOCATION in AndroidManifest.xml — grep count: 1
- [x] ACCESS_COARSE_LOCATION in AndroidManifest.xml — grep count: 1
- [x] schemaVersion => 1 — confirmed

## Self-Check: PASSED

---
*Phase: 05-gps-voice-polish*
*Completed: 2026-05-19*
