# Plan 01-02 Summary — Persistence Stack

**Phase:** 01-foundation-setup  
**Plan:** 01-02  
**Wave:** 2  
**Status:** Complete  
**Completed:** 2026-05-17

## Files Created

### Domain layer

| File | Purpose |
|------|---------|
| `lib/domain/enums/hole_outcome.dart` | `HoleOutcome` enum: eagle, birdie, par, bogey, doubleBogey, pickup |
| `lib/domain/models/course_model.dart` | Freezed `CourseModel` with nullable courseRating/slope |
| `lib/domain/models/hole_model.dart` | Freezed `HoleModel` with nullable GPS fields |
| `lib/domain/models/round_model.dart` | Freezed `RoundModel` with nullable completedAt |
| `lib/domain/repositories/course_repository.dart` | Abstract `CourseRepository` interface |
| `lib/domain/repositories/round_repository.dart` | Abstract `RoundRepository` interface |
| Generated: `course_model.freezed.dart`, `course_model.g.dart`, `hole_model.freezed.dart`, `hole_model.g.dart`, `round_model.freezed.dart`, `round_model.g.dart` | Freezed/json_serializable generated code |

### Data layer — Drift

| File | Purpose |
|------|---------|
| `lib/data/local/database/tables/rounds_table.dart` | `Rounds` table — 8 columns, completedAt nullable |
| `lib/data/local/database/tables/holes_table.dart` | `Holes` table — 10 columns, FK → rounds |
| `lib/data/local/database/tables/shots_table.dart` | `Shots` table — 6 columns, FK → holes |
| `lib/data/local/database/app_database.dart` | `@DriftDatabase` schemaVersion 1 with PRAGMA FK |
| `lib/data/local/database/daos/round_dao.dart` | `RoundDao`: insert, findIncompleteRoundId, getRoundById, completeRound |
| `lib/data/local/database/daos/hole_dao.dart` | `HoleDao`: empty stub for Phase 2 |
| Generated: `app_database.g.dart`, `round_dao.g.dart`, `hole_dao.g.dart` | Drift generated code |

### Data layer — Hive

| File | Purpose |
|------|---------|
| `lib/data/local/preferences/hive_player_prefs.dart` | Typed handicapIndex + lastUsedCourseId wrappers |
| `lib/data/local/preferences/hive_course_box.dart` | JSON-string course cache (D-05) |

### Providers

| File | Purpose |
|------|---------|
| `lib/data/local/database/app_database_provider.dart` | `appDatabaseProvider` keepAlive + onDispose(db.close) |
| `lib/data/local/preferences/hive_player_prefs_provider.dart` | `hivePlayerPrefsProvider` keepAlive |
| `lib/data/local/preferences/hive_course_box_provider.dart` | `hiveCourseBoxProvider` keepAlive |

### Schema snapshot

| File | Purpose |
|------|---------|
| `drift_schemas/drift_schema_v1.json` | v1 schema snapshot for migration tooling |
| `build.yaml` | Scopes drift_dev to database directory only |

## Files Modified

| File | Change |
|------|--------|
| `lib/app/constants.dart` | Added `tileCacheStoreName = 'brdy_tiles'` |
| `lib/main.dart` | Added FMTC init with try/catch before runApp (D-07, P-03) |
| `lib/features/setup/providers/app_startup_provider.dart` | Real body: queries `roundDao.findIncompleteRoundId()` |

## Build Results

- `dart run build_runner build --delete-conflicting-outputs` — exit 0, 846 outputs
- `drift_dev schema dump` — wrote `drift_schemas/drift_schema_v1.json`
- `flutter analyze --no-fatal-warnings` — No issues found
- `flutter test` — 1 passing (BrdyApp smoke test)

## Key Notes

- `appStartupProvider` now wired to `RoundDao.findIncompleteRoundId()`; ready for Plan 04 createRound flow
- `build.yaml` added to prevent drift_dev from erroring on non-Drift files (known drift_dev 2.18 issue)
- FMTC uses `const FMTCStore(...)` for idiomatic const construction
